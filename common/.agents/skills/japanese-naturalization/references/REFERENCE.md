# Japanese Naturalization References

Use this file as the entry point for supporting references. It is a map, not a
replacement for the task-specific files below.

## Runtime References

Load these only when the active rewrite needs the corresponding guidance:

| File | Use when |
|---|---|
| [terminology-traps.md](terminology-traps.md) | A phrase may need context-specific term choice, domain wording, or audience-specific translation. |
| [japanese-style-defaults.md](japanese-style-defaults.md) | The rewrite needs lightweight orthography or style defaults and no project style guide overrides them. |
| [ai-like-japanese-patterns.md](ai-like-japanese-patterns.md) | The output feels generic, translationese, overly stiff, or AI-like. |

## Evaluation Fixtures

Use these only when testing, validating, or updating the skill:

| File | Purpose |
|---|---|
| [evaluation-prompts.csv](evaluation-prompts.csv) | CSV regression fixtures for representative rewrite and terminology cases. |

## Maintenance References

Use these only when updating or auditing the skill:

| File | Purpose |
|---|---|
| [improvement-workflow.md](improvement-workflow.md) | SkillOpt-informed process for incorporating user feedback into bounded, validated updates. |
| [CHANGELOG.md](CHANGELOG.md) | High-level chronological index of accepted changes. |

## Source Hierarchy

When a rewrite or skill update depends on terminology or style evidence, prefer
sources in this order:

1. User-provided style guide, glossary, product UI, repository text, or target
   document context.
2. Official product, platform, framework, or standards documentation.
3. Product-maintained examples and localization guidance.
4. Domain-specific dictionaries, public-sector guidance, or reputable style
   guides.
5. General dictionaries, blogs, search results, or frequency signals as weak
   supporting evidence only.

For substantial terminology research, use the `term-translation-research` skill
when available. For Agent Skills structure, validation, Codex/Claude
Code-specific behavior, or SkillOpt-style review discipline, use the
`agent-skill-authoring` skill when available.

## Maintenance Policy

- Keep `SKILL.md` focused on activation-time behavior.
- Keep bulky evidence, rejected alternatives, and chronological history out of
  runtime instructions.
- Keep evaluation fixtures separate from runtime references unless they are
  needed for the active task.
- Promote a note into runtime references only when it has become a reusable
  procedure, applicability condition, output constraint, or failure-avoidance
  rule.
- Add or update an evaluation fixture when a behavior-changing rule is accepted.
