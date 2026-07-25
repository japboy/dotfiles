# Instruction Patterns

Reusable techniques for structuring skill content. These are standard-site
authoring recommendations, not specification requirements. Use the ones that fit
the task; a skill does not need all of them.

Primary source: [Best practices for skill creators](https://agentskills.io/skill-creation/best-practices).

## Calibrating Control

Match instruction specificity to task fragility, and calibrate each part of a
skill independently.

- **Give the agent freedom** when multiple approaches are valid and the task
  tolerates variation. For flexible instructions, explaining *why* is more
  effective than a rigid directive, because an agent that understands the
  purpose makes better context-dependent decisions.
- **Be prescriptive** when operations are fragile, consistency matters, or a
  specific sequence must be followed. State the exact command and say that it
  must not be modified.
- **Provide defaults, not menus.** When several tools or approaches could work,
  pick one default and mention alternatives briefly. Options presented without a
  clear default are a common cause of wasted agent steps.
- **Favor procedures over declarations.** Teach how to approach a class of
  problems rather than what to produce for one instance. Specific details such
  as output templates, constraints, and tool names are still valuable; it is the
  *approach* that should generalize.

## Gotchas Sections

Often the highest-value content in a skill: concrete, environment-specific facts
that defy reasonable assumptions. These are corrections to mistakes the agent
will otherwise make, not general advice.

```markdown
## Gotchas

- The `users` table uses soft deletes. Queries must include
  `WHERE deleted_at IS NULL` or results will include deactivated accounts.
- The `/health` endpoint returns 200 as long as the web server is running, even
  if the database connection is down. Use `/ready` for full service health.
```

Keep gotchas in `SKILL.md` where the agent reads them before hitting the
situation. A separate reference file works only if the skill states when to load
it; for non-obvious issues the agent may not recognize the trigger.

When an agent makes a mistake that has to be corrected by hand, adding the
correction here is one of the most direct ways to improve the skill.

## Templates for Output Format

Provide a concrete template rather than describing the format in prose; agents
pattern-match well against structures. Short templates can live inline in
`SKILL.md`. Longer templates, or templates needed only in some cases, belong in
`assets/` and should be referenced from `SKILL.md` so they load on demand.

## Checklists for Multi-Step Workflows

An explicit checklist helps the agent track progress and avoid skipping steps,
especially when steps have dependencies or validation gates.

```markdown
Progress:
- [ ] Step 1: Analyze the form (run `scripts/analyze_form.py`)
- [ ] Step 2: Create field mapping (edit `fields.json`)
- [ ] Step 3: Validate mapping (run `scripts/validate_fields.py`)
```

## Validation Loops

Instruct the agent to validate its own work before moving on: do the work, run a
validator (script, reference checklist, or self-check), fix issues, repeat until
validation passes.

Distinguish this from redundant self-verification. A validation loop is worth
encoding when it has an external verifier the agent would not otherwise run. A
generic "double-check your answer" or "verify with a subagent" instruction is
not; current models already self-verify, and such instructions add cost without
improving results. See the instruction-calibration guidance in `SKILL.md`.

## Plan-Validate-Execute

For batch or destructive operations, have the agent write an intermediate plan
in a structured format, validate that plan against a source of truth, and only
then execute.

```markdown
1. Extract form fields: `python scripts/analyze_form.py input.pdf` -> `form_fields.json`
2. Create `field_values.json` mapping each field name to its intended value
3. Validate: `python scripts/validate_fields.py form_fields.json field_values.json`
4. If validation fails, revise `field_values.json` and re-validate
5. Fill the form: `python scripts/fill_form.py input.pdf field_values.json output.pdf`
```

The essential ingredient is step 3: a validator that checks the plan against the
source of truth and emits errors specific enough for the agent to self-correct.

## Bundling Reusable Scripts

When comparing execution traces across evaluation runs, watch for the agent
independently reinventing the same logic each time (building a chart, parsing a
format, validating output). That is the signal to write a tested script once and
bundle it in `scripts/`.

## Sourcing Skill Content

Skills generated purely from an LLM's general knowledge produce vague procedures
("handle errors appropriately"). Ground the skill in real expertise instead:

- **Extract from a hands-on task.** Complete a real task with an agent, then
  extract the reusable pattern. Pay attention to the steps that worked, the
  corrections that had to be made, the input/output formats, and the
  project-specific context that had to be supplied.
- **Synthesize from project artifacts.** Internal runbooks, style guides, API
  specifications, code review comments, version control history, and real
  failure cases outperform generic reference material, because they capture the
  actual schemas, failure modes, and recovery procedures.
