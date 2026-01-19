---
name: creating-skills
description: >
  Creates and validates Claude Code Agent Skills. Use when the user asks to
  "create a skill", "make a new skill", "define a skill", "write SKILL.md",
  "set up skill directory", "validate skill structure", or mentions creating
  reusable agent capabilities.
---

# Creating Agent Skills

## Entities

### Skill Directory Structure

Based on [Agent Skills Specification](https://agentskills.io/specification):

```
skill-name/
├── SKILL.md              # Required: Core skill definition
├── scripts/              # Optional: Executable code
│   └── extract.py
├── references/           # Optional: Additional documentation
│   ├── REFERENCE.md      # Technical reference (recommended)
│   └── domain.md
└── assets/               # Optional: Static resources
    ├── template.json
    └── schema.yaml
```

### Directory Descriptions

| Directory | Purpose |
|-----------|---------|
| `scripts/` | Executable code (Python, Bash, JavaScript) |
| `references/` | Documentation loaded on demand (`REFERENCE.md` for detailed reference) |
| `assets/` | Static resources (templates, images, data files, schemas) |

### SKILL.md Components

1. **Frontmatter** (YAML): Metadata defining when the skill triggers
2. **Body** (Markdown): Instructions for executing the skill

## States

- **Planning**: Gathering requirements and trigger phrases
- **Drafting**: Writing SKILL.md and supporting files
- **Validating**: Checking structure and content quality
- **Complete**: Skill ready for use

## Actions

### Define Frontmatter

Write YAML frontmatter with required and optional fields:

```yaml
---
name: skill-name
description: >
  What the skill does and when to use it. Include specific keywords
  that help agents identify relevant tasks.
license: Apache-2.0
compatibility: Requires git, docker
metadata:
  author: example-org
  version: "1.0"
---
```

**Field Constraints:**

| Field | Required | Constraints |
|-------|----------|-------------|
| `name` | Yes | 1-64 chars, lowercase alphanumeric and hyphens, no leading/trailing/consecutive hyphens, must match directory name |
| `description` | Yes | 1-1024 chars, describe what and when |
| `license` | No | License name or reference to bundled file |
| `compatibility` | No | 1-500 chars, environment requirements |
| `metadata` | No | Key-value mapping for additional properties |
| `allowed-tools` | No | Space-delimited pre-approved tools (experimental) |

**Naming Best Practices:**

Use **gerund form** (verb + -ing) for skill names to clearly describe the activity:

Good:
```yaml
name: processing-pdfs
name: analyzing-spreadsheets
name: generating-reports
name: reviewing-code
```

Avoid:
```yaml
name: pdf-helper      # vague - what does "help" mean?
name: utils           # generic - no indication of purpose
name: data-tools      # unclear - what operations?
name: anthropic-skill # reserved words not allowed
```

Consistent naming helps:
- Claude understand what a skill does at a glance
- Reference skills in documentation and conversations
- Maintain a cohesive skill library

**Description Best Practices:**
- Start with a verb describing what the skill does
- Include when to use it (trigger conditions)
- Include specific keywords for agent task matching

Good:
```yaml
description: >
  Extracts text and tables from PDF files, fills PDF forms, and merges
  multiple PDFs. Use when working with PDF documents or when the user
  mentions PDFs, forms, or document extraction.
```

Poor:
```yaml
description: Helps with PDFs.
```

### Write Skill Body

The Markdown body contains skill instructions. Recommended sections:

- Step-by-step instructions
- Examples of inputs and outputs
- Common edge cases

**Writing Style:**
- Use imperative or infinitive verb forms
- Avoid second-person pronouns ("you", "your")
- Keep under 500 lines (< 5000 tokens recommended)
- Move detailed content to `references/` directory

Good:
```markdown
Parse the configuration file.
Validate input before processing.
```

Bad:
```markdown
You should parse the configuration file.
```

### Organize Supporting Files

**scripts/ directory:**
- Self-contained or clearly document dependencies
- Include helpful error messages
- Handle edge cases gracefully

**references/ directory:**
- `REFERENCE.md` for detailed technical reference
- Domain-specific files as needed
- Keep files focused (smaller = less context usage)
- Link from SKILL.md: `See [reference](references/REFERENCE.md)`

**assets/ directory:**
- Templates (document, configuration)
- Images (diagrams, examples)
- Data files (lookup tables, schemas)

### Validate Skill

Use [skills-ref](https://github.com/agentskills/agentskills/tree/main/skills-ref) for validation:

```bash
skills-ref validate ./skill-name
```

Manual validation checklist in [validation-checklist.md](./references/validation-checklist.md).

## Constraints

- `name` must match parent directory name exactly
- `name` allows only lowercase letters, numbers, hyphens (no `--`, no leading/trailing `-`)
- `description` must be 1-1024 characters
- Keep SKILL.md under 500 lines
- Keep file references one level deep (avoid nested chains)
- All referenced files must exist
