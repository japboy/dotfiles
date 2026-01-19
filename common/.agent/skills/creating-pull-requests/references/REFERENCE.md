# Pull Request Technical Reference

## Git Commands

### Branch Operations

| Command | Description |
|---------|-------------|
| `git checkout -b <branch>` | Create and switch to new branch |
| `git branch -d <branch>` | Delete local branch (safe) |
| `git branch -D <branch>` | Delete local branch (force) |
| `git push origin --delete <branch>` | Delete remote branch |

### Staging and Committing

| Command | Description |
|---------|-------------|
| `git add <files>` | Stage specific files |
| `git add -p` | Stage interactively (patch mode) |
| `git diff --staged` | Show staged changes |
| `git commit` | Commit with editor |
| `git commit -m "<message>"` | Commit with inline message |
| `git commit --amend` | Amend last commit |

### Remote Operations

| Command | Description |
|---------|-------------|
| `git push -u origin <branch>` | Push and set upstream |
| `git push --force-with-lease` | Safe force push |
| `git fetch origin` | Fetch from remote |
| `git pull --rebase origin <branch>` | Pull with rebase |

### Rebase and Merge

| Command | Description |
|---------|-------------|
| `git rebase <branch>` | Rebase onto branch |
| `git rebase -i HEAD~<n>` | Interactive rebase |
| `git rebase --continue` | Continue after conflict resolution |
| `git rebase --abort` | Abort rebase |
| `git merge --no-ff <branch>` | Merge with merge commit |

## GitHub CLI Commands

### Pull Request Operations

| Command | Description |
|---------|-------------|
| `gh pr create` | Create PR interactively |
| `gh pr create --fill` | Create PR with commit info |
| `gh pr create --draft` | Create draft PR |
| `gh pr list` | List open PRs |
| `gh pr view` | View current PR |
| `gh pr checkout <number>` | Checkout PR locally |
| `gh pr merge` | Merge PR interactively |

### Issue Operations

| Command | Description |
|---------|-------------|
| `gh issue list` | List open issues |
| `gh issue view <number>` | View issue details |
| `gh issue create` | Create new issue |

## Branch Naming Conventions

### Type Prefixes

| Prefix | Use Case | Example |
|--------|----------|---------|
| `feature/` | New functionality | `feature/user-auth` |
| `fix/` | Bug fixes | `fix/login-timeout` |
| `refactor/` | Code improvements | `refactor/api-client` |
| `docs/` | Documentation | `docs/api-reference` |
| `test/` | Test additions | `test/auth-coverage` |
| `chore/` | Maintenance | `chore/update-deps` |

### Naming Rules

- Use lowercase letters and hyphens
- Keep names concise but descriptive
- Include ticket number if applicable: `fix/PROJ-123-login-bug`

## Conflict Resolution

### Identify Conflicts

```bash
git status
# Shows files with conflicts marked as "both modified"
```

### Conflict Markers

```
<<<<<<< HEAD
Current branch content
=======
Incoming branch content
>>>>>>> feature-branch
```

### Resolution Steps

1. Open conflicted file
2. Decide which changes to keep
3. Remove conflict markers
4. Stage resolved file: `git add <file>`
5. Continue: `git rebase --continue` or `git merge --continue`

## Safety Practices

### Before Force Push

Always use `--force-with-lease` instead of `--force`:

```bash
# Safe: fails if remote has new commits
git push --force-with-lease

# Dangerous: overwrites remote unconditionally
git push --force  # Avoid
```

### Protecting Work

```bash
# Create backup branch before risky operations
git branch backup-<date>

# Stash uncommitted changes
git stash push -m "WIP: description"
```

## External References

- [Git Documentation](https://git-scm.com/doc)
- [GitHub CLI Manual](https://cli.github.com/manual/)
- [Pro Git Book](https://git-scm.com/book/en/v2)
