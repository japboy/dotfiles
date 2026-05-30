# Changelog

This file is the high-level chronological index of accepted changes to the
`creating-skills` skill. It is a record, not runtime instruction for creating or
updating skills.

Use this file to answer "what changed and when?" Keep evidence, rationale, and
rejected alternatives in the detailed record files linked from each entry.

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
