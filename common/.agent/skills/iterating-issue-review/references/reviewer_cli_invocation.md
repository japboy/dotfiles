# Reviewer CLI Invocation

How `run_review.sh` invokes each reviewer CLI. The skill always uses
the **maximum reasoning effort** the CLI supports; do not override
this per invocation. The binding rule lives in
[SKILL.md](../SKILL.md); this file documents the implementation
details.

## Codex

```bash
codex exec \
    -c 'model_reasoning_effort="xhigh"' \
    -o "<workdir>/final.md" \
    "<prompt>" \
    > "<workdir>/raw.txt" 2>&1
```

- `-c key=value`: TOML config override that wins over any
  `~/.codex/config.toml` setting.
- `model_reasoning_effort`: accepted values are
  `none, minimal, low, medium, high, xhigh`. `xhigh` is the maximum.
- `-o` / `--output-last-message`: writes the final assistant message
  to the given file. The skill reads `final.md` from this path; the
  full transcript stays in `raw.txt`.

## Claude Code

```bash
claude -p \
    --effort max \
    --output-format json \
    "<prompt>" \
    > "<workdir>/raw.txt" 2>&1
jq -r '.result // ""' "<workdir>/raw.txt" > "<workdir>/final.md"
```

- `--effort`: accepted values are `low, medium, high, max`. `max` is
  the maximum.
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

## Why fix the effort

Maximum reasoning effort is fixed by the skill so that review
quality does not drift with local config changes (for example, a
user lowering `model_reasoning_effort` in `~/.codex/config.toml`
for unrelated work). The trade-off is higher latency and cost per
round; see [cost_and_rate_limits.md](cost_and_rate_limits.md).
