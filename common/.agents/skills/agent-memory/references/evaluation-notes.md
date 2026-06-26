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
