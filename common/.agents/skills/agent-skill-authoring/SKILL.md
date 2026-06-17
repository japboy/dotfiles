---
name: agent-skill-authoring
description: >
  Create, update, validate, and review Agent Skills for Codex and Claude Code.
  Use when the user asks to "create a skill", "make a new skill", "define a
  skill", "write SKILL.md", "improve a skill description", "set up skill
  directories", "add Codex openai.yaml metadata", "validate skill structure",
  apply SkillOpt-style evaluation, or distinguish standard Agent Skills
  requirements from Codex- or Claude Code-specific practices.
---

# Agent Skill Authoring

## Purpose

Create and review skills by separating four layers clearly:

1. **Agent Skills standard**: Format and validation rules from the shared
   specification
2. **Shared authoring practices**: Patterns that work well across clients, but
   are recommendations rather than spec requirements
3. **Product-specific practices**: Additional conventions that apply only to
   Codex or only to Claude Code
4. **Evidence-based iteration**: SkillOpt-informed review criteria for updating
   existing skills from observed successes, failures, and validation results

Never present a product-specific convention or research-derived review practice
as if it were part of the Agent Skills standard.

## Authoritative Sources

Use these sources in this order:

1. Agent Skills specification for cross-product format rules
2. Product documentation for Codex- or Claude Code-specific behavior
3. Product-maintained example repositories for implementation patterns
4. Research sources, such as SkillOpt, for evaluation and iteration practices

SkillOpt is not a format specification. Use it to evaluate whether a skill
update is evidence-backed, bounded, validated, compact, and generalizable.

See [REFERENCE.md](references/REFERENCE.md) for the source map and
cross-checking guidance.

## Working Model

Start each skill task by classifying the target:

- **Standard only**: The user wants a portable Agent Skill
- **Codex only**: The user wants a skill optimized for Codex
- **Claude Code only**: The user wants a skill optimized for Claude Code
- **Both Codex and Claude Code**: The user wants a portable baseline plus
  product-specific additions where needed

If the target product is unclear, default to:

1. A standard-compliant baseline
2. Shared practices that help multiple clients
3. Optional product-specific additions called out explicitly
4. SkillOpt-informed evaluation only for non-trivial updates or reviews

## Standard Baseline

Treat the following as the portable baseline that should remain true across
products.

### Directory Structure

At minimum, create:

```text
skill-name/
|-- SKILL.md
|-- scripts/      # Optional
|-- references/   # Optional
|-- assets/       # Optional
`-- ...           # Optional extra files or directories
```

Important constraints:

- `SKILL.md` is required
- `scripts/`, `references/`, and `assets/` are optional conventions defined by
  the spec
- Extra files or directories are allowed by the spec
- Do not claim that non-standard directories such as `examples/` are forbidden;
  they are simply not part of the minimal standard vocabulary

### Frontmatter

Write YAML frontmatter at the top of `SKILL.md`.

Required fields:

- `name`
- `description`

Optional standard fields:

- `license`
- `compatibility`
- `metadata`
- `allowed-tools`

Portable example:

```yaml
---
name: skill-name
description: >
  Explain what the skill does and when it should trigger. Include concrete
  task language that helps the client decide when to use the skill.
compatibility: Requires Python 3.11+ and network access
metadata:
  example-org/version: "1.0.0"
---
```

### Standard Validation Rules

Treat these as specification-level rules:

- `name` must be 1-64 characters
- `name` must use lowercase letters, digits, and hyphens
- `name` must not start or end with a hyphen
- `name` must not contain consecutive hyphens
- `name` must match the parent directory name
- `description` must be 1-1024 characters
- `description` should explain what the skill does and when to use it
- `compatibility`, if present, must be 1-500 characters
- `metadata`, if present, should be a key-value mapping with string keys and
  string values
- `allowed-tools` is experimental in the standard; client support can vary

Validate with:

```bash
uvx --from skills-ref agentskills validate ./skill-name
```

### Standard Progressive Disclosure

Structure the skill so clients can load context progressively:

1. Put trigger-critical information in `name` and `description`
2. Keep `SKILL.md` focused on the core workflow
3. Move detailed reference material into `references/`
4. Store deterministic or repetitive operations in `scripts/`
5. Store templates and output resources in `assets/`

Specification-backed targets:

- Keep `SKILL.md` instructions under the recommended 5,000-token guidance when
  practical
- Keep the main `SKILL.md` under 500 lines
- Use relative paths from the skill root when referencing bundled files
- Keep references close to `SKILL.md`; avoid deep reference chains

## Shared Practices for Codex and Claude Code

Treat the following as strong recommendations that work well in multiple
clients. They are not part of the baseline specification unless stated
otherwise.

### Description Quality

Use `description` as the primary trigger surface.

Good descriptions:

- Say what the skill does
- Say when it should be used
- Include concrete user/task language
- Make scope boundaries obvious
- Front-load the strongest trigger words because some clients shorten long
  skill descriptions in listings

Good:

```yaml
description: >
  Extract text and tables from PDF files, fill PDF forms, and merge PDF
  documents. Use when the task involves PDF extraction, form filling,
  document merging, or similar PDF workflows.
```

Poor:

```yaml
description: Helps with PDFs.
```

Do not force one house style as if it were required by the spec. For example,
third-person phrasing, imperative phrasing, and exact quote-heavy trigger lists
can all be useful, but they are authoring choices.

### Resource Selection

Use resource directories intentionally:

- `scripts/`: deterministic helpers, reusable automation, or fragile sequences
- `references/`: long or topic-specific guidance that should load on demand
- `assets/`: templates, boilerplate, icons, fonts, sample outputs, or other
  output-side artifacts
- Extra directories: allowed when they clearly serve the skill, but document
  them explicitly from `SKILL.md`
- Scripts that read or write files should keep path inputs finite and verify resolved paths stay inside the intended base

### Writing Style

Prefer instruction styles that reduce ambiguity:

- Use direct, concrete language
- Prefer explicit steps for fragile workflows
- Prefer examples for trigger descriptions and edge cases
- Avoid unnecessary explanation of things the model already knows
- Encode procedural rules, tool policies, output constraints, and known failure
  modes when they are supported by evidence

Imperative or infinitive phrasing is usually effective, but do not treat second
person or alternative phrasing as an automatic spec violation.

### Validation Beyond Syntax

After baseline validation:

1. Check that the description triggers on the intended tasks
2. Check that the body gives enough guidance to complete those tasks
3. Check that every referenced file exists
4. Check that resource directories are actually used
5. Check that supporting scripts run if the skill depends on them
6. Check that behavior-changing updates have evidence and validation notes

## Codex-Specific Practices

Apply this section only when the skill targets Codex or both products.

### Codex Skill Discovery

Codex reads skills from repository, user, admin, and system locations. For
repository skills, Codex scans `.agents/skills` from the current working
directory up to the repository root. Codex also supports user skills in
`$HOME/.agents/skills`, admin skills in `/etc/codex/skills`, and system skills
bundled with Codex.

Important distinctions:

- Direct skill folders are appropriate for local authoring and repo-scoped
  workflows
- Plugins are the distribution unit for reusable Codex skills and app
  integrations
- Codex follows symlinked skill folders when scanning skill locations
- `~/.codex/config.toml` can disable a skill with `[[skills.config]]`

### `agents/openai.yaml`

Codex supports product-specific metadata in `skill-name/agents/openai.yaml`.
Use this file for Codex-only UI metadata, icons, brand color, default prompts,
implicit invocation policy, and declared tool dependencies.

Important distinctions:

- `agents/openai.yaml` is not part of the Agent Skills standard
- It is a Codex product extension
- A skill can be standard-compliant without it
- A Codex-focused skill is usually better with it
- `policy.allow_implicit_invocation` defaults to `true`; when set to `false`,
  explicit `$skill` invocation still works

See [REFERENCE.md](references/REFERENCE.md) for the current representative
`openai.yaml` fields.

### Local Codex Tooling in This Repository

When working in this repository, prefer the bundled Codex-oriented helpers in
`common/.agents/skills/.system/skill-creator/`:

- `scripts/init_skill.py`
- `scripts/generate_openai_yaml.py`
- `scripts/quick_validate.py`
- `references/openai_yaml.md`

Use them as repository-specific tooling, not as the portable standard.

### Codex Authoring Guidance

For Codex-focused skills:

- Keep the standard `SKILL.md` portable
- Put Codex-only UI or policy metadata in `agents/openai.yaml`
- Generate or refresh `openai.yaml` when the skill title, summary, icons,
  brand color, default prompt, invocation policy, or tool dependencies change
- Keep `default_prompt` short and aligned with the intended invocation
- Test prompts against the description to confirm explicit and implicit trigger
  behavior

## Claude Code-Specific Practices

Apply this section only when the skill targets Claude Code or both products.

Claude Code follows the Agent Skills open standard, then adds Claude Code-only
features such as invocation control, dynamic context injection, subagent
execution, hooks, model/effort overrides, and additional discovery locations.

Important distinctions:

- For portable skills, keep the standard `name` and `description` baseline
- For Claude Code-only skills, Claude Code treats all frontmatter fields as
  optional and recommends `description` so Claude knows when to use the skill
- The slash command usually comes from the skill directory name, not
  frontmatter `name`; plugin-root `SKILL.md` is the notable exception
- Claude Code-specific fields are not portable standard fields unless the Agent
  Skills spec separately defines them

Common Claude Code locations:

- `~/.claude/skills/<skill-name>/SKILL.md`
- `.claude/skills/<skill-name>/SKILL.md`
- `<plugin>/skills/<skill-name>/SKILL.md`
- enterprise-managed locations where applicable

Claude Code-specific frontmatter includes `when_to_use`, `argument-hint`,
`arguments`, `disable-model-invocation`, `user-invocable`, `allowed-tools`,
`disallowed-tools`, `model`, `effort`, `context`, `agent`, `hooks`, `paths`, and
`shell`. Use these only when they intentionally change Claude Code invocation,
execution, permissions, or context behavior.

Claude Code combines `description` and `when_to_use` for listings and truncates
that combined text at 1,536 characters. Keep the key use case first.

Claude Code supports dynamic context injection with `` !`command` `` and
` ```! ` fenced command blocks. Treat this as Claude Code-specific behavior,
use `${CLAUDE_SKILL_DIR}` for bundled files, keep commands deterministic, and
account for settings that can disable skill shell execution.

Use `context: fork` only for skills that contain an actionable task. A forked
subagent receives the skill content as its prompt and does not automatically
inherit the full main conversation.

For detailed Claude Code checks, use
[validation-checklist.md](references/validation-checklist.md).

## SkillOpt-Informed Review

Use this section when updating or reviewing an existing skill. SkillOpt treats a
skill as an external, trainable text state for a fixed target model and harness.
Use its ideas for review discipline; do not treat them as format requirements.

For non-trivial updates, check these axes:

- **Fixed target**: State the target product, model or harness, and evaluator.
  Do not attribute improvement to a skill if those variables also changed.
- **Evidence**: Base edits on representative prompts, trajectories, logs,
  outputs, verifier results, or reviewer judgments.
- **Success/failure separation**: Repair systematic failures and preserve
  reusable success patterns without merging anecdotal one-offs into rules.
- **Bounded edits**: Prefer small add/delete/replace changes over wholesale
  rewrites. Avoid duplicating existing guidance.
- **Validation gate**: Compare the previous and candidate skill on
  representative or held-out prompts before accepting behavior changes.
- **Rejected edits**: Record rejected changes and why they were rejected when
  the information will help future reviews.
- **Record/runtime separation**: Put changelogs, evaluation notes, rejected
  edits, and decision records in `references/`; promote only validated runtime
  rules into `SKILL.md`.
- **Traceability**: Make the evidence or rationale for accepted behavioral
  changes recoverable without turning history into task instructions.
- **Generalization**: Encode reusable procedures, tool policies, applicability
  conditions, output constraints, and failure modes rather than task-specific
  answers.
- **Transfer**: If the skill claims portability, test or document each intended
  product or harness.
- **Compactness**: Keep deployed runtime instructions inspectable; keep bulky
  evidence and reviewer rationale out of activation-time instructions.

For the full checklist, use [validation-checklist.md](references/validation-checklist.md).
This reference implementation keeps [CHANGELOG.md](references/CHANGELOG.md), [evaluation-notes.md](references/evaluation-notes.md), [rejected-edits.md](references/rejected-edits.md), and [decision-records.md](references/decision-records.md) in `references/`.

## Creation Workflow

Follow this workflow unless the task is narrowly scoped enough to skip parts of
it.

### Step 1: Clarify the Target

Identify whether the skill should target:

- standard Agent Skills only
- Codex
- Claude Code
- both Codex and Claude Code

### Step 2: Collect Concrete Use Cases

Gather examples of real user requests that should trigger the skill.

Useful questions:

- What kinds of tasks should trigger the skill?
- What would a user actually say?
- What should not trigger the skill?
- Is the skill meant to be portable, Codex-specific, Claude Code-specific, or
  dual-target?

### Step 3: Plan Reusable Resources

For each representative task:

1. Determine the core workflow
2. Identify repeated or fragile operations
3. Decide whether those operations belong in `scripts/`, `references/`,
   `assets/`, or another clearly justified directory

### Step 4: Create the Baseline Skill

Create the portable baseline first:

1. Create the skill directory
2. Write `SKILL.md`
3. Add only the resource directories actually needed
4. Validate against the standard

When working in this repository and creating a Codex-focused skill from
scratch, use:

```bash
common/.agents/skills/.system/skill-creator/scripts/init_skill.py <skill-name> --path <output-directory>
```

### Step 5: Add Product-Specific Extensions

Only after the baseline is sound:

- Add `agents/openai.yaml` for Codex if needed
- Add Claude Code frontmatter or plugin structure only when the target requires
  Claude Code-specific behavior

### Step 6: Validate and Test

Validate in layers:

1. Standard syntax and naming
2. Shared trigger and resource quality
3. Codex-specific metadata if targeting Codex
4. Claude Code behavior if targeting Claude Code
5. SkillOpt-informed evidence, boundedness, validation, and traceability for
   non-trivial updates

### Step 7: Iterate

Update the skill after real use:

- strengthen or narrow the description
- move long detail from `SKILL.md` into references
- add scripts for repeated tasks
- remove dead files or unused resource directories
- preserve evidence for accepted and rejected behavioral changes

## Forward-Testing

Forward-test complex skills when the workflow, boundaries, or trigger behavior
are uncertain.

Use realistic tasks with minimal leaked context:

- pass the skill and a user-like request
- avoid telling the evaluator what bug is suspected
- review outputs, logs, and artifacts
- tighten the skill if success depends on hidden hints

## What to Avoid

- presenting Codex extensions as if they were part of the standard
- presenting Claude Code extensions as if they were part of the standard
- claiming extra directories are forbidden when the spec allows additional
  files
- forcing one naming style such as gerunds as if it were required
- treating writing-style preferences as hard validation errors unless the user
  asked for that convention
- duplicating detailed content across `SKILL.md` and `references/`
- accepting skill rewrites without evidence, bounded scope, or validation
- shipping optimizer/reviewer-only notes as runtime instructions unless they are
  intentionally useful to the agent

## Quick Reference

Use this decision table:

- **Need portable compliance**: follow the Agent Skills standard first
- **Need better Codex UX**: add `agents/openai.yaml`
- **Need Claude Code behavior**: add Claude Code frontmatter, dynamic context,
  or plugin-specific layout explicitly
- **Need both**: keep `SKILL.md` standard, then layer Codex and Claude Code
  additions without mixing them into the baseline
- **Need an update review**: require evidence, bounded edits, validation, and
  traceability before accepting behavioral changes

See [validation-checklist.md](references/validation-checklist.md) for a layered
review checklist.
