# Term Translation Research Reference

Use this reference when a task requires a final term recommendation, a
comparison of candidate translations, or a decision about established usage.

## Source Hierarchy

Use the highest available source layer for the target audience. Do not let weak
general usage override strong domain or industry evidence.

| Tier | Source type | Use for |
|---|---|---|
| 0 | User-provided internal glossary, product UI, code, Notion, design files, or brand docs | Domain-specific terms and product constraints |
| 1 | Standards bodies and official terminology databases | Cross-organization industry terms |
| 2 | Government ministries, international organizations, and public agencies | Public-sector or regulated-domain usage |
| 3 | Professional associations, academic glossaries, textbooks, and peer-reviewed literature | Discipline-specific educational or professional usage |
| 4 | Product-maintained terminology portals and vendor localization glossaries | Platform, software, and product ecosystem terms |
| 5 | General dictionaries, style guides, and public-facing explainers | General-audience clarity |
| 6 | Blogs, media, forums, search-result frequency, and generated summaries | Weak supporting evidence only |

Examples of high-authority terminology sources:

- ISO 704: terminology work principles and methods.
- IATE: multilingual terminology database for EU institutions and bodies.
- WIPO Pearl: validated multilingual scientific and technical terminology.
- Microsoft Terminology: Microsoft product and IT localization terminology.
- TBX / ISO 30042: terminology database exchange model.
- UNESCO, OECD, national ministries, and official curriculum glossaries for
  education terms.
- MDN, W3C, WHATWG, official API docs, or Context7-backed library docs for web
  and software terms.

## Candidate Statuses

Use exactly one primary status for each candidate.

| Status | Meaning | Required evidence |
|---|---|---|
| `established` | A stable term in the relevant community | Tier 1-3 source, or multiple independent high-authority sources, with concept match |
| `preferred` | Best choice for the target context, but not fully settled | Strong source fit or product/context rationale with caveats |
| `acceptable` | Understandable and unlikely to mislead, but weak as a fixed term | Concept fit plus no major collision, with limited authority |
| `descriptive` | Useful as an explanation for general readers, not a technical term | Clear audience benefit, usually paired with an established term |
| `avoid` | Misleading, colliding, obsolete, or too broad/narrow | Evidence of conflict, semantic drift, or audience confusion |
| `unverified` | Not enough evidence to recommend | Missing source, stale source, or unresolved concept ambiguity |

Confidence is separate from status:

- `high`: current, authoritative, and concept-matched evidence.
- `medium`: good evidence with limited scope or unresolved caveats.
- `low`: evidence exists but is weak, dated, indirect, or audience-specific.

## Evidence Fields

Track these fields while researching:

| Field | Values or notes |
|---|---|
| `source_term` | Original term or phrase |
| `candidate_term` | Proposed translation or label |
| `language_pair` | Example: `ja-en`, `en-ja` |
| `concept_definition` | One sentence defining the concept, not the wording |
| `usage_layer` | `domain-specific`, `industry`, `general` |
| `audience` | Internal, teacher, developer, policymaker, student, general user, etc. |
| `status` | One candidate status from the finite list |
| `confidence` | `high`, `medium`, or `low` |
| `sources` | URLs, internal locators, file paths, page titles, dates |
| `evidence_notes` | Why the source supports or weakens the candidate |
| `collision_risk` | Existing acronym, product label, legal term, UI conflict, etc. |
| `decision` | Recommend, use with caveat, explain only, or reject |

## Search Patterns

Start narrow, then widen.

| Goal | Query pattern |
|---|---|
| Official term | `"candidate term" glossary site:official-domain` |
| Cross-language term | `"source term" "candidate term" terminology` |
| Education/public policy | `site:mext.go.jp`, `site:oecd.org`, `site:unesco.org`, official ministry domains |
| Software/web term | MDN, W3C, WHATWG, official product docs, Context7-backed library docs |
| Product localization | Microsoft Terminology, Apple style guides, platform glossaries, official vendor docs |
| Collision check | `"candidate term" acronym`, `"candidate term" glossary`, product/repo search |

For connected workspace sources, search internal pages before public web when
the user links or names a relevant internal source.

## Red Flags

Mark a candidate `avoid` or `unverified` when:

- The term matches a different established concept.
- The term is a literal translation with no evidence of adoption.
- A general word is being treated as a discipline term without support.
- An acronym collides with an existing product, feature, or industry acronym.
- Sources use similar words but define a different concept.
- Evidence comes only from machine translation, SEO pages, or generated text.
- The source is stale and the domain is known to change quickly.

## Output Templates

### Compact Recommendation

```markdown
**Decision**
Use `<term>` for `<audience/context>`. Status: `<status>`, confidence:
`<confidence>`.

**Why**
<short rationale with citations>

**Use By Audience**
| Audience | Recommended wording | Status | Notes |
|---|---|---|---|

**Local Fixes**
- <immediate wording or collision-resolution action>

**Fundamental Solutions**
- <glossary, termbase, naming policy, or review workflow>
```

### Evidence Matrix

```markdown
| Candidate | Layer | Status | Confidence | Evidence | Risk |
|---|---|---|---|---|---|
```

## Termbase Recommendation

For recurring terminology decisions, recommend a lightweight termbase with:

- `concept_id`
- `source_term`
- `approved_term`
- `language`
- `usage_layer`
- `audience`
- `status`
- `do_not_use`
- `definition`
- `source_links`
- `owner`
- `last_reviewed`

For interchange with localization or translation systems, mention TBX only as a
fundamental option when the organization needs structured terminology exchange.
