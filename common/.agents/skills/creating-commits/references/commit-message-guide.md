# Commit Message Guide

## Structure

```
<type>(<scope>): <subject>

Problem:
- <optional: what is wrong with the current state>

Change:
- <optional: what this commit changes>

Rationale:
- <optional: why this result or approach is better>

Alternatives:
- <optional: rejected option or trade-off>

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

Write the body as concise labeled bullet lists when a body is needed:
- Prefer the section headers `Problem:`, `Change:`, and `Rationale:`
- Add `Alternatives:` only when trade-offs or rejected options matter
- Omit any section that would be empty or redundant
- Do not repeat the same point across multiple sections
- Start each bullet with `- `
- Keep each bullet focused on one concrete point
- Keep the whole body brief; do not expand obvious points just to fill sections
- Wrap at 72 characters per line when practical

### Footer

- Reference issues: `Fixes #123`, `Closes #456`
- Breaking changes: `BREAKING CHANGE: <description>`
- Co-author signatures: Append the fixed block from SKILL.md verbatim (required)

## Examples

### Good Example

```
fix(auth): prevent token from remaining valid after password reset

Problem:
- Reset tokens stay valid after a successful password reset.

Change:
- Delete the token immediately after a successful reset.

Rationale:
- This makes the recovery flow single-use and removes replay risk.

Alternatives:
- A blacklist would add state management without helping this flow.

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

```
fix(auth): prevent token reuse after password reset

Problem:
- Reset tokens stay valid after a successful password reset.

Change:
- Delete the token immediately after a successful reset.
- The recovery flow becomes single-use and removes replay risk.

Rationale:
- This makes the recovery flow single-use and removes replay risk.
```
- Repeats the same point in `Change:` and `Rationale:`
- Uses more words than necessary

## Checklist

Before committing, verify:

- [ ] Subject uses imperative mood
- [ ] Subject is under 50 characters
- [ ] Body is omitted if the subject is sufficient
- [ ] If present, body uses concise labeled sections with bullet points
- [ ] Empty or redundant sections are removed
- [ ] Points are not repeated across sections
- [ ] `Alternatives:` is included only when trade-offs matter
- [ ] Footer includes co-author signatures
- [ ] Commit is atomic (single logical change)
