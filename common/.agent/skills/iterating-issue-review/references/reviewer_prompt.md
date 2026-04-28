# Reviewer Prompt Template

The helper script substitutes the `{{placeholders}}` below and sends the
result to the reviewer CLI as the prompt argument.

Placeholders:

- `{{repo}}` — `owner/name`
- `{{issue}}` — issue number
- `{{round}}` — 1-based round counter
- `{{current_body}}` — the issue body at the start of the round
- `{{prior_feedback}}` — the prior-batch final messages. On the very
  first batch this is `(no prior round)`. Otherwise `run_batch.sh`
  pre-composes a file concatenating every `final.md` from the
  previous batch's rounds, each section preceded by a
  `### From: round-<n>` header, and hands the same file to every
  worker in the current batch. Reviewers should treat the headers
  as attribution only and avoid repeating advice that was already
  acted on.

The template is intentionally plain text (not Markdown-heavy) so that
the reviewer model does not over-interpret formatting.

---BEGIN-TEMPLATE---
You are reviewing a GitHub issue that documents an execution plan.

Repository: {{repo}}
Issue: #{{issue}} (round {{round}})

Your task is to identify gaps, ambiguities, or errors in the current
issue body that should be addressed before implementation begins.

Rules:

1. For each finding, end the item with exactly one severity tag on a
   line by itself or at the end of the item:
     [BLOCKER]     - must be fixed before proceeding
     [IMPORTANT]   - should be fixed; may be discussed
     [SUGGESTION]  - improvement, not required
     [NIT]         - trivial style or phrasing
     [QUESTION]    - clarification needed

2. Classify each finding as one of:
     local       - symptomatic fix; resolves the surface issue only
     fundamental - root-cause fix; resolves the underlying problem
   State the classification on the line following the finding, e.g.
   "Classification: fundamental".

3. For deterministic fixes (one obvious edit with no alternatives),
   state the exact replacement text or the exact section to add.

4. For choices (two or more viable directions), enumerate the options
   rather than picking silently.

5. Do not repeat advice from prior rounds unless the prior advice was
   not applied.

6. If you have no findings tagged [BLOCKER], [IMPORTANT], or [QUESTION],
   end your response with a final line whose contents are exactly:
     [CONVERGED]

7. Respond in the primary language used in the issue body.

Current issue body:

{{current_body}}

Prior-round feedback:

{{prior_feedback}}
---END-TEMPLATE---
