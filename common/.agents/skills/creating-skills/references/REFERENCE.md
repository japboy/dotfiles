# References

## Source Hierarchy

Use sources in this order when authoring or reviewing skills:

1. **Agent Skills standard**
2. **Product-specific documentation**
3. **Product-maintained example repositories**
4. **Research sources for evaluation practices**

This order matters. Product examples are useful implementation references, but
they do not override the shared specification unless the product explicitly says
so. Research papers can inform evaluation and iteration, but they do not define
the Agent Skills file format.

## Standard Agent Skills Sources

These are the baseline references for any portable skill:

- [Agent Skills Specification](https://agentskills.io/specification) -
  authoritative shared format and validation rules
- [What are Skills?](https://agentskills.io/what-are-skills) - concept overview
- [Integrate Skills](https://agentskills.io/integrate-skills) - client-side
  integration guidance
- [skills-ref Library](https://github.com/agentskills/agentskills/tree/main/skills-ref) -
  reference validator and prompt-generation tooling
- [Agent Skills spec source](https://github.com/agentskills/agentskills/blob/main/docs/specification.mdx) -
  canonical source text for the public spec

## `skills-ref` Installation and Execution

The reference validator is distributed as the Python package `skills-ref`, but
recent package metadata exposes the CLI executable as `agentskills`. Do not
assume either command is installed globally.

Standalone validation:

```bash
uvx --from skills-ref agentskills validate ./skill-name
```

Project-pinned usage:

```bash
uv add --dev skills-ref
uv run agentskills validate ./skill-name
```

The package requires Python 3.11 or later. Some public specification examples
still show `skills-ref validate`; prefer the package-published `agentskills`
entry point when using the current PyPI package.

## Codex Sources

Use these for Codex-specific behavior:

- [OpenAI Codex: Agent Skills](https://developers.openai.com/codex/skills) -
  Codex support for local skills, progressive disclosure, skill discovery, and
  `agents/openai.yaml`
- [OpenAI skills examples](https://github.com/openai/skills) - examples linked
  from the Codex docs

Key Codex-only topics:

- `.agents/skills` repository discovery from current directory to repo root
- user/admin/system skill locations
- plugin distribution for reusable skills and app integrations
- `~/.codex/config.toml` `[[skills.config]]` skill disabling
- `agents/openai.yaml`
- `policy.allow_implicit_invocation`
- `dependencies.tools`
- UI metadata such as `display_name`, `short_description`, `icon_small`,
  `icon_large`, `brand_color`, and `default_prompt`

## Claude Code Sources

Use these for Claude Code-specific behavior:

- [Claude Code skills docs](https://code.claude.com/docs/en/skills) - browser
  documentation
- [Claude Code skills Markdown](https://code.claude.com/docs/en/skills.md) -
  same documentation in Markdown form
- [Claude Code docs index](https://code.claude.com/docs/llms.txt) - official
  index for current Claude Code docs
- [Anthropic skills repository](https://github.com/anthropics/skills) -
  Anthropic-maintained skill examples
- [Claude Code plugin-dev skills](https://github.com/anthropics/claude-code/tree/main/plugins/plugin-dev/skills) -
  plugin-oriented implementation examples

Key Claude Code-only topics:

- personal, project, plugin, and enterprise skill locations
- parent-directory and nested `.claude/skills` discovery
- live change detection for `SKILL.md`
- custom commands merged into skills
- invocation control with `disable-model-invocation` and `user-invocable`
- dynamic context injection with `` !`command` `` and ` ```! ` blocks
- `${CLAUDE_SKILL_DIR}` for bundled file paths
- `context: fork` and `agent` for subagent execution
- `allowed-tools`, `disallowed-tools`, `model`, `effort`, `hooks`, `paths`, and
  `shell`

Important note:

- Claude Code docs say Claude Code skills follow the Agent Skills open standard
  and extend it with additional features
- For Claude Code-only skills, the docs state that all frontmatter fields are
  optional and `description` is recommended; for portable standard skills,
  `name` and `description` remain required by the Agent Skills spec
- Claude Code frontmatter `name` is generally a display label; the slash command
  normally comes from the skill directory name, except for plugin-root
  `SKILL.md`
- Claude Code-specific fields are not the shared Agent Skills baseline unless
  separately defined by the Agent Skills spec

## Research and Evaluation Sources

Use research sources to improve review discipline, not to define syntax.

- [SkillOpt: Executive Strategy for Self-Evolving Agent Skills](https://arxiv.org/html/2605.23904v2) -
  arXiv HTML for the May 25, 2026 v2 paper
- [SkillOpt source package](https://arxiv.org/e-print/2605.23904v2) - official
  arXiv source used to verify method and appendix details

SkillOpt-backed evaluation concepts:

- skills are an external text state for a fixed target model and execution
  harness
- scored rollouts provide evidence for edits
- success and failure trajectories should be analyzed separately before merging
  candidate edits
- edits should be bounded add/delete/replace changes rather than uncontrolled
  rewrites
- candidate skills should pass a validation gate before acceptance
- rejected edits are useful negative feedback and should remain traceable
- durable optimizer/reviewer guidance should stay separate from deployed runtime
  instructions unless it is useful to the target model
- final skills should remain compact, inspectable, procedural, and
  generalizable rather than instance-specific
- transfer should be evaluated explicitly when portability across models,
  harnesses, or products is claimed

## Standard Baseline Summary

### Required Files

```text
skill-name/
`-- SKILL.md
```

### Common Optional Directories

```text
skill-name/
|-- scripts/
|-- references/
|-- assets/
`-- ...
```

The spec explicitly allows additional files or directories beyond the common
ones above.

### Frontmatter Fields

Required:

- `name`
- `description`

Optional standard fields:

- `license`
- `compatibility`
- `metadata`
- `allowed-tools`

### Validation Rules

`name`

- 1-64 characters
- lowercase letters, digits, and hyphens
- no leading hyphen
- no trailing hyphen
- no consecutive hyphens
- must match the parent directory name

`description`

- 1-1024 characters
- should explain what the skill does and when to use it
- should include specific keywords that help agents identify relevant tasks

`compatibility`

- 1-500 characters if present
- should be included only when the skill has specific environment requirements

`metadata`

- key-value mapping
- recommended string keys and string values
- use reasonably unique key names to avoid accidental conflicts

`allowed-tools`

- space-separated string in the standard
- experimental; support varies by client

### Progressive Disclosure

The Agent Skills spec describes progressive disclosure in three layers:

1. metadata loaded at startup: `name` and `description`
2. `SKILL.md` instructions loaded when the skill is activated
3. bundled resources loaded only when required

Spec recommendations include keeping `SKILL.md` instructions under 5,000 tokens
and the main `SKILL.md` under 500 lines, moving detail into supporting files,
and using relative paths from the skill root.

## Shared Practices for Codex and Claude Code

These are recommendations that work well in multiple products:

- Keep `description` concrete and trigger-oriented
- Front-load key trigger terms because clients may shorten long descriptions
- Keep `SKILL.md` focused on the core workflow
- Use progressive disclosure
- Move detailed material into `references/`
- Put deterministic helpers in `scripts/`
- Put templates and output resources in `assets/`
- Link supporting files directly from `SKILL.md`
- Validate referenced files and executable scripts, not just frontmatter
- For updates, require evidence, bounded edits, validation, and traceability

These are useful practices, not specification requirements unless the standard
states them directly.

## Codex-Specific Practices

Codex extends the baseline with `agents/openai.yaml`.

Representative structure:

```text
skill-name/
|-- SKILL.md
`-- agents/
    `-- openai.yaml
```

Representative Codex fields:

```yaml
interface:
  display_name: "Optional user-facing name"
  short_description: "Optional user-facing description"
  icon_small: "./assets/small-logo.svg"
  icon_large: "./assets/large-logo.png"
  brand_color: "#3B82F6"
  default_prompt: "Optional surrounding prompt to use the skill with"

policy:
  allow_implicit_invocation: false

dependencies:
  tools:
    - type: "mcp"
      value: "openaiDeveloperDocs"
      description: "OpenAI Docs MCP server"
      transport: "streamable_http"
      url: "https://developers.openai.com/mcp"
```

This file is a Codex extension, not part of the shared Agent Skills spec.
`allow_implicit_invocation` defaults to `true`; setting it to `false` blocks
implicit matching while preserving explicit `$skill` invocation.

## Claude Code-Specific Practices

Claude Code examples and docs commonly show:

- skills under `~/.claude/skills/` or project `.claude/skills/`
- plugin skills under `<plugin>/skills/`
- `.claude/commands/` files still working as skill-like commands
- extra frontmatter fields for invocation, arguments, tools, model/effort,
  context, hooks, paths, and shell behavior
- supporting files such as templates, examples, references, and scripts
- dynamic context injection with shell commands before the skill content is sent
  to Claude

Treat these as Claude Code implementation practices when relevant. Do not copy
them into a portable skill without labeling them as Claude Code-specific.

## SkillOpt-Informed Review Model

Use this model when evaluating a proposed skill update:

1. **Fixed target**: Identify the target model/product/harness and evaluator.
   Do not attribute gains to a skill if those variables also changed.
2. **Evidence**: Collect representative successes, failures, traces, prompts,
   outputs, or verifier results.
3. **Pattern extraction**: Prefer recurring patterns over single examples.
   Separate failure repairs from success reinforcements.
4. **Bounded edits**: Use small add/delete/replace changes with explicit scope.
   Avoid broad rewrites unless the existing skill is structurally unsalvageable.
5. **Validation gate**: Compare previous and candidate skills on held-out or at
   least representative prompts before accepting behavior-changing edits.
6. **Rejected-edit memory**: Record rejected changes and the reason or evidence
   against them.
7. **Compactness**: Keep the deployed skill auditable; move rationale and bulky
   evidence out of runtime instructions.
8. **Generalization**: Encode procedural knowledge, not one-off answers or
   benchmark-specific artifacts.
9. **Transfer**: If a skill claims portability, test or document each intended
   product/harness.
10. **Separation**: Keep reviewer/optimizer guidance separate from target-agent
    runtime instructions unless it is useful during task execution.

### Recommended Record Layout

SkillOpt does not prescribe a `CHANGELOG.md` convention, but it does separate the
compact deployed skill from optimizer-side state, rejected-edit buffers, and edit
trace reports. In Agent Skills terms, that maps best to keeping runtime rules in
`SKILL.md` and maintenance records in `references/`.

Recommended structure:

```text
skill-name/
|-- SKILL.md
`-- references/
    |-- CHANGELOG.md
    |-- evaluation-notes.md
    |-- rejected-edits.md
    `-- decision-records.md
```

Use these files as follows:

- `SKILL.md`: current validated runtime instructions only
- `references/CHANGELOG.md`: high-level chronological index of accepted
  changes, with links to detailed records
- `references/evaluation-notes.md`: prompts, fixtures, scores, reviewer
  judgments, and validation-gate evidence
- `references/rejected-edits.md`: rejected candidate edits, score drops, and
  reasons to avoid repeating them
- `references/decision-records.md`: durable maintenance decisions that explain
  why the skill is shaped a certain way, but are not task-time instructions

The `creating-skills` skill itself follows this layout and can be used as a
reference implementation for record/runtime separation. Its `CHANGELOG.md` is
kept as an index, not as the place for detailed evidence or decision rationale.

Promote a note from `references/` into `SKILL.md` only when it has become a
validated, reusable procedure, tool policy, applicability condition, output
constraint, or failure-avoidance rule. Do not copy time-ordered history into
`SKILL.md` merely to preserve context.

If `SKILL.md` links these files, label them as update/audit references so an
agent does not treat them as required task instructions:

```markdown
## Maintenance References

For skill updates or audits only, see:
- [CHANGELOG.md](references/CHANGELOG.md)
- [evaluation-notes.md](references/evaluation-notes.md)
- [rejected-edits.md](references/rejected-edits.md)
```

## Repository-Specific Codex Helpers

This repository includes Codex-oriented tooling under:

```text
common/.agents/skills/.system/skill-creator/
```

Useful files:

- `scripts/init_skill.py`
- `scripts/generate_openai_yaml.py`
- `scripts/quick_validate.py`
- `references/openai_yaml.md`

These are repository-specific helpers. They are not the Agent Skills standard.

## Common Mistakes

1. Treating `agents/openai.yaml` as standard instead of Codex-specific
2. Treating Claude Code frontmatter extensions as standard instead of
   Claude Code-specific
3. Treating Claude Code plugin examples as if they define the portable standard
4. Claiming `examples/` is forbidden when the standard allows extra
   files/directories
5. Treating style preferences such as imperative voice as hard spec rules
6. Omitting product-specific metadata when the user explicitly wants Codex or
   Claude Code integration
7. Accepting skill edits without evidence, bounded scope, or a validation gate
8. Shipping reviewer-only notes, rejected edits, or benchmark details as runtime
   instructions without a clear task-time purpose
9. Treating chronological change history as runtime procedure instead of
   maintenance records under `references/`
