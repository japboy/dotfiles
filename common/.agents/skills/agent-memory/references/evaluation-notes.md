# Evaluation Notes

## 2026-06-26 Initial Creation

Target: portable Agent Skills baseline without product-specific metadata.

Validation performed:

- `uvx --from skills-ref agentskills validate ./agent-memory`
  - Result: passed.
- `python3 -m py_compile scripts/agent_memory.py`
  - Result: passed.
- Temporary Git repository smoke test:
  - `init` created `.agents/memory.yml` and `.agents/memory.db`.
  - `record` inserted one event.
  - Re-running the same `record` command returned `duplicate`.
  - `recall` returned `recent`, `topic`, `scope`, and `search` lanes.
  - `index-artifacts` indexed two Git-tracked text artifacts.

Open risks:

- The helper intentionally uses only a small built-in artifact classifier.
  Repository-specific classification should be added through future policy or
  extractor logic rather than schema changes.
- The helper writes repository-local SQLite WAL files during operation. Repos
  that commit `.agents/` should decide explicitly whether `.agents/memory.db`
  is ignored, committed after checkpointing, or kept local-only.

## 2026-06-26 Skill-Root Invocation Fix

Observed issue:

- When the skill is installed under `$HOME/.agents/skills/agent-memory`, command
  examples that used `python scripts/agent_memory.py ...` caused Codex to look
  for `scripts/` under the target repository rather than under the skill.

Accepted fix:

- Runtime instructions now require agents to resolve `skill-root` separately
  from `repo-root` and invoke
  `python <skill-root>/scripts/agent_memory.py --repo <repo-root> ...`.

Reasoning:

- Agent Skills specify `scripts/` as a skill resource directory and file
  references are relative to the skill root.
- Codex supports user skills under `$HOME/.agents/skills`, so a bundled helper
  should not be addressed as repository-relative.

## 2026-07-25 Git-Common Worktree Sharing

Status: **Provisional**. The requested storage invariant has deterministic smoke
coverage, but no previous-version/candidate behavioral benchmark or description
trigger-rate evaluation was run.

Validation performed:

- `uvx --from skills-ref agentskills validate ./agent-memory`: passed.
- `python3 -m py_compile scripts/agent_memory.py`: passed.
- Created a temporary repository with `base` and linked `feature` worktrees.
- Initialized and recorded an event from `base`; recalled it from `feature`.
- Recorded another event from `feature`; recalled it from `base`.
- Confirmed both invocations reported the same `git_common_dir`, policy path,
  and database path, while reporting different `worktree_root` values.
- Confirmed the database resolved below the Git common directory.

Design evidence:

- `git rev-parse --show-toplevel` identifies the active worktree boundary.
- `git rev-parse --git-common-dir` identifies the repository state shared by
  linked worktrees.
- Artifact reads remain worktree-contained; policy and SQLite writes are
  Git-common-contained. Arbitrary external paths remain invalid.

No legacy `.agents/memory.db` or `.agents/memory.yml` exists in this repository,
so no migration was required here. A future migration tool must select its
source worktree explicitly rather than guessing among divergent databases.
