# References

## Source Hierarchy

Use sources in this order when authoring or reviewing skills:

1. **Agent Skills specification** for portable format and validation rules
2. **Agent Skills standard-site authoring and evaluation guidance** for
   recommended authoring, description-optimization, and evaluation practice
3. **Product-specific documentation**
4. **Product-maintained example repositories**
5. **Research sources** for additional evaluation and iteration rationale

This order matters. Product examples are useful implementation references, but
they do not override the shared specification unless the product explicitly says
so. Standard-site authoring guidance is recommendation, not syntax: it is
authoritative for *practice* but does not add validation rules. Research papers
can inform evaluation and iteration, but they do not define the Agent Skills
file format.

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

### Standard-Site Authoring and Evaluation Guidance

The standard site publishes authoring guidance alongside the specification.
These pages are the primary source for recommended practice, above product
documentation and research sources:

- [Quickstart](https://agentskills.io/skill-creation/quickstart) - creating a
  first skill
- [Best practices for skill creators](https://agentskills.io/skill-creation/best-practices) -
  sourcing skill content from real expertise, spending context wisely,
  calibrating control, and reusable instruction patterns
- [Optimizing skill descriptions](https://agentskills.io/skill-creation/optimizing-descriptions) -
  trigger evaluation, train/validation splits, and description revision
- [Using scripts](https://agentskills.io/skill-creation/using-scripts) -
  bundling and running executable scripts
- [Evaluating skill output quality](https://agentskills.io/skill-creation/evaluating-skills) -
  eval-driven iteration, assertions, grading, and cost/benefit benchmarks

Condensed procedures derived from these pages live in
[instruction-patterns.md](instruction-patterns.md) and
[evaluation-workflow.md](evaluation-workflow.md).

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

- [Build skills](https://learn.chatgpt.com/docs/build-skills) - Codex support
  for local skills, progressive disclosure, skill discovery, and
  `agents/openai.yaml`
- [OpenAI skills examples](https://github.com/openai/skills) - examples linked
  from the Codex docs

The former `https://developers.openai.com/codex/skills` and
`https://developers.openai.com/codex/build-skills` URLs now issue a permanent
redirect to `learn.chatgpt.com/docs/build-skills`. Prefer the current URL.

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

Codex skill-listing budget:

- The startup skills list uses at most 2% of the model's context window, or
  8,000 characters when the context window is unknown
- When many skills are installed, Codex shortens skill descriptions first
- This makes front-loading the key use case a requirement rather than a
  stylistic preference

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
- `context: fork`, `agent`, and `background` for subagent execution
- `allowed-tools`, `disallowed-tools`, `model`, `effort`, `hooks`, `paths`, and
  `shell`

Claude Code context accounting for skills:

- Once a skill loads, its body stays in context across turns, so every line is a
  recurring token cost
- The startup skill listing budget scales at 1% of the model's context window,
  configurable with the `skillListingBudgetFraction` setting or the
  `SLASH_COMMAND_TOOL_CHAR_BUDGET` environment variable
- When the listing overflows, Claude Code drops descriptions starting with the
  least-invoked skills, so frequently used skills keep their full text
- Each listing entry's combined `description` and `when_to_use` text is capped at
  1,536 characters regardless of budget, configurable with
  `skillListingMaxDescChars`
- Low-priority skills can be set to `"name-only"` in `skillOverrides` to free
  listing budget
- `/doctor` estimates the listing's context cost and its biggest contributors
- After auto-compaction, Claude Code re-attaches the most recent invocation of
  each skill, keeping only the **first 5,000 tokens** of each, within a
  **combined 25,000-token** budget filled from the most recently invoked skill;
  older skills can be dropped entirely

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

The standard site now publishes the primary evaluation procedure; see
[evaluation-workflow.md](evaluation-workflow.md). SkillOpt remains useful as
supplementary rationale for *why* that discipline works, and it supplies
vocabulary the standard pages do not, such as rejected-edit buffers and
optimizer/runtime separation. It is no longer the primary source for how to
evaluate a skill.

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

## Model and Harness Guidance Sources

Vendor prompting guides describe how a *specific* model behaves. Treat them as
fixed-target evidence, not as portable Agent Skills rules. Use them to explain
why a shared authoring practice exists, and record the target model when citing
one.

- [Prompting Claude Opus 5](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5)
- [Claude prompting best practices](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices)
- [Prompting guidance for GPT-5.6 Sol](https://developers.openai.com/api/docs/guides/prompt-guidance-gpt-5p6.md)

Points where these guides converge, and which therefore generalize into shared
authoring practice:

- Instructions for behavior the model already performs reliably should be
  deleted, not merely tolerated. Both vendors name self-verification and
  re-checking explicitly.
- Prompts should state the outcome, success criteria, constraints, and stopping
  conditions, and leave routine path selection to the model.
- Absolute language should be reserved for genuine invariants.
- Conservative or hedging instructions are followed literally and suppress
  recall, so exhaustive generation and filtering belong in separate phases.
- Output length and progress-narration cadence must be stated explicitly; they
  are not controlled by reasoning-effort settings.
- Positive examples of a desired style outperform prohibitions.

Points that are model-specific and must not be promoted into portable guidance:
context window sizes, thinking-disabled output artifacts, API parameters such as
verbosity or programmatic tool calling, and any recommended effort default.

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
- Front-load key trigger terms because clients shorten descriptions from a
  budget shared across every installed skill, not a per-skill allowance
- Keep `SKILL.md` focused on the core workflow
- Put the rules that must survive a long session near the top of `SKILL.md`
- Delete instructions the agent already follows reliably, especially generic
  self-verification and re-checking
- State success criteria and stopping conditions
- Reserve absolute language for genuine invariants and explain the reason behind
  flexible rules
- Separate exhaustive generation from filtering instead of asking for
  conservative output in one pass
- State output length and progress-update cadence explicitly for skills that
  produce documents or run long workflows
- Use progressive disclosure
- Move detailed material into `references/`
- Put deterministic helpers in `scripts/`
- Put templates and output resources in `assets/`
- Link supporting files directly from `SKILL.md`
- Validate referenced files and executable scripts, not just frontmatter
- For scripts that read or write files, keep path inputs finite: use
  skill-root-relative bundled resources, derive explicit repo/workspace roots,
  prefer fixed repo-local scratch paths, reject absolute or traversal paths, and
  verify resolved paths stay inside the intended base before filesystem access
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

## Update Review Model

Use this model when evaluating a proposed skill update. It combines the
standard-site evaluation procedure in [evaluation-workflow.md](evaluation-workflow.md)
with SkillOpt's review vocabulary:

1. **Fixed target**: Identify the target model/product/harness and evaluator.
   Do not attribute gains to a skill if those variables also changed.
2. **Evidence**: Collect representative successes, failures, traces, prompts,
   outputs, or verifier results.
3. **Pattern extraction**: Prefer recurring patterns over single examples.
   Separate failure repairs from success reinforcements.
4. **Bounded edits**: Use small add/delete/replace changes with explicit scope.
   Avoid broad rewrites unless the existing skill is structurally unsalvageable.
5. **Validation gate**: Compare previous and candidate skills on held-out or at
   least representative prompts before accepting behavior-changing edits, from a
   clean context each run. Record token count and duration alongside quality, and
   weigh the gain against the added cost rather than treating cost as neutral.
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
|-- evals/
|   `-- evals.json
`-- references/
    |-- CHANGELOG.md
    |-- evaluation-notes.md
    |-- rejected-edits.md
    `-- decision-records.md
```

The standard-site evaluation guidance uses `evals/evals.json` as its test-case
layout. This is authoring guidance, not an Agent Skills specification
requirement. Eval *results* belong in a workspace directory outside the skill,
so they never enter the skill's activation context.

Use these files as follows:

- `SKILL.md`: current runtime instructions; mark an unevaluated
  behavior-changing candidate `provisional` in maintenance records
- `references/CHANGELOG.md`: high-level chronological index with explicit
  `provisional`, `accepted`, or `rejected` state and links to detailed records
- `references/evaluation-notes.md`: prompts, fixtures, scores, reviewer
  judgments, and validation-gate evidence
- `references/rejected-edits.md`: rejected candidate edits, score drops, and
  reasons to avoid repeating them
- `references/decision-records.md`: durable maintenance decisions that explain
  why the skill is shaped a certain way, but are not task-time instructions

The `agent-skill-authoring` skill demonstrates the `references/` maintenance
record subset. It does not currently include `evals/evals.json`, so do not cite
it as a complete evaluation-layout reference implementation. Its `CHANGELOG.md`
is kept as an index, not as the place for detailed evidence or decision
rationale.

Ordinarily promote a note from `references/` into `SKILL.md` only when it has
become a validated, reusable procedure, tool policy, applicability condition,
output constraint, or failure-avoidance rule. If an immediate local correction
must ship before comparative evaluation, record it as provisional and do not
claim improvement. Do not copy time-ordered history into `SKILL.md` merely to
preserve context.

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

This repository declares the user-facing Codex helper path as:

```text
~/.agents/skills/.system/skill-creator/
```

When these paths resolve to regular readable files, useful files are:

- `scripts/init_skill.py`
- `scripts/generate_openai_yaml.py`
- `scripts/quick_validate.py`
- `references/openai_yaml.md`

These are repository-specific helpers. They are not the Agent Skills standard,
and missing, recursive, or broken symlinks must not block portable authoring.

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
10. Treating a single vendor's model-specific prompting guidance as a portable
    Agent Skills authoring rule
11. Measuring only whether a skill improves quality, without recording the token
    and time cost it adds
12. Adding rules to fix every observed failure until the skill is
    over-constrained, instead of testing whether deleting instructions helps
