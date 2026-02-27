# Reference: Reverse Engineering Design Systems

## 1. Official reference baseline

Use these references as authoritative inputs for structure and API contracts.

- Adobe Spectrum structure references
  - https://spectrum.adobe.com/page/principles/
  - https://spectrum.adobe.com/page/design-tokens/
  - https://spectrum.adobe.com/page/platform-scale/
  - https://spectrum.adobe.com/page/theming/
  - https://spectrum.adobe.com/page/color-fundamentals/
  - https://spectrum.adobe.com/page/color-system/
  - https://spectrum.adobe.com/page/using-color/
  - https://spectrum.adobe.com/page/typography/
  - https://spectrum.adobe.com/page/object-styles/
  - https://spectrum.adobe.com/page/motion/
  - https://spectrum.adobe.com/page/states/
  - https://spectrum.adobe.com/page/iconography/
  - https://spectrum.adobe.com/page/illustration/
  - https://spectrum.adobe.com/page/inclusive-design/
  - https://spectrum.adobe.com/page/international-design/
  - https://spectrum.adobe.com/page/bi-directionality/
  - https://spectrum.adobe.com/page/data-visualization-fundamentals/
  - https://spectrum.adobe.com/page/color-for-data-visualization/
  - https://spectrum.adobe.com/page/voice-and-tone/
  - https://spectrum.adobe.com/page/grammar-and-mechanics/
  - https://spectrum.adobe.com/page/inclusive-ux-writing/
  - https://spectrum.adobe.com/page/writing-about-people/
  - https://spectrum.adobe.com/page/writing-for-readability/
  - https://spectrum.adobe.com/page/writing-with-visuals/
  - https://spectrum.adobe.com/page/in-product-word-list/
  - https://spectrum.adobe.com/page/writing-for-errors/
  - https://spectrum.adobe.com/page/writing-for-onboarding/
- Design and knowledge API references
  - https://www.figma.com/developers/api
  - https://developers.notion.com/reference/intro
- Layout abstraction references
  - Material Design 2 layout grid: https://m2.material.io/design/layout/responsive-layout-grid.html#columns-gutters-and-margins
  - Material Design 3 understanding layout overview: https://m3.material.io/foundations/layout/understanding-layout/overview
  - Android canonical layouts: https://developer.android.com/design/ui/mobile/guides/layout-and-content/canonical-layouts
  - Material Components Web layout grid source: https://github.com/material-components/material-components-web/tree/master/packages/mdc-layout-grid
  - Material Components Web layout grid README: https://raw.githubusercontent.com/material-components/material-components-web/master/packages/mdc-layout-grid/README.md

Identifier contracts derived from official APIs:
- Figma `GET /v1/files/{file_key}/nodes` requires `file_key` in path and node IDs in `ids` query, where node IDs are `1:5` style identifiers.
- Notion `GET /v1/pages/{page_id}` requires `page_id` as UUID-compatible identifier.

Policy:
- Treat Spectrum as structure taxonomy only.
- Treat project evidence (code/design/knowledge) as content authority.

## 2. Source collection contract

Required input columns for `source-registry.csv`:

- `source_type`: `code | figma | notion | doc | api | other`
- `source_locator`: URL/path/identifier
- `source_section`: logical section path or component scope
- `evidence_level`: `official | l1 | l2 | na`
- `priority`: `high | medium | low`
- `notes`: free text

Optional columns:

- `owner`
- `collected_at`
- `project_id`

Quality gates before extraction:

- No missing `source_type`.
- No missing `source_locator`.
- Unsupported `source_type` rows must be tagged `invalid`.
- Duplicate canonical keys must be logged and retained in duplicate audit output.

## 3. Normalization rules

Use deterministic canonicalization by `source_type`.

### 3.1 Figma

Input:
- URL containing `file_key` and `node-id`

Normalization:
- Parse `file_key` from `/design/<file_key>/...` or `/file/<file_key>/...`
- Parse `node-id` query value
- URL decode `node-id`
- Convert `<number>-<number>` to `<number>:<number>`
- Validate with `^[0-9]+:[0-9]+$`

Canonical key:
- `figma:<file_key>:<node_id>`

### 3.2 Code

Input:
- `path` or `path:line`

Normalization:
- Normalize slash direction to POSIX `/`
- Collapse `.` and `..` path segments
- Keep line as integer if present

Canonical key:
- `code:<path>:<line_or_0>`

### 3.3 Notion

Input:
- Page URL or page identifier

Normalization:
- Extract 32-hex page id from URL/id
- Normalize to lowercase, no separators for stable keying
- Keep fragment as section when available

Canonical key:
- `notion:<page_id>:<section_or_root>`

### 3.4 Generic URL (`doc`, `api`, `other` URL case)

Normalization:
- Lowercase scheme and host
- Drop fragment for canonical URL keying
- Sort query parameters

Canonical key:
- `url:<normalized_url>`

### 3.5 Row-level quality flags

Emit one of:
- `valid`
- `duplicate`
- `invalid`

Keep `invalid_reason` and `duplicate_of` references for auditability.

## 4. Fixed Adobe Spectrum structure

### 4.1 Foundation (14 fixed elements)

- `design_tokens`
- `platform_scale`
- `theming`
- `color`
- `typography`
- `object_styles`
- `motion`
- `states`
- `iconography`
- `illustration`
- `inclusive_design`
- `international_design`
- `bi_directionality`
- `data_visualization`

### 4.2 Content (6 fixed elements)

- `voice_and_tone`
- `grammar_and_mechanics`
- `language_and_inclusivity`
- `in_product_word_list`
- `writing_for_errors`
- `writing_for_onboarding`

`language_and_inclusivity` fixed subtopics:
- `inclusive_ux_writing`
- `writing_about_people`
- `writing_for_readability`
- `writing_with_visuals`

## 5. Core schemas

### 5.1 Foundation observation schema

Mandatory columns:

- `foundation_element`
- `subtopic`
- `evidence_source`
- `evidence_ref`
- `state`
- `platform`
- `theme`
- `locale`
- `direction`
- `structure_fit`
- `content_validity`

Conditional mandatory by source:

- For `code`/`figma`: `file_key`, `node_id`, `source_url`, `batch_id`
- For `notion_l1`/`notion_l2`: `notion_page_url`, `section_path`, `notion_last_edited_time`, `evidence_level`

### 5.2 Content observation schema

Mandatory columns:

- `content_element`
- `content_subtopic`
- `evidence_source`
- `evidence_ref`
- `text_source_type`
- `text_value`
- `state`
- `audience`
- `structure_fit`
- `content_validity`

Element-specific required examples:

- `voice_and_tone`: `tone_label`
- `grammar_and_mechanics`: `grammar_rule_type`, `grammar_rule_evidence`
- `in_product_word_list`: `term`, `canonical_term`, `term_status`
- `writing_for_errors`: `error_trigger`, `user_impact`, `recovery_action`, `cta_label`
- `writing_for_onboarding`: `onboarding_goal`, `step_order_rule`, `completion_signal`

### 5.3 Layout abstraction schemas (Grid System x Canonical Layout)

`layout-grid-observations.csv` mandatory columns:
- `viewport_bucket`
- `columns`
- `gutter`
- `margin`
- `container_max_width`
- `evidence_ref`

`layout-grid-rules.csv` mandatory columns:
- `grid_rule_set_id`
- `viewport_bucket`
- `columns`
- `gutter`
- `margin`
- `container_max_width`
- `rule_status`

Rule gate:
- Every approved grid rule must have at least one `code` evidence and one `figma` evidence.
- Single-source rules must remain `pending`.

`canonical-layout-rules.csv` mandatory columns:
- `layout_id`
- `primary_regions`
- `pane_count`
- `navigation_mode`
- `transition_rule`
- `grid_rule_set_id`

`layout-abstraction-validation.csv` mandatory columns:
- `screen_or_flow`
- `layout_diff`
- `conflict_type`
- `resolve_action`

Validation gate:
- For every diff row, require either `conflict_type` (`layout_mismatch` or `canonical_mismatch`) or `resolve_action`.
- If residual diff remains after validation, require `exception_reason` or `rule_set_split`.

## 6. State machines

Evidence lifecycle:
- `S0 Candidate`
- `S1 Extracted`
- `S2 Structured`
- `S3a StructureValidated`
- `S3b ContentValidated`
- `S4 Approved`

Batch lifecycle (for large design-source extraction):
- `B0 Queued`
- `B1 Running`
- `B2 Succeeded`
- `B3 FailedRetryable`
- `B4 FailedTerminal`
- `B5 DeferredByRateLimit`

Content-style lifecycle:
- `CT0 RawExtracted`
- `CT1 Normalized`
- `CT2 Annotated`
- `CT3 Structured`
- `CT4 CrossSourceValidated`
- `CT5 Adopted`

Layout abstraction lifecycle:
- `LA0 RawObserved`
- `LA1 GridMeasured`
- `LA2 CanonicalHypothesized`
- `LA3 Linked`
- `LA4 Validated`
- `LA5 Adopted`

## 7. Deterministic merge keys

Foundation:
- `identity_key = source_identity + ':' + subtopic + ':' + state + ':' + theme + ':' + locale + ':' + direction`
- `merge_key = foundation_element + ':' + subtopic + ':' + state + ':' + platform + ':' + theme + ':' + locale + ':' + direction`

Content:
- `identity_key = source_identity + ':' + text_key + ':' + state + ':' + text_difficulty + ':' + auto_setting`
- `merge_key = content_element + ':' + content_subtopic + ':' + state + ':' + audience + ':' + text_difficulty + ':' + auto_setting`

`source_identity`:
- For `code`/`figma`: `file_key + ':' + node_id`
- For `notion`: `notion_page_url + ':' + section_path`

## 8. Output package contract

Minimum required outputs:

- `design-system/principles.md`
- `design-system/foundation.md`
- `design-system/content.md`
- `design-system-inventory/gap-register.md`
- `design-system-inventory/decision-log.md`
- `design-system-inventory/principles-conflicts.csv`
- `design-system-inventory/layout-grid-observations.csv`
- `design-system-inventory/layout-grid-rules.csv`
- `design-system-inventory/canonical-layout-observations.csv`
- `design-system-inventory/canonical-layout-rules.csv`
- `design-system-inventory/layout-abstraction-validation.csv`
- `design-system-inventory/layout-abstraction-rulebook.md`

## 9. Definition of done

Structure validated:
- Every fixed Foundation element has evidence or explicit non-applicable reason.
- Every fixed Content element has evidence or explicit non-applicable reason.
- No unknown taxonomy values remain in approved rows.

Content validated:
- Approved rules are supported by at least two evidence sources when available.
- Secondary evidence alone never approves a rule.
- All conflicts have `resolve_action`.

Layout abstraction validated:
- Every `layout-grid-observations.csv` row includes `viewport_bucket`, `columns`, `gutter`, `margin`, `container_max_width`, and `evidence_ref`.
- Every `layout-grid-rules.csv` approved rule has both `code` and `figma` evidence.
- Every `canonical-layout-rules.csv` row includes `layout_id`, `primary_regions`, `pane_count`, `navigation_mode`, `transition_rule`, and `grid_rule_set_id`.
- Every `layout-abstraction-validation.csv` diff row includes `conflict_type` (`layout_mismatch` or `canonical_mismatch`) or `resolve_action`.

Governance:
- Structure and content judgments are stored separately.
- Every approved rule is traceable to concrete evidence references.
