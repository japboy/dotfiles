---
name: creating-skills
description: >
  Create, update, and validate Agent Skills for Codex and Claude Code. Use
  when the user asks to "create a skill", "make a new skill", "define a
  skill", "write SKILL.md", "improve a skill description", "set up skill
  directories", "add Codex openai.yaml metadata", "validate skill
  structure", or distinguish standard Agent Skills requirements from Codex-
  or Claude Code-specific practices.
---

# Creating Skills

## Purpose

Create skills by separating three layers clearly:

1. **Agent Skills standard**: Format and validation rules that come from the
   shared specification
2. **Shared authoring practices**: Patterns that work well in both Codex and
   Claude Code, but are recommendations rather than spec requirements
3. **Product-specific practices**: Additional conventions that apply only to
   Codex or only to Claude Code

Never present a product-specific convention as if it were part of the Agent
Skills standard.

## Authoritative Sources

Use these sources in this order:

1. Agent Skills specification for cross-product format rules
2. Codex docs for Codex-specific behavior and `agents/openai.yaml`
3. Claude Code docs or Anthropic-maintained examples for Claude Code-specific
   behavior

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
2. Shared practices that help both products
3. Optional product-specific additions called out explicitly

## Standard Baseline

Treat the following as the portable baseline that should remain true across
products.

### Directory Structure

At minimum, create:

```text
skill-name/
├── SKILL.md
├── scripts/      # Optional
├── references/   # Optional
├── assets/       # Optional
└── ...           # Optional extra files or directories
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
  author: example-org
  version: "1.0.0"
---
```

### Standard Validation Rules

Treat these as specification-level rules:

- `name` must be at most 64 characters
- `name` must use lowercase letters, digits, and hyphens
- `name` must not start or end with a hyphen
- `name` must not contain consecutive hyphens
- `name` must match the parent directory name
- `description` must be non-empty and at most 1024 characters

Validate with:

```bash
skills-ref validate ./skill-name
```

## Shared Practices for Codex and Claude Code

Treat the following as strong recommendations that work well in both products.
They are not part of the baseline specification unless stated otherwise.

### Description Quality

Use `description` as the primary trigger surface.

Good descriptions:

- Say what the skill does
- Say when it should be used
- Include concrete user/task language
- Make scope boundaries obvious

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

### Progressive Disclosure

Keep context efficient:

1. Put trigger-critical information in `name` and `description`
2. Keep `SKILL.md` focused on the core workflow
3. Move detailed reference material into `references/`
4. Store deterministic or repetitive operations in `scripts/`
5. Store templates and output resources in `assets/`

Good shared targets:

- Keep `SKILL.md` materially below the point where it becomes bloated
- Keep reference files focused by topic
- Link supporting files directly from `SKILL.md`
- Avoid deep reference chains when a flatter structure works

### Resource Selection

Use resource directories intentionally:

- `scripts/`: deterministic helpers, reusable automation, or fragile sequences
- `references/`: long or topic-specific guidance that should load on demand
- `assets/`: templates, boilerplate, icons, fonts, sample outputs, or other
  output-side artifacts
- Extra directories: allowed when they clearly serve the skill, but document
  them explicitly from `SKILL.md`

### Writing Style

Prefer instruction styles that reduce ambiguity:

- Use direct, concrete language
- Prefer explicit steps for fragile workflows
- Prefer examples for trigger descriptions and edge cases
- Avoid unnecessary explanation of things the model already knows

Imperative or infinitive phrasing is usually effective, but do not treat second
person or alternative phrasing as an automatic spec violation.

### Validation Beyond Syntax

After baseline validation:

1. Check that the description triggers on the intended tasks
2. Check that the body gives enough guidance to complete those tasks
3. Check that every referenced file exists
4. Check that resource directories are actually used
5. Check that supporting scripts run if the skill depends on them

## Codex-Specific Practices

Apply this section only when the skill targets Codex or both products.

### `agents/openai.yaml`

Codex supports product-specific metadata in:

```text
skill-name/
└── agents/
    └── openai.yaml
```

Use this file for Codex-specific additions such as:

- UI-facing metadata
- default prompts
- implicit invocation policy
- declared tool dependencies

Representative example:

```yaml
interface:
  display_name: "Optional user-facing name"
  short_description: "Optional user-facing description"
  default_prompt: "Use $skill-name to help with this task."

policy:
  allow_implicit_invocation: true

dependencies:
  tools:
    - type: "mcp"
      value: "github"
      description: "GitHub MCP server"
      transport: "streamable_http"
      url: "https://example.invalid/mcp"
```

Important distinctions:

- `agents/openai.yaml` is not part of the Agent Skills standard
- It is a Codex product extension
- A skill can be standard-compliant without it
- A Codex-focused skill is usually better with it

### Local Codex Tooling in This Repository

When working in this repository, prefer the bundled Codex-oriented helpers in
`common/.agent/skills/.system/skill-creator/`:

- `scripts/init_skill.py`
- `scripts/generate_openai_yaml.py`
- `scripts/quick_validate.py`
- `references/openai_yaml.md`

Use them as repository-specific tooling, not as the portable standard.

### Codex Authoring Guidance

For Codex-focused skills:

- Keep the standard `SKILL.md` portable
- Put Codex-only UI or policy metadata in `agents/openai.yaml`
- Generate or refresh `openai.yaml` when the skill title, summary, or default
  invocation changes
- Keep `default_prompt` short and explicitly mention `$skill-name`

## Claude Code-Specific Practices

Apply this section only when the skill targets Claude Code or both products.

### Plugin Context vs Portable Skill Context

Claude Code supports portable Agent Skills, but some Anthropic examples come
from plugin development workflows. Distinguish clearly between:

- **Portable skill guidance**: useful across products
- **Claude Code plugin conventions**: specific to Claude Code plugins

Do not lift plugin-dev conventions into the standard layer without labeling
them.

### Plugin-Dev Conventions

Anthropic-maintained examples may include conventions such as:

- skill directories inside a plugin `skills/` folder
- plugin auto-discovery behavior
- extra frontmatter such as `version`
- extra directories such as `examples/`

These may be valid and useful in Claude Code, but they are not required by the
shared Agent Skills specification.

### Claude Code Authoring Guidance

For Claude Code-focused skills:

- Use the standard `SKILL.md` baseline first
- Add Claude Code plugin structure only when the user is building a plugin
- Treat Anthropic example repositories as implementation references, not as the
  normative spec
- If using extra directories such as `examples/`, explain their purpose from
  `SKILL.md`

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
common/.agent/skills/.system/skill-creator/scripts/init_skill.py <skill-name> --path <output-directory>
```

### Step 5: Add Product-Specific Extensions

Only after the baseline is sound:

- Add `agents/openai.yaml` for Codex if needed
- Add Claude Code plugin structure if the skill is meant to live inside a
  plugin

### Step 6: Validate and Test

Validate in layers:

1. Standard syntax and naming
2. Shared trigger and resource quality
3. Codex-specific metadata if targeting Codex
4. Claude Code plugin behavior if targeting Claude Code plugins

### Step 7: Iterate

Update the skill after real use:

- strengthen or narrow the description
- move long detail from `SKILL.md` into references
- add scripts for repeated tasks
- remove dead files or unused resource directories

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
- presenting Claude Code plugin conventions as if they were part of the
  standard
- claiming extra directories are forbidden when the spec allows additional
  files
- forcing one naming style such as gerunds as if it were required
- treating writing-style preferences as hard validation errors unless the user
  asked for that convention
- duplicating detailed content across `SKILL.md` and `references/`

## Quick Reference

Use this decision table:

- **Need portable compliance**: follow the Agent Skills standard first
- **Need better Codex UX**: add `agents/openai.yaml`
- **Need Claude Code plugin integration**: add plugin-specific layout and
  conventions explicitly
- **Need both**: keep `SKILL.md` standard, then layer Codex and Claude Code
  additions without mixing them into the baseline

See [validation-checklist.md](references/validation-checklist.md) for a layered
review checklist.
