# Convergence Criteria

Canonical reference for end-of-batch handling: severity tag
vocabulary, consolidation procedure, stop rule, decision protocol,
and edge cases. SKILL.md links into the subsections of this file
rather than restating their contents.

## Severity Tags

The reviewer tags each finding with exactly one of the following.
The orchestrator parses tags with a simple substring scan over
every `round-*/final.md` that belongs to the batch.

| Tag | Meaning | Blocks convergence? |
|---|---|:-:|
| `[BLOCKER]` | Must be fixed before proceeding. | Yes |
| `[IMPORTANT]` | Should be fixed; may be discussed. | Yes |
| `[QUESTION]` | Clarification needed from the author. | Yes |
| `[SUGGESTION]` | Improvement, not required. | No |
| `[NIT]` | Trivial style, phrasing, or typo. | No |

## Classification (local vs fundamental)

Each finding is also classified as:

- `local` — a symptomatic fix that repairs the surface issue but
  does not address the underlying cause
- `fundamental` — a root-cause fix

When both a local and a fundamental option exist, prefer the
fundamental one unless the user explicitly accepts the local fix.

## Consolidation (End of Batch)

After a batch (parallel or serial), consolidate findings
semantically. Scripts never collapse findings automatically; this
is the orchestrator's responsibility.

Steps:

1. Read every round's `final.md` in the batch, in round-number
   order.
2. Group findings that describe the same defect. Treat two findings
   as duplicates only when they point to the same span of the issue
   body and propose the same or clearly-equivalent change.
3. For a merged group, take the **highest** severity tag among its
   members (`BLOCKER` > `IMPORTANT` > `QUESTION` > `SUGGESTION` >
   `NIT`).
4. Preserve findings unique to a single round. They are evidence of
   the diversity the batch is meant to capture, not noise.
5. Apply the decision protocol below to the consolidated list.

## Stop Rule

A batch is converged when **all three** hold:

1. Every `final.md` of the batch's rounds contains a line whose
   contents are exactly `[CONVERGED]`.
2. No `final.md` in the batch contains any `[BLOCKER]`,
   `[IMPORTANT]`, or `[QUESTION]` tag.
3. No ambiguity surfaced during consolidation is still pending a
   user response.

Stop the loop only when a batch converges. Never fabricate
`[CONVERGED]`; if any round in the batch omits it, the batch has
not converged and another batch must run.

## Decision Protocol

Apply per consolidated finding. Never improvise outside this
table:

| Finding shape | Action |
|---|---|
| Deterministic fix — the reviewer specifies exactly what to change and the change has no meaningful alternatives | Apply to the draft body without prompting |
| Ambiguous choice — two or more viable directions, a design trade-off, a `[QUESTION]` tag, or contradictory advice across rounds in the batch | Present the options to the user and wait for direction |
| Disagreement — the orchestrator believes the reviewers are wrong | Surface both positions to the user and wait |
| `[SUGGESTION]` / `[NIT]` without a deterministic fix | Skip, unless the user has asked for optional polish |

When in doubt about whether a fix is deterministic, treat it as
ambiguous and ask. Do not guess.

Cross-round contradiction inside the same batch (two rounds
propose opposite changes) is **always** ambiguous, even if each
individual finding looks deterministic in isolation.

## Edge Cases

These cases extend the rules above. The rules above are
authoritative; this list only spells out behaviors for situations
they do not name explicitly.

- **Missing tag** — if a finding has no severity tag, treat it as
  `[IMPORTANT]` and surface it for confirmation.
- **Multiple tags on one finding** — use the highest-severity tag
  (`BLOCKER` > `IMPORTANT` > `QUESTION` > `SUGGESTION` > `NIT`).
- **`[CONVERGED]` alongside blockers** — the reviewer
  contradicted itself; treat as non-convergence and, if it
  recurs, surface the contradiction to the user.
- **Partial convergence in a batch** — some rounds emit
  `[CONVERGED]`, others do not. Not converged. Run another batch.
- **Empty `final.md`** — the reviewer produced no final message.
  Do not retry silently. Inspect `raw.txt` and `dispatch.log` and
  surface the failure.
- **All findings `[SUGGESTION]` / `[NIT]` but `[CONVERGED]`
  missing** — if any one round in the batch is still missing
  `[CONVERGED]`, the batch is not converged regardless of the
  other rounds' states. When every round in a batch returns only
  `[SUGGESTION]` / `[NIT]` items but the signal is absent, run
  one more batch with the same body; the reviewers may be
  withholding the signal while listing optional polish.
- **One round fails to execute** — the batch is inconclusive. Do
  not apply findings from the surviving rounds before re-running
  the failed round (or the whole batch with fresh round numbers).
  Surface the failure first.
- **Concurrency change between batches** — the prior-feedback
  file covers only the `concurrency` rounds immediately before
  the new `--round`. When the user increases or decreases
  concurrency between batches, earlier rounds may fall outside
  that window. This is acceptable; if coverage of older rounds is
  needed, the orchestrator can merge them manually into the
  prior-feedback file before dispatch.
