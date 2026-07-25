---
name: handoff-context-summarization
description: >
  Summarize current conversation context using Model-First-Reasoning (MFR)
  methodology for seamless handoff to subsequent agents. Use when ending a
  session, switching agents, or when the user asks to "summarize context",
  "save session state", "prepare handoff", or "document current progress".
compatibility: Requires Bash 3.2+, awk, mktemp, and a writable Desktop directory only for persisted output.
---

# Handoff Context Summarization

Organize the current conversation context using MFR (Model-First-Reasoning)
methodology so a subsequent agent can continue without hidden state. Return the
summary in chat by default. Write a file only when the user explicitly requests
saved, persisted, or file output.

## Entities

### Persisted Summary Structure

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

## Output States

- **Analyzing**: Reviewing conversation to identify key information
- **Modeling**: Organizing information into MFR categories
- **ChatOnly**: Returning the validated summary without a filesystem write
- **Persisting**: Passing a validated summary to the bundled save helper
- **Complete**: Summary returned in chat, or saved at the helper-reported path
- **Blocked**: Required content is missing or persistence validation fails

Allowed transitions:

```text
Analyzing -> Modeling -> ChatOnly -> Complete
Analyzing -> Modeling -> Persisting -> Complete
Analyzing -> Modeling -> Blocked
Persisting -> Blocked
```

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

### 4. Generate the Summary

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

Before delivery, require each exact heading once with non-empty content:

- `## Entities`
- `## States`
- `## Actions`
- `## Constraints`

If the user did not explicitly request persistence, return the summary in chat
and stop in `Complete`. Do not call the script.

### 5. Persist Only When Requested

Resolve `skill-root` as the directory containing this `SKILL.md`. The helper is
a bundled skill resource, not a repository-relative script. Write the generated
summary to a temporary input file using the active environment's safe file API,
then redirect that file to the helper:

```bash
bash <skill-root>/scripts/save-summary.sh <summary-title> < /absolute/path/to/summary-input.md
```

The script:

- Reads content from stdin
- Generates timestamp in `YYYYMMDDHHmm` format automatically
- Validates title uses lowercase alphanumeric segments separated by single
  hyphens
- Ensures title is 50 characters or less
- Validates the four required headings occur exactly once and have content
- Creates a fully written temporary file in the Desktop directory
- Publishes it atomically and refuses to overwrite the same timestamp/title
- Outputs the saved absolute filepath

Do not interpolate the whole summary into `echo`, a command argument, or an
unquoted shell expression. Content can contain quotes, `$`, backticks, and
newlines; file redirection passes those bytes without shell re-interpretation.

## Constraints

- Summary must include all four MFR categories
- Persisted filename must follow the specified format exactly
- Title should be descriptive but concise (50 characters or fewer)
- Avoid including sensitive information (credentials, secrets)
- Focus on information useful for agent handoff, not general documentation

## Completion

Chat-only output is complete when the rendered summary contains the four exact,
non-empty MFR headings. Persisted output is complete only when the helper exits
successfully and reports the new absolute path. A validation error, filename
collision, missing Desktop, or write failure is `Blocked`; report it without
claiming that a file was saved.

## Reference

Read [MFR Methodology](references/REFERENCE.md) when inheritance is ambiguous,
when modeling preconditions/effects or blockers, or when the compact templates
above are insufficient.
