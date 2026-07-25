# Skill Validation Checklist

Use this checklist in layers. Do not confuse shared specification rules,
recommended authoring practice, product-specific conventions, and update-review
practices.

## Layer 1: Agent Skills Standard

These checks apply to any portable Agent Skill.

### Structure

- [ ] Skill directory exists
- [ ] `SKILL.md` exists in the skill root
- [ ] Optional directories are used intentionally
- [ ] Extra files or directories, if present, are justified by the skill

### Frontmatter

- [ ] YAML frontmatter exists at the top of `SKILL.md`
- [ ] `name` exists
- [ ] `description` exists

### `name`

- [ ] 1-64 characters
- [ ] lowercase letters, digits, and hyphens only
- [ ] does not start with a hyphen
- [ ] does not end with a hyphen
- [ ] does not contain consecutive hyphens
- [ ] matches the parent directory name exactly

### `description`

- [ ] 1-1024 characters
- [ ] explains what the skill does
- [ ] explains when the skill should be used
- [ ] includes concrete keywords or task language for discovery

### Optional Standard Fields

- [ ] `license`, if present, is appropriate
- [ ] `compatibility`, if present, is 1-500 characters and describes real
      environment requirements
- [ ] `metadata`, if present, is an intentional key-value mapping
- [ ] `allowed-tools`, if present, is intentional, space-separated, and supported
      by the target client

### Progressive Disclosure

- [ ] `SKILL.md` is focused on activation-time instructions
- [ ] main instructions are materially below the 5,000-token guidance when
      practical
- [ ] `SKILL.md` is under 500 lines unless the extra length is justified
- [ ] rules that must hold for the whole task appear near the top of `SKILL.md`
- [ ] each supporting file reference states *when* to load it, not just that it
      exists
- [ ] file references use relative paths from the skill root
- [ ] reference chains are shallow enough for predictable loading

### Standard Validation Command

- [ ] `uvx --from skills-ref agentskills validate ./skill-name` passes

## Layer 2: Shared Quality Checks for Codex and Claude Code

These are strong recommendations, not standard syntax rules.

### Trigger Quality

- [ ] `description` is concrete rather than vague
- [ ] `description` front-loads the key use case and trigger words
- [ ] `description` uses task language the client can match
- [ ] scope boundaries are clear enough to avoid over-triggering
- [ ] realistic should-trigger and should-not-trigger prompts have been checked
- [ ] negative prompts include near-misses, not only unrelated requests
- [ ] description length is justified against a listing budget shared with every
      other installed skill
- [ ] description changes were selected on held-out prompts rather than the
      prompts used to guide the edit

### Progressive Disclosure

- [ ] `SKILL.md` focuses on the core workflow
- [ ] long or detailed reference material is moved into `references/`
- [ ] repetitive or fragile operations are moved into `scripts/` when useful
- [ ] templates or output artifacts live in `assets/` when useful

### Resource Hygiene

- [ ] every referenced file exists
- [ ] supporting files are linked clearly from `SKILL.md`
- [ ] resource directories are actually used by the workflow
- [ ] no large duplicated content appears in both `SKILL.md` and `references/`

### Supporting Script Safety

- [ ] scripts that access files classify paths as bundled resource, repository
      file, repo-local scratch file, or external input
- [ ] bundled files are referenced relative to the skill root
- [ ] repository files are resolved from an explicit repo/workspace root
- [ ] arbitrary filesystem path CLI options are avoided or strictly allowlisted
- [ ] absolute paths and `..` traversal are rejected when relative paths are
      expected
- [ ] resolved paths are checked to remain inside the intended base directory
- [ ] validation is adjacent to filesystem read/write sinks
- [ ] scratch files live under a fixed repo-local path such as
      `.tmp/<skill-name>/...`

### Writing Quality

- [ ] instructions are concrete and easy to follow
- [ ] examples exist for important tasks or edge cases
- [ ] the document avoids unnecessary context bloat
- [ ] procedural rules, tool policies, output constraints, and failure modes are
      stated when supported by evidence

### Instruction Calibration

- [ ] every instruction would change behavior if followed; none restate what the
      agent already does reliably
- [ ] no generic self-verification, re-check, or double-check instructions
- [ ] no repeated rules, no style instructions that change nothing, and no
      examples that change nothing
- [ ] prescriptive detail is reserved for fragile operations and mandatory
      sequences
- [ ] success criteria and stopping conditions are stated
- [ ] absolute language is reserved for genuine invariants
- [ ] exhaustive generation and filtering are separate phases, rather than a
      single instruction to be conservative
- [ ] output length is calibrated for skills that produce written deliverables
- [ ] progress-update cadence is stated for long-running workflows
- [ ] the skill is not over-constrained: added rules are still improving results

Important note:

- Imperative voice is usually good practice
- Avoiding second person is often helpful
- Neither is a universal spec requirement by itself

## Layer 3: Codex-Specific Checks

Run this layer only when the skill targets Codex.

### Discovery and Scope

- [ ] repository skill location is under the intended `.agents/skills` scope
- [ ] user/admin/system placement is intentional if used
- [ ] duplicate skill names are understood; Codex does not merge them
- [ ] symlinked skill folders, if used, point to the intended target
- [ ] `[[skills.config]]` disables only the intended skill when used
- [ ] the description still carries its key use case after Codex shortens the
      listing to 2% of the context window, or 8,000 characters when unknown

### `agents/openai.yaml`

- [ ] `agents/openai.yaml` exists if Codex-specific metadata is needed
- [ ] `interface.display_name` is user-facing and accurate
- [ ] `interface.short_description` is concise and accurate
- [ ] `interface.icon_small`, if present, points to a valid small icon asset
- [ ] `interface.icon_large`, if present, points to a valid large icon asset
- [ ] `interface.brand_color`, if present, is an intentional brand color
- [ ] `interface.default_prompt`, if present, aligns with the intended skill use
- [ ] `policy.allow_implicit_invocation`, if present, matches the intended
      trigger behavior; omitted means Codex default behavior applies
- [ ] `dependencies.tools`, if present, reflects actual tool dependencies

### Separation of Concerns

- [ ] portable behavior stays in `SKILL.md`
- [ ] Codex-only UI, policy, or dependency settings stay in `agents/openai.yaml`
- [ ] Codex extensions are not described as if they were part of the shared
      standard

## Layer 4: Claude Code-Specific Checks

Run this layer only when the skill targets Claude Code.

### Portable Skill vs Claude Code Skill

- [ ] it is clear whether the skill is portable, Claude Code-only, or dual-target
- [ ] portable skills keep standard `name` and `description`
- [ ] Claude Code-only skills document when they intentionally rely on Claude
      Code's optional frontmatter behavior
- [ ] slash command naming follows the skill location rules, not an incorrect
      assumption that frontmatter `name` always controls invocation

### Discovery and Distribution

- [ ] personal, project, plugin, or enterprise location is intentional
- [ ] parent-directory and nested `.claude/skills` discovery are considered for
      monorepos
- [ ] plugin structure is used only when plugin distribution is needed
- [ ] `.claude/commands` compatibility is not confused with portable Agent
      Skills structure

### Claude Code Frontmatter

- [ ] `description` contains the key use case first
- [ ] `when_to_use`, if present, adds trigger guidance without bloating the
      combined listing text beyond the 1,536-character cap
- [ ] the skill still works when only its first 5,000 tokens survive
      auto-compaction re-attachment
- [ ] `argument-hint` and `arguments`, if present, match actual placeholders
- [ ] `disable-model-invocation` is used for workflows the model should not
      trigger automatically
- [ ] `user-invocable: false` is used only for background skills that should be
      hidden from the slash menu
- [ ] `allowed-tools` grants only the intended pre-approved tools
- [ ] `disallowed-tools` removes tools intentionally and temporarily
- [ ] `model` and `effort` overrides are intentional, measured, and scoped to the
      active skill turn, not defaults carried over from another skill or model
- [ ] before any raised `effort`, the body was checked for a missing success
      criterion, dependency rule, tool-selection rule, or verification loop
- [ ] `context: fork` is used only when the skill contains an actionable task
- [ ] skills that delegate state which work warrants a subagent and cap the
      number, and do not use subagents to double-check their own work
- [ ] `agent`, if present, names the intended built-in or custom subagent
- [ ] `hooks`, if present, are scoped to the skill lifecycle intentionally
- [ ] `paths`, if present, limit automatic activation to the intended globs
- [ ] `shell`, if present, matches the intended dynamic command environment

### Dynamic Context and Supporting Files

- [ ] `` !`command` `` or ` ```! ` dynamic context injection is used only when
      Claude Code-specific execution is intended
- [ ] injected commands are deterministic and least-privilege
- [ ] `${CLAUDE_SKILL_DIR}` is used when bundled files must be referenced
      reliably
- [ ] settings that disable skill shell execution are considered
- [ ] extra directories such as `examples/` are intentional and documented

### Separation of Concerns

- [ ] Claude Code conventions are not described as if they were standard Agent
      Skills requirements

## Layer 5: Update Review

Run this layer for non-trivial updates to existing skills, especially when the
change affects triggering, tool use, output format, or product portability.

### Fixed Evaluation Target

- [ ] target product, model/harness, and evaluator are stated
- [ ] evaluation isolates the skill change rather than changing multiple
      variables at once
- [ ] portability claims identify each intended product or harness
- [ ] model-specific vendor guidance is recorded as fixed-target evidence rather
      than promoted into portable authoring rules

### Evidence

- [ ] update is based on representative prompts, trajectories, outputs, logs,
      verifier results, or reviewer judgments
- [ ] successes and failures are considered separately before merging lessons
- [ ] repeated patterns are prioritized over single anecdotal examples
- [ ] task-specific values are not hardcoded as general rules

### Bounded Edits

- [ ] update scope or edit budget is explicit
- [ ] edits are small add/delete/replace changes unless a rewrite is justified
- [ ] deletion was considered as an edit, not only addition
- [ ] duplicated guidance is removed or avoided
- [ ] new rules are procedural and generalizable

### Validation Gate

- [ ] previous and candidate skill behavior are compared on representative or
      held-out prompts/tasks
- [ ] each run starts from a clean context, without leftover authoring context
- [ ] token count and duration are recorded for both sides of the comparison
- [ ] the quality gain is judged against the token and time cost it adds
- [ ] acceptance criterion is documented
- [ ] rejected or inconclusive results block or narrow the change
- [ ] an unevaluated behavior-changing candidate is marked `provisional`, not
      `accepted`, and has an explicit follow-up gate
- [ ] open-ended domains use documented human or model-based review when
      automatic verification is unavailable

### Records and Traceability

- [ ] changelogs, evaluation notes, rejected edits, and decision records live in
      `references/` or another explicitly documented record location
- [ ] `CHANGELOG.md`, if present, records each change as `provisional`,
      `accepted`, or `rejected` and links to detailed records rather than
      duplicating evidence or rationale
- [ ] rejected edits and reasons are recorded when they inform future reviews
- [ ] accepted behavioral changes can be traced to evidence or rationale
- [ ] reviewer/optimizer-only notes are not shipped as runtime instructions
      unless they help task execution
- [ ] chronological history is not copied into `SKILL.md` as task instructions
- [ ] protected or durable guidance is not overwritten by local cleanup edits

### Compactness, Cost, and Transfer

- [ ] `SKILL.md` size remains inspectable after the update
- [ ] bulky evidence, rationale, and time-ordered history live outside runtime
      instructions
- [ ] training/review cost is paid before deployment and does not require extra
      optimizer calls at runtime
- [ ] cross-product or cross-harness transfer is tested or explicitly marked as
      unverified

## Severity Guide

### Critical

- missing `SKILL.md`
- missing standard-required `name` for a portable skill
- missing standard-required `description` for a portable skill
- invalid `name` for a portable skill
- `name` does not match the directory for a portable skill
- invalid YAML frontmatter

### Major

- vague or misleading `description`
- missing referenced files
- product-specific conventions misrepresented as standard requirements
- Codex or Claude Code integration requested by the user but not implemented
- behavior-changing update accepted without evidence or validation
- Claude Code-only behavior added to a skill that claims portability
- one vendor's model-specific prompting guidance presented as a portable
  authoring rule

### Minor

- unnecessary verbosity
- weak examples
- underused supporting files
- stale product metadata
- unrecorded rejected edits when they would help future reviews
- behavior-changing update accepted without recording its token and time cost
- instructions that restate behavior the agent already performs reliably

## Useful Commands

```bash
# Standard validation
uvx --from skills-ref agentskills validate ./skill-name

# Inspect frontmatter quickly
grep '^name:' skill-name/SKILL.md
grep '^description:' -n skill-name/SKILL.md

# Count lines
wc -l skill-name/SKILL.md

# Find references from SKILL.md
grep -oE '(scripts|references|assets|agents)/[^)\"]+' skill-name/SKILL.md
```
