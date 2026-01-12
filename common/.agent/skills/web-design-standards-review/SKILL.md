---
name: web-design-standards-review
description: Evaluate and apply modern web design principles using web standards (W3C/WHATWG) and authoritative guidance (MDN, web.dev). Covers mobile-first, fluid layouts, CSS logical properties, feature detection (vs UA/version sniffing), progressive enhancement, accessibility (WCAG), internationalization, semantics, and performance-oriented UX.
license: CC-BY-4.0
compatibility: Works in any web-frontend environment; assumes access to HTML/CSS/JS and standard browser devtools.
metadata:
  version: "1.0"
  author: "community-template"
---

# Web Design Standards Review

Use this skill when you need to **define**, **justify**, or **review** web UI design/implementation principles with a focus on:
- **Web standards** (W3C/WHATWG specs) vs
- **Authoritative guidance** (MDN, web.dev, W3C WAI)

Your goal is to produce decisions that are **robust across devices, input methods, writing directions, and user settings** (zoom, font-size, high contrast), and to avoid brittle heuristics (e.g., browser/version sniffing).

## Output contract

When you apply this skill, return:

1. **Decision** for each principle: _Recommend_ / _Recommend with constraints_ / _Discourage_
2. **Rationale by category**
   - **Standard**: a capability/behavior defined by a spec (e.g., CSS Grid, Media Queries, CSS Logical Properties)
   - **Guidance**: best practices (e.g., progressive enhancement, content-driven breakpoints)
   - **Heuristic**: experience-based advice that may not be formally standardized
3. **Scope & exceptions**
4. **Implementation guidance** (prefer concrete patterns/snippets)
5. **Review checklist**
6. **References** (prefer W3C/WHATWG, then MDN/web.dev/WAI)

If the user asks "Is this a standard?", be strict: **the *principle* is usually guidance**, while the *tools* (CSS/HTML/JS features) are standards.

---

## Principles

### 1) Mobile-first over desktop-first

**Decision:** Recommend (Guidance)

**Intent:** Establish a baseline UX that works on small screens and constrained conditions; then enhance for larger viewports and richer input.

**Implementation guidance**
- Start with a simple single-column baseline and progressive enhancement for larger screens.
- Use content-driven breakpoints rather than targeting specific devices.
- Ensure tap targets and readable typography at the baseline.

**Exceptions**
- Desktop-only specialist apps where high-density workflows are an explicit requirement. Even then, ensure accessibility and resilience for zoom/font scaling.

---

### 2) Fluid/relative layout over pixel-perfect fixed layout

**Decision:** Recommend (Guidance + Standards as enablers)

**Intent:** Layout should adapt to viewport size, zoom, font-size changes, and translated text length.

**Implementation guidance**
- Prefer modern layout primitives: **Flexbox** and **Grid**.
- Use relative units for sizing and spacing: `%`, `em`, `rem`, `vw`, `vh`, and consider `clamp()` for responsive typography.
- Prefer intrinsic sizing and min/max constraints over hard-coded pixel widths.

**Exceptions**
- Pixel-precise surfaces where the content itself is pixel-addressed (e.g., bitmap editors, some games/canvas UIs). Isolate these areas and keep the surrounding UI fluid.

---

### 3) Logical direction over physical direction (I18N-ready layout)

**Decision:** Recommend (Standard + Guidance)

**Intent:** Support RTL languages and alternate writing modes (e.g., vertical writing) without rewriting layout rules.

**Implementation guidance**
- Replace `left/right/top/bottom`-anchored rules with **CSS Logical Properties**:
  - `margin-inline-start/end`, `padding-inline-start/end`
  - `inset-inline-start/end` (instead of left/right)
  - `border-inline-start/end-*`, etc.
- Prefer direction-aware values where available:
  - `text-align: start/end` (instead of left/right)
- Test with `dir="rtl"` and at least one non-Latin locale; validate overflow and truncation behavior.

**Migration strategy**
- Start with shared primitives (spacing, layout wrappers, components) and new code.
- Migrate high-impact screens next; avoid “big bang” replacements unless you have strong automated visual regression coverage.

---

### 4) Feature detection over browser/version detection (UA sniffing)

**Decision:** Recommend (Guidance)

**Intent:** Use capabilities, not identities. Browser/version detection breaks under UA reduction and is brittle across forks and compatibility layers.

**Implementation guidance**
- **CSS**
  - `@supports (property: value) { ... }`
  - `CSS.supports("property", "value")`
- **JavaScript**
  - `if ("serviceWorker" in navigator) { ... }`
  - `if (typeof IntersectionObserver === "function") { ... }`
  - Prefer try/catch around feature use for runtime-guarding when appropriate.

**Exceptions (narrow and justified)**
- Analytics/telemetry (non-functional behavior)
- Known, severe, vendor-specific bugs with documented, time-bounded workarounds
- Even then, prefer capability-based alternatives (e.g., Client Hints / UA-CH where supported) and document why.

---

### 5) Progressive enhancement as the default strategy

**Decision:** Recommend (Guidance)

**Intent:** A working baseline first; enhancements layered by capability.

**Typical pattern**
1. Baseline: semantic HTML + minimal CSS that yields a usable page.
2. Enhance: richer layout (Grid/Flex), advanced styling, optional JS behaviors.
3. Guard: apply enhancements using feature detection (`@supports`, runtime checks).
4. Fallback: ensure critical flows remain possible without the enhancement.

**Accessibility implication**
Progressive enhancement pairs naturally with accessibility: if you start from semantic HTML, assistive technologies and keyboard interaction are far more likely to “just work”.

---

## Cross-cutting principles (always consider)

### Accessibility (WCAG-aligned)

- Keyboard support and visible focus
- Adequate color contrast
- Alternative text for meaningful images
- Clear headings/landmarks and form labels
- Error states: explain and recover

Rule of thumb: **Use native HTML semantics first**, add ARIA only when necessary.

### Semantics & structure

- Separate **meaning** (HTML) from **presentation** (CSS) and **behavior** (JS).
- Avoid using divs for everything when a semantic element exists; it impacts navigation and accessibility.

### Internationalization & localization (I18N/L10N)

- Expect text expansion/contraction; avoid fixed-width containers that rely on English copy lengths.
- Avoid embedding text in images.
- Support locale formats (dates, numbers, currency) and ensure fonts cover required glyphs.

### Performance as UX

- Optimize for “usable quickly”:
  - avoid unnecessary JS
  - optimize images/fonts
  - measure user-centric metrics (e.g., Core Web Vitals concepts)
- Prefer resilient UI under slow networks and low-end devices.

### Resilience

- Don’t break under:
  - zoom and increased font-size
  - high-contrast or reduced motion preferences
  - intermittent network/offline states
- Design empty/error/loading states intentionally.

---

## Review checklist

- [ ] Baseline UI works on small screens and constrained conditions (mobile-first mindset)
- [ ] Layout is fluid: survives zoom and font-size changes (relative units + modern layout)
- [ ] Direction is logical: can flip `dir` to RTL without breaking core layout
- [ ] No UA/version sniffing for functionality; uses feature detection and guards
- [ ] Progressive enhancement is explicit: enhancements are optional layers
- [ ] WCAG considerations covered (keyboard, focus, contrast, text alternatives, forms)
- [ ] I18N doesn’t break layout (text length, locale formatting, fonts)
- [ ] Performance budgets and measurements exist (esp. images/fonts/JS)

---

## Examples

### Example: Replace UA sniffing with feature detection

**Bad**
```js
if (navigator.userAgent.includes("Safari/") && !navigator.userAgent.includes("Chrome/")) {
  // do X
}
```

**Better**
```js
if ("serviceWorker" in navigator) {
  // do X
} else {
  // fallback behavior
}
```

### Example: Replace physical with logical properties

**Bad**
```css
.card {
  padding-left: 16px;
  border-left: 4px solid currentColor;
}
```

**Better**
```css
.card {
  padding-inline-start: 1rem;
  border-inline-start: 0.25rem solid currentColor;
}
```

See `references/REFERENCE.md` for curated standards and guidance links.
