#!/usr/bin/env python3
"""Repository-local SQLite memory helper for the agent-memory skill."""

from __future__ import annotations

import argparse
import hashlib
import json
import mimetypes
import os
from pathlib import Path
import sqlite3
import subprocess
import sys
from typing import Any


SKILL_ROOT = Path(__file__).resolve().parents[1]
SCHEMA_PATH = SKILL_ROOT / "references" / "schema.sql"
TEMPLATE_PATH = SKILL_ROOT / "assets" / "memory.yml"
EXTRACTOR_ID = "agent-memory.git-tracked-text"
EXTRACTOR_VERSION = "1"


def run_git(repo: Path, args: list[str]) -> str | None:
    result = subprocess.run(
        ["git", "-C", str(repo), *args],
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        text=True,
        check=False,
    )
    if result.returncode != 0:
        return None
    return result.stdout.strip()


def find_repo_root(start: Path) -> Path:
    resolved = start.resolve()
    root = run_git(resolved, ["rev-parse", "--show-toplevel"])
    if root:
        return Path(root).resolve()
    return resolved


def memory_paths(repo: Path) -> tuple[Path, Path]:
    agents_dir = repo / ".agents"
    return agents_dir / "memory.db", agents_dir / "memory.yml"


def ensure_inside(base: Path, target: Path) -> Path:
    base_resolved = base.resolve()
    target_resolved = target.resolve()
    try:
        target_resolved.relative_to(base_resolved)
    except ValueError as exc:
        raise SystemExit(f"path escapes repository: {target}") from exc
    return target_resolved


def connect(db_path: Path) -> sqlite3.Connection:
    conn = sqlite3.connect(db_path)
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA foreign_keys = ON")
    conn.execute("PRAGMA busy_timeout = 5000")
    conn.execute("PRAGMA journal_mode = WAL")
    conn.execute("PRAGMA synchronous = FULL")
    return conn


def init_repo(repo: Path) -> dict[str, str]:
    db_path, config_path = memory_paths(repo)
    db_path.parent.mkdir(parents=True, exist_ok=True)
    created_config = "false"
    if not config_path.exists():
        config_path.write_text(TEMPLATE_PATH.read_text(encoding="utf-8"), encoding="utf-8")
        created_config = "true"

    conn = connect(db_path)
    try:
        conn.executescript(SCHEMA_PATH.read_text(encoding="utf-8"))
        conn.commit()
    finally:
        conn.close()

    return {
        "repo_root": str(repo),
        "database": str(db_path),
        "config": str(config_path),
        "created_config": created_config,
    }


def json_arg(value: str) -> str:
    try:
        parsed = json.loads(value)
    except json.JSONDecodeError as exc:
        raise argparse.ArgumentTypeError(f"invalid JSON: {exc}") from exc
    if not isinstance(parsed, dict):
        raise argparse.ArgumentTypeError("JSON value must be an object")
    return json.dumps(parsed, sort_keys=True, separators=(",", ":"))


def current_branch(repo: Path) -> str | None:
    return run_git(repo, ["branch", "--show-current"]) or None


def current_head(repo: Path) -> str | None:
    return run_git(repo, ["rev-parse", "HEAD"]) or None


def worktree_key(repo: Path) -> str:
    git_dir = run_git(repo, ["rev-parse", "--git-dir"])
    common_dir = run_git(repo, ["rev-parse", "--git-common-dir"])
    raw = json.dumps(
        {
            "repo": str(repo),
            "git_dir": git_dir,
            "git_common_dir": common_dir,
        },
        sort_keys=True,
    )
    return hashlib.sha256(raw.encode("utf-8")).hexdigest()


def ensure_session(conn: sqlite3.Connection, repo: Path, session_id: str) -> None:
    conn.execute(
        """
        INSERT INTO sessions(id, worktree_key, branch, head_oid_at_start, status)
        VALUES (?, ?, ?, ?, 'active')
        ON CONFLICT(id) DO UPDATE SET
          worktree_key = excluded.worktree_key
        """,
        (session_id, worktree_key(repo), current_branch(repo), current_head(repo)),
    )


def derived_idempotency_key(payload: dict[str, Any]) -> str:
    stable = json.dumps(payload, sort_keys=True, separators=(",", ":"))
    return hashlib.sha256(stable.encode("utf-8")).hexdigest()


def cmd_init(args: argparse.Namespace) -> None:
    repo = find_repo_root(Path(args.repo))
    print(json.dumps(init_repo(repo), indent=2, sort_keys=True))


def cmd_status(args: argparse.Namespace) -> None:
    repo = find_repo_root(Path(args.repo))
    db_path, config_path = memory_paths(repo)
    result: dict[str, Any] = {
        "repo_root": str(repo),
        "database": str(db_path),
        "database_exists": db_path.exists(),
        "config": str(config_path),
        "config_exists": config_path.exists(),
    }
    if db_path.exists():
        conn = connect(db_path)
        try:
            result["events"] = conn.execute("SELECT COUNT(*) FROM memory_events").fetchone()[0]
            result["sessions"] = conn.execute("SELECT COUNT(*) FROM sessions").fetchone()[0]
            result["artifacts"] = conn.execute("SELECT COUNT(*) FROM artifacts").fetchone()[0]
        finally:
            conn.close()
    print(json.dumps(result, indent=2, sort_keys=True))


def cmd_record(args: argparse.Namespace) -> None:
    repo = find_repo_root(Path(args.repo))
    init_repo(repo)
    db_path, _ = memory_paths(repo)
    session_id = args.session_id or os.environ.get("AGENT_MEMORY_SESSION_ID") or "default"
    meta_json = args.meta or "{}"
    payload = {
        "session_id": session_id,
        "kind": args.kind,
        "topic_key": args.topic_key,
        "scope_uri": args.scope_uri,
        "body": args.body,
        "importance": args.importance,
        "meta_json": json.loads(meta_json),
    }
    idempotency_key = None if args.allow_duplicate else (
        args.idempotency_key or derived_idempotency_key(payload)
    )

    conn = connect(db_path)
    conn.isolation_level = None
    try:
        conn.execute("BEGIN IMMEDIATE")
        ensure_session(conn, repo, session_id)
        if idempotency_key is not None:
            duplicate = conn.execute(
                "SELECT id FROM memory_events WHERE idempotency_key = ?",
                (idempotency_key,),
            ).fetchone()
            if duplicate:
                conn.execute("COMMIT")
                print(json.dumps({"status": "duplicate", "event_id": duplicate["id"]}, sort_keys=True))
                return
        if args.session_seq is None:
            row = conn.execute(
                "SELECT COALESCE(MAX(session_seq), 0) + 1 FROM memory_events WHERE session_id = ?",
                (session_id,),
            ).fetchone()
            session_seq = int(row[0])
        else:
            session_seq = args.session_seq
        cursor = conn.execute(
            """
            INSERT INTO memory_events(
              session_id,
              session_seq,
              kind,
              topic_key,
              scope_uri,
              body,
              importance,
              meta_json,
              idempotency_key
            )
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            (
                session_id,
                session_seq,
                args.kind,
                args.topic_key,
                args.scope_uri,
                args.body,
                args.importance,
                meta_json,
                idempotency_key,
            ),
        )
        conn.execute("COMMIT")
    except Exception:
        conn.execute("ROLLBACK")
        raise
    finally:
        conn.close()

    print(json.dumps({"status": "inserted", "event_id": cursor.lastrowid}, sort_keys=True))


def rows_to_dicts(rows: list[sqlite3.Row]) -> list[dict[str, Any]]:
    return [dict(row) for row in rows]


def event_select() -> str:
    return """
      SELECT id, session_id, session_seq, occurred_at, kind, topic_key, scope_uri,
             importance, body, meta_json
      FROM memory_events
    """


def cmd_recall(args: argparse.Namespace) -> None:
    repo = find_repo_root(Path(args.repo))
    init_repo(repo)
    db_path, _ = memory_paths(repo)
    conn = connect(db_path)
    lanes: dict[str, Any] = {}
    try:
        lanes["recent"] = rows_to_dicts(
            conn.execute(
                event_select() + " ORDER BY occurred_at DESC, id DESC LIMIT ?",
                (args.limit,),
            ).fetchall()
        )
        if args.topic_key:
            lanes["topic"] = rows_to_dicts(
                conn.execute(
                    event_select()
                    + " WHERE topic_key = ? ORDER BY occurred_at DESC, id DESC LIMIT ?",
                    (args.topic_key, args.limit),
                ).fetchall()
            )
        if args.scope_uri:
            lanes["scope"] = rows_to_dicts(
                conn.execute(
                    event_select()
                    + " WHERE scope_uri = ? ORDER BY occurred_at DESC, id DESC LIMIT ?",
                    (args.scope_uri, args.limit),
                ).fetchall()
            )
        if args.query:
            try:
                lanes["search"] = rows_to_dicts(
                    conn.execute(
                        """
                        SELECT e.id, e.session_id, e.session_seq, e.occurred_at, e.kind,
                               e.topic_key, e.scope_uri, e.importance, e.body, e.meta_json,
                               bm25(memory_events_fts) AS rank
                        FROM memory_events_fts
                        JOIN memory_events AS e ON e.id = memory_events_fts.rowid
                        WHERE memory_events_fts MATCH ?
                        ORDER BY rank
                        LIMIT ?
                        """,
                        (args.query, args.limit),
                    ).fetchall()
                )
            except sqlite3.OperationalError:
                lanes["search"] = rows_to_dicts(
                    conn.execute(
                        event_select()
                        + " WHERE body LIKE ? ORDER BY occurred_at DESC, id DESC LIMIT ?",
                        (f"%{args.query}%", args.limit),
                    ).fetchall()
                )
    finally:
        conn.close()
    print(json.dumps({"repo_root": str(repo), "lanes": lanes}, indent=2, sort_keys=True))


def tracked_files(repo: Path) -> list[str]:
    result = subprocess.run(
        ["git", "-C", str(repo), "ls-files", "-z"],
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        check=False,
    )
    if result.returncode != 0:
        return []
    return [item.decode("utf-8") for item in result.stdout.split(b"\0") if item]


def is_probably_text(path: Path, max_bytes: int) -> bool:
    try:
        data = path.read_bytes()
    except OSError:
        return False
    if len(data) > max_bytes:
        return False
    if b"\0" in data:
        return False
    try:
        data.decode("utf-8")
    except UnicodeDecodeError:
        return False
    return True


def classify_artifact(path: Path) -> str:
    if path.name in {"AGENTS.md", "README.md"}:
        return "project-instruction"
    if path.suffix in {
        ".c",
        ".cc",
        ".cpp",
        ".cs",
        ".go",
        ".java",
        ".js",
        ".jsx",
        ".kt",
        ".mjs",
        ".py",
        ".rb",
        ".rs",
        ".ts",
        ".tsx",
    }:
        return "implementation"
    if path.suffix in {".md", ".mdx", ".rst", ".txt"}:
        return "document"
    return "artifact"


def blob_oid(repo: Path, rel_path: str) -> str | None:
    return run_git(repo, ["rev-parse", f"HEAD:{rel_path}"])


def cmd_index_artifacts(args: argparse.Namespace) -> None:
    repo = find_repo_root(Path(args.repo))
    init_repo(repo)
    db_path, _ = memory_paths(repo)
    files = tracked_files(repo)
    conn = connect(db_path)
    inserted = 0
    skipped = 0
    try:
        for rel in files:
            if rel in {".agents/memory.db", ".agents/memory.db-wal", ".agents/memory.db-shm"}:
                skipped += 1
                continue
            path = ensure_inside(repo, repo / rel)
            if not path.is_file() or not is_probably_text(path, args.max_bytes):
                skipped += 1
                continue
            content = path.read_bytes()
            content_hash = hashlib.sha256(content).hexdigest()
            uri = f"repo:{rel}"
            media_type = mimetypes.guess_type(path.name)[0] or "text/plain"
            kind = classify_artifact(path)
            title = path.name
            conn.execute(
                """
                INSERT INTO artifacts(uri, artifact_kind, media_type, title)
                VALUES (?, ?, ?, ?)
                ON CONFLICT(uri) DO UPDATE SET
                  artifact_kind = excluded.artifact_kind,
                  media_type = excluded.media_type,
                  title = excluded.title,
                  last_seen_at = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
                """,
                (uri, kind, media_type, title),
            )
            artifact_id = conn.execute(
                "SELECT id FROM artifacts WHERE uri = ?",
                (uri,),
            ).fetchone()["id"]
            conn.execute(
                """
                INSERT OR IGNORE INTO artifact_snapshots(
                  artifact_id,
                  git_blob_oid,
                  content_hash,
                  extractor_id,
                  extractor_version
                )
                VALUES (?, ?, ?, ?, ?)
                """,
                (artifact_id, blob_oid(repo, rel), content_hash, EXTRACTOR_ID, EXTRACTOR_VERSION),
            )
            inserted += 1
        conn.commit()
    finally:
        conn.close()
    print(json.dumps({"indexed": inserted, "skipped": skipped}, sort_keys=True))


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo", default=".", help="repository root or path inside it")
    subparsers = parser.add_subparsers(dest="command", required=True)

    init_parser = subparsers.add_parser("init", help="initialize .agents memory files")
    init_parser.set_defaults(func=cmd_init)

    status_parser = subparsers.add_parser("status", help="show memory store status")
    status_parser.set_defaults(func=cmd_status)

    record_parser = subparsers.add_parser("record", help="record a memory event")
    record_parser.add_argument("--session-id")
    record_parser.add_argument("--session-seq", type=int)
    record_parser.add_argument("--kind", required=True)
    record_parser.add_argument("--topic-key")
    record_parser.add_argument("--scope-uri")
    record_parser.add_argument("--body", required=True)
    record_parser.add_argument("--importance", type=int, default=3, choices=range(0, 6))
    record_parser.add_argument("--meta", type=json_arg, default="{}")
    record_parser.add_argument("--idempotency-key")
    record_parser.add_argument("--allow-duplicate", action="store_true")
    record_parser.set_defaults(func=cmd_record)

    recall_parser = subparsers.add_parser("recall", help="recall memory by lane")
    recall_parser.add_argument("--query")
    recall_parser.add_argument("--topic-key")
    recall_parser.add_argument("--scope-uri")
    recall_parser.add_argument("--limit", type=int, default=20)
    recall_parser.set_defaults(func=cmd_recall)

    index_parser = subparsers.add_parser("index-artifacts", help="index Git-tracked text artifacts")
    index_parser.add_argument("--max-bytes", type=int, default=2_097_152)
    index_parser.set_defaults(func=cmd_index_artifacts)

    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()
    args.func(args)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
