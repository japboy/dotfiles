# Output Format — Binding Report Contract

Read this file before rendering any batch report. The fixed order is:

1. Mechanical header from `summarize_batch.sh`
2. One Findings table
3. Required per-finding sections
4. `Cross-round notes` only when a real pattern or conflict exists
5. User questions for every `Awaiting` row
6. `User decisions` after all answers, omitted when none were needed
7. Validation and persistence

Never paste a per-round `final.md` verbatim. Summarize findings and
link every source to its absolute `file://` path.

## Mechanical header

Run `scripts/summarize_batch.sh` and paste its stdout verbatim. Its
heading and bullets are authoritative, including the literal absolute
round-directory path. Do not hand-compose or abbreviate them.

## Findings table

Allocate stable cross-batch IDs with
`scripts/allocate_finding_numbers.sh`, then emit exactly one row per
finding with these columns in this order:

```markdown
## Findings

| # | Severity | Sources | Disposition | Summary |
|---|----------|---------|-------------|---------|
```

- `Severity`: `BLOCKER`, `IMPORTANT`, `QUESTION`, `SUGGESTION`, or
  `NIT`.
- `Sources`: every source as `[round-N](file:///<absolute-path>)
  <reviewer>`, sorted by round and separated by `<br>`.
- `Disposition`: `Auto-applied`, `Awaiting (Q<n>)`, or `Skipped`.
- `Summary`: one short line when a detail section follows. Otherwise
  include the defect, action or skip reason, and rationale in at most
  about 800 characters. Never copy reviewer prose verbatim.

## Required per-finding sections

| Severity | Disposition | Detail section |
|---|---|:-:|
| `BLOCKER` | any | Required |
| `IMPORTANT` | `Awaiting (Q<n>)` | Required |
| `IMPORTANT` | `Auto-applied` / `Skipped` | Omit |
| `QUESTION` | any | Required |
| `SUGGESTION` / `NIT` | any | Omit |

Each required section is `### Finding <#> — <SEVERITY>`, followed by
a `**Sources**:` bullet list, `**Disposition**:`, and explanatory
prose of at most 400 characters. Add a fenced block only when prose
cannot convey the fix. Sort sections by finding ID.

Before persistence, verify that the detail-section count equals
`BLOCKER + IMPORTANT/Awaiting + QUESTION` and every `Awaiting (Q<n>)`
maps one-to-one to a user question and decision entry.

## Cross-round notes

Add `## Cross-round notes` only for a substantive contradiction,
consensus, or pattern. Omit it otherwise.

## AskUserQuestion fields

When the orchestrator runs in Claude Code, batch every `Awaiting`
finding into AskUserQuestion calls — at most 4 questions per
invocation; issue multiple sequential calls when the batch has
more.

Per question:

- `header` — chip label shown in the UI. Keep ≤12 characters.
  Examples: `Migration`, `Auth flow`, `Schema v2`. Avoid trailing
  punctuation and reuse the same word the table's `Awaiting`
  cell references.
- `question` — single sentence ending with `?`. Restate the
  trade-off concisely; the user already saw the per-finding
  section, so do not repeat its prose verbatim.
- `options` — 2-4 mutually exclusive choices. Each option:
  - `label` — 1-5 words, no trailing punctuation.
  - `description` — one or two sentences explaining what choosing
    this option means in concrete terms (what edits to the body,
    what trade-off accepted).
  - `preview` (optional) — only when a code or text snippet helps
    the user compare options at a glance. Keep small; AskUserQuestion
    renders previews when an option is focused.
- `multiSelect` — `false` by default. Set `true` only when the
  user legitimately needs to combine options (rare for issue-body
  fixes; common for tag-style picks).

The "Other" option is auto-provided by the tool. Never add it
manually. Watch for free-text replies under "Other"; record them
faithfully in the User decisions log.

### Recommended option

When the orchestrator has a recommendation, place it as the first
option and append `(Recommended)` to its `label`. This is a tool
convention, not a guarantee — the user can still pick another
option.

## Question identifier mapping

The `Q<n>` strings in the Findings table's Disposition column,
the per-finding sections' Disposition lines, and the User
decisions log all share the same numbering. Number questions in
the order they appear in the table (i.e. by `#` ascending), not
in the order they are dispatched.

If a single AskUserQuestion call carries 3 questions, those become
`Q1`, `Q2`, `Q3`; a follow-up call's first question is `Q4`.
Numbers reset for each new batch.

## Codex fallback

The Codex CLI does not provide an AskUserQuestion equivalent, so
the structured selection UI is unavailable. **The user still picks
the option themselves**; only the presentation channel changes
(structured chip UI → inline Markdown options + free-text reply).
The orchestrator never resolves an `Awaiting` finding without an
explicit user answer.

When the orchestrator runs in Codex:

1. Skip the AskUserQuestion call.
2. Under each `Awaiting` finding's per-finding section, render a
   numbered list of options whose entries mirror the would-be
   AskUserQuestion options. Every `Awaiting` finding has a
   per-finding section under the current rules
   (`BLOCKER`+Awaiting / `IMPORTANT`+Awaiting / `QUESTION`+any),
   so there is always a section to attach the options to.

   ```markdown
   **Options for Q1**:

   1. <label> — <description>
   2. <label> — <description>
   ```

3. Wait for the user's free-text reply identifying the chosen
   option (by number or label).
4. Record the reply in the User decisions log using the same
   format Claude Code mode uses.

Do not invent a fake AskUserQuestion call to record the result;
the log line is the contract.

## User decisions log format

Each line records the resolution of one question. Format:

```markdown
- Q<n> (<header>): selected "<label>"[; reason: <one-line>]
```

Rules:

- The header in parentheses matches the AskUserQuestion `header`
  field (or the equivalent label in Codex fallback).
- The selected label is the `label` field, quoted verbatim.
  When the user picked "Other", write `selected "Other" → custom:
  <free-text>` instead.
- The optional `; reason: …` clause appears only when the user
  added notes via the AskUserQuestion `annotations` channel or
  provided rationale in their free-text reply.
- Lines appear in `Q<n>` order.

The User decisions section as a whole is omitted when the batch
has no `Awaiting` findings.

## Persistence

After all required user answers and issue-body edits are settled:

1. Write the complete report to
   `<round_root>/consolidated-for-batch-<K>.md`.
2. Write the revised issue body to
   `<round_root>/revised-body-for-batch-<K>.md`.
3. Push only that body with:

   ```bash
   gh issue edit <N> --repo <owner/name> \
     --body-file <round_root>/revised-body-for-batch-<K>.md
   ```

The persisted finding counter, consolidated report, revised body, and
per-round audit files together form the explicit batch state. Do not
persist or push until the section-count and question-mapping checks
above pass.
