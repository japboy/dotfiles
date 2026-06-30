# Changelog

This file is the high-level chronological index of accepted changes to the
`japanese-naturalization` skill. It is a maintenance record, not runtime
rewriting guidance.

Use this file to answer "what changed and when?" Keep entries compact. Detailed
examples belong in [evaluation-prompts.csv](evaluation-prompts.csv); reusable
runtime rules belong in [terminology-traps.md](terminology-traps.md),
[japanese-style-defaults.md](japanese-style-defaults.md), or
[ai-like-japanese-patterns.md](ai-like-japanese-patterns.md). If detailed
decision records or rejected-edit notes become necessary, add separate
maintenance files and link them from this changelog.

## 2026-06-30

- Added [REFERENCE.md](REFERENCE.md) as the entry point for runtime references,
  maintenance records, source hierarchy, and maintenance policy.
  - Evidence: Existing repository skills commonly use `references/REFERENCE.md`
    as the reference map; Agent Skills allows supporting reference files and
    recommends progressive disclosure.
  - Validation:

    ```bash
    uvx --from skills-ref agentskills validate "$SKILL_DIR"
    ```

- Added a SkillOpt-informed improvement workflow for incorporating user feedback
  about unnatural expressions without creating one-off special-case sections.
  - Runtime entry point:
    [Skill Improvement Feedback](../SKILL.md#skill-improvement-feedback)
  - Maintenance workflow:
    [improvement-workflow.md](improvement-workflow.md)
  - Evidence: User requested SkillOpt-informed self-improvement instructions;
    `agent-skill-authoring` recommends bounded edits, validation gates,
    traceability, and runtime/record separation.
  - Validation:

    ```bash
    uvx --from skills-ref agentskills validate "$SKILL_DIR"
    ```

- Changed the expression-feedback policy so pointed-out or noticed unnatural
  wording triggers skill-update consideration and, when reusable, an explicit
  bounded update proposal instead of requiring the user to say "reflect" or
  "incorporate" first.
  - Runtime entry point:
    [Skill Improvement Feedback](../SKILL.md#skill-improvement-feedback)
  - Maintenance workflow:
    [improvement-workflow.md](improvement-workflow.md)
  - Evidence: User clarified that the skill should proactively consider or
    propose updates when expression issues are pointed out or found.
  - Validation:

    ```bash
    uvx --from skills-ref agentskills validate "$SKILL_DIR"
    ```

- Removed location-specific assumptions from cross-skill references. Related
  skills are now invoked only "when available" so the skill does not assume
  where another skill is loaded from.
  - Evidence: User clarified that cross-skill references should not assume a
    specific skill-loading level.
  - Validation:

    ```bash
    uvx --from skills-ref agentskills validate "$SKILL_DIR"
    ```

- Replaced hardcoded skill validation paths with `SKILL_DIR`, defined as the
  directory containing this skill's `SKILL.md`.
  - Evidence: User clarified that the skill may be reached through symlinks or
    other installation layouts, so maintenance instructions should not assume a
    concrete filesystem location.
  - Validation:

    ```bash
    uvx --from skills-ref agentskills validate "$SKILL_DIR"
    ```

- Classified [evaluation-prompts.csv](evaluation-prompts.csv) as an evaluation
  fixture rather than a runtime reference while keeping it under `references/`.
  - Evidence: The CSV is used for regression checks during testing and skill
    updates, not as output material or a task-time lookup table.
  - Validation:

    ```bash
    uvx --from skills-ref agentskills validate "$SKILL_DIR"
    ```
