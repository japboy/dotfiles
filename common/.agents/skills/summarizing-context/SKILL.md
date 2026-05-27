---
name: summarizing-context
description: >
  Summarize current conversation context using Model-First-Reasoning (MFR)
  methodology for seamless handoff to subsequent agents. Use when ending a
  session, switching agents, or when the user asks to "summarize context",
  "save session state", "prepare handoff", or "document current progress".
---

# Summarizing Context

Organize and persist the current conversation context using MFR (Model-First-Reasoning) methodology, enabling accurate understanding by subsequent agents.

## Entities

### Context Summary Structure

```
~/Desktop/
└── summary-YYYYMMDDHHmm-[summary-title].md
```

### MFR Categories

| Category | Description |
|----------|-------------|
| **Entities** | Key objects, concepts, files, or components discussed |
| **States** | Current status, progress, or conditions of entities |
| **Actions** | Completed actions, pending tasks, or recommended next steps |
| **Constraints** | Limitations, requirements, or boundaries identified |

## States

- **Analyzing**: Reviewing conversation to identify key information
- **Modeling**: Organizing information into MFR categories
- **Persisting**: Writing summary to assets directory
- **Complete**: Summary saved and ready for handoff

## Actions

### 1. Check for Previous Summary

Before analyzing the conversation, check if a previous context summary exists at the beginning of the conversation context window:

- Look for a markdown file matching the pattern `summary-YYYYMMDDHHmm-*.md` loaded at the start of the context
- Only files following this exact naming convention should be considered for inheritance
- If found, note the **Entities** and **Constraints** sections for potential inheritance

**Inheritance Rules:**

| Category | Inheritance Behavior |
|----------|---------------------|
| **Entities** | Inherit unless explicitly removed or replaced in the current session |
| **States** | Update based on current session progress (do NOT inherit as-is) |
| **Actions** | Fresh for each session (completed actions become historical context) |
| **Constraints** | Inherit unless explicitly changed or resolved in the current session |

> **Important**: Entities and Constraints represent stable context that should persist across sessions unless there is clear evidence of change. States and Actions are session-specific and should reflect current progress.

### 2. Analyze Conversation

Review the current conversation to identify:
- Main objectives and goals discussed
- Technical decisions made
- Problems encountered and solutions applied
- Files or components modified
- Outstanding questions or blockers

### 3. Model with MFR

Organize extracted information into the four MFR categories:

**Entities**: List all significant objects (inherit from previous summary if available)

```markdown
## Entities

- **[Entity Name]**: [Brief description and current relevance]
- **[File Path]**: [Purpose and modifications made]
```

> If a previous summary exists, include all entities from it unless they were explicitly removed or are no longer relevant to the project.

**States**: Document current conditions

```markdown
## States

- **[Entity]**: [Current state] - [Details]
- **Progress**: [Percentage or milestone reached]
```

**Actions**: Record completed and pending work

```markdown
## Actions

### Completed

- [Action description with outcome]

### Pending

- [Remaining task with context]

### Recommended Next Steps

1. [Prioritized next action]
```

**Constraints**: Note limitations and requirements (inherit from previous summary if available)

```markdown
## Constraints

- **Technical**: [Technical limitations identified]
- **Scope**: [Boundaries of current work]
- **Dependencies**: [External requirements]
```

> If a previous summary exists, include all constraints from it unless they were explicitly resolved or changed during the current session.

### 4. Generate Summary File

Create a markdown file with the following structure:

```markdown
# Context Summary: [Brief Title]

**Date**: YYYY-MM-DD HH:mm
**Session Goal**: [Primary objective of the session]

## Entities

[List of key entities]

## States

[Current states and progress]

## Actions

[Completed, pending, and recommended actions]

## Constraints

[Identified limitations and requirements]

## Additional Notes

[Any context that does not fit the above categories]
```

### 5. Save to Desktop

Pipe the summary content to the script, which saves it to Desktop with a timestamped filename:


```bash
echo '<summary-content>' | ./scripts/save-summary.sh <summary-title>
```

Example:


```bash
echo '# Context Summary: API Refactoring

**Date**: 2025-01-19 14:30
**Session Goal**: Refactor API endpoints

## Entities

- **ApiClient**: Main HTTP client class
- **src/api/endpoints.ts**: Modified endpoint definitions

## States

- **Progress**: 70% complete

## Actions

### Completed

- Refactored authentication endpoints

### Pending

- Update remaining CRUD endpoints

## Constraints

- Must maintain backward compatibility' | ./scripts/save-summary.sh api-refactoring-progress
# Output: /Users/username/Desktop/summary-202501191430-api-refactoring-progress.md
```

The script:

- Reads content from stdin
- Generates timestamp in `YYYYMMDDHHmm` format automatically
- Validates title contains only lowercase letters, numbers, and hyphens
- Ensures title is 50 characters or less
- Saves file to Desktop and outputs the filepath

> **Note**: Use single quotes (`'...'`) around the content to preserve special characters like `#`, `*`, and `$`. Do not use heredoc syntax (`cat <<'EOF'`) as it is not supported in some environments.

## Constraints

- Summary must include all four MFR categories
- Filename must follow the specified format exactly
- Title should be descriptive but concise (under 50 characters)
- Avoid including sensitive information (credentials, secrets)
- Focus on information useful for agent handoff, not general documentation

## Reference

See [MFR Methodology](references/REFERENCE.md) for detailed modeling guidelines.
