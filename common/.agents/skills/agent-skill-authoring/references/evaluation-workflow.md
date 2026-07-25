# Evaluation Workflow

Concrete procedures for measuring whether a skill triggers correctly and whether
it improves output quality. These are standard-site recommendations, not
specification requirements.

Primary sources:

- [Optimizing skill descriptions](https://agentskills.io/skill-creation/optimizing-descriptions)
- [Evaluating skill output quality](https://agentskills.io/skill-creation/evaluating-skills)

Measure two things separately: whether the agent invokes the skill on the
prompts it should, and whether the output is better when it does. A skill that
triggers is not a skill that works.

## Trigger Evaluation

Tests the `description` field, which carries the entire burden of activation.

### Query set

Aim for about 20 labeled queries: 8-10 `should_trigger: true` and 8-10
`should_trigger: false`.

```json
[
  { "query": "I've got a spreadsheet in ~/data/q4_results.xlsx with revenue in col C - can you add a profit margin column?", "should_trigger": true },
  { "query": "whats the quickest way to convert this json file to yaml", "should_trigger": false }
]
```

- Vary phrasing (formal, casual, typos), explicitness (naming the domain vs
  describing the need), detail, and number of steps.
- The most useful positives are ones where the skill helps but the connection is
  not obvious from the query alone.
- The most valuable negatives are **near-misses** that share keywords or
  concepts but need something different. Obviously irrelevant queries test
  nothing.
- Include realistic context: file paths, personal framing, column names, typos.

### Measurement

Model behavior is nondeterministic. Run each query about 3 times and compute a
**trigger rate**. A positive query passes above a threshold (0.5 is a reasonable
default); a negative query passes below it.

### Avoiding overfitting

Split the query set and keep the split fixed across iterations:

- **Train (~60%)**: the only set used to identify failures and guide edits.
- **Validation (~40%)**: held out, used only to check that changes generalize.

Both sets need a proportional mix of positives and negatives.

Loop: evaluate on both sets, identify train-set failures, revise, repeat. Select
the iteration with the best **validation** pass rate. The best description is
often not the last one produced, because later iterations overfit to the train
set.

Revision guidance:

- Positives failing: the description is too narrow. Broaden the scope or add
  context about when the skill is useful.
- Negatives triggering: the description is too broad. Clarify the boundary
  against adjacent capabilities.
- Do not paste keywords from failed queries; that is overfitting. Address the
  general category those queries represent.
- If several incremental edits fail, try a structurally different framing.
- Re-check the 1024-character limit. Descriptions grow during optimization.

About five iterations is usually enough. If nothing improves, the queries may be
the problem rather than the description.

## Output-Quality Evaluation

### Test cases

Store in `evals/evals.json` inside the skill directory. A test case is a
realistic prompt, a human-readable description of success, and optional input
files.

```json
{
  "skill_name": "csv-analyzer",
  "evals": [
    {
      "id": 1,
      "prompt": "I have a CSV of monthly sales in data/sales_2025.csv. Find the top 3 months by revenue and make a bar chart.",
      "expected_output": "A bar chart image showing the top 3 months by revenue, with labeled axes and values.",
      "files": ["evals/files/sales_2025.csv"],
      "assertions": [
        "The output includes a bar chart image file",
        "The chart shows exactly 3 months",
        "Both axes are labeled"
      ]
    }
  ]
}
```

Start with 2-3 cases. Vary phrasing, cover at least one boundary condition, and
use realistic context. Write assertions **after** seeing the first round of
outputs; what "good" looks like is usually not knowable in advance.

### Baseline comparison

Run each case twice: once **with the skill** and once **without it**. When
improving an existing skill, snapshot the previous version and use that as the
baseline instead.

Every run must start with a clean context. Leftover context from authoring the
skill masks gaps in the written instructions. Use a subagent or a separate
session per run.

Workspace layout, one directory per iteration:

```text
csv-analyzer/
|-- SKILL.md
`-- evals/evals.json
csv-analyzer-workspace/
`-- iteration-1/
    |-- eval-top-months-chart/
    |   |-- with_skill/{outputs/,timing.json,grading.json}
    |   `-- without_skill/{outputs/,timing.json,grading.json}
    `-- benchmark.json
```

Only `evals/evals.json` is authored by hand; the rest is produced during the
run.

### Assertions and grading

Good assertions are programmatically or observably verifiable ("The output file
is valid JSON", "The report includes at least 3 recommendations"). Avoid vague
("the output is good") and brittle ("uses exactly the phrase ...") assertions.
Qualities like writing style or visual design are better caught in human review
than decomposed into pass/fail checks.

Grading records PASS/FAIL with evidence that quotes or references the actual
output. Require concrete evidence for a PASS; a section titled "Summary"
containing one vague sentence is a FAIL. Use scripts rather than LLM judgment
for mechanical checks.

### Cost and benefit

Record `total_tokens` and `duration_ms` per run, and aggregate per configuration
into `benchmark.json` with the delta between them:

```json
{
  "run_summary": {
    "with_skill":    { "pass_rate": {"mean": 0.83}, "tokens": {"mean": 3800} },
    "without_skill": { "pass_rate": {"mean": 0.33}, "tokens": {"mean": 2100} },
    "delta": { "pass_rate": 0.50, "time_seconds": 13.0, "tokens": 1700 }
  }
}
```

The delta is the acceptance signal: what the skill costs against what it buys. A
skill that adds 13 seconds for a 50-point pass-rate gain is worth it; one that
doubles token usage for a 2-point gain is not. Standard deviation is meaningful
only with multiple runs per case.

For version comparison, add a **blind A/B**: present both outputs to a judge
without revealing which version produced them. Two outputs can pass every
assertion and still differ in overall quality.

### Pattern analysis

- Remove assertions that pass in both configurations; they inflate the with-skill
  pass rate without reflecting skill value.
- Investigate assertions that fail in both; the assertion, the test case, or the
  target is probably wrong.
- Study assertions that pass with the skill and fail without, and understand
  which instruction or script made the difference.
- High variance across runs means either a flaky case or ambiguous instructions.
- Read the transcript behind any time or token outlier.

### Iteration

Three signals feed the next revision: failed assertions (specific gaps), human
feedback (broader quality issues), and execution transcripts (why things went
wrong). Ignored instructions are usually ambiguous ones; unproductive steps
usually trace to instructions that should be simplified or removed.

When proposing changes, require that they:

- **Generalize** beyond the test cases rather than patching specific examples.
- **Keep the skill lean.** Fewer, better instructions often outperform
  exhaustive rules. If transcripts show wasted work, remove the instructions
  causing it. If pass rates plateau while rules accumulate, the skill is likely
  over-constrained; delete instructions and check whether results hold.
- **Explain the why.** "Do X because Y tends to cause Z" is followed more
  reliably than "ALWAYS do X, NEVER do Y".
- **Bundle repeated work** into `scripts/` when runs keep reinventing it.

Stop when feedback is consistently empty or iterations stop producing measurable
improvement.

## Product Automation

Claude Code can automate this loop with the `skill-creator` plugin, which stores
cases in `evals/evals.json`, spawns an isolated subagent per case while
recording token count and duration, writes `grading.json`, aggregates
`benchmark.json` for with-skill versus without-skill, runs blind A/B version
comparison, and tunes descriptions against generated should-trigger and
should-not-trigger prompts. Treat the plugin as product tooling; the workflow
above is the portable procedure.
