# Changelog

This file is the high-level chronological index of accepted changes to the
`agent-skill-authoring` skill. It is a record, not runtime instruction for creating or
updating skills.

Use this file to answer "what changed and when?" Keep evidence, rationale, and
rejected alternatives in the detailed record files linked from each entry.

## 2026-07-25

- Added Agent Skills standard-site authoring and evaluation guidance as source
  layer 2, demoted SkillOpt to supplementary rationale, and renamed the review
  section to `Update Review`.
  - Decision: [Treat Standard-Site Authoring Guidance as Its Own Source Layer](decision-records.md#2026-07-25-treat-standard-site-authoring-guidance-as-its-own-source-layer)
  - Evidence: [2026-07-25 Context-Engineering Review](evaluation-notes.md#2026-07-25-context-engineering-review)
- Added an `Instruction Calibration` block to the shared practices: delete
  instructions the agent already follows, state success criteria and stopping
  conditions, reserve absolute language for invariants, separate exhaustive
  generation from filtering, state output length and update cadence, and watch
  for over-constraint.
  - Decision: [Keep Model-Specific Prompting Guidance Out of Runtime Rules](decision-records.md#2026-07-25-keep-model-specific-prompting-guidance-out-of-runtime-rules)
  - Rejected alternative: [Encoding Claude Opus 5 or GPT-5.6 Sol specifics as runtime rules](rejected-edits.md#encoding-claude-opus-5-or-gpt-56-sol-specifics-as-runtime-rules)
- Documented that skill-listing budgets are shared across all installed skills,
  with the Codex and Claude Code figures in their product sections, and added
  Claude Code post-compaction re-attachment limits.
- Added `evals/`-based evaluation and description trigger tuning, plus a cost
  accounting axis to the update review.
- Added [instruction-patterns.md](instruction-patterns.md) and
  [evaluation-workflow.md](evaluation-workflow.md); compressed `SKILL.md` by a
  comparable number of lines to stay under the 500-line recommendation.
  - Decision: [Move Instruction Patterns and Evaluation Procedure to `references/`](decision-records.md#2026-07-25-move-instruction-patterns-and-evaluation-procedure-to-references)
  - Rejected alternative: [Keeping the full standard field list in both `SKILL.md` and `REFERENCE.md`](rejected-edits.md#keeping-the-full-standard-field-list-in-both-skillmd-and-referencemd)
- Updated the Codex documentation URL to `learn.chatgpt.com/docs/build-skills`
  after the previous `developers.openai.com` paths began issuing permanent
  redirects.

## 2026-05-30

- Separated Agent Skills standard rules, Codex-specific practices, Claude
  Code-specific practices, and SkillOpt-informed review criteria.
  - Decision: [Keep Standard, Product, and Review Layers Separate](decision-records.md#2026-05-30-keep-standard-product-and-review-layers-separate)
  - Evidence: [2026-05-30 Validation](evaluation-notes.md#2026-05-30-validation)
- Added current standalone validator guidance using the PyPI package entry
  point:

  ```bash
  uvx --from skills-ref agentskills validate ./skill-name
  ```

  - Decision: [Prefer `uvx --from skills-ref agentskills`](decision-records.md#2026-05-30-prefer-uvx---from-skills-ref-agentskills)
  - Rejected alternative: [Using `skills-ref validate` as the primary command](rejected-edits.md#using-skills-ref-validate-as-the-primary-command)
- Added SkillOpt-informed record/runtime separation guidance and reorganized this
  skill as the reference implementation for that record layout.
  - Decision: [Store Maintenance Records Under `references/`](decision-records.md#2026-05-30-store-maintenance-records-under-references)
  - Rejected alternative: [Shipping chronological history in `SKILL.md`](rejected-edits.md#shipping-chronological-history-in-skillmd)
