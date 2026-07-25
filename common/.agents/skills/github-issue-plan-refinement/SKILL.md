---
name: github-issue-plan-refinement
description: >
  Iteratively refine a GitHub issue body that holds an execution plan by
  running one or more external review agents (Codex CLI or Claude Code
  CLI) against it, classifying the feedback by severity, applying
  deterministic fixes automatically, surfacing ambiguous choices to the
  user, and updating the issue body via `gh issue edit`. Each batch
  consumes `concurrency` consecutive round numbers; about 30% of the
  workers in a batch use a dissenting reviewer for model diversity.
  Each batch uses one explicit low, medium, or high reasoning-effort value. Use when
  the user asks to "iterate on issue #NNN", "refine the plan in
  #NNN", "run a review round on #NNN", "run N parallel reviews on
  #NNN", "loop reviewer feedback on #NNN", or wants to repeat
  reviewer rounds against a GitHub issue until no blockers remain.
compatibility: >
  Requires bash 3.2+, python3, gh, and at least one of `codex` /
  `claude` on PATH. `jq` is required when the `claude` reviewer is
  selected. Tested on macOS; Linux should work but is not exercised.
---

# GitHub Issue Plan Refinement

## Purpose

Raise the precision of a GitHub issue body that captures an execution
plan by repeatedly:

1. Sending the current body to one or more external review agents
2. Classifying each agent's findings by severity
3. Consolidating overlapping findings, applying deterministic fixes,
   surfacing ambiguous ones to the user
4. Replacing the issue body with the revised draft

The loop stops when **every round in the most recent batch** returns
the convergence signal and none of them leaves blocker / important /
question findings behind.

## Round and Batch Model

- A **round** is one reviewer pass. It produces one `final.md` and
  lives at `round-<N>/`. Round numbers are monotonically increasing.
- A **batch** is a set of rounds dispatched by a single invocation
  of [run_batch.sh](scripts/run_batch.sh). Batch size equals
  `--concurrency` (minimum 1). With `--concurrency 1` the batch
  carries a single reviewer; with N ≥ 2, about 30% of the workers
  use a dissenting reviewer (see Reviewer Distribution).
- A batch starting at `--round K` with `--concurrency N` consumes
  round numbers `K, K+1, ..., K+N-1`. The next invocation should
  pass `--round (K + N)`. One round is never reused by two workers.
- [run_review.sh](scripts/run_review.sh) is the per-round worker
  that `run_batch.sh` dispatches; direct invocation is supported
  only for debugging.
- Looping over batches is driven by the orchestrator (the primary
  agent in this session). Scripts never auto-advance batches.

This is the primary semantic of the skill. Concurrency multiplies
the rate at which round numbers advance, not the contents of a
single round.

## Inputs

Every batch invocation of `run_batch.sh` takes:

- `issue`: issue number, e.g. `42`
- `round`: the starting round number for the batch
- `main`: `codex` or `claude` — the primary reviewer
- `concurrency`: positive integer `N` (≥1)
- `effort` (optional): `low`, `medium`, or `high`; defaults to `high`
- `repo` (optional): `owner/name`; resolved from `gh repo view`
  when absent

## Reviewer Distribution

`run_batch.sh` computes the reviewer mix deterministically:

```text
others = 0                         when N == 1
others = max(1, round(N * 0.3))    when N >= 2
main   = N - others
```

The "other" reviewer is `claude` when `--main codex`, and vice versa.
Main slots take the **lower** round numbers (`K .. K + main - 1`);
other slots take the **upper** (`K + main .. K + N - 1`). The
dissenting reviewer sees the same prompt as the main — diversity
comes from the model change, not from prompt variation.

## Batch Workflow

```bash
scripts/run_batch.sh \
  --main <codex|claude> \
  --concurrency <N> \
  --issue <N> \
  --round <K> \
  [--effort <low|medium|high>] \
  [--repo <owner/name>]
```

Layout after the batch:

```text
<tmpdir>/github-issue-plan-refinement/<owner>-<repo>/issue-<N>/
├── prior-for-batch-<K>.md      (pre-computed prior feedback)
├── round-<K>/                  (main reviewer)
├── round-<K+1>/                (main reviewer, when N >= 2)
├── ...
├── round-<K + main - 1>/       (last main slot)
├── round-<K + main>/           (other reviewer, only when N >= 2)
└── round-<K + N - 1>/          (last other slot)
```

Each round directory contains:

```text
round-<n>/
├── current_body.md
├── prompt.md
├── raw.txt
├── final.md
├── reviewer        (name of the reviewer CLI used)
├── effort          (explicit reasoning-effort value)
└── dispatch.log    (worker's stdout/stderr captured during dispatch)
```

`run_batch.sh` emits one TSV line per round to stdout:

```text
<round>\t<reviewer>\t<round-dir>
```

The orchestrator iterates over those lines to read each `final.md`.

## Prior Feedback Handling

Before dispatch, `run_batch.sh` concatenates the previous batch's
`final.md` files into a single `prior-for-batch-<K>.md`:

- Source rounds: `max(1, K - concurrency)` through `K - 1`
- Each section is labeled `### From: round-<n>` so reviewers can tell
  perspectives apart
- Empty file when no prior rounds exist (round 1 of a fresh issue)

Every worker in the batch receives this same file via
`--prior-feedback-file`, which eliminates races on sibling outputs
and guarantees that all workers share the same prior context.

## Consolidation (End of Batch)

At the end of every batch the orchestrator consolidates findings
semantically: read each round's `final.md` in order, merge true
duplicates while keeping the highest severity, preserve unique
findings, then apply the decision protocol. Scripts never collapse
findings automatically.

The full procedure lives in
[convergence_criteria.md → Consolidation](references/convergence_criteria.md#consolidation-end-of-batch).

## Output Format

Before rendering any batch report, read
[output_format.md](references/output_format.md). It owns the binding
report contract: fixed section order, table columns, required detail
sections, question mapping, persistence paths, and validation rules.

Run the two bundled commands instead of reconstructing their state:

```bash
scripts/summarize_batch.sh \
  --issue <N> --round <K> --concurrency <C> [--repo <owner/name>]
scripts/allocate_finding_numbers.sh \
  --issue <N> --count <total-findings-in-this-batch> \
  [--repo <owner/name>]
```

Paste the header command's stdout verbatim. Use the allocator's
numbers in allocation order. Never paste reviewer outputs verbatim,
abbreviate absolute audit paths, invent an `Awaiting` decision, or
persist a report that fails the section-count and question-mapping
checks in `output_format.md`.

## Decision Protocol and Convergence

Each consolidated finding is handled by the decision protocol:
deterministic fixes apply to the draft body without prompting,
ambiguous choices and cross-round contradictions are surfaced to
the user, optional polish (`[SUGGESTION]` / `[NIT]`) is skipped
unless requested. The full table — including disagreement handling,
the in-doubt rule, and the cross-round contradiction clause — lives
in
[convergence_criteria.md → Decision Protocol](references/convergence_criteria.md#decision-protocol).

A batch converges only when every round in the batch emits a line
whose contents are exactly `[CONVERGED]` **and** no round leaves a
`[BLOCKER]`, `[IMPORTANT]`, or `[QUESTION]` tag behind, **and** no
ambiguity surfaced during consolidation is still pending a user
response. Never fabricate the signal. Full stop rule and edge
cases (partial convergence, contradictions, empty outputs, failed
rounds) live in
[convergence_criteria.md → Stop Rule](references/convergence_criteria.md#stop-rule)
and
[Edge Cases](references/convergence_criteria.md#edge-cases).

## State

Per-round and per-batch artifacts persist under the OS temp
directory at `<round_root> = <tmpdir>/github-issue-plan-refinement/<owner>-<repo>/issue-<N>/` so that:

- Each round is reproducible from its inputs
- Each batch's prior-feedback file, consolidated report, and revised
  body are archived alongside the rounds
- Post-hoc review of the iteration history is possible

Layout summary:

```text
<round_root>/
├── round-<n>/                              (one per reviewer pass)
│   ├── current_body.md
│   ├── prompt.md
│   ├── raw.txt
│   ├── final.md
│   ├── reviewer
│   └── dispatch.log                        (worker stdout/stderr)
├── prior-for-batch-<K>.md                  (input, written by orchestrator script)
├── consolidated-for-batch-<K>.md           (output, written by orchestrator)
├── revised-body-for-batch-<K>.md           (output, written by orchestrator)
└── finding-counter                         (cross-batch `#` allocator state)
```

The `scripts/` directory also contains `lib.sh`, a sourced helper
(not directly executable) that defines `iir_detect_tmpdir`,
`iir_round_root`, `iir_others_count`, and `iir_print_usage` for
the other scripts.

The helper scripts resolve the temp directory in this order:

1. `$TMPDIR` if set and existing (honored by macOS per-user temp dirs)
2. `getconf DARWIN_USER_TEMP_DIR` as a macOS fallback
3. `/tmp` only when neither of the above yields a usable directory

Never hardcode `/tmp` in callers.

## Reviewer CLIs

The scripts invoke every worker in a batch with the same explicit
`low`, `medium`, or `high` reasoning effort. `high` is the default;
choose another value deliberately and keep it fixed within the batch.

See [reviewer_cli_invocation.md](references/reviewer_cli_invocation.md)
for the exact flags, accepted-value tables, and diagnostic notes.

## Orchestration Loop

The orchestrator drives the loop:

1. Confirm issue number, `main`, `effort`, and `concurrency` with the user
   before the first batch.
2. Start at round `1`. Each batch is invoked once.
3. Run `run_batch.sh` for the current `--round` and
   `--concurrency`.
4. Consolidate findings per
   [convergence_criteria.md → Consolidation](references/convergence_criteria.md#consolidation-end-of-batch).
   Decide for each finding whether the disposition is
   `Auto-applied`, `Awaiting`, or `Skipped`.
5. Allocate finding numbers via
   `allocate_finding_numbers.sh --count <total-findings>`.
6. Render the report per the Output Format:
   1. Run `summarize_batch.sh` and capture its stdout (header).
   2. Append the Findings table.
   3. Append per-finding sections for `BLOCKER` / `IMPORTANT`.
   4. Append `Cross-round notes` only when needed.
   5. Display the report so far in chat.
   6. Issue AskUserQuestion calls for `Awaiting` findings (≤4 per
      call; multiple calls when more).
   7. After each set of answers, append to `User decisions`.
7. Apply auto-applied fixes and the user's selected options to
   the draft body.
8. Write the complete report to
   `<round_root>/consolidated-for-batch-<K>.md`, write the revised
   body to `<round_root>/revised-body-for-batch-<K>.md`, and push
   via `gh issue edit <N> --repo <owner/name>
    --body-file <round_root>/revised-body-for-batch-<K>.md`.
9. Check the convergence rule. If not converged, advance `--round`
   by `concurrency` and loop.

Do not collapse multiple batches into a single shell pipeline. Each
batch is a user-visible checkpoint.

## Cost and Rate Limits

Batches multiply reviewer cost by `concurrency`; the explicit `effort`
value also affects cost. `run_batch.sh` warns at `--concurrency > 5` but
does not enforce a hard cap.

See [cost_and_rate_limits.md](references/cost_and_rate_limits.md)
for the cost shape, rate-limit failure handling, disk usage, and
practical concurrency guidance.

## Constraints

- Always use `gh` for GitHub operations.
- Always pass reviewer selection via `--main` to `run_batch.sh`.
- Always pass one explicit reviewer effort to the batch and keep it
  unchanged for every round in that batch.
- Always render the per-batch report per the Output Format:
  `summarize_batch.sh` header (verbatim) + Findings table +
  per-finding sections for `BLOCKER` / `IMPORTANT` + AskUserQuestion
  for `Awaiting` rows + User decisions section.
- Always obtain the mechanical header by running
  `summarize_batch.sh` and pasting its stdout. Never hand-compose
  the header.
- Always render the `Round directory` bullet with the literal
  absolute path emitted by the script, in **both** the link label
  and the `file://` href. Substituting `round_root`,
  `<round_root>`, `...`, or any other placeholder is a violation
  even when the path is long; abbreviation breaks the audit anchor
  used by every Sources link.
- Always allocate the `#` column via
  `allocate_finding_numbers.sh` so numbers never repeat across
  batches.
- Always persist the complete report to
  `<round_root>/consolidated-for-batch-<K>.md` and the revised body
  to `<round_root>/revised-body-for-batch-<K>.md` before
  `gh issue edit`.
- Never paste a round's `final.md` verbatim into the report.
  Summarize in the table; the Source column links to the file.
- Always emit one per-finding section for **every** `BLOCKER` row,
  **every** `IMPORTANT` row whose Disposition is `Awaiting`, and
  **every** `QUESTION` row. Section count must equal
  `(BLOCKER count) + (IMPORTANT-Awaiting count) + (QUESTION count)`.
  Never collapse, merge, or skip a required section, regardless of
  how short the explanation feels or how much the table Summary
  already conveys.
- When a finding has no per-finding section
  (`IMPORTANT`+Auto-applied/Skipped, `SUGGESTION`, `NIT`), expand
  its `Summary` cell to about 2× a non-omitted section's prose
  length so the row alone carries the defect, the action taken or
  reason for skipping, and any non-obvious rationale.
- Always cap each per-finding section's prose at 400 characters;
  use a code block (excluded from the count) when the explanation
  needs concrete code.
- Omit `Cross-round notes` only when there is nothing to record.
- Never post feedback as an issue comment.
- Never auto-apply a fix when the reviewers disagree or present
  options.
- Never skip the user when a `[BLOCKER]` or `[IMPORTANT]` finding is
  ambiguous or contradicted.
- Never hardcode `/tmp`; rely on the helpers' temp-dir detection.
- Never declare convergence unless every round in the batch emitted
  `[CONVERGED]`.
- Never reuse a round number.

## References

- [reviewer_prompt.md](references/reviewer_prompt.md) — the prompt
  template (same prompt for every reviewer in a batch)
- [convergence_criteria.md](references/convergence_criteria.md) —
  canonical end-of-batch reference: severity tags, classification,
  consolidation, stop rule, decision protocol, edge cases
- [output_format.md](references/output_format.md) —
  AskUserQuestion field-level rules, Codex fallback, User
  decisions log line format
- [reviewer_cli_invocation.md](references/reviewer_cli_invocation.md)
  — exact flags and accepted-value tables for `codex` / `claude`
- [cost_and_rate_limits.md](references/cost_and_rate_limits.md) —
  per-batch cost shape, rate-limit handling, disk usage,
  concurrency guidance
