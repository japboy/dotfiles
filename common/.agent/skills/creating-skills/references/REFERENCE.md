# References

## Source Hierarchy

Use sources in this order when authoring or reviewing skills:

1. **Agent Skills standard**
2. **Product-specific documentation**
3. **Product-maintained example repositories**

This order matters. Product examples are useful implementation references, but
they do not override the shared specification unless the product explicitly says
so.

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

## Codex Sources

Use these for Codex-specific behavior:

- [OpenAI Codex: Agent Skills](https://developers.openai.com/codex/skills) -
  Codex support for local skills, progressive disclosure, and
  `agents/openai.yaml`

Key Codex-only topics:

- `agents/openai.yaml`
- `policy.allow_implicit_invocation`
- `dependencies.tools`
- UI metadata such as `display_name`, `short_description`, and `default_prompt`

## Claude Code Sources

Use these for Claude Code-specific behavior:

- [Claude Code skills docs](https://code.claude.com/docs/en/skills)
- [Anthropic skills repository](https://github.com/anthropics/skills) -
  Anthropic-maintained skill examples
- [Claude Code plugin-dev skills](https://github.com/anthropics/claude-code/tree/main/plugins/plugin-dev/skills) -
  plugin-oriented implementation examples
- [Claude Code plugin-dev skill-development](https://github.com/anthropics/claude-code/blob/main/plugins/plugin-dev/skills/skill-development/SKILL.md) -
  plugin-oriented authoring guidance
- [Claude Code plugin-dev plugin-structure](https://github.com/anthropics/claude-code/blob/main/plugins/plugin-dev/skills/plugin-structure/SKILL.md) -
  Claude Code plugin layout guidance

Important note:

- Anthropic plugin-dev examples often show valid Claude Code conventions
- They may include extra frontmatter such as `version`
- They may use extra directories such as `examples/`
- Those conventions are not the shared Agent Skills baseline unless separately
  defined by the Agent Skills spec

## Standard Baseline Summary

### Required Files

```text
skill-name/
└── SKILL.md
```

### Common Optional Directories

```text
skill-name/
├── scripts/
├── references/
├── assets/
└── ...
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

- at most 64 characters
- lowercase letters, digits, hyphens
- no leading hyphen
- no trailing hyphen
- no consecutive hyphens
- must match the parent directory name

`description`

- non-empty
- at most 1024 characters
- should explain what the skill does and when to use it

## Shared Practices for Codex and Claude Code

These are recommendations that work well in both products:

- Keep `description` concrete and trigger-oriented
- Keep `SKILL.md` focused on the core workflow
- Use progressive disclosure
- Move detailed material into `references/`
- Put deterministic helpers in `scripts/`
- Put templates and output resources in `assets/`
- Link supporting files directly from `SKILL.md`
- Validate referenced files and executable scripts, not just frontmatter

These are useful practices, not specification requirements.

## Codex-Specific Practices

Codex extends the baseline with `agents/openai.yaml`.

Representative structure:

```text
skill-name/
├── SKILL.md
└── agents/
    └── openai.yaml
```

Representative Codex fields:

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

This file is a Codex extension, not part of the shared Agent Skills spec.

## Claude Code-Specific Practices

Claude Code examples commonly show:

- skills inside plugin `skills/` directories
- plugin auto-discovery
- plugin-specific structure and manifests
- extra frontmatter fields in some examples
- extra directories such as `examples/`

Treat these as Claude Code implementation practices when relevant, especially
for plugin development. Do not automatically copy them into a portable skill
without labeling them as Claude Code-specific.

## Repository-Specific Codex Helpers

This repository includes Codex-oriented tooling under:

```text
common/.agent/skills/.system/skill-creator/
```

Useful files:

- `scripts/init_skill.py`
- `scripts/generate_openai_yaml.py`
- `scripts/quick_validate.py`
- `references/openai_yaml.md`

These are repository-specific helpers. They are not the Agent Skills standard.

## Common Mistakes

1. Treating `agents/openai.yaml` as standard instead of Codex-specific
2. Treating Claude Code plugin-dev examples as if they define the standard
3. Claiming `examples/` is forbidden when the standard allows extra
   files/directories
4. Treating style preferences such as imperative voice as hard spec rules
5. Omitting product-specific metadata when the user explicitly wants Codex or
   Claude Code integration
