# Skill Validation Checklist

Use this checklist in layers. Do not confuse shared specification rules with
product-specific conventions.

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

- [ ] at most 64 characters
- [ ] lowercase letters, digits, and hyphens only
- [ ] does not start with a hyphen
- [ ] does not end with a hyphen
- [ ] does not contain consecutive hyphens
- [ ] matches the parent directory name exactly

### `description`

- [ ] non-empty
- [ ] at most 1024 characters
- [ ] explains what the skill does
- [ ] explains when the skill should be used

### Optional Standard Fields

- [ ] `license`, if present, is appropriate
- [ ] `compatibility`, if present, describes environment requirements
- [ ] `metadata`, if present, is used intentionally
- [ ] `allowed-tools`, if present, is intentional and supported by the target
      client

### Standard Validation Command

- [ ] `skills-ref validate ./skill-name` passes

## Layer 2: Shared Quality Checks for Codex and Claude Code

These are strong recommendations, not standard syntax rules.

### Trigger Quality

- [ ] `description` is concrete rather than vague
- [ ] `description` uses task language the client can match
- [ ] scope boundaries are clear enough to avoid over-triggering

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

### Writing Quality

- [ ] instructions are concrete and easy to follow
- [ ] examples exist for important tasks or edge cases
- [ ] the document avoids unnecessary context bloat

Important note:

- Imperative voice is usually good practice
- Avoiding second person is often helpful
- Neither is a universal spec requirement by itself

## Layer 3: Codex-Specific Checks

Run this layer only when the skill targets Codex.

### `agents/openai.yaml`

- [ ] `agents/openai.yaml` exists if Codex-specific metadata is needed
- [ ] `interface.display_name` is user-facing and accurate
- [ ] `interface.short_description` is concise and accurate
- [ ] `interface.default_prompt`, if present, mentions `$skill-name`
- [ ] `policy.allow_implicit_invocation`, if present, matches the intended
      trigger behavior
- [ ] `dependencies.tools`, if present, reflects actual tool dependencies

### Separation of Concerns

- [ ] portable behavior stays in `SKILL.md`
- [ ] Codex-only UI or policy settings stay in `agents/openai.yaml`
- [ ] Codex extensions are not described as if they were part of the shared
      standard

## Layer 4: Claude Code-Specific Checks

Run this layer only when the skill targets Claude Code.

### Portable Skill vs Plugin Skill

- [ ] it is clear whether the skill is a portable skill or a Claude Code plugin
      skill
- [ ] plugin-specific structure is used only when the user actually needs a
      plugin

### Plugin Conventions

- [ ] Claude Code plugin layout is correct when applicable
- [ ] any extra frontmatter fields are intentional and Claude Code-specific
- [ ] any extra directories such as `examples/` are intentional and documented

### Separation of Concerns

- [ ] Claude Code conventions are not described as if they were standard Agent
      Skills requirements

## Severity Guide

### Critical

- missing `SKILL.md`
- missing `name`
- missing `description`
- invalid `name`
- `name` does not match the directory
- invalid YAML frontmatter

### Major

- vague or misleading `description`
- missing referenced files
- product-specific conventions misrepresented as standard requirements
- Codex or Claude Code integration requested by the user but not implemented

### Minor

- unnecessary verbosity
- weak examples
- underused supporting files
- stale product metadata

## Useful Commands

```bash
# Standard validation
skills-ref validate ./skill-name

# Inspect frontmatter quickly
grep '^name:' skill-name/SKILL.md
grep '^description:' -n skill-name/SKILL.md

# Count lines
wc -l skill-name/SKILL.md

# Find references from SKILL.md
grep -oE '(scripts|references|assets|agents)/[^)\"]+' skill-name/SKILL.md
```
