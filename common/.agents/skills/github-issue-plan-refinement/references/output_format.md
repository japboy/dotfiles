# Output Format — Interactive Sub-rules

Detailed sub-rules referenced by the SKILL.md "Output Format"
section. SKILL.md owns the binding shape (header → table →
per-finding sections → cross-round notes → AskUserQuestion → user
decisions → persistence). This file fills in the precise field
shapes for AskUserQuestion, the Codex fallback, and the User
decisions log line format.

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
