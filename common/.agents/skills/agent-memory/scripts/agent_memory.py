#!/usr/bin/env python3
"""Git-repository-shared SQLite memory helper for the agent-memory skill."""

from __future__ import annotations

import argparse
import fnmatch
import hashlib
import json
import mimetypes
from pathlib import Path
import sqlite3
import subprocess
from typing import Any


SKILL_ROOT = Path(__file__).resolve().parents[1]
SCHEMA_PATH = SKILL_ROOT / "references" / "schema.sql"
TEMPLATE_PATH = SKILL_ROOT / "assets" / "memory.yml"
EXTRACTOR_ID = "agent-memory.git-tracked-text"
EXTRACTOR_VERSION = "1"
CONFIG_RELATIVE_PATH = Path("agent-memory/memory.yml")
JOURNAL_MODES = {"delete", "truncate", "persist", "memory", "wal", "off"}


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
    if not resolved.is_dir():
        raise SystemExit(f"repository path is not a directory: {start}")
    root = run_git(resolved, ["rev-parse", "--show-toplevel"])
    if not root:
        raise SystemExit(f"not inside a Git repository: {start}")
    return Path(root).resolve()


def git_common_dir(repo: Path) -> Path:
    raw = run_git(repo, ["rev-parse", "--git-common-dir"])
    if not raw:
        raise SystemExit(f"cannot resolve Git common directory: {repo}")
    candidate = Path(raw)
    if not candidate.is_absolute():
        candidate = repo / candidate
    resolved = candidate.resolve()
    if not resolved.is_dir():
        raise SystemExit(f"Git common directory is not a directory: {resolved}")
    return resolved


def ensure_inside(base: Path, target: Path, *, boundary: str) -> Path:
    base_resolved = base.resolve()
    target_resolved = target.resolve()
    try:
        target_resolved.relative_to(base_resolved)
    except ValueError as exc:
        raise SystemExit(f"path escapes {boundary}: {target}") from exc
    return target_resolved


def parse_scalar(value: str) -> Any:
    if value == "null":
        return None
    if value in {"true", "false"}:
        return value == "true"
    if value.startswith(('"', "'")):
        if value.startswith('"'):
            return json.loads(value)
        return value[1:-1]
    try:
        return int(value)
    except ValueError:
        return value


def parse_policy_yaml(text: str) -> dict[str, Any]:
    """Parse the finite YAML subset used by the bundled policy template."""
    tokens: list[tuple[int, str, int]] = []
    for number, raw_line in enumerate(text.splitlines(), start=1):
        if not raw_line.strip() or raw_line.lstrip().startswith("#"):
            continue
        if "\t" in raw_line[: len(raw_line) - len(raw_line.lstrip())]:
            raise SystemExit(f"invalid policy YAML at line {number}: tabs are not allowed")
        tokens.append((len(raw_line) - len(raw_line.lstrip()), raw_line.strip(), number))

    def split_entry(value: str, number: int) -> tuple[str, str]:
        if ":" not in value:
            raise SystemExit(f"invalid policy YAML at line {number}: expected key: value")
        key, raw_value = value.split(":", 1)
        if not key:
            raise SystemExit(f"invalid policy YAML at line {number}: empty key")
        return key, raw_value.strip()

    def parse_mapping(
        index: int, indent: int, initial: dict[str, Any] | None = None
    ) -> tuple[dict[str, Any], int]:
        result = initial or {}
        while index < len(tokens):
            token_indent, token, number = tokens[index]
            if token_indent < indent:
                break
            if token_indent != indent or token.startswith("- "):
                raise SystemExit(f"invalid policy YAML indentation at line {number}")
            key, raw_value = split_entry(token, number)
            if key in result:
                raise SystemExit(f"duplicate policy key at line {number}: {key}")
            index += 1
            if raw_value:
                result[key] = parse_scalar(raw_value)
            else:
                if index >= len(tokens) or tokens[index][0] <= indent:
                    result[key] = None
                else:
                    result[key], index = parse_block(index, tokens[index][0])
        return result, index

    def parse_block(index: int, indent: int) -> tuple[Any, int]:
        if tokens[index][1].startswith("- "):
            result: list[Any] = []
            while index < len(tokens):
                token_indent, token, number = tokens[index]
                if token_indent < indent:
                    break
                if token_indent != indent or not token.startswith("- "):
                    raise SystemExit(f"invalid policy YAML indentation at line {number}")
                item_text = token[2:].strip()
                index += 1
                if not item_text:
                    if index >= len(tokens) or tokens[index][0] <= indent:
                        raise SystemExit(f"empty policy list item at line {number}")
                    item, index = parse_block(index, tokens[index][0])
                elif ":" in item_text:
                    key, raw_value = split_entry(item_text, number)
                    item = {key: parse_scalar(raw_value) if raw_value else None}
                    if index < len(tokens) and tokens[index][0] > indent:
                        item, index = parse_mapping(index, tokens[index][0], item)
                else:
                    item = parse_scalar(item_text)
                result.append(item)
            return result, index
        return parse_mapping(index, indent)

    if not tokens:
        raise SystemExit("memory policy is empty")
    policy, final_index = parse_block(0, tokens[0][0])
    if final_index != len(tokens) or not isinstance(policy, dict):
        raise SystemExit("memory policy must be a YAML mapping")
    return policy


def require_mapping(parent: dict[str, Any], key: str) -> dict[str, Any]:
    value = parent.get(key)
    if not isinstance(value, dict):
        raise SystemExit(f"memory policy field must be a mapping: {key}")
    return value


def require_positive_int(parent: dict[str, Any], key: str) -> int:
    value = parent.get(key)
    if not isinstance(value, int) or isinstance(value, bool) or value <= 0:
        raise SystemExit(f"memory policy field must be a positive integer: {key}")
    return value


def validate_relative_policy_path(storage_root: Path, value: Any, field: str) -> Path:
    if not isinstance(value, str) or not value:
        raise SystemExit(f"memory policy field must be a non-empty path: {field}")
    candidate = Path(value)
    if candidate.is_absolute() or ".." in candidate.parts:
        raise SystemExit(f"memory policy path must be Git-common-relative: {field}")
    return ensure_inside(
        storage_root,
        storage_root / candidate,
        boundary="Git common directory",
    )


def validate_policy(repo: Path, policy: dict[str, Any]) -> dict[str, Any]:
    if policy.get("version") != 1:
        raise SystemExit("unsupported memory policy version; expected version: 1")
    storage_root = git_common_dir(repo)
    storage = require_mapping(policy, "storage")
    if storage.get("scope") != "git-common":
        raise SystemExit("storage.scope must be git-common")
    database = validate_relative_policy_path(
        storage_root, storage.get("database"), "storage.database"
    )
    config = validate_relative_policy_path(
        storage_root, storage.get("config"), "storage.config"
    )
    expected_config = ensure_inside(
        storage_root,
        storage_root / CONFIG_RELATIVE_PATH,
        boundary="Git common directory",
    )
    if config != expected_config:
        raise SystemExit("storage.config must be agent-memory/memory.yml")
    if database == config:
        raise SystemExit("storage.database and storage.config must be different paths")
    journal_mode = storage.get("journal_mode")
    if not isinstance(journal_mode, str) or journal_mode.lower() not in JOURNAL_MODES:
        raise SystemExit("storage.journal_mode is not a supported SQLite journal mode")

    events = require_mapping(policy, "events")
    importance = events.get("default_importance")
    if not isinstance(importance, int) or isinstance(importance, bool) or not 0 <= importance <= 5:
        raise SystemExit("events.default_importance must be an integer from 0 through 5")
    kinds = events.get("allowed_kinds", events.get("recommended_kinds"))
    if not isinstance(kinds, list) or not kinds or not all(isinstance(item, str) and item for item in kinds):
        raise SystemExit("events.allowed_kinds must be a non-empty string list")
    events["allowed_kinds"] = kinds

    retrieval = require_mapping(policy, "retrieval")
    for key in ("recent_limit", "search_limit", "topic_limit", "scope_limit"):
        require_positive_int(retrieval, key)

    artifacts = require_mapping(policy, "artifacts")
    sources = artifacts.get("sources")
    if not isinstance(sources, list) or len(sources) != 1 or not isinstance(sources[0], dict):
        raise SystemExit("artifacts.sources must contain exactly one source mapping")
    source = sources[0]
    if not isinstance(source.get("id"), str) or not source["id"]:
        raise SystemExit("artifacts.sources[0].id must be a non-empty string")
    for key in ("include", "exclude"):
        values = source.get(key)
        if not isinstance(values, list) or not all(isinstance(item, str) for item in values):
            raise SystemExit(f"artifacts.sources[0].{key} must be a string list")
    require_positive_int(source, "max_bytes")
    classifications = artifacts.get("kinds")
    if not isinstance(classifications, list) or not all(isinstance(item, dict) for item in classifications):
        raise SystemExit("artifacts.kinds must be a list of mappings")
    classification_ids: set[str] = set()
    for index, classification in enumerate(classifications):
        identifier = classification.get("id")
        match = classification.get("match")
        if not isinstance(identifier, str) or not identifier:
            raise SystemExit(f"artifacts.kinds[{index}].id must be a non-empty string")
        if identifier in classification_ids:
            raise SystemExit(f"duplicate artifact kind id: {identifier}")
        classification_ids.add(identifier)
        if not isinstance(match, dict):
            raise SystemExit(f"artifacts.kinds[{index}].match must be a mapping")
        unknown_match_keys = set(match) - {"basenames", "extensions"}
        if unknown_match_keys:
            raise SystemExit(
                f"unsupported artifact match keys for {identifier}: "
                + ", ".join(sorted(unknown_match_keys))
            )
        for key in ("basenames", "extensions"):
            values = match.get(key, [])
            if not isinstance(values, list) or not all(
                isinstance(item, str) and item for item in values
            ):
                raise SystemExit(f"artifact kind {identifier}.{key} must be a string list")
        if not match.get("basenames") and not match.get("extensions"):
            raise SystemExit(f"artifact kind requires at least one matcher: {identifier}")
    return policy


def policy_path(repo: Path) -> Path:
    storage_root = git_common_dir(repo)
    return ensure_inside(
        storage_root,
        storage_root / CONFIG_RELATIVE_PATH,
        boundary="Git common directory",
    )


def load_policy(repo: Path, *, use_template_if_missing: bool = False) -> dict[str, Any]:
    path = policy_path(repo)
    source = TEMPLATE_PATH if use_template_if_missing and not path.exists() else path
    try:
        text = source.read_text(encoding="utf-8")
    except OSError as exc:
        raise SystemExit(f"cannot read memory policy: {source}: {exc}") from exc
    return validate_policy(repo, parse_policy_yaml(text))


def memory_paths(repo: Path, policy: dict[str, Any]) -> tuple[Path, Path]:
    storage_root = git_common_dir(repo)
    storage = require_mapping(policy, "storage")
    return (
        validate_relative_policy_path(
            storage_root, storage["database"], "storage.database"
        ),
        validate_relative_policy_path(
            storage_root, storage["config"], "storage.config"
        ),
    )


def connect(db_path: Path, policy: dict[str, Any]) -> sqlite3.Connection:
    conn = sqlite3.connect(db_path)
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA foreign_keys = ON")
    conn.execute("PRAGMA busy_timeout = 5000")
    journal_mode = require_mapping(policy, "storage")["journal_mode"].upper()
    conn.execute(f"PRAGMA journal_mode = {journal_mode}")
    conn.execute("PRAGMA synchronous = FULL")
    return conn


def init_repo(repo: Path) -> tuple[dict[str, str], dict[str, Any]]:
    config_path = policy_path(repo)
    config_path.parent.mkdir(parents=True, exist_ok=True)
    created_config = "false"
    if not config_path.exists():
        config_path.write_text(TEMPLATE_PATH.read_text(encoding="utf-8"), encoding="utf-8")
        created_config = "true"
    policy = load_policy(repo)
    db_path, config_path = memory_paths(repo, policy)
    db_path.parent.mkdir(parents=True, exist_ok=True)

    conn = connect(db_path, policy)
    try:
        conn.executescript(SCHEMA_PATH.read_text(encoding="utf-8"))
        conn.commit()
    finally:
        conn.close()

    return ({
        "worktree_root": str(repo),
        "git_common_dir": str(git_common_dir(repo)),
        "database": str(db_path),
        "config": str(config_path),
        "created_config": created_config,
    }, policy)


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
    result, _ = init_repo(repo)
    print(json.dumps(result, indent=2, sort_keys=True))


def cmd_status(args: argparse.Namespace) -> None:
    repo = find_repo_root(Path(args.repo))
    policy = load_policy(repo, use_template_if_missing=True)
    db_path, config_path = memory_paths(repo, policy)
    result: dict[str, Any] = {
        "worktree_root": str(repo),
        "git_common_dir": str(git_common_dir(repo)),
        "database": str(db_path),
        "database_exists": db_path.exists(),
        "config": str(config_path),
        "config_exists": config_path.exists(),
    }
    if db_path.exists():
        conn = connect(db_path, policy)
        try:
            result["events"] = conn.execute("SELECT COUNT(*) FROM memory_events").fetchone()[0]
            result["sessions"] = conn.execute("SELECT COUNT(*) FROM sessions").fetchone()[0]
            result["artifacts"] = conn.execute("SELECT COUNT(*) FROM artifacts").fetchone()[0]
        finally:
            conn.close()
    print(json.dumps(result, indent=2, sort_keys=True))


def cmd_record(args: argparse.Namespace) -> None:
    repo = find_repo_root(Path(args.repo))
    _, policy = init_repo(repo)
    db_path, _ = memory_paths(repo, policy)
    session_id = args.session_id
    if not session_id.strip():
        raise SystemExit("--session-id must be non-empty")
    kinds = require_mapping(policy, "events")["allowed_kinds"]
    if args.kind not in kinds:
        raise SystemExit(f"event kind is not declared by memory policy: {args.kind}")
    importance = args.importance
    if importance is None:
        importance = require_mapping(policy, "events")["default_importance"]
    meta_json = args.meta or "{}"
    payload = {
        "session_id": session_id,
        "kind": args.kind,
        "topic_key": args.topic_key,
        "scope_uri": args.scope_uri,
        "body": args.body,
        "importance": importance,
        "meta_json": json.loads(meta_json),
    }
    idempotency_key = None if args.allow_duplicate else (
        args.idempotency_key or derived_idempotency_key(payload)
    )

    conn = connect(db_path, policy)
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
                importance,
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
    _, policy = init_repo(repo)
    db_path, _ = memory_paths(repo, policy)
    retrieval = require_mapping(policy, "retrieval")
    limits = {
        "recent": args.limit or retrieval["recent_limit"],
        "topic": args.limit or retrieval["topic_limit"],
        "scope": args.limit or retrieval["scope_limit"],
        "search": args.limit or retrieval["search_limit"],
    }
    conn = connect(db_path, policy)
    lanes: dict[str, Any] = {}
    try:
        lanes["recent"] = rows_to_dicts(
            conn.execute(
                event_select() + " ORDER BY occurred_at DESC, id DESC LIMIT ?",
                (limits["recent"],),
            ).fetchall()
        )
        if args.topic_key:
            lanes["topic"] = rows_to_dicts(
                conn.execute(
                    event_select()
                    + " WHERE topic_key = ? ORDER BY occurred_at DESC, id DESC LIMIT ?",
                    (args.topic_key, limits["topic"]),
                ).fetchall()
            )
        if args.scope_uri:
            lanes["scope"] = rows_to_dicts(
                conn.execute(
                    event_select()
                    + " WHERE scope_uri = ? ORDER BY occurred_at DESC, id DESC LIMIT ?",
                    (args.scope_uri, limits["scope"]),
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
                        (args.query, limits["search"]),
                    ).fetchall()
                )
            except sqlite3.OperationalError:
                lanes["search"] = rows_to_dicts(
                    conn.execute(
                        event_select()
                        + " WHERE body LIKE ? ORDER BY occurred_at DESC, id DESC LIMIT ?",
                        (f"%{args.query}%", limits["search"]),
                    ).fetchall()
                )
    finally:
        conn.close()
    print(
        json.dumps(
            {
                "worktree_root": str(repo),
                "git_common_dir": str(git_common_dir(repo)),
                "lanes": lanes,
            },
            indent=2,
            sort_keys=True,
        )
    )


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


def read_bounded_text(path: Path, max_bytes: int) -> bytes | None:
    try:
        if path.stat().st_size > max_bytes:
            return None
        with path.open("rb") as handle:
            data = handle.read(max_bytes + 1)
    except OSError:
        return None
    if len(data) > max_bytes:
        return None
    if b"\0" in data:
        return None
    try:
        data.decode("utf-8")
    except UnicodeDecodeError:
        return None
    return data


def policy_glob_matches(rel_path: str, pattern: str) -> bool:
    return pattern == "**/*" or fnmatch.fnmatchcase(rel_path, pattern)


def classify_artifact(path: Path, policy: dict[str, Any]) -> str:
    for classification in require_mapping(policy, "artifacts")["kinds"]:
        identifier = classification.get("id")
        match = classification.get("match")
        if not isinstance(identifier, str) or not isinstance(match, dict):
            raise SystemExit("each artifacts.kinds item requires string id and mapping match")
        basenames = match.get("basenames", [])
        extensions = match.get("extensions", [])
        if not isinstance(basenames, list) or not isinstance(extensions, list):
            raise SystemExit("artifact kind basenames and extensions must be lists")
        if path.name in basenames or path.suffix in extensions:
            return identifier
    return "artifact"


def blob_oid(repo: Path, rel_path: str) -> str | None:
    return run_git(repo, ["rev-parse", f"HEAD:{rel_path}"])


def cmd_index_artifacts(args: argparse.Namespace) -> None:
    repo = find_repo_root(Path(args.repo))
    _, policy = init_repo(repo)
    db_path, _ = memory_paths(repo, policy)
    source = require_mapping(policy, "artifacts")["sources"][0]
    max_bytes = source["max_bytes"]
    includes = source["include"]
    excludes = source["exclude"]
    files = tracked_files(repo)
    conn = connect(db_path, policy)
    inserted = 0
    skipped = 0
    try:
        for rel in files:
            if not any(policy_glob_matches(rel, pattern) for pattern in includes):
                skipped += 1
                continue
            if any(policy_glob_matches(rel, pattern) for pattern in excludes):
                skipped += 1
                continue
            path = ensure_inside(
                repo,
                repo / rel,
                boundary="current worktree",
            )
            if not path.is_file():
                skipped += 1
                continue
            content = read_bounded_text(path, max_bytes)
            if content is None:
                skipped += 1
                continue
            content_hash = hashlib.sha256(content).hexdigest()
            uri = f"repo:{rel}"
            media_type = mimetypes.guess_type(path.name)[0] or "text/plain"
            kind = classify_artifact(path, policy)
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
    parser.add_argument("--repo", required=True, help="explicit path inside the target Git repository")
    subparsers = parser.add_subparsers(dest="command", required=True)

    init_parser = subparsers.add_parser(
        "init", help="initialize shared Git-common memory files"
    )
    init_parser.set_defaults(func=cmd_init)

    status_parser = subparsers.add_parser("status", help="show memory store status")
    status_parser.set_defaults(func=cmd_status)

    record_parser = subparsers.add_parser("record", help="record a memory event")
    record_parser.add_argument("--session-id", required=True)
    record_parser.add_argument("--session-seq", type=int)
    record_parser.add_argument("--kind", required=True)
    record_parser.add_argument("--topic-key")
    record_parser.add_argument("--scope-uri")
    record_parser.add_argument("--body", required=True)
    record_parser.add_argument("--importance", type=int, choices=range(0, 6))
    record_parser.add_argument("--meta", type=json_arg, default="{}")
    record_parser.add_argument("--idempotency-key")
    record_parser.add_argument("--allow-duplicate", action="store_true")
    record_parser.set_defaults(func=cmd_record)

    recall_parser = subparsers.add_parser("recall", help="recall memory by lane")
    recall_parser.add_argument("--query")
    recall_parser.add_argument("--topic-key")
    recall_parser.add_argument("--scope-uri")
    recall_parser.add_argument("--limit", type=int, choices=range(1, 1001))
    recall_parser.set_defaults(func=cmd_recall)

    index_parser = subparsers.add_parser("index-artifacts", help="index policy-selected Git-tracked text artifacts")
    index_parser.set_defaults(func=cmd_index_artifacts)

    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()
    args.func(args)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
