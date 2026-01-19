# References

## Official Documentation

### Agent Skills Specification (Primary)

- [Agent Skills Specification](https://agentskills.io/specification) - **Authoritative format specification**
- [What are Skills?](https://agentskills.io/what-are-skills) - Concept overview
- [Integrate Skills](https://agentskills.io/integrate-skills) - Integration guide
- [Example Skills](https://github.com/anthropics/skills) - Official example repository
- [skills-ref Library](https://github.com/agentskills/agentskills/tree/main/skills-ref) - Validation tool

### Claude Code Documentation

- [Agent Skills - Claude Code Docs](https://code.claude.com/docs/en/skills) - Claude Code specific usage and examples
- [Skill authoring best practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices) - Naming conventions, description writing, progressive disclosure patterns

### Claude Code Plugin Development

- [Claude Code Skills](https://github.com/anthropics/claude-code/tree/main/plugins/plugin-dev/skills) - Claude Code specific extensions
- [Skill Development Guide](https://github.com/anthropics/claude-code/blob/main/plugins/plugin-dev/skills/skill-development/SKILL.md) - Claude Code authoring patterns

## Frontmatter Specification

### Required Fields

| Field | Constraints |
|-------|-------------|
| `name` | 1-64 chars, lowercase `a-z`, `0-9`, `-` only. No leading/trailing/consecutive hyphens. Must match directory name. |
| `description` | 1-1024 chars. Describe what the skill does AND when to use it. |

### Optional Fields

| Field | Constraints |
|-------|-------------|
| `license` | License name or reference to bundled file |
| `compatibility` | 1-500 chars. Environment requirements (products, packages, network) |
| `metadata` | Key-value mapping for additional properties |
| `allowed-tools` | Space-delimited pre-approved tools (experimental) |

### Name Validation Rules

Valid:
```yaml
name: pdf-processing
name: data-analysis
name: code-review
```

Invalid:
```yaml
name: PDF-Processing   # uppercase not allowed
name: -pdf             # cannot start with hyphen
name: pdf--processing  # consecutive hyphens not allowed
```

## Directory Structure

```
skill-name/
├── SKILL.md              # Required
├── scripts/              # Executable code
├── references/           # Additional documentation
│   └── REFERENCE.md      # Technical reference
└── assets/               # Static resources
```

**Note:** `examples/` is NOT part of the official spec. Use `scripts/` for executable examples.

## Progressive Disclosure

Token budget guidelines:

| Level | Content | Budget |
|-------|---------|--------|
| Metadata | `name` + `description` | ~100 tokens |
| Instructions | SKILL.md body | < 5000 tokens |
| Resources | scripts/, references/, assets/ | As needed |

Recommendation: Keep SKILL.md under 500 lines.

## Writing Style

### Correct: Imperative Form

```markdown
Parse the frontmatter using sed.
Extract fields with grep.
Validate values before use.
```

### Incorrect: Second-Person

```markdown
You should parse the frontmatter.
You can extract fields with grep.
```

## Common Anti-Patterns

1. **Vague descriptions** - Missing specific keywords for task matching
2. **Bloated SKILL.md** - Too much detail in main file
3. **Second-person language** - Using "you" in body
4. **Name mismatch** - `name` field differs from directory name
5. **Invalid name format** - Uppercase, consecutive hyphens, etc.
6. **Orphaned references** - Links to non-existent files
7. **Deep nesting** - Reference chains beyond one level
