# Commit Message Guide

## Structure

```
<type>(<scope>): <subject>

Problem:
- <what is wrong with the current state>

Change:
- <what this commit changes>

Rationale:
- <why this result or approach is better>

Alternatives:
- <optional trade-off or rejected option>

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

Write the body as labeled sections with bullet lists:
- Use the section headers `Problem:`, `Change:`, and `Rationale:`
- Add `Alternatives:` only when trade-offs or rejected options matter
- Start each bullet with `- `
- Keep each bullet focused on one concrete point
- Explain what is wrong with the current state in `Problem:`
- Explain what this commit changes in `Change:`
- Explain why this result or approach is better in `Rationale:`
- Mention alternative solutions considered in `Alternatives:` when relevant

Wrap at 72 characters per line.

### Footer

- Reference issues: `Fixes #123`, `Closes #456`
- Breaking changes: `BREAKING CHANGE: <description>`
- Co-author signatures: Append the fixed block from SKILL.md verbatim (required)

## Examples

### Good Example

```
fix(auth): prevent token from remaining valid after password reset

Problem:
- Password reset tokens remained valid after use, allowing reuse within
  the expiration window and increasing replay risk.

Change:
- Invalidate the token immediately after a successful password reset so
  each token becomes single-use.

Rationale:
- Reused reset tokens weaken the recovery flow and create avoidable
  security exposure if a token is intercepted.
- Direct deletion keeps the lifecycle explicit and deterministic without
  adding new persistence or background cleanup paths.

Alternatives:
- Considered a token blacklist, but rejected it because it adds more
  state management for no practical gain in this flow.

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
- [ ] Body uses labeled sections with bullet points
- [ ] Body includes `Problem:`, `Change:`, and `Rationale:`
- [ ] Body explains what changed and why
- [ ] Body includes rationale for the approach
- [ ] `Alternatives:` is included when trade-offs matter
- [ ] Footer includes co-author signatures
- [ ] Commit is atomic (single logical change)
