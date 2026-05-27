# Reference

## Official Commit Message Recommendations

Git does not define a single mandatory commit message template for every
repository. However, Git's official documentation and the `git.git`
contribution guides consistently recommend a small set of conventions.

### Git-wide baseline

#### Start with one short title line

Git's `git-commit` manual recommends beginning the message with a single
short line that summarizes the change.

- 50 characters is the soft limit
- Git treats this first line as the commit title
- `git format-patch` uses that title as the email subject

Source:
- [`Documentation/git-commit.adoc`](https://github.com/git/git/blob/master/Documentation/git-commit.adoc)
  `DISCUSSION`
- [`Documentation/user-manual.adoc`](https://github.com/git/git/blob/master/Documentation/user-manual.adoc)
  guidance on creating good commit messages

#### Separate title and body with a blank line

Git officially recommends a blank line between the short title and the
detailed body.

Source:
- [`Documentation/git-commit.adoc`](https://github.com/git/git/blob/master/Documentation/git-commit.adoc)
  `DISCUSSION`
- [`Documentation/user-manual.adoc`](https://github.com/git/git/blob/master/Documentation/user-manual.adoc)

#### Use the body for non-obvious detail

Git's documentation treats the body as the place for fuller
explanation. The contribution docs make the intent more explicit: the
body should explain motivation and justification, not merely restate the
diff.

Source:
- [`Documentation/git-commit.adoc`](https://github.com/git/git/blob/master/Documentation/git-commit.adoc)
  `DISCUSSION`
- [`Documentation/SubmittingPatches`](https://github.com/git/git/blob/master/Documentation/SubmittingPatches)
  `Describe your changes well`

### Additional `git.git` conventions

These are official Git sources, but they describe conventions for
contributing to the Git project itself, not universal requirements for
all repositories.

#### Prefer `area: subject`

`git.git` conventionally prefixes the title with an area identifier such
as a filename or subsystem name.

Examples used by Git:

- `doc: clarify distinction between sign-off and pgp-signing`
- `githooks.txt: improve the intro section`

Source:
- [`Documentation/SubmittingPatches`](https://github.com/git/git/blob/master/Documentation/SubmittingPatches)
  `Describe your changes well`

#### Omit the period at the end of the title

The Git contribution guide explicitly says the first line should skip
the full stop.

Source:
- [`Documentation/SubmittingPatches`](https://github.com/git/git/blob/master/Documentation/SubmittingPatches)
  `Describe your changes well`

#### Use imperative mood

Git explicitly recommends writing the title and explanation in
imperative mood, as if instructing the codebase.

Examples from Git:

- `make xyzzy do frotz`
- not `makes xyzzy do frotz`
- not `changed xyzzy to do frotz`

Source:
- [`Documentation/SubmittingPatches`](https://github.com/git/git/blob/master/Documentation/SubmittingPatches)
  `Describe your changes well`
- [`Documentation/MyFirstContribution.adoc`](https://github.com/git/git/blob/master/Documentation/MyFirstContribution.adoc)
  sample commit message explanation

#### Explain the "why"

Git's contribution guide says the log message is as important as the
code and should help future maintainers understand why the code does
what it does.

The guide explicitly calls out these useful body elements:

- explain the current problem
- justify why the chosen result is better
- mention discarded alternatives when relevant

Source:
- [`Documentation/SubmittingPatches`](https://github.com/git/git/blob/master/Documentation/SubmittingPatches)
  `Describe your changes well`

#### Describe the current problem in present tense

When explaining the status quo, Git recommends present tense.

Example guidance from Git:

- write `The code does X when it is given input Y`
- not `The code used to do X`

Source:
- [`Documentation/SubmittingPatches`](https://github.com/git/git/blob/master/Documentation/SubmittingPatches)
  `Describe your changes well`

#### Wrap body text at about 72 columns

`MyFirstContribution` explicitly explains its sample message as being
formatted to 72 columns per line.

Source:
- [`Documentation/MyFirstContribution.adoc`](https://github.com/git/git/blob/master/Documentation/MyFirstContribution.adoc)
  explanation after the sample message

### Non-requirements in the official Git baseline

The official Git documentation reviewed here does not require:

- a fixed `<type>(<scope>): <subject>` schema
- mandatory labeled sections such as `Problem:`, `Change:`,
  `Rationale:`, or `Alternatives:`
- bullet-list bodies

These may be repository-local conventions, but they are not the
official Git baseline found in the cited documentation.

### Practical minimum template derived from the official guidance

```text
<short title, ideally <= 50 chars>

<body explaining why the change is needed, what problem exists, and why
this approach is preferable>
```

For `git.git` style specifically:

```text
<area>: <imperative subject without trailing period>

<wrapped body, typically around 72 columns, focused on motivation and
justification>
```

## Conventional Commits Reference

### Type conventions

The `<type>(<scope>): <subject>` shape used by this skill is compatible
with Conventional Commits, but the common type table often seen in team
guides should not be mistaken for the exact normative type set of the
specification.

According to the Conventional Commits 1.0.0 specification:

- commits must start with a `type`
- `feat` is the required type for a new feature
- `fix` is the required type for a bug fix
- `BREAKING CHANGE:` or `!` carries special semantic meaning
- types other than `feat` and `fix` may be used

This means types such as `docs`, `refactor`, `test`, and `chore` are
commonly used conventions, but they are not the full normative type set
defined by the specification itself.

Source:
- [Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/)
  summary and FAQ
- [Conventional Commits 1.0.0 beta specification](https://www.conventionalcommits.org/en/v1.0.0/-beta)
  normative rules using RFC 2119 language

## Primary References

- [`Documentation/git-commit.adoc`](https://github.com/git/git/blob/master/Documentation/git-commit.adoc)
- [`Documentation/user-manual.adoc`](https://github.com/git/git/blob/master/Documentation/user-manual.adoc)
- [`Documentation/SubmittingPatches`](https://github.com/git/git/blob/master/Documentation/SubmittingPatches)
- [`Documentation/MyFirstContribution.adoc`](https://github.com/git/git/blob/master/Documentation/MyFirstContribution.adoc)
- [Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/)
