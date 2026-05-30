# Decision Records

This file records durable maintenance decisions for the `agent-skill-authoring` skill.
These decisions explain why the skill is shaped a certain way, but they are not
runtime instructions unless they are promoted into `SKILL.md`.

## 2026-05-30: Keep Standard, Product, and Review Layers Separate

Decision:

- Keep Agent Skills standard rules separate from Codex extensions, Claude Code
  extensions, and SkillOpt-informed review practice.

Rationale:

- The Agent Skills specification defines portable structure and validation.
- Codex and Claude Code add product behavior that should not be presented as
  portable standard behavior.
- SkillOpt informs evidence-backed update practice, not file-format syntax.

## 2026-05-30: Store Maintenance Records Under `references/`

Decision:

- Store changelogs, evaluation notes, rejected edits, and durable maintenance
  decisions under `references/`.
- Treat `CHANGELOG.md` as an index of accepted changes, not as the place for
  detailed evidence, rationale, or rejected alternatives.
- Keep `SKILL.md` limited to current validated runtime instructions and concise
  navigation to maintenance records.

Rationale:

- Agent Skills progressive disclosure loads `SKILL.md` on activation, while
  resources are loaded only when needed.
- SkillOpt separates compact deployed skills from optimizer-side state,
  rejected-edit buffers, and edit trace reports.
- A record/runtime boundary keeps the skill inspectable and prevents historical
  notes from becoming accidental task instructions.
- A changelog provides a fast audit entry point while detailed records remain in
  the files that own the evidence, rationale, and negative feedback.

## 2026-05-30: Prefer `uvx --from skills-ref agentskills`

Decision:

- Recommend standalone validation with:

  ```bash
  uvx --from skills-ref agentskills validate ./skill-name
  ```

Rationale:

- The validator package is distributed as `skills-ref`, but current PyPI package
  metadata exposes the executable as `agentskills`.
- `uvx` avoids assuming a global installation.
