---
name: creating-pull-requests
description: >
  Create Git branches, make atomic commits, push changes, and open pull requests.
  Use when the user asks to "create a PR", "open a pull request", "commit my changes",
  "push to remote", "submit code for review", "make a branch", or mentions
  git workflows like branching, committing, or code review submission.
---

# Pull Request Workflow

## Entities

### Branch

A separate line of development. Use type prefixes for clarity:
- `feature/<description>` - New features
- `fix/<description>` - Bug fixes
- `refactor/<description>` - Code refactoring
- `docs/<description>` - Documentation updates

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

### Pull Request

A request to merge changes from a feature branch into the main branch.

#### PR Body Signature

Append the following line verbatim to the end of all PR descriptions:

```
🤖 Generated with [Claude Code](https://claude.ai/code) via [Zed](https://zed.dev/docs/ai/external-agents)
```

> **Note:** This is a fixed template. Copy exactly as shown, as a blockquote (`>`) in the PR body.

## States

### Unstaged Changes

Modified files not yet added to staging area.

### Staged Changes

Changes ready to be committed. Review with `git diff --staged`.

### Committed Changes

Changes saved to local repository history.

### Pushed Changes

Commits pushed to remote repository.

### Open Pull Request

A PR awaiting review or merge.

## Actions

### Create Branch

```bash
git checkout <base-branch> && git pull origin <base-branch>
git checkout -b <type>/<description>
```

`<base-branch>` is the main branch (e.g., `main`, `master`) or a branch specified by the user.

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

### Push Changes

```bash
git push -u origin <branch-name>
```

### Create Pull Request

```bash
gh pr create --fill
```

Follow repository's PR template if available.

### Handle Merge Conflicts

1. Identify conflicting files with `git status`
2. Show conflict details to user
3. Ask user for resolution strategy
4. Resolve, stage, and continue

### Handle Push Rejection

1. Fetch latest: `git fetch origin <base-branch>`
2. Rebase: `git rebase origin/<base-branch>`
3. Resolve conflicts if any
4. Force push if rebased: `git push --force-with-lease`

## Constraints

- Never commit directly to the main branch
- Always ask user confirmation before committing
- Always include co-author signatures in commit messages
- Always include PR body signature at the end of PR descriptions
- Always follow repository's PR template when creating pull requests
- Make minimal, atomic commits (one logical change per commit)
- Use `git` command for Git operations
- Use `gh` command for GitHub operations
- Write commit messages that:
  - Describe what changed before and after the modification
  - Enable reviewers to understand the intent without reading code
  - State purpose and rationale in the body
  - Follow the format: `<type>(<scope>): <subject>` with body and footer

See [commit-message-guide.md](references/commit-message-guide.md) for detailed examples and [REFERENCE.md](references/REFERENCE.md) for command reference.
