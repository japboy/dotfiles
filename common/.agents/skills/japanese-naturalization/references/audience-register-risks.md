# Audience Register Risks

Use this file when naturalizing casual or socially sensitive Japanese where the
same expression can land differently by audience, generation, hierarchy,
workplace norms, or identity context.

These entries are risk checks, not banned-word rules. The goal is to preserve
meaning while avoiding avoidable audience mismatch, age-marked casualness, or
wording that could be read as ridicule, exclusion, or harassment in the target
channel.

## Update Rules

Keep this file compact and evidence-backed:

1. Add or revise a row in the Risk Registry instead of creating phrase-specific
   narrative sections.
2. Keep each rule bounded to one risk pattern, one context, and one rewrite
   action.
3. Put source links or local evidence in the Evidence Registry and refer to them
   by ID.
4. Add an evaluation fixture in [evaluation-prompts.csv](evaluation-prompts.csv)
   when the rule changes rewrite behavior.
5. Do not infer a reader's actual age, gender, identity, or tolerance from a
   phrase alone. Use audience and channel evidence, or choose the safer neutral
   wording when evidence is missing.

## Risk Registry

| Rule ID | Trigger | Context | Prefer | Avoid or treat carefully | Rewrite action | Evidence | Eval |
|---|---|---|---|---|---|---|---|
| casual-aging | Internet slang, memes, abbreviations, or community shorthand such as TL;DR | Public docs, READMEs, workplace-broad channels, mixed-generation audiences | 要約, 概要, 先に要点, Summary, or the product's existing heading style | Preserving slang only because it feels casual or familiar | Replace with a neutral, widely understood label unless project evidence shows the audience expects the shorthand. | user-feedback-2026-07-02, bunka-keigo-diversity | register-002 |
| self-age-label | Self-deprecating age or generation labels | Workplace chat, review comments, team documentation | 古く見えるかもしれない, 世代感が出るかもしれない, 今の読み手に伝わりにくいかもしれない | 老害, おじさん構文, 昭和っぽい as unqualified labels | Preserve the concern, but avoid amplifying age-based ridicule or turning self-deprecation into a label for other people. | user-feedback-2026-07-02, mhlw-harassment-types | register-003 |
| identity-attribute-casualness | Jokes, compliments, criticism, or labels tied to age, gender, nationality, disability, family status, appearance, or similar attributes | Workplace, support, hiring, education, public documentation, or unknown audience | Task-relevant, neutral wording that describes behavior, content, or effect | Attribute-based jokes, stereotypes, unnecessary personal references | Remove added attribute framing unless it is part of the original meaning and necessary to preserve. If necessary, phrase it neutrally. | mhlw-harassment-types |  |
| hierarchy-overfamiliar | Very casual praise, teasing, nicknames, or imperative wording | Manager-to-member, reviewer-to-author, support-to-customer, teacher-to-learner | Respectful, specific wording about the work or next action | Teasing, pressure, mockery, or overly intimate tone | Keep warmth if intended, but make the relationship and channel safe for repeated workplace use. | bunka-keigo-diversity, mhlw-harassment-types |  |

## Decision Process

1. Identify the real audience: specific person, team, company-wide, external
   reader, learner, customer, or unknown.
2. Check whether the phrase is stable domain terminology, local team convention,
   or time-sensitive casual slang.
3. Check whether the wording refers to an attribute, identity, hierarchy, or
   private matter that is unnecessary for the message.
4. For mixed or unknown audiences, prefer neutral wording that preserves meaning
   without relying on a generation-specific or in-group reading.
5. When the original intentionally uses humor or self-deprecation, preserve the
   intent only if it remains safe in the target channel; otherwise preserve the
   underlying concern in neutral wording.
6. Do not call a phrase old, young, offensive, or harassing unless the user,
   project evidence, or a credible source supports that classification.

## Evidence Registry

| Evidence ID | Source | Supports |
|---|---|---|
| user-feedback-2026-07-02 | User-provided Slack thread about whether TL;DR in a README may feel generation-marked | Treat casual shorthand as audience-sensitive in workplace technical documentation. |
| bunka-keigo-diversity | https://www.bunka.go.jp/seisaku/bunkashingikai/kokugo/hokoku/pdf/keigo_tosin.pdf | The Agency for Cultural Affairs' keigo guideline notes that attitudes toward wording can vary by generation and sex, and that different perceptions may coexist. |
| mhlw-harassment-types | https://www.mhlw.go.jp/stf/seisakunitsuite/bunya/koyou_roudou/koyoukintou/seisaku06/index.html | MHLW lists workplace power-harassment patterns including insults, severe verbal abuse, isolation, and intrusion into private matters; wording should avoid avoidable ridicule or exclusion in workplace contexts. |
