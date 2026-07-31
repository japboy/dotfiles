---
name: git-commit-creation
description: >
  Create authorized, atomic Git commits with repository-compliant messages and
  current-agent attribution. Use only when the user explicitly asks to create a
  commit or to commit already-scoped changes. Do not use for requests limited to
  staging, status inspection, commit planning, or drafting a message.
---

# Git Commit Creation

## Contract

Create one logical commit only after the target repository, branch, authorized
scope, staged diff, message policy, and current-agent signature are explicit.
Preserve unrelated staged and unstaged changes.

### Signature Source

Use exactly one signature source: the current runtime or product's supplied
agent attribution. Append that block once, verbatim, after other footers. Do not
copy an example signature, combine signatures from several products, attribute
tools that did not author the change, or invent an identity or email address.

This skill's house contract requires agent attribution. If the current runtime
supplies no identity, stop and request the missing identity before committing.

For ChatGPT (Codex), the product-supplied attribution is:

```text
Co-authored-by: Codex <noreply@openai.com>
```

Use this block only when the current runtime is ChatGPT (Codex).

GitHub recognizes a co-author trailer in this form when a runtime supplies one:

```text
Co-authored-by: Name <email@example.com>
```

The shape above is explanatory, not a fallback identity. See GitHub's
[co-authored commit documentation](https://docs.github.com/pull-requests/committing-changes-to-your-project/creating-and-editing-commits/creating-a-commit-with-multiple-authors#creating-co-authored-commits-on-the-command-line).

## States

- **Uninspected**: repository, branch, worktree, and index are unknown.
- **Blocked**: target is a protected main branch, authorization is absent, scope
  is ambiguous, or required attribution is unavailable.
- **Authorized**: the user's explicit request authorizes a commit with a finite
  file or hunk scope.
- **Staged**: the index contains exactly the authorized logical change plus any
  pre-existing staged changes the user explicitly included.
- **ExistingHead**: `HEAD` resolves; the next commit must have that OID as its
  single first parent.
- **UnbornHead**: `HEAD` does not resolve; the next commit must be a root commit
  with no parent.
- **Committed**: `HEAD` advanced by one commit and the committed paths and
  remaining worktree state were inspected.

Allowed transitions:

```text
Uninspected -> Blocked
Uninspected -> Authorized -> Staged -> ExistingHead -> Committed
Uninspected -> Authorized -> Staged -> UnbornHead -> Committed
```

Do not skip a state or continue from `Blocked` without new user authorization or
a changed repository state.

## Workflow

### 1. Inspect Without Mutation

Resolve the repository root and inspect branch, worktree, and index:

```bash
git rev-parse --show-toplevel
git branch --show-current
git status --short --branch
git diff
git diff --staged
```

Under this repository's house policy, stop on `main`, `master`, or another
repository-declared protected branch. Do not create or switch branches unless
the user authorized that separate action.

An explicit request such as "commit these changes" authorizes committing the
identified scope. If the agent proposed the commit without such a request, ask
for confirmation before staging or committing.

### 2. Establish the Staged Scope

Stage only the authorized paths or hunks, using explicit path arguments. Record
what was already staged before mutation so it is not silently absorbed into or
removed from the commit.

```bash
git add -- <authorized-paths>
git diff --staged --check
git diff --staged
```

The transition to `Staged` succeeds only when the staged diff is non-empty,
contains one logical change, and every staged path is authorized. If unrelated
pre-existing staged content cannot be separated without altering user work,
stop and ask the user how to scope the commit.

### 3. Select the Message Policy

Apply repository instructions first. This repository's house policy uses
Conventional Commit-style `<type>(<scope>): <subject>` titles and optional
labeled bullet sections. That shape is not a universal Git requirement.

Git's official baseline is narrower: a short title, a blank line before a body,
and a body for non-obvious motivation. The imperative title, no trailing period,
and roughly 72-column body are `git.git` contribution conventions. See
[REFERENCE.md](references/REFERENCE.md) for the official source-code references
and [commit-message-guide.md](references/commit-message-guide.md) for this
repository's house template.

### 4. Commit and Verify

First run `git rev-parse --verify HEAD`. Its exit status selects exactly one
branch:

- **ExistingHead**: capture the returned OID. After the commit,
  `git rev-parse HEAD^` must equal it.
- **UnbornHead**: record that no parent exists. After the commit,
  `git rev-list --parents -n 1 HEAD` must output exactly the new commit OID and
  no parent OID.

Commit with the selected message and current-agent signature, then inspect the
transition:

```bash
git commit
git show --stat --oneline --decorate --no-renames HEAD
git status --short --branch
```

The transition to `Committed` succeeds only when `HEAD` changed by exactly one
commit, the commit contains the authorized staged paths, the signature appears
once, and remaining changes are reported without modification.

## Repository House Message Policy

- Use one logical change per commit.
- Use `<type>(<scope>): <subject>`; omit scope when it adds no information.
- Use a concise imperative subject without a trailing period.
- When a body is needed:
  - Use concise labeled bullet sections
  - Prefer the section headers `Problem:`, `Change:`, and `Rationale:`
  - Add `Alternatives:` only when a rejected option or trade-off matters
  - Omit any section that would be empty or redundant
  - Avoid repeating the same point across multiple sections
  - Start each body entry with `- ` and keep each bullet concrete
  - Explain why the change exists without forcing a body for trivial commits

See [commit-message-guide.md](references/commit-message-guide.md) for detailed examples.
