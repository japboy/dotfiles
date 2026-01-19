# Skill Validation Checklist

Based on [Agent Skills Specification](https://agentskills.io/specification).

## Automated Validation

Use the official validation tool:

```bash
skills-ref validate ./skill-name
```

## Structure Validation

- [ ] Skill directory exists with correct name
- [ ] `SKILL.md` file present in skill root
- [ ] Directory structure follows specification:
  ```
  skill-name/
  ├── SKILL.md         # Required
  ├── scripts/         # Optional: executable code
  ├── references/      # Optional: documentation
  └── assets/          # Optional: static resources
  ```
- [ ] No `examples/` directory (not in spec; use `scripts/` instead)

## Frontmatter Validation

### Required Fields

- [ ] YAML frontmatter present (between `---` delimiters)
- [ ] `name` field defined and valid
- [ ] `description` field defined (1-1024 chars)

### `name` Field Rules

- [ ] 1-64 characters
- [ ] Only lowercase letters (`a-z`), numbers (`0-9`), hyphens (`-`)
- [ ] Does not start with hyphen
- [ ] Does not end with hyphen
- [ ] No consecutive hyphens (`--`)
- [ ] Matches parent directory name exactly

```yaml
# Valid
name: pdf-processing
name: code-review

# Invalid
name: PDF-Processing   # uppercase
name: -pdf             # starts with hyphen
name: pdf-             # ends with hyphen
name: pdf--processing  # consecutive hyphens
```

### `description` Field Rules

- [ ] 1-1024 characters
- [ ] Describes what the skill does
- [ ] Describes when to use it
- [ ] Includes specific keywords for agent task matching

```yaml
# Good
description: >
  Extracts text and tables from PDF files, fills PDF forms,
  and merges multiple PDFs. Use when working with PDF documents.

# Poor
description: Helps with PDFs.
```

### Optional Fields

- [ ] `license` - License name or reference to bundled file
- [ ] `compatibility` - 1-500 chars, environment requirements
- [ ] `metadata` - Key-value mapping
- [ ] `allowed-tools` - Space-delimited tool list (experimental)

## Body Content Validation

- [ ] Uses imperative or infinitive verb forms
- [ ] No second-person pronouns ("you", "your")
- [ ] Under 500 lines (< 5000 tokens recommended)
- [ ] Includes step-by-step instructions
- [ ] Includes examples of inputs/outputs
- [ ] Covers common edge cases

```markdown
# Good
Parse the configuration file.
Validate input before processing.

# Bad
You should parse the configuration file.
```

## File Reference Validation

- [ ] All linked files exist
- [ ] References use relative paths from skill root
- [ ] References are one level deep (no nested chains)
- [ ] Markdown links are properly formatted

```markdown
# Correct
See [reference](references/REFERENCE.md) for details.
Run: scripts/extract.py

# Avoid
See [nested](references/advanced/deep/file.md)
```

## Directory Content Validation

### scripts/

- [ ] Scripts are self-contained or document dependencies
- [ ] Include helpful error messages
- [ ] Handle edge cases gracefully

### references/

- [ ] Files are focused (smaller = less context usage)
- [ ] `REFERENCE.md` contains technical reference if present

### assets/

- [ ] Contains only static resources (templates, images, data)
- [ ] No executable code

## Severity Classification

### Critical (Must Fix)

- Missing or invalid `name` field
- Missing `description` field
- `name` does not match directory name
- Second-person pronouns in body
- Referenced files do not exist

### Major (Should Fix)

- `description` lacks keywords for task matching
- SKILL.md exceeds 500 lines
- Missing step-by-step instructions
- Deeply nested file references

### Minor (Consider Fixing)

- Missing optional fields (license, metadata)
- Suboptimal description wording
- Style inconsistencies

## Validation Commands

```bash
# Check directory structure
ls -la skill-name/

# Verify name matches directory
grep '^name:' skill-name/SKILL.md

# Count lines
wc -l skill-name/SKILL.md

# Find second-person pronouns
grep -in '\byou\b\|\byour\b' skill-name/SKILL.md

# Verify name format (should return nothing if valid)
grep '^name:' skill-name/SKILL.md | grep -E '[A-Z]|^name: -|--|- *$'

# List all referenced files
grep -oE '(scripts|references|assets)/[^)\"]+' skill-name/SKILL.md
```
