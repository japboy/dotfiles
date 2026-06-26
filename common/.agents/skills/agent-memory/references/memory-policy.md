# Agent Memory Policy

## Purpose

This skill stores flow information for agents working in a repository. Flow
information includes observations, actions, failed attempts, handoff notes,
artifact references, and searchable rollups. Stock information belongs in the
repository's own documents and source code.

## Architectural Classification

### Local Fix

Use `.agents/memory.db` as a SQLite event log with FTS5 search and artifact
metadata. This solves immediate recall needs without prescribing a repository's
documentation layout.

### Fundamental Solution

Separate these concerns:

- Flow state: session events, handoffs, rollups, and artifact references in
  `.agents/memory.db`.
- Stock state: repository documents, code, generated assets, and other durable
  artifacts in the repository.
- Policy state: repository-specific discovery and retrieval settings in
  `.agents/memory.yml`.

This keeps the database declarative, self-describing, deterministic, explicit,
finite, exhaustive enough for retrieval lanes, and predictable across sessions.

## Repository Independence

The schema must not encode repository-specific paths such as `docs/adr`,
`docs/design`, `rfcs`, or `architecture`. Treat every durable repository file as
an artifact with a URI, kind, media type, content hash, and optional Git blob
OID. Repository-specific artifact classification belongs in `.agents/memory.yml`
or in future extractor logic, not in the schema.

## Skill Resource Paths

Keep bundled helpers in the skill directory. A user-installed skill can live
under `$HOME/.agents/skills/agent-memory`, while repository memory files live
under `<repo-root>/.agents/`. These are different roots.

Do not copy helper scripts into each repository merely to make command examples
work. Instead, resolve `skill-root` from the loaded `SKILL.md` path and run:

```bash
python <skill-root>/scripts/agent_memory.py --repo <repo-root> <command>
```

This keeps deterministic helper code as skill resources and repository-local
state as repository data.

## Retrieval Lanes

Do not rely on a single global timeline. Parallel sessions can work on unrelated
topics. Retrieve memory through fixed lanes:

1. Repository policy: `.agents/memory.yml` and any active instruction files.
2. Continuation: explicit `session_edges` relationships when present.
3. Topic: events matching `topic_key`.
4. Scope: events matching `scope_uri` such as a path, symbol, feature, or issue.
5. Search: FTS5 matches over event body.
6. Recent: a small global recency fallback.

## Downsampling

Use rollups for semantic downsampling, not as a replacement for canonical
repository artifacts. A rollup must keep provenance through event ranges,
source hashes, and a status value. When a rollup becomes stable project
knowledge, promote it into an artifact and record the promotion event.

## Idempotency

Use stable keys for repeatable operations:

- Session identity: `sessions.id`
- Event ordering: `(session_id, session_seq)`
- Event replay protection: `idempotency_key`
- Artifact identity: `artifacts.uri`
- Artifact snapshot identity:
  `(artifact_id, content_hash, extractor_id, extractor_version)`
- Rollup identity: `(rollup_type, rollup_key, source_hash)`

## Concurrency

SQLite supports multiple readers with a single writer. Keep write transactions
short. Use `BEGIN IMMEDIATE` for event insertion, `busy_timeout` for contention,
and WAL mode for repository-local concurrent read/write behavior.
