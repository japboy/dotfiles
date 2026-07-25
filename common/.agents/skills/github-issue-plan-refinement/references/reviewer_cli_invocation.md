# Reviewer CLI Invocation

How `run_review.sh` invokes each reviewer CLI. The skill accepts the
finite cross-client set `low`, `medium`, or `high`, defaults to `high`,
and records the selected value in each round. The binding rule lives in
[SKILL.md](../SKILL.md); this file documents the implementation
details.

## Codex

```bash
codex exec \
    -c 'model_reasoning_effort="<low|medium|high>"' \
    -o "<workdir>/final.md" \
    "<prompt>" \
    > "<workdir>/raw.txt" 2>&1
```

- `-c key=value`: TOML config override that wins over any
  `~/.codex/config.toml` setting.
- `model_reasoning_effort`: this skill deliberately uses the portable
  subset `low`, `medium`, or `high`.
- `-o` / `--output-last-message`: writes the final assistant message
  to the given file. The skill reads `final.md` from this path; the
  full transcript stays in `raw.txt`.

## Claude Code

```bash
claude -p \
    --effort "<low|medium|high>" \
    --output-format json \
    "<prompt>" \
    > "<workdir>/raw.txt" 2>&1
jq -r '.result // ""' "<workdir>/raw.txt" > "<workdir>/final.md"
```

- `--effort`: this skill deliberately uses `low`, `medium`, or `high`.
- `--output-format json`: emits a single JSON object whose `.result`
  field contains the final message.
- `jq -r '.result // ""'`: extracts the final message into
  `final.md`. Empty string fallback prevents `null` text from
  reaching the file.

## Diagnostics

Both modes capture full session output to `raw.txt`. Inspect this
file when:

- `final.md` is empty (run_review.sh exits 75)
- The reviewer reports an error
- A worker fails inside `run_batch.sh` (also see the
  per-round `dispatch.log`)

## Why make effort explicit

An explicit batch value prevents review configuration from drifting with
unrelated local CLI settings. Keeping one value across a batch also makes
rounds comparable without asserting that maximum effort is universally
optimal. See [cost_and_rate_limits.md](cost_and_rate_limits.md).
