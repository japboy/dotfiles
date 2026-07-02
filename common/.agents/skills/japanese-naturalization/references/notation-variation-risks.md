# Notation Variation Risks

Use this file when the target text has multiple plausible written forms for the
same or nearby expression: kanji/kana choices, okurigana, same-reading kanji,
katakana/English variants, punctuation, number style, full-width/half-width
forms, or repeated labels for the same concept.

These checks do not mean every variation is bad. Natural Japanese often uses
controlled variation for readability, rhythm, register, emphasis, or meaning.
The risk is variation that makes one concept look like several concepts, hides a
meaning distinction, breaks document-level predictability, or distracts the
reader.

## Canonical Baseline

When no project style guide, glossary, product UI, or publication rule overrides
it, treat official Japanese orthography references as the canonical baseline:

1. 常用漢字表, 現代仮名遣い, 送り仮名の付け方, 外来語の表記, and ローマ字のつづり方.
2. 公用文作成の考え方 for reader-oriented writing, punctuation, numbers,
   symbols, and document-level consistency.
3. 「異字同訓」の漢字の使い分け例 when same-reading kanji may change meaning.

These sources are guides and baselines, not automatic rewrite commands. They are
especially useful for public, educational, business, support, and formal writing.
Technical identifiers, quoted text, legal text, product names, UI labels, and
project glossaries can override them.

## Risk Registry

| Rule ID | Trigger | Natural or intentional variation | Confusing variation | Rewrite action | Evidence | Eval |
|---|---|---|---|---|---|---|
| same-concept-notation | The same concept appears with multiple written forms in one document or nearby section | Variation marks a real distinction, quote, UI label, or purposeful register shift | Same concept alternates without explanation, such as できる/出来る, こと/事, 問い合わせ/問合せ | Choose one local canonical form and apply it to the affected scope; do not rewrite unrelated sections. | bunka-national-standards, koyobun-consistency | notation-001 |
| meaning-bearing-kanji | Same-reading kanji can imply different meanings | Kanji choice distinguishes concepts, such as 計る/測る/量る or 変える/替える/換える/代える | A smoother-looking replacement changes the intended concept or makes it ambiguous | Define the concept first, then choose the matching kanji, kana form, or a clearer paraphrase. | iji-dokun | notation-002 |
| readability-kana | Kana or mixed notation is used where kanji would also be possible | Kana lightens dense prose, helps broad audiences, avoids overtechnical tone, or follows local style | Kana and kanji forms alternate so often that terms look unstable or searchability suffers | Preserve deliberate readability choices; normalize only repeated unmotivated alternation. | koyobun-reader, okurigana-reader | notation-003 |
| punctuation-number-width | Punctuation, number notation, unit notation, or full-width/half-width style varies | Variation follows quoted source text, code, UI labels, mathematical notation, or bilingual examples | Same document mixes punctuation systems, number width, month/place notation, or symbols without reason | Unify within the relevant document or section unless the source format requires the variation. | koyobun-consistency | notation-004 |
| term-vs-wording-variety | A repeated non-technical word or phrase varies for rhythm | Variation prevents monotonous prose while keeping reference obvious | A product term, role, feature name, or state label varies and may imply different concepts | Keep natural variety for ordinary prose, but stabilize labels that readers must track precisely. | koyobun-reader, project-or-domain-evidence |  |

## Decision Process

1. Identify the unit of consistency: sentence, paragraph, section, page,
   document, product UI, glossary, or repository.
2. Decide whether the variants refer to the same concept, different concepts, a
   quote/source form, or a UI/product label.
3. Check whether the variation is meaning-bearing. If the written form changes
   the concept, do not normalize mechanically.
4. Check whether the variation is reader-helpful. Kana, synonyms, or softer
   wording may be natural when they reduce density or fit the audience.
5. Check whether the variation is reader-costly. Normalize when it harms
   searchability, comparison, state tracking, or argument clarity.
6. Prefer the smallest affected scope that resolves confusion. Do not impose a
   document-wide rewrite when the issue is local.
7. When both forms are acceptable, choose deterministically from the target
   document's existing majority pattern, project style guide, or official
   baseline, in that order.

## Evidence Registry

| Evidence ID | Source | Supports |
|---|---|---|
| bunka-national-standards | https://www.bunka.go.jp/kokugo_nihongo/sisaku/joho/joho/kijun/naikaku/index.html | Culture Agency lists official Japanese notation standards as baselines for general social writing. |
| koyobun-reader | https://www.bunka.go.jp/seisaku/bunkashingikai/kokugo/hokoku/pdf/93651301_01.pdf | Public writing should adapt to document purpose, type, and expected readers while preserving source meaning. |
| koyobun-consistency | https://www.bunka.go.jp/seisaku/bunkashingikai/kokugo/hokoku/pdf/93651301_01.pdf | Public writing guidance calls for consistency in punctuation, full-width/half-width usage, symbols, and related notation choices within a document. |
| okurigana-reader | https://www.bunka.go.jp/seisaku/bunkashingikai/kokugo/hokoku/pdf/93651301_01.pdf | Reader-oriented public explanation may avoid omitting okurigana even where omission is otherwise allowed. |
| iji-dokun | https://www.bunka.go.jp/seisaku/bunkashingikai/kokugo/hokoku/pdf/ijidokun_140221.pdf | The Culture Council report gives examples for same-reading kanji choices and notes that some distinctions require careful handling. |
| project-or-domain-evidence | Local project docs, product UI, code, glossary, or domain-specific official sources | Use when notation is part of a product term, domain convention, or local reader expectation. |
