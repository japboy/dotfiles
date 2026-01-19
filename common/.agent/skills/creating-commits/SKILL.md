---
name: creating-commits
description: >
  Create atomic Git commits with proper messages and co-author signatures.
  Use when the user asks to "commit my changes", "make a commit", "save my work",
  or mentions committing code changes. Focuses on commit message formatting,
  atomic commits, and maintaining consistent co-authorship attribution.
---

# Commit Workflow

## Entities

### Commit

An atomic snapshot of changes. Each commit should encapsulate a single logical change.

#### Co-author Signatures

Append the following block verbatim to all commit messages (do not modify):

```
🤖 Generated with [Claude Code](https://claude.ai/code) via [Zed](https://zed.dev/docs/ai/external-agents)

Co-Authored-By: Zed <noreply@zed.dev>
Co-Authored-By: GitHub Copilot <noreply@github.com>
Co-Authored-By: Claude Code <noreply@anthropic.com>
```

> **Note:** This is a fixed template, not an example. Copy exactly as shown.

See [Creating co-authored commits](https://docs.github.com/pull-requests/committing-changes-to-your-project/creating-and-editing-commits/creating-a-commit-with-multiple-authors#creating-co-authored-commits-on-the-command-line) for details.

## States

### Unstaged Changes

Modified files not yet added to staging area.

### Staged Changes

Changes ready to be committed. Review with `git diff --staged`.

### Committed Changes

Changes saved to local repository history.

## Actions

### Stage Changes

```bash
git add <files>
git diff --staged  # Review before committing
```

### Commit Changes

Evaluate after every change whether it is atomic and propose a commit to the user.

```bash
git commit
```

## Constraints

- Never commit directly to the main branch
- Always ask user confirmation before committing
- Always include co-author signatures in commit messages
- Make minimal, atomic commits (one logical change per commit)
- Use `git` command for Git operations
- Write commit messages that:
  - Describe what changed before and after the modification
  - Enable reviewers to understand the intent without reading code
  - State purpose and rationale in the body
  - Follow the format: `<type>(<scope>): <subject>` with body and footer

See [commit-message-guide.md](references/commit-message-guide.md) for detailed examples.
