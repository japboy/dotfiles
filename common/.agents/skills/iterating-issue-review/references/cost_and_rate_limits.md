# Cost and Rate Limits

The skill optimizes for review quality, not for cost. This file
records the cost shape so the orchestrator can advise the user when
it matters.

## Cost shape

- One round = one reviewer CLI invocation at maximum reasoning
  effort.
- One batch = `concurrency` rounds, dispatched concurrently.
- Per-batch wall-clock is bounded by the slowest worker.
- Per-batch cost is roughly `concurrency * single-round-cost`. The
  reasoning effort is fixed at the maximum (`xhigh` for Codex,
  `max` for Claude), so per-round cost runs higher than a default
  invocation.

## Rate limit risk

A batch dispatches all workers near-simultaneously. With
`--concurrency` greater than the per-minute call quota of the
reviewer service, the back half of the batch can fail with a
rate-limit error. `run_batch.sh` emits a notice when
`--concurrency > 5` but does not enforce a hard cap. With
`--concurrency 1` the rate-limit risk is the same as a single
reviewer call.

When a rate-limit failure occurs:

1. The failed worker's `final.md` is empty; `dispatch.log` and
   `raw.txt` capture the error.
2. The orchestrator should surface the failure (do not consolidate
   on a partial batch).
3. Retry the failed round with the same round number after the
   rate limit clears, or re-run the whole batch with fresh round
   numbers.

## Disk usage

Round history grows linearly with rounds:

- Each round is a few KB to ~100 KB depending on issue size and
  reviewer verbosity.
- Each batch adds three batch-level files (`prior-for-batch-K.md`,
  `consolidated-for-batch-K.md`, `revised-body-for-batch-K.md`).

Periodic cleanup of old `<tmpdir>/iterating-issue-review/` subtrees
is fine. The OS temp directory may also be cleared by the system on
reboot or by macOS housekeeping; do not rely on artifacts surviving
across reboots when the audit trail matters.

## Practical guidance

- Start with `--concurrency 3` for moderately complex issues. The
  extra two reviewers usually surface enough diversity to be worth
  the cost.
- Only raise `--concurrency` past 5 when the issue has wide
  surface area (many sections, many stakeholders). Past 8 the cost
  rarely justifies the marginal diversity.
- When iterating tightens the issue body to near-convergence, drop
  back to `--concurrency 1` for the last serial round to confirm a
  clean `[CONVERGED]`.
