---
name: pullrequest
description: Create Git branch, commit, push, and open a pull request. Use when a user needs to make code changes in a repository.
---

# Entities

- Commit
    - A saved snapshot of changes in a Git repository.
- Branch
    - A separate line of development in a Git repository.
- Pull request
    - A request to merge code changes from one branch to another in a Git repository.

# States

- Working changes to be committed
    - Code changes that are staged but not yet committed.
- Commits already made
    - Commits that have already been made.
- Working branch
    - The current branch where code changes are being made.
- Working pull request
    - The pull request being created to merge code changes.

# Actions

- Use `git` command for Git-related tasks.
- Use `gh` command for GitHub-related tasks.

## Commit granularity

- Always make a minimal commit that encapsulates an atomic change.
- After every change, evaluate whether it is atomic and decide whether to propose a commit to the user.

# Constraints

- Always ask the user for confirmation before committing changes.
- Always create pull requests following the repository's PR template.
- Never commit directly to the main branch.
