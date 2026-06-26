---
name: agent-memory
description: >
  Build and use repository-local agent memory in .agents/memory.db and
  .agents/memory.yml. Use when a task needs session memory, work logs, handoff
  recall, SQLite-backed agent logs, artifact-aware repository memory, or
  idempotent memory setup across agent sessions.
compatibility: Requires Python 3.11+, Git, and SQLite with JSON1 and FTS5.
---

# Agent Memory

Use this skill to maintain repository-local agent memory as flow information:
session events, handoffs, artifact references, and searchable summaries. Do not
use the database as the canonical home for stable stock information. Stable
decisions, designs, documentation, and implementation state belong in the
repository's own files.

## Core Rules

1. Store memory files under the repository root `.agents/` directory:
   `.agents/memory.db` and `.agents/memory.yml`.
2. Treat `.agents/memory.yml` as declarative repository policy. Do not hardcode
   paths such as `docs/adr` or `docs/design` into the runtime workflow.
3. Treat `.agents/memory.db` as an idempotent local flow-memory store. It may be
   rebuilt, migrated, or re-indexed from repository artifacts and new events.
4. Use artifact references for stock information. When information becomes
   stable, update the relevant repository document or code, then record an event
   that references that artifact.
5. Prefer explicit state: session ids, topic keys, scope URIs, event kinds,
   artifact URIs, hashes, and source ranges should be written explicitly.
6. Prefer finite state: use a small, documented event vocabulary for each
   repository, but do not encode repository-specific vocabulary into the schema.
7. Never record secrets, credentials, private keys, access tokens, or unrelated
   personal data.

## Workflow

Before running bundled helpers, resolve two separate roots:

- `repo-root`: the repository that should receive `.agents/memory.db` and
  `.agents/memory.yml`.
- `skill-root`: the directory containing this `SKILL.md`.

Do not assume `scripts/agent_memory.py` exists in the repository. The helper is
bundled with this skill, so invoke it from `skill-root`:

```bash
python <skill-root>/scripts/agent_memory.py --repo <repo-root> status
```

### 1. Initialize Or Verify Memory

At the start of a task that needs repository memory, initialize the store:

```bash
python <skill-root>/scripts/agent_memory.py --repo <repo-root> init
```

This command is idempotent. It creates `.agents/memory.yml` only if absent and
applies the SQLite schema to `.agents/memory.db`.

### 2. Recall Before Acting

Use recall before making a plan when prior session context could matter:

```bash
python <skill-root>/scripts/agent_memory.py --repo <repo-root> recall \
  --query "<task keywords>" \
  --topic-key "<optional-topic>" \
  --scope-uri "<optional-repo-uri>"
```

Read recall output by lane, not as one global timeline:

- `recent`: a small recency window across sessions
- `topic`: events sharing a topic key
- `scope`: events sharing a repository scope URI
- `search`: FTS5 keyword matches

Global recency is a fallback, because parallel sessions may work on unrelated
topics.

### 3. Record Flow Events

Record only information useful to a later agent:

```bash
python <skill-root>/scripts/agent_memory.py --repo <repo-root> record \
  --session-id "<stable-session-id>" \
  --kind observation \
  --topic-key "<topic>" \
  --scope-uri "repo:path/or/topic" \
  --body "Short factual event text." \
  --meta '{"source":"agent"}'
```

Use `--idempotency-key` when retrying or replaying an event. Without
`--allow-duplicate`, the helper derives a deterministic key from the event
payload to prevent accidental duplicate records.

Record these kinds of events:

- `observation`: factual context discovered during work
- `action`: meaningful operation performed
- `file_change`: a change made to a repository artifact
- `question`: unresolved or user-facing question
- `answer`: answer or resolution reached in-session
- `error`: blocker or failed attempt worth preserving
- `handoff`: compact state for continuation
- `artifact_ref`: relevant repository artifact found, read, or updated
- `summary`: generated rollup or session summary

### 4. Index Repository Artifacts

When repository files changed materially, refresh artifact metadata:

```bash
python <skill-root>/scripts/agent_memory.py --repo <repo-root> index-artifacts
```

The helper records artifact URI, kind, media type, Git blob OID when available,
and content hash. It does not store full repository file contents in the
database.

### 5. Promote Stable Knowledge Out Of The DB

If a memory event becomes stable stock information:

1. Update the repository artifact that should own the information.
2. Run `index-artifacts`.
3. Record an `artifact_ref` or `file_change` event linking the session to that
   artifact.

Do not create a database "current memory item" as the canonical source of truth.

## Supporting Files

- [schema.sql](references/schema.sql): SQLite schema.
- [memory-policy.md](references/memory-policy.md): design rationale and
  retrieval policy.
- [REFERENCE.md](references/REFERENCE.md): official sources and source-code
  references.
- [evaluation-notes.md](references/evaluation-notes.md): validation records for
  updates and audits.
- [memory.yml](assets/memory.yml): default repository policy template.

## Maintenance

For skill updates or audits, apply the Agent Skills validation checklist from
the `agent-skill-authoring` skill. Keep runtime instructions in this file and
put bulky rationale or evaluation records under `references/`.
