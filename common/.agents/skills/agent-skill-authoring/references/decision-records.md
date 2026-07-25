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

## 2026-07-25: Treat Standard-Site Authoring Guidance as Its Own Source Layer

Decision:

- Insert Agent Skills standard-site authoring and evaluation guidance
  (`agentskills.io/skill-creation/*`) as source layer 2, above product
  documentation and above research sources.
- Demote SkillOpt from primary source for evaluation practice to supplementary
  rationale, and rename the `SkillOpt-Informed Review` section to
  `Update Review`.

Rationale:

- The standard site now publishes `quickstart`, `best-practices`,
  `optimizing-descriptions`, `using-scripts`, and `evaluating-skills`. The skill
  previously attributed evidence-based iteration only to a research paper, which
  understated the authority of the published procedure and left concrete
  artifacts such as `evals/evals.json` and benchmark deltas undocumented.
- These pages are recommendation, not syntax. They rank above product docs for
  *practice* but add no validation rules, so the layer boundary the skill
  already enforces still holds.
- SkillOpt retains vocabulary the standard pages do not provide, notably
  rejected-edit buffers and optimizer/runtime separation, so it stays cited.

## 2026-07-25: Keep Model-Specific Prompting Guidance Out of Runtime Rules

Decision:

- Record vendor model-prompting guidance as fixed-target evidence under
  `references/`, and promote into `SKILL.md` only the model-agnostic authoring
  rule that two or more independent vendors document convergently.
- Never write a model name, context window size, API parameter, or recommended
  effort default into `SKILL.md` as an authoring rule.

Rationale:

- A skill that encodes one model's behavior stops being a portable Agent Skill
  and silently becomes a tuning document for that model.
- SkillOpt's fixed-target axis already requires stating the target model and
  harness for any evidence. `references/` is where that statement belongs.
- Convergence across independent vendors is the available signal that an
  observation reflects instruction-following in general rather than one model's
  quirk.

## 2026-07-25: Move Instruction Patterns and Evaluation Procedure to `references/`

Decision:

- Add `references/instruction-patterns.md` and
  `references/evaluation-workflow.md`, and keep only the decision rules and
  entry points in `SKILL.md`.

Rationale:

- The new material would have pushed `SKILL.md` to roughly 570 lines, past the
  500-line specification recommendation.
- Templates, checklists, eval file formats, and benchmark schemas are needed at
  specific moments, not on every activation, which is exactly the case
  progressive disclosure is designed for.
- Compressing `SKILL.md` by the same amount that was added applied the skill's
  own new over-constraint rule to itself.
