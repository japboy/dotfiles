# References

## Agent Skills

- [Agent Skills Specification](https://agentskills.io/specification): portable
  skill structure, required frontmatter, validation rules, and progressive
  disclosure model.
- [Agent Skills specification source](https://github.com/agentskills/agentskills/blob/main/docs/specification.mdx):
  source for the public specification.
- [OpenAI Codex Agent Skills](https://developers.openai.com/codex/skills):
  Codex discovery of `.agents/skills`, local/user/admin/system skill locations,
  and Codex `agents/openai.yaml` metadata.

## SQLite

- [SQLite application file format](https://www.sqlite.org/appfileformat.html):
  rationale for using a SQLite database as a local application file.
- [SQLite FTS5](https://www.sqlite.org/fts5.html): full-text search virtual
  table module used by `memory_events_fts`.
- [SQLite JSON functions](https://www.sqlite.org/json1.html): `json_valid` and
  related JSON functions used for explicit metadata checks.
- [SQLite STRICT tables](https://www.sqlite.org/stricttables.html): rigid type
  enforcement used by the schema.
- [SQLite WAL](https://www.sqlite.org/wal.html): write-ahead logging behavior,
  reader/writer concurrency, and single-writer constraints.
- [FTS5 source](https://raw.githubusercontent.com/sqlite/sqlite/master/ext/fts5/fts5_main.c):
  SQLite source file for the FTS5 module.
- [JSON source](https://raw.githubusercontent.com/sqlite/sqlite/master/src/json.c):
  SQLite source file for JSON functions.
- [WAL source](https://raw.githubusercontent.com/sqlite/sqlite/master/src/wal.c):
  SQLite source file for write-ahead logging.

## Git

- [git-ls-files](https://git-scm.com/docs/git-ls-files): source of tracked file
  discovery for artifact indexing.
- [git-worktree](https://git-scm.com/docs/git-worktree): background for
  multiple worktrees sharing one repository.
- [gitattributes](https://git-scm.com/docs/gitattributes): binary file handling
  considerations when repository-local databases are committed or ignored.

## Validation Notes

This skill currently targets the portable Agent Skills baseline and does not
ship Codex-specific `agents/openai.yaml` metadata. If Codex UI metadata is added
later, keep it separate from portable runtime instructions because
`agents/openai.yaml` is a Codex extension, not part of the portable standard.
