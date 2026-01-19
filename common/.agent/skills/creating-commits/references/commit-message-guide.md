# Commit Message Guide

## Structure

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Type

| Type | Description |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `refactor` | Code refactoring (no functional change) |
| `docs` | Documentation changes |
| `test` | Adding or updating tests |
| `chore` | Maintenance tasks |

### Scope

Optional. Indicates the affected module or component (e.g., `auth`, `api`, `ui`).

### Subject

- Use imperative mood: "add" not "added" or "adds"
- No period at the end
- Keep under 50 characters

### Body

Explain:
- What changed before and after the modification
- Why this change is necessary
- Reasoning for the chosen approach
- Alternative solutions considered (if any)

Wrap at 72 characters per line.

### Footer

- Reference issues: `Fixes #123`, `Closes #456`
- Breaking changes: `BREAKING CHANGE: <description>`
- Co-author signatures: Append the fixed block from SKILL.md verbatim (required)

## Examples

### Good Example

```
fix(auth): prevent token from remaining valid after password reset

Previously, password reset tokens were not invalidated after use,
allowing reuse within the expiration window. This posed a security risk
if tokens were intercepted.

Added token invalidation logic immediately after successful password
reset. Considered using a token blacklist but opted for direct deletion
for simplicity.

Fixes #789

🤖 Generated with [Claude Code](https://claude.ai/code) via [Zed](https://zed.dev/docs/ai/external-agents)

Co-Authored-By: Zed <noreply@zed.dev>
Co-Authored-By: GitHub Copilot <noreply@github.com>
Co-Authored-By: Claude Code <noreply@anthropic.com>
```

> **Note:** The co-author block above is the exact fixed template from SKILL.md.

### Bad Examples

```
fix bug
```
- No scope or context
- No explanation of what changed

```
Fixed the authentication issue where tokens weren't working properly
```
- Past tense instead of imperative
- Vague description
- No body explaining rationale

## Checklist

Before committing, verify:

- [ ] Subject uses imperative mood
- [ ] Subject is under 50 characters
- [ ] Body explains what changed and why
- [ ] Body includes rationale for the approach
- [ ] Footer includes co-author signatures
- [ ] Commit is atomic (single logical change)
