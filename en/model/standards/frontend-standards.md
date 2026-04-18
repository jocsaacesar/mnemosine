---
document: frontend-standards
version: 2.2.0
created: 2025-06-01
updated: 2026-04-16
total_rules: 38
severities:
  error: 21
  warning: 17
scope: HTML, CSS, and UX across all web projects
stack: frontend
applies_to: ["all"]
requires: [security-standards, js-standards]
replaces: [frontend-standards-v1]
---

# Frontend/UX/UI Standards — your organization

> Constitutional document. Delivery contract for every
> developer who touches frontend in our projects.
> Code that violates ERROR rules is not discussed — it is returned.

---

## How to use this document

### For the developer

1. Read this document before touching HTML, CSS, or UX in any project. JavaScript rules live in `js-standards.md`.
2. Reference rule IDs during development and before opening a PR.
3. Check the DoD at the end of this document before requesting review.

### For the auditor (human or AI)

1. Read the frontmatter to understand scope and dependencies.
2. Audit each file against the rules by ID and severity.
3. Classify violations: ERROR blocks merge, WARNING requires written justification.
4. Reference violations by rule ID (e.g., "violates UI-011").

### For Claude Code

1. Read the frontmatter to identify scope and dependencies.
2. When generating frontend code, apply all rules in this document automatically. For JS, apply `js-standards.md`.
3. In code review, reference violations by ID (e.g., "UI-012 — no static inline CSS").
4. Never generate code that violates ERROR rules. WARNING rules can be relaxed with explicit justification in the PR.

---

## Severities

| Level | Meaning | Action |
|-------|---------|--------|
| **ERROR** | Non-negotiable violation | Blocks merge. Fix before review. |
| **WARNING** | Strong recommendation | Must be justified in writing if ignored. |

---

## 1. Design tokens and visual identity

### UI-001 — Colors defined as CSS custom properties [ERROR]

**Rule:** All project colors are declared as CSS variables in `:root`. Never use hex, RGB, or HSL values directly in components.

**Checks:** Search for `#[0-9a-fA-F]`, `rgb(`, `hsl(` outside the `:root` block. Any occurrence in a component is a violation.

**Why:** The project works with multiple projects, each with its own visual identity. Centralized design tokens allow Claude Code to generate components without knowing the specific palette — just reference the variables. When the designer changes a color, the change propagates automatically.

**Correct example:**
```css
/* project tokens — defined once */
:root {
    --brand-primary: #E2C5B0;
    --brand-primary-hover: #d4b39e;
    --brand-secondary: #EFD7D3;
    --color-text: #3d3d3d;
    --color-text-muted: #939393;
    --color-bg: #faf8f6;
    --color-bg-card: #ffffff;
    --color-border: #e8e0da;
}
```

```html
<!-- correct usage — references the token -->
<div style="color: var(--color-success);">Operation completed</div>
```

**Incorrect example:**
```html
<!-- hardcoded color — breaks when palette changes -->
<div style="color: #198754;">Operation completed</div>
```

### UI-002 — Semantic colors for meaningful data [ERROR]

**Rule:** Data that carries meaning (status, categories, indicators) uses semantic tokens (e.g., `--color-success`, `--color-danger`, `--color-info`). Never mix meanings — green always means positive/success, red always means negative/error.

**Checks:** Inspect status badges/spans. Does the applied color contradict the displayed text? Violation.

**Why:** Projects frequently involve financial data, statuses, and metrics. If each developer picks arbitrary colors, users lose the ability to scan the interface quickly. Semantic consistency reduces interpretation errors.

**Correct example:**
```css
:root {
    --color-success: #198754;
    --color-danger: #dc3545;
    --color-info: #0dcaf0;
    --color-warning: #ffc107;
}
```

```html
<span style="color: var(--color-success);">Approved</span>
<span style="color: var(--color-danger);">Rejected</span>
```

**Incorrect example:**
```html
<!-- green for "rejected" — contradicts the semantics -->
<span style="color: var(--color-success);">Rejected</span>
```

### UI-003 — Typography via design tokens [WARNING]

**Rule:** Project fonts are declared as CSS variables. The application body uses the font stack defined in the `--font-family-base` token. Brand fonts (logo, special headings) are served as graphic assets or web fonts declared in the token.

**Checks:** Search for `font-family:` outside `:root`. Value that doesn't use `var(--font-family-*)` is a violation.

**Why:** Small teams generate code via AI. If the font isn't tokenized, Claude Code will guess a different font stack for each file. A centralized token guarantees consistency without manual effort.

**Correct example:**
```css
:root {
    --font-family-base: system-ui, -apple-system, "Segoe UI", Roboto, sans-serif;
    --font-family-mono: "SFMono-Regular", "Cascadia Code", monospace;
}

body {
    font-family: var(--font-family-base);
    color: var(--color-text);
    background-color: var(--color-bg);
}
```

**Incorrect example:**
```css
body {
    font-family: Arial, sans-serif;
}

.sidebar {
    font-family: "Helvetica Neue", sans-serif;
}
```

### UI-004 — Numeric values aligned in monospace font [WARNING]

**Rule:** Numbers that need visual alignment (monetary values, quantities in tables, metrics) use a monospace font via the `--font-family-mono` token or equivalent utility class.

**Checks:** Inspect numeric columns in tables and cards. Is the rendered font proportional? Violation.

**Why:** Projects deal with financial values and metrics. Proportional fonts misalign decimal places in columns, making it harder to read and compare values.

**Correct example:**
```html
<span class="font-monospace">$1,500.00</span>
```

**Incorrect example:**
```html
<span>$1,500.00</span>
```

### UI-005 — Logo as graphic asset, never recreated in CSS [ERROR]

**Rule:** The project logo is served as an optimized SVG or PNG. Never recreate logos via CSS, styled text, or combined icons.

**Checks:** Search for elements with class `logo` or `brand`. Is it an `<img>` with `src` pointing to SVG/PNG? If not, violation.

**Why:** Logos are created by designers and have exact proportions, colors, and shapes. Recreating them via CSS produces inconsistencies between pages and breaks across different browsers. SVG scales without loss and maintains brand fidelity.

**Correct example:**
```html
<img src="/assets/img/logo.svg" alt="Project Name" class="logo" width="180" height="40">
```

**Incorrect example:**
```html
<!-- fake logo via CSS -->
<div style="font-family: cursive; font-size: 2rem; color: pink;">
    Project Name
</div>
```

**Exceptions:** Favicon icons can be simplifications of the logo, served as a separate SVG.

### UI-006 — Brand visual elements follow the project guide [WARNING]

**Rule:** Each project has a visual identity guide (provided by the designer). Decorative icons, patterns, slogans, and brand graphic elements must follow that guide. Don't invent brand visual elements without reference to the guide.

**Checks:** Does the decorative/brand icon element have a match in the project's identity guide? If not, violation.

**Why:** The project works with external designers. Visual elements invented by the developer disrespect the designer's work and create visual inconsistency. The identity guide is the source of truth.

**Correct example:**
```html
<!-- uses asset from the identity guide -->
<img src="/assets/img/icon-brand.svg" alt="" class="decorative-icon" aria-hidden="true">
```

**Incorrect example:**
```html
<!-- emoji as substitute for a brand icon -->
<span class="brand-icon">🌸</span>
```

---

## 2. CSS — conventions and restrictions

### UI-007 — Utility-first, custom CSS only when necessary [WARNING]

**Rule:** Prefer utility classes from the adopted CSS framework (Bootstrap, Tailwind, etc.). Custom CSS only when the utility doesn't cover the case (animations, pseudo-elements, very specific layouts).

**Checks:** Does newly added custom CSS have an equivalent framework utility? If so, violation.

**Why:** Small teams maintain multiple projects. Custom CSS grows indefinitely and becomes impossible to audit. Utilities are standardized, documented, and removable. Claude Code generates utilities with more precision than custom CSS.

**Correct example:**
```html
<!-- framework utilities -->
<div class="card shadow-sm border-0 mb-3">
    <div class="card-body p-4">
        <h5 class="card-title fw-bold">Title</h5>
    </div>
</div>
```

**Incorrect example:**
```html
<!-- unnecessary custom CSS -->
<div class="my-card">
    <!-- .my-card { box-shadow: 0 .125rem .25rem rgba(0,0,0,.075); border: none; margin-bottom: 1rem; } -->
</div>
```

### UI-008 — Grid system for layout, never manual positioning [ERROR]

**Rule:** Page layouts use the CSS framework's grid system (`container`, `row`, `col-*`, or Flexbox/Grid equivalents). Never use `float` or `position: absolute` for page layout.

**Checks:** Search for `float:` and `position: absolute` in page layout CSS. Any occurrence is a violation.

**Why:** Layouts with float and position absolute break on different screens and are impossible to maintain. Claude Code generates correct responsive code when using a grid system — with float, it generates visual bugs that only appear in production.

**Correct example:**
```html
<div class="container">
    <div class="row g-4">
        <div class="col-md-8"><!-- main content --></div>
        <div class="col-md-4"><!-- sidebar --></div>
    </div>
</div>
```

**Incorrect example:**
```html
<div style="float: left; width: 66%;"><!-- content --></div>
<div style="float: right; width: 33%;"><!-- sidebar --></div>
```

### UI-009 — Framework responsive breakpoints, no custom values [ERROR]

**Rule:** Use the native breakpoints of the adopted CSS framework. Never create media queries with arbitrary values.

**Checks:** Search for `@media` in custom CSS. Does the breakpoint value match the framework's? If not, violation.

**Why:** Custom breakpoints create fragmentation — each developer picks a different value, and the layout breaks between them. Standardized breakpoints ensure that all components adapt at the same points.

**Correct example:**
```html
<!-- standard framework breakpoints -->
<div class="col-12 col-md-6 col-lg-4">...</div>
```

**Incorrect example:**
```css
/* invented breakpoint — doesn't match the framework */
@media (min-width: 850px) {
    .my-class { width: 50%; }
}
```

### UI-010 — Framework components before custom components [WARNING]

**Rule:** Use the CSS framework's native components (cards, modals, alerts, tables, badges, dropdowns, toasts) before creating custom ones. Build from scratch only when the framework offers no solution.

**Checks:** Does the newly created custom component have a native framework equivalent? If so, violation.

**Why:** Custom components require maintenance, accessibility testing, and their own documentation. The team is small — each custom component is technical debt. Framework components are already tested, accessible, and documented.

**Correct example:**
```html
<!-- framework modal -->
<div class="modal" id="confirmation" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">...</div>
    </div>
</div>
```

**Incorrect example:**
```html
<!-- custom modal from scratch -->
<div class="my-overlay" style="position: fixed; top: 0; left: 0; width: 100%; height: 100%;">
    <div class="my-popup" style="position: absolute; top: 50%; left: 50%;">...</div>
</div>
```

### UI-011 — No !important [ERROR]

**Rule:** Never use `!important` in custom CSS. To override framework styles, use higher specificity or CSS custom properties.

**Checks:** Search for `!important` in project CSS/SCSS files. Any occurrence is a violation.

**Why:** `!important` creates impossible-to-debug cascades. When two `!important` declarations conflict, the solution is another `!important` — a complexity spiral. In the project, specificity resolves conflicts predictably.

**Correct example:**
```css
/* higher specificity */
.dashboard .card-title {
    font-size: 1.25rem;
}
```

**Incorrect example:**
```css
.card-title {
    font-size: 1.25rem !important;
}
```

### UI-012 — No inline CSS in HTML [ERROR]

**Rule:** Styles live in CSS files or in framework utility classes. Never use the `style=""` attribute directly in HTML, except for dynamic values injected by backend/JS (e.g., progress bar width, user-defined color).

**Checks:** Search for `style="` in HTML. Is the value static (not injected by backend/JS)? Violation.

**Why:** Inline CSS is not auditable, not reusable, and does not respect design tokens. Claude Code tends to generate `style=""` as a shortcut — this rule enforces the discipline of using tokens and classes.

**Correct example:**
```html
<!-- utility class -->
<div class="text-success fw-bold">Approved</div>

<!-- dynamic (acceptable) -->
<div class="progress-bar" style="width: 75%"></div>
```

**Incorrect example:**
```html
<!-- static inline style -->
<div style="color: green; font-weight: bold;">Approved</div>
```

### UI-013 — Dark mode prepared via theme attribute [WARNING]

**Rule:** Use a theme attribute on `<html>` (e.g., `data-bs-theme="light"`, `data-theme="light"`) and respect the framework's CSS variables. Project design tokens should have variants for both themes.

**Checks:** Do tokens in `:root` have a corresponding `[data-theme="dark"]` variant? If not, violation.

**Why:** Projects eventually request dark mode. If tokens are not prepared from the start, implementing it requires rewriting CSS for all components. Preparing from the start costs nothing and saves days in the future.

**Correct example:**
```css
:root {
    --color-bg: #faf8f6;
    --color-bg-card: #ffffff;
    --color-text: #3d3d3d;
    --color-border: #e8e0da;
}

[data-theme="dark"] {
    --color-bg: #212529;
    --color-bg-card: #2b3035;
    --color-text: #dee2e6;
    --color-border: #495057;
}
```

**Incorrect example:**
```css
/* hardcoded colors without theme variants */
body { background: white; color: black; }
.card { background: #f8f9fa; }
```

---

## 3. UX — interaction and feedback

### UI-014 — Privacy mode for sensitive data [ERROR]

**Rule:** Interfaces displaying sensitive data (financial values, personal data, confidential metrics) must have a control that hides/shows that data. When hidden, values are replaced with `*****`. The state persists in `localStorage`.

**Checks:** Does the screen display a financial value or personal data? Is there a privacy toggle button? If not, violation.

**Why:** Projects deal with financial and personal data. Users open the application in public environments (office, transit). Without privacy mode, data is exposed to anyone nearby.

**Correct example:**
```html
<!-- toggle button -->
<button id="togglePrivacy" aria-label="Hide sensitive values">
    <i class="bi bi-eye"></i>
</button>

<!-- visible -->
<span class="sensitive-data" data-visible="true">$12,450.00</span>

<!-- hidden -->
<span class="sensitive-data" data-visible="false">*****</span>
```

**Incorrect example:**
```html
<!-- values always exposed, no privacy control -->
<span>$12,450.00</span>
```

**Exceptions:** Internal interfaces without sensitive data (e.g., system configuration panel).

### UI-015 — Primary actions accessible without scrolling [WARNING]

**Rule:** The initial screen of any application displays primary actions prominently, accessible without scrolling or deep navigation.

**Checks:** Open the initial screen at 375px viewport. Is the primary action visible without scrolling? If not, violation.

**Why:** Project users are frequently non-technical. If the primary action is hidden in menus or below the fold, the user calls support. Visible primary actions reduce support tickets and increase adoption.

**Correct example:**
```html
<!-- primary actions at the top of the dashboard -->
<div class="d-flex gap-2 mb-4">
    <a href="/new" class="btn btn-primary">New entry</a>
    <a href="/report" class="btn btn-outline-secondary">View report</a>
</div>
```

**Incorrect example:**
```html
<!-- primary action hidden in submenu -->
<nav>
    <ul>
        <li>Menu
            <ul>
                <li>Submenu
                    <ul>
                        <li><a href="/new">New entry</a></li>
                    </ul>
                </li>
            </ul>
        </li>
    </ul>
</nav>
```

### UI-016 — Positive friction for destructive or irreversible operations [ERROR]

**Rule:** Every operation that significantly alters state (confirm transaction, cancel, delete, archive) requires explicit user confirmation via modal or intermediate step.

**Checks:** Click a destructive button (delete, cancel, archive). Does a confirmation modal/step appear? If not, violation.

**Why:** Projects deal with financial data and critical records. An accidental click on "delete" without confirmation caused data loss in production. Positive friction prevents errors that cost hours of support and restoration.

**Correct example:**
```html
<!-- confirmation modal before deleting -->
<div class="modal" id="confirmDelete" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Confirm deletion</h5>
            </div>
            <div class="modal-body">
                <p>Are you sure you want to delete this record?</p>
            </div>
            <div class="modal-footer">
                <button class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                <button class="btn btn-danger" id="btnDelete">Delete</button>
            </div>
        </div>
    </div>
</div>
```

**Incorrect example:**
```html
<!-- direct destructive action without confirmation -->
<button onclick="deleteRecord(id)">Delete</button>
```

### UI-017 — Visual feedback on every user action [ERROR]

**Rule:** Every user action produces immediate visual feedback: success toast, error alert, loading spinner. The user must never be left wondering if the action worked.

**Checks:** Execute each flow action. Does a toast/alert/spinner appear? If not, violation.

**Why:** Without feedback, the user clicks twice, closes the tab, or calls support thinking it "froze." This has already happened — a user duplicated financial transactions by clicking twice on a button without feedback.

**Correct example:**
```html
<!-- success toast -->
<div class="toast align-items-center text-bg-success" role="alert" aria-live="assertive">
    <div class="d-flex">
        <div class="toast-body">Record saved successfully.</div>
        <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>
    </div>
</div>

<!-- spinner during operation -->
<button class="btn btn-primary" disabled>
    <span class="spinner-border spinner-border-sm" role="status"></span>
    Processing...
</button>
```

**Incorrect example:**
```html
<!-- button without feedback — user doesn't know if it worked -->
<button onclick="save()">Save</button>
<!-- no toast, no spinner, no indication -->
```

### UI-018 — Empty states with guidance [WARNING]

**Rule:** When a list, table, or section is empty, display a message guiding the user on what to do to populate it.

**Checks:** Empty a list/table (filter with no results or new data). Does an orientational message appear? If not, violation.

**Why:** Non-technical users interpret an empty screen as "error" or "system is broken." An empty state with guidance turns confusion into action.

**Correct example:**
```html
<div class="text-center py-5 text-muted">
    <p class="mb-3">No records found.</p>
    <a href="/new" class="btn btn-primary">Create first record</a>
</div>
```

**Incorrect example:**
```html
<!-- empty table without explanation -->
<table>
    <thead><tr><th>Name</th><th>Value</th></tr></thead>
    <tbody></tbody>
</table>
```

---

## 4. Forms

### UI-019 — Correct inputmode for numeric and monetary values [ERROR]

**Rule:** Monetary value fields use `inputmode="decimal"` to invoke the numeric keyboard with decimal separator on mobile devices. Integer quantity fields use `inputmode="numeric"`.

**Checks:** Search for `<input>` for monetary values. Does it have `inputmode="decimal"`? If not, violation.

**Why:** Projects are used on mobile. Without `inputmode`, the user gets a QWERTY keyboard for entering numbers — a frustrating experience that generates input errors and complaints.

**Correct example:**
```html
<input type="text" inputmode="decimal" name="amount" placeholder="0.00"
       class="form-control" autocomplete="off">
```

**Incorrect example:**
```html
<!-- type number with increment arrows — terrible for monetary values -->
<input type="number" name="amount">
```

### UI-020 — inputmode="numeric" for code/PIN fields [WARNING]

**Rule:** Numeric code fields (PIN, verification code, ZIP) use `inputmode="numeric"` to invoke the numeric keyboard without decimal separator.

**Checks:** Search for `<input>` for PIN/ZIP/code. Does it have `inputmode="numeric"`? If not, violation.

**Why:** The correct keyboard reduces friction. Project users access via mobile — each field with the wrong keyboard is a micro-frustration that accumulates.

**Correct example:**
```html
<input type="text" inputmode="numeric" name="code" maxlength="6"
       class="form-control" placeholder="000000" autocomplete="one-time-code">
```

**Incorrect example:**
```html
<input type="text" name="code" placeholder="Enter the code">
```

### UI-021 — Labels mandatory on every form field [ERROR]

**Rule:** Every `<input>`, `<select>`, and `<textarea>` has an associated `<label>` via `for`/`id` attributes. Never use placeholder as a label substitute.

**Checks:** Inspect every `<input>`/`<select>`/`<textarea>`. Does it have a corresponding `<label for="...">`? If not, violation.

**Why:** Placeholder disappears when the user types — they no longer know what the field asks for. Screen readers depend on `<label>` to identify fields. Without a label, the form is inaccessible.

**Correct example:**
```html
<label for="description" class="form-label">Description</label>
<input type="text" class="form-control" id="description" name="description">
```

**Incorrect example:**
```html
<!-- placeholder as label — inaccessible -->
<input type="text" class="form-control" placeholder="Description">
```

### UI-022 — Visual validation with framework classes [WARNING]

**Rule:** Use the CSS framework's validation classes (`is-valid`, `is-invalid` or equivalents) with visible error messages next to the field.

**Checks:** Submit a form with an invalid field. Does the `is-invalid` class (or equivalent) + visible message appear? If not, violation.

**Why:** Standardized visual validation allows Claude Code to generate forms with consistent error feedback across all projects. Custom validation per project creates inconsistency and rework.

**Correct example:**
```html
<input type="text" class="form-control is-invalid" id="amount" name="amount">
<div class="invalid-feedback">Amount is required.</div>
```

**Incorrect example:**
```html
<input type="text" class="form-control" id="amount" name="amount">
<span style="color: red; font-size: 12px;">Required field</span>
```

### UI-023 — Complex forms grouped with fieldset and legend [WARNING]

**Rule:** Forms with multiple sections use `<fieldset>` and `<legend>` to group related fields.

**Checks:** Form with >1 logical section. Does it use `<fieldset>`+`<legend>` to group? If not, violation.

**Why:** Long forms without grouping are intimidating. `<fieldset>` and `<legend>` create visual and semantic separation that helps both the user and screen readers understand the structure.

**Correct example:**
```html
<form>
    <fieldset>
        <legend>Personal data</legend>
        <label for="name" class="form-label">Name</label>
        <input type="text" class="form-control" id="name" name="name">
    </fieldset>
    <fieldset>
        <legend>Address</legend>
        <label for="zip" class="form-label">ZIP Code</label>
        <input type="text" class="form-control" id="zip" name="zip" inputmode="numeric">
    </fieldset>
</form>
```

**Incorrect example:**
```html
<form>
    <h4>Personal data</h4>
    <input type="text" name="name" placeholder="Name">
    <h4>Address</h4>
    <input type="text" name="zip" placeholder="ZIP Code">
</form>
```

---

## 5. Tables and listings

### UI-024 — Responsive tables [ERROR]

**Rule:** Every table uses a responsive wrapper (e.g., `.table-responsive`) for horizontal scrolling on small screens.

**Checks:** Search for `<table>` without a `.table-responsive` wrapper (or equivalent). Any occurrence is a violation.

**Why:** Tables without a responsive wrapper break the layout on mobile. The user cannot see columns on the right and thinks the data doesn't exist. This has happened — a user complained that the "status column was missing" because it was off screen.

**Correct example:**
```html
<div class="table-responsive">
    <table class="table table-hover align-middle">
        <thead class="table-light">
            <tr>
                <th>Date</th>
                <th>Description</th>
                <th class="text-end">Amount</th>
                <th>Status</th>
            </tr>
        </thead>
        <tbody><!-- data --></tbody>
    </table>
</div>
```

**Incorrect example:**
```html
<!-- table without responsive wrapper -->
<table class="table">
    <thead><tr><th>Date</th><th>Description</th><th>Amount</th><th>Status</th></tr></thead>
    <tbody><!-- data --></tbody>
</table>
```

### UI-025 — Numeric values right-aligned in tables [ERROR]

**Rule:** Columns with numeric values (monetary, quantities, percentages) are right-aligned and use monospace font.

**Checks:** Inspect `<td>` with numeric values. Does it have `text-end` + `font-monospace` (or equivalent)? If not, violation.

**Why:** Right alignment allows instant visual comparison of magnitudes. Without alignment, the user must read each number individually to compare — slow and error-prone.

**Correct example:**
```html
<td class="text-end font-monospace">$1,500.00</td>
```

**Incorrect example:**
```html
<td>$1,500.00</td>
```

### UI-026 — Status with colored semantic badges [WARNING]

**Rule:** Record statuses are displayed with badges using consistent semantic colors throughout the project.

**Checks:** Search for status displays. Does it use a badge with a semantic framework class? If not, violation.

**Why:** Standardized badges create a visual language that the user learns once and applies across all screens. If each screen uses a different style for status, the user has to relearn on every page.

**Correct example:**
```html
<span class="badge text-bg-warning">Pending</span>
<span class="badge text-bg-success">Confirmed</span>
<span class="badge text-bg-danger">Cancelled</span>
```

**Incorrect example:**
```html
<!-- status as loose text without visual emphasis -->
<span>pending</span>
<span style="color: green;">ok</span>
```

---

## 6. Dashboards and data visualization

### UI-027 — Cards for dashboard metrics [WARNING]

**Rule:** Main dashboard metrics (KPIs, totals, counters) are displayed in standardized framework cards, organized in a responsive grid.

**Checks:** Does the dashboard display metrics? Are they in framework cards + responsive grid? If not, violation.

**Why:** Cards create clear visual hierarchy. Loose metrics on the page compete for attention and confuse the user. Cards in a responsive grid work on both desktop and mobile without adjustment.

**Correct example:**
```html
<div class="row g-4">
    <div class="col-sm-6 col-xl-3">
        <div class="card border-0 shadow-sm">
            <div class="card-body">
                <p class="text-muted small mb-1">Total records</p>
                <h3 class="fw-bold font-monospace sensitive-data" data-visible="true">
                    1,247
                </h3>
            </div>
        </div>
    </div>
    <!-- more cards -->
</div>
```

**Incorrect example:**
```html
<!-- loose metrics without structure -->
<p>Total: 1247</p>
<p>Active: 89</p>
<p>Pending: 34</p>
```

### UI-028 — Charts with accessible text alternative [ERROR]

**Rule:** Every chart (canvas, SVG, chart library) must have an accessible text description via `aria-label` or hidden text with a `visually-hidden` class.

**Checks:** Search for `<canvas>` or chart container. Does it have `aria-label` or `visually-hidden` with a description? If not, violation.

**Why:** Charts without a text alternative are invisible to screen readers. Besides excluding visually impaired users, this hurts SEO and prevents AI tools from extracting information from the chart.

**Correct example:**
```html
<div id="category-chart"
     role="img"
     aria-label="Distribution chart by category: Food 35%, Transport 20%, Housing 30%, Leisure 15%">
</div>
```

**Incorrect example:**
```html
<!-- chart without text alternative -->
<div id="category-chart"></div>
```

### UI-029 — Chart colors consistent with design tokens [WARNING]

**Rule:** Charts use the same colors defined in the project's design tokens. Semantic colors (success, error, warning) maintain the same meaning as other components.

**Checks:** Does the chart's color config use `getComputedStyle` + `getPropertyValue('--color-*')`? Hardcoded color is a violation.

**Why:** If the chart uses a different palette from the rest of the interface, the user loses the visual reference. Green in the chart should mean the same as green in the badge and text.

**Correct example:**
```javascript
const chartColors = {
    positive: getComputedStyle(document.documentElement).getPropertyValue('--color-success').trim(),
    negative: getComputedStyle(document.documentElement).getPropertyValue('--color-danger').trim(),
    neutral: getComputedStyle(document.documentElement).getPropertyValue('--color-info').trim(),
};
```

**Incorrect example:**
```javascript
// hardcoded colors that don't match the project tokens
const chartColors = {
    positive: '#00ff00',
    negative: '#ff0000',
    neutral: '#0000ff',
};
```

---

## 7. Accessibility

### UI-030 — Minimum WCAG AA contrast [ERROR]

**Rule:** All text has a minimum contrast ratio of 4.5:1 against the background (WCAG AA). Large text (18px+ or 14px+ bold) accepts 3:1.

**Checks:** Test text-color/background-color pairs with a contrast tool. Ratio <4.5:1 (or <3:1 for large text) is a violation.

**Why:** Projects are used by a diverse audience, including people with low vision. Insufficient contrast generates "I can't read it" complaints and excludes users. WCAG AA is the legal minimum in many contexts.

**Correct example:**
```css
/* dark text on light background — contrast 10.5:1 */
.content {
    color: #3d3d3d;
    background-color: #ffffff;
}
```

**Incorrect example:**
```css
/* light gray text on white background — contrast 2.1:1 */
.content {
    color: #c0c0c0;
    background-color: #ffffff;
}
```

### UI-031 — Functional keyboard navigation [ERROR]

**Rule:** Every interactive element (buttons, links, inputs, modals) is accessible via keyboard (Tab, Enter, Escape). Tab order follows the logical visual order. No interactive element is keyboard-inaccessible.

**Checks:** Navigate the page using only Tab/Enter/Escape. Does any interactive element not receive focus or respond? Violation.

**Why:** Users with motor disabilities depend on the keyboard. Additionally, power users prefer keyboard for speed. If a modal doesn't close with Escape or a dropdown doesn't navigate with arrow keys, the experience is broken.

**Correct example:**
```html
<!-- native button — keyboard-accessible automatically -->
<button type="button" class="btn btn-primary">Save</button>

<!-- link with destination — accessible via Tab and Enter -->
<a href="/report" class="btn btn-outline-secondary">View report</a>
```

**Incorrect example:**
```html
<!-- div as button — doesn't receive Tab focus, doesn't respond to Enter -->
<div class="btn-fake" onclick="save()">Save</div>
```

### UI-032 — ARIA roles in dynamic components [WARNING]

**Rule:** Dynamic components (modals, toasts, dropdowns, tabs, accordions) use correct ARIA roles and attributes. CSS framework components already implement ARIA — don't remove those attributes. Custom components must implement equivalent ARIA.

**Checks:** Inspect the dynamic component. Does it have `role`, `aria-*` as per the framework spec? If not, violation.

**Why:** Claude Code frequently generates dynamic components. Without an explicit rule about ARIA, the generated code omits roles and attributes, creating components that are visually correct but inaccessible to screen readers.

**Correct example:**
```html
<!-- toast with correct ARIA -->
<div class="toast" role="alert" aria-live="assertive" aria-atomic="true">
    <div class="toast-body">Record saved.</div>
</div>

<!-- accordion with ARIA -->
<div class="accordion-item">
    <h2 class="accordion-header">
        <button class="accordion-button" type="button"
                data-bs-toggle="collapse" data-bs-target="#section1"
                aria-expanded="true" aria-controls="section1">
            Section 1
        </button>
    </h2>
    <div id="section1" class="accordion-collapse collapse show"
         aria-labelledby="heading1">
        <div class="accordion-body">Content</div>
    </div>
</div>
```

**Incorrect example:**
```html
<!-- toast without ARIA roles -->
<div class="toast">
    <div class="toast-body">Record saved.</div>
</div>

<!-- custom accordion without ARIA -->
<div class="my-accordion">
    <div class="my-accordion-header" onclick="toggle()">Section 1</div>
    <div class="my-accordion-body">Content</div>
</div>
```

### UI-033 — No information conveyed by color alone [ERROR]

**Rule:** Visual indicators (status, success/error, categories) never depend only on color. Always accompanied by an icon, sign (+/-), text, or visual pattern.

**Checks:** Mentally remove colors (grayscale). Are indicators still distinguishable by icon/sign/text? If not, violation.

**Why:** 8% of men have some degree of color blindness. If income is green and expense is red without any other differentiator, a color-blind user cannot distinguish the two. We have already received this complaint in production.

**Correct example:**
```html
<!-- color + text sign -->
<span class="text-success font-monospace">+$1,500.00</span>
<span class="text-danger font-monospace">-$800.00</span>
```

**Incorrect example:**
```html
<!-- color only — color-blind user cannot distinguish -->
<span class="text-success font-monospace">$1,500.00</span>
<span class="text-danger font-monospace">$800.00</span>
```

---

## 8. Documentation

### UI-038 — Comments explain the "why", never the "what" [WARNING]

**Rule:** Comments in CSS explain non-obvious decisions ("why"), never describe what the code does ("what"). Self-explanatory code needs no comment.

**Checks:** Does the newly added comment describe what the line does (e.g., "sets the color")? If so, violation — rewrite or remove.

**Why:** Comments that describe the obvious become noise and go stale. Comments that explain decisions (e.g., "overflow hidden because of a Safari 16 bug") remain useful and prevent someone from removing the line without understanding the consequence.

**Correct example:**
```css
/* Forces GPU compositing to avoid flickering on scroll in iOS Safari */
.sidebar {
    transform: translateZ(0);
}
```

**Incorrect example:**
```css
/* Sets the text color to gray */
.text-muted {
    color: #6c757d;
}
```

---

## 9. Mobile-first (rules added 2026-04-12, incident 0015)

### UI-040 — Action button never a direct child of flex-row in a card [ERROR]

**Rule:** Action buttons (CTA, logout, delete, configure) are never direct children of a horizontal `flex-row` container inside cards or profile/info sections. They must occupy their own block below the content.

**Checks:** Inspect cards with action buttons. Is the button a direct child of a `flex-row` container? If so, violation.

**Why:** On mobile (viewport <=640px), flex-row compresses the button laterally, reducing touch target and breaking the layout.

**Correct example:**
```tsx
<CardContent className="space-y-4">
  <div className="flex items-center gap-4">
    <Avatar />
    <Info />
  </div>
  <ActionButton className="w-full min-h-11" />
</CardContent>
```

**Incorrect example:**
```tsx
<CardContent>
  <div className="flex items-center gap-4">
    <Avatar />
    <Info />
    <ActionButton /> {/* squeezed on mobile */}
  </div>
</CardContent>
```

---

### UI-041 — Minimum 44x44px touch target on every interactive element [ERROR]

**Rule:** Every button, link, toggle, checkbox, and clickable element must have a minimum touch area of 44x44px (width x height). Use `min-h-11` (44px) in Tailwind.

**Checks:** DevTools mobile 375px. Interactive element with rendered dimension <44px on any axis is a violation.

**Why:** WCAG 2.5.5 (AAA) and Apple HIG recommend 44px. Mobile-first audiences with smaller screens need generous targets. A 32px button on a phone = touch error = frustration.

---

### UI-042 — Flex-row with >2 interactive children becomes flex-col on mobile [WARNING]

**Rule:** If a flex-row container has more than 2 interactive elements (buttons, links, inputs), it must use `flex-col` or responsive wrap (`flex-wrap`) at the mobile breakpoint (<=640px).

**Checks:** Flex-row with >2 interactive elements. Does it have `flex-col` or `flex-wrap` at the mobile breakpoint? If not, violation.

**Why:** 3+ buttons in a row on mobile become microscopic. The layout should prioritize readability and touch area over visual density.

**Correct example:**
```tsx
<div className="flex flex-col gap-2 sm:flex-row sm:gap-3">
  <Button>Action 1</Button>
  <Button>Action 2</Button>
  <Button>Action 3</Button>
</div>
```

### UI-043 — Form fields empty by default [ERROR]

**Rule:** Every form field must start **empty** (no pre-filled value). Values like `0`, `0.00`, empty string displayed as content, or any default that looks like real data are prohibited. The field should show only the **placeholder** (hint text in muted color) until the user interacts.

**Checks:** Open a creation form. Does any field show a visible value (not a placeholder) before interaction? If so, violation.

**Why:** A field showing "0.00" as a value confuses the user — it looks like saved data, not an empty field. A placeholder communicates the expected format without polluting the form. Clean form = visual confidence.

**Exceptions:**
- Edit mode fields that load an existing value from the database
- Fields with explicit semantic defaults (e.g., date = today, status = active) where the default is the user's most likely choice

**Incorrect example:**
```tsx
<Input value="0.00" />           // looks like data, not an empty field
<InputMoney amount={0} />        // if it renders "0.00" as value, it violates
```

**Correct example:**
```tsx
<Input placeholder="0.00" />            // placeholder in gray, field is empty
<InputMoney amount={0} />               // renders empty, placeholder appears
<InputMoney amount={entry.amount} />    // edit mode: OK, loads real data
```

---

## Definition of Done — Delivery Checklist

> PRs that don't meet the DoD don't enter review. They are returned.

| # | Item | Rules | Verification |
|---|------|-------|--------------|
| 1 | No static inline CSS | UI-012 | Search for `style=` in HTML and verify if it's dynamic |
| 2 | No `!important` | UI-011 | Search for `!important` in CSS files |
| 3 | Colors via design tokens | UI-001, UI-002 | Search for hex/RGB values outside `:root` |
| 4 | Labels on all fields | UI-021 | Inspect every `<input>`, `<select>`, `<textarea>` |
| 5 | Responsive tables | UI-024 | Verify `.table-responsive` on every `<table>` |
| 6 | Charts with accessible text | UI-028 | Verify `aria-label` or `visually-hidden` on charts |
| 7 | WCAG AA contrast | UI-030 | Test with DevTools or contrast tool |
| 8 | Keyboard navigation | UI-031 | Navigate the page using only Tab/Enter/Escape |
| 9 | No information by color alone | UI-033 | Verify indicators have icon/sign/text beyond color |
| 10 | Visual feedback on actions | UI-017 | Test each action and verify toast/alert/spinner |
| 11 | Friction on destructive operations | UI-016 | Test delete/cancel and verify confirmation modal |
| 12 | Layout via grid system | UI-008 | Search for `float:` and `position: absolute` for layout |
| 13 | Buttons outside flex-row in cards | UI-040 | Inspect cards with buttons: is it in its own block? |
| 14 | Touch targets >=44px | UI-041 | DevTools mobile 375px: every interactive >=44x44px? |
| 15 | Responsive flex-row | UI-042 | >2 interactive elements in row: has flex-col on mobile? |
| 16 | Fields empty by default | UI-043 | New form: does any field start with a visible value (not placeholder)? |
