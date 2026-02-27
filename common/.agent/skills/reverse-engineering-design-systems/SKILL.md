---
name: reverse-engineering-design-systems
description: >
  Reverse-engineers existing implementations, design files, and documentation
  into a reusable design system while preserving Adobe Spectrum's
  Principles/Foundation/Content structure. Use when users ask to derive design
  rules from legacy projects, normalize heterogeneous inputs, and produce
  evidence-based design system documentation.
license: Apache-2.0
compatibility: Requires Python 3.10+ and access to project code plus design/document sources.
metadata:
  author: codex
  version: "1.0.0"
---

# Reverse Engineering Design Systems

Use this skill to infer a project-specific design system from existing code, design artifacts, and knowledge bases, then publish outputs in Adobe Spectrum's structural taxonomy.

## Non-negotiable constraints

- Treat Adobe Spectrum as a structure reference only.
- Derive all project rules from project evidence (code, design assets, documentation).
- Maintain deterministic pipelines with explicit finite states.
- Keep missing values explicit as `unknown` or `na`; do not leave semantic gaps as blank.
- Record evidence links for every decision.

## Architecture principles

1. Declarative
2. Self-describing
3. Deterministic
4. Explicit State
5. Finite State
6. Self-documenting
7. Exhaustive
8. Predictable

## Required structure contract (Adobe Spectrum)

- `Principles`
- `Foundation`
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
- `Content`
  - `voice_and_tone`
  - `grammar_and_mechanics`
  - `language_and_inclusivity`
    - `inclusive_ux_writing`
    - `writing_about_people`
    - `writing_for_readability`
    - `writing_with_visuals`
  - `in_product_word_list`
  - `writing_for_errors`
  - `writing_for_onboarding`

## Inputs

Collect inputs into a single registry CSV first:

- `source_type`
- `source_locator`
- `source_section`
- `evidence_level`
- `priority`
- `notes`

Start from `assets/source-registry.template.csv` and adapt per project.

## Data intake and normalization

1. Ingest all source locators into one registry table.
2. Normalize locators into machine-joinable identifiers.
3. Validate required fields and supported source types.
4. Deduplicate using deterministic canonical keys.
5. Split invalid and duplicate rows into separate audit files.
6. Freeze queue order before extraction.

Run:

```bash
python scripts/normalize_sources.py \
  --input assets/source-registry.template.csv \
  --out-dir ./design-system-inventory/intake
```

Generated files:

- `normalized.csv`
- `duplicates.csv`
- `invalid.csv`
- `summary.json`

## Finite states

Evidence lifecycle:

- `S0 Candidate`
- `S1 Extracted`
- `S2 Structured`
- `S3a StructureValidated`
- `S3b ContentValidated`
- `S4 Approved`

Allowed transitions:

- `S0 -> S1 -> S2 -> S3a -> S3b -> S4`
- Do not skip states.

## Execution flow

### Phase 0: Input Freeze

- Freeze source scope (code, design, docs, operations records).
- Freeze branch/commit and extraction window.
- Define priority scope.

### Phase 0.5: Deterministic Intake

- Normalize all source locators.
- Generate canonical keys and queue order.
- Isolate `invalid` rows with explicit reasons.
- Persist duplicate logs.

### Phase 1: Code Reverse Engineering

- Extract Foundation, Content, and Components observations from implementation.
- Keep line-level evidence references (`path:line`).
- Mark non-applicable entries with reasons.

### Phase 1.5: Knowledge Reverse Engineering

- Extract rules from documentation/knowledge sources.
- Separate first-class evidence from secondary evidence.
- Map statements into Foundation/Content/Components/Operations candidates.

### Phase 2: Design Reverse Engineering

- Extract observations from design files (nodes, styles, variants, states).
- Normalize design node identifiers before extraction.
- Keep raw-response references and extraction parameters.

### Phase 2.5: Foundation Schema Fixing

- Harmonize code/design/knowledge observations into one Foundation schema.
- Enforce conditional required fields by source type.
- Compute `identity_key` and `merge_key`.

### Phase 2.6: Layout Abstraction (Grid System x Canonical Layout)

- Separate `Grid System` as the abstract layer and `Canonical Layout` as the concrete layer.
- Treat Material Design 2 layout grid as axis definitions only (`columns/gutters/margins/container`); never copy values directly.
- Treat Material Design 3 understanding-layout guidance as the layout behavior baseline; derive concrete canonical templates from project evidence plus platform canonical references.
- Fix abstract observation axes to `columns`, `gutter`, `margin`, `container_max_width`.
- Fix concrete observation axes to `layout_id`, `primary_regions`, `pane_count`, `navigation_mode`, `transition_rule`.
- Require `canonical_layout -> grid_rule_set_id` linkage so concrete rules always reference abstract rules.
- For abstract grid measurement, observe code evidence from `theme.breakpoints.values`, `theme.spacing`, `maxWidth`, `padding`, `margin`, `gap`, `grid-template-columns`, and `flex-basis`.
- For abstract grid measurement, observe design evidence from Grid, Auto Layout, and Constraints settings.
- Keep evidence references as `path:line` for code and `source_url + node_id` for design.
- For canonical extraction, infer regions and pane transitions by responsibility plus window-size class/breakpoint transitions.
- Promote a canonical candidate only when at least two independent screens reproduce the same responsibility pattern.
- Build `grid_rule_set` candidates per viewport bucket and rank `canonical_layout` candidates by coverage, state completeness, and code/design agreement.
- Record unresolved conflicts as `layout_mismatch` (abstract conflict) or `canonical_mismatch` (concrete conflict) and route to conflict resolution.
- Validate by reapplying `canonical_layout + grid_rule_set` to representative screens and log `layout-diff` rows.
- Any residual diff must include `exception_reason` or `rule_set_split`; no silent exceptions.
- Track layout abstraction state transitions explicitly:
  - `LA0 RawObserved`
  - `LA1 GridMeasured`
  - `LA2 CanonicalHypothesized`
  - `LA3 Linked`
  - `LA4 Validated`
  - `LA5 Adopted`

### Phase 2.7: Content Schema Fixing

- Harmonize text and writing observations into one Content schema.
- Preserve state, audience, and language/inclusivity subtopics.
- Enforce per-element required keys.

### Phase 2.8: Style Reverse Engineering

- Build a multi-source text corpus.
- Apply deterministic text normalization rules.
- Infer voice/tone, grammar/mechanics, inclusivity patterns.
- Log all style conflicts explicitly.

### Phase 3: Principles Inference

- Infer project-specific principles from recurring evidence.
- Require counter-evidence checks before approval.
- For every conflict, record `conflict_type` and `resolve_action`.

### Phase 4: Structure Mapping

- Map all approved observations to Spectrum structure.
- Keep structure-fit and content-validity as separate fields.
- Keep unclassified records only with explicit reasons.

### Phase 5: Gap and Decision

- Compute missing, duplicate, and conflicting rules.
- Record adoption decision (`adopt`, `defer`, `reject`) with evidence.

### Phase 6: Documentation

Publish:

- `design-system/principles.md`
- `design-system/foundation.md`
- `design-system/content.md`

## Output requirements

- Output structure must remain `Principles/Foundation/Content`.
- Include evidence links for every normative rule.
- Keep structure references and project-content evidence separated.
- Keep conflict logs and decision logs as first-class deliverables.
- Include layout abstraction artifacts as first-class outputs:
  - `design-system-inventory/layout-grid-observations.csv`
  - `design-system-inventory/layout-grid-rules.csv`
  - `design-system-inventory/canonical-layout-observations.csv`
  - `design-system-inventory/canonical-layout-rules.csv`
  - `design-system-inventory/layout-abstraction-validation.csv`
  - `design-system-inventory/layout-abstraction-rulebook.md`

## Validation checklist

- Every Foundation element has an observed row or explicit non-applicable reason.
- Every Content element has an observed row or explicit non-applicable reason.
- `language_and_inclusivity` includes all four subtopics.
- No approved rule is justified by secondary evidence only.
- No direct copy of Spectrum prose into project principles.
- `layout-grid-observations.csv` rows always include `viewport_bucket`, `columns`, `gutter`, `margin`, `container_max_width`, and `evidence_ref`.
- `layout-grid-rules.csv` rules always include at least one `code` evidence and one `figma` evidence; single-source rules remain `pending`.
- `canonical-layout-rules.csv` rows always include `layout_id`, `primary_regions`, `pane_count`, `navigation_mode`, `transition_rule`, and `grid_rule_set_id`.
- `layout-abstraction-validation.csv` diff rows always include either `conflict_type` (`layout_mismatch` or `canonical_mismatch`) or `resolve_action`.
- All pending conflicts have owners and statuses.

See detailed schema and reference contracts in `references/REFERENCE.md`.
