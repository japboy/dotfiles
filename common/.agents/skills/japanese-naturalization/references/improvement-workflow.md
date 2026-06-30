# Improvement Workflow

Use this workflow when user feedback or the agent's own review identifies a
potentially reusable Japanese expression issue and a skill update is being
considered, proposed, or applied.

This is a SkillOpt-informed maintenance workflow. SkillOpt is not an Agent
Skills format specification. Use it here only as review discipline: fixed
target, evidence, bounded edits, validation, rejected-edit memory, compactness,
and separation between runtime instructions and maintenance records.

## Update Proposal Policy

- Fix the current rewrite before discussing skill maintenance.
- When the feedback appears reusable beyond the immediate answer, propose a
  bounded skill update and name the likely destination file.
- When the user is already working on this skill's maintenance, apply the
  bounded update directly after checking evidence, scope, and validation.
- Do not silently promote a one-off wording preference into a durable rule.

## Feedback Intake

For each user correction, extract a finite feedback record:

| Field | Meaning |
|---|---|
| observed_phrase | The phrase the user found unnatural. |
| context | Domain, audience, channel, and surrounding sentence if available. |
| problem_type | One of `terminology`, `style-default`, `ai-like-pattern`, `register`, `evaluation-only`, `unclear`, or `rejected`. |
| preferred_wording | User-preferred or researched wording, if known. |
| evidence | User judgment, local project usage, official source, style guide, or research note. |
| validation | New or existing evaluation fixture that checks the behavior. |
| decision | `accept`, `accept-with-caveat`, `defer`, or `reject`. |

If the context or preferred wording is missing, do not invent a durable rule.
Either ask one concise question or record the feedback as `evaluation-only` or
`defer`.

## Classification

Classify the feedback into exactly one primary destination:

| Problem type | Destination | When to use |
|---|---|---|
| `terminology` | [terminology-traps.md](terminology-traps.md) | A phrase needs context-specific term choice, such as `consumer` or `API 配線`. |
| `style-default` | [japanese-style-defaults.md](japanese-style-defaults.md) | A general orthography or light style default applies across many contexts. |
| `ai-like-pattern` | [ai-like-japanese-patterns.md](ai-like-japanese-patterns.md) | A recurring AI-like phrase should be inspected but not banned. |
| `register` | [evaluation-prompts.csv](evaluation-prompts.csv), and only later a reference rule if repeated | The issue depends mainly on tone, channel, or audience. |
| `evaluation-only` | [evaluation-prompts.csv](evaluation-prompts.csv) | The feedback is useful as a regression case but too narrow for a rule. |
| `unclear` | No runtime rule | The concept, target context, or preferred wording is unresolved. |
| `rejected` | [CHANGELOG.md](CHANGELOG.md), or a future `rejected-edits.md` if rejected edits become frequent | The edit would overfit, contradict evidence, or reduce portability. |

## Bounded Edit Rules

- Prefer adding or revising one registry row, one warning pattern, or one eval
  fixture over rewriting a whole reference file.
- Do not create term-specific narrative sections for individual phrases.
- Do not promote one user preference into a general rule unless the context and
  applicability conditions are explicit.
- Keep source links in a common evidence section or compact note rather than
  duplicating rationale across rules.
- Keep bulky evidence, chronological history, and rejected-edit rationale out of
  `SKILL.md`. Use [CHANGELOG.md](CHANGELOG.md) for compact accepted-change
  entries; split detailed evidence or rejected edits into separate maintenance
  files if the records become too large.

## Validation Gate

After an accepted update:

1. Validate the skill structure:
   - Set `SKILL_DIR` to the directory that contains this skill's `SKILL.md`.

   ```bash
   uvx --from skills-ref agentskills validate "$SKILL_DIR"
   ```

2. Validate changed data files:
   - Parse `evaluation-prompts.csv` with a CSV parser if edited.
   - Check Markdown tables for consistent column counts if edited.
   - Search for stale references to renamed files.

3. Forward-test the new rule when practical:
   - Use the observed phrase in a realistic assistant response.
   - Confirm the rewrite changes only the intended wording.
   - Confirm a nearby non-trigger case is not mechanically rewritten.

## Acceptance Criteria

Accept a behavior-changing update only when all are true:

- The trigger phrase and context are explicit.
- The preferred wording preserves meaning.
- The rule is bounded and does not overgeneralize.
- The target reference file is the correct destination.
- At least one evaluation fixture or validation note can catch regressions.
- The skill still passes the Agent Skills validator.

Defer or reject the update when the evidence is only a single ambiguous example,
the preferred wording changes meaning, or the rule would make the skill less
portable across audiences.
