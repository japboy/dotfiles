---
name: agent-memory
description: >
  Build and use Git-repository-shared agent memory across branches and
  worktrees. Use when a task needs session memory, work logs, handoff recall,
  SQLite-backed agent logs, artifact-aware repository memory, or idempotent
  memory setup across agent sessions.
compatibility: Requires Python 3.11+, Git, and SQLite with JSON1 and FTS5.
---

# Agent Memory

Use this skill to maintain repository-local agent memory as flow information:
session events, handoffs, artifact references, and searchable summaries. Do not
use the database as the canonical home for stable stock information. Stable
decisions, designs, documentation, and implementation state belong in the
repository's own files.

## Core Rules

1. Store memory policy and database under the repository's Git common directory:
   `<git-common-dir>/agent-memory/memory.yml` and `memory.db`. All linked
   worktrees share this directory.
2. Treat the shared `memory.yml` as declarative repository policy. Do not
   hardcode storage paths, retrieval limits, event kinds, artifact rules, or
   paths such as `docs/adr` and `docs/design` into the runtime workflow.
3. Treat the shared `memory.db` as an idempotent local flow-memory store. It may
   be rebuilt, migrated, or re-indexed from repository artifacts and new events.
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

Before running bundled helpers, resolve three separate, explicit roots:

- `worktree-root`: the current worktree whose branch and artifacts are active.
- `git-common-dir`: the repository-owned directory returned by
  `git rev-parse --git-common-dir`; memory state is shared here.
- `skill-root`: the directory containing this `SKILL.md`.

Do not assume `scripts/agent_memory.py` exists in the repository. The helper is
bundled with this skill, so invoke it from `skill-root`:

```bash
python <skill-root>/scripts/agent_memory.py --repo <worktree-root> status
```

### 1. Initialize Or Verify Memory

At the start of a task that needs repository memory, initialize the store:

```bash
python <skill-root>/scripts/agent_memory.py --repo <worktree-root> init
```

This command is idempotent. It creates the shared policy only if absent and
applies the SQLite schema to its database. The helper rejects a `--repo`
outside a Git worktree, contains artifact reads inside the active worktree, and
contains policy/database writes inside the Git common directory. Thus branches
and linked worktrees share memory without granting arbitrary external paths.

### 2. Recall Before Acting

Use recall before making a plan when prior session context could matter:

```bash
python <skill-root>/scripts/agent_memory.py --repo <worktree-root> recall \
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
python <skill-root>/scripts/agent_memory.py --repo <worktree-root> record \
  --session-id "<stable-session-id>" \
  --kind observation \
  --topic-key "<topic>" \
  --scope-uri "repo:path/or/topic" \
  --body "Short factual event text." \
  --meta '{"source":"agent"}'
```

Use `--idempotency-key` when retrying or replaying an event. Without
`--allow-duplicate`, the helper derives a deterministic key from the event
payload to prevent accidental duplicate records. Always supply a stable,
task-specific `--session-id`; the helper has no implicit default session.

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
python <skill-root>/scripts/agent_memory.py --repo <worktree-root> index-artifacts
```

The helper applies the `artifacts` include, exclude, size, and classification
rules from the shared `memory.yml`. It checks file size before bounded reads,
then records artifact URI, kind, media type, Git blob OID when available, and
content hash. It does not store full repository file contents in the database.

### 5. Promote Stable Knowledge Out Of The DB

If a memory event becomes stable stock information:

1. Update the repository artifact that should own the information.
2. Run `index-artifacts`.
3. Record an `artifact_ref` or `file_change` event linking the session to that
   artifact.

Do not create a database "current memory item" as the canonical source of truth.

## Supporting Files

- Read [schema.sql](references/schema.sql) when changing database entities,
  constraints, indexes, or migrations.
- Read [memory-policy.md](references/memory-policy.md) when changing the
  flow/stock boundary, retrieval lanes, idempotency, or concurrency behavior.
- Read [REFERENCE.md](references/REFERENCE.md) when verifying a design claim
  against SQLite, Git, Agent Skills, or product documentation.
- Read [evaluation-notes.md](references/evaluation-notes.md) only when auditing
  or evaluating a skill update.
- Read [memory.yml](assets/memory.yml) when changing repository policy fields or
  their defaults; the helper copies it only when repository policy is absent.

## Completion

Memory setup or use is complete only when `status` reports the expected
`worktree_root`, shared `git_common_dir`, policy, and database; every requested
record reports `inserted` or `duplicate`; any requested recall returns its
finite lane object; and every material repository change requested for
indexing is followed by a successful `index-artifacts` result. Stop without
claiming completion when identity resolution, policy validation, containment,
schema application, or a requested operation fails.

## Maintenance

For skill updates or audits, apply the Agent Skills validation checklist from
the `agent-skill-authoring` skill. Keep runtime instructions in this file and
put bulky rationale or evaluation records under `references/`.
