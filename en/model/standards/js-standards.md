---
document: js-standards
version: 2.1.0
created: 2025-06-01
updated: 2026-04-16
total_rules: 37
severities:
  error: 21
  warning: 16
stack: js
scope: All JavaScript code — vanilla JS, frameworks, Node.js, build scripts
applies_to: ["all"]
requires: []
replaces: ["js-standards v2.0.0"]
---

# JavaScript Standards — your organization

> Constitutional document. Delivery contract for every
> developer who touches JavaScript in our projects.
> Code that violates ERROR rules is not discussed — it is returned.

---

## How to use this document

### For the developer

1. Read this document before writing JavaScript in any project.
2. Use the rule IDs (JS-001 to JS-037) to reference in PRs and code reviews.
3. Check the DoD at the end before opening any Pull Request.

### For the auditor (human or AI)

1. Read the frontmatter to understand scope and dependencies.
2. Audit the code against each rule by ID.
3. Classify violations by the severity defined in this document.
4. Reference violations by rule ID (e.g., "violates JS-014").

### For Claude Code

1. Read the frontmatter to identify scope and severities.
2. When reviewing JS code, check each rule by ID.
3. ERROR violations block merge — report as blocking.
4. WARNING violations should be reported, but accept written justification.
5. Always reference by ID (e.g., "violates JS-027").

---

## Severities

| Level | Meaning | Action |
|-------|---------|--------|
| **ERROR** | Non-negotiable violation | Blocks merge. Fix before review. |
| **WARNING** | Strong recommendation | Must be justified in writing if ignored. |

---

## 1. Fundamental principles

### JS-001 — KISS: simplicity first [WARNING]

**Rule:** Code should be as simple as possible. If there's a direct way to solve it, use that. Abstractions, patterns, and indirections only enter when the problem demands it.

**Checks:** Grep for wrapper classes, factories, or adapters without more than one consumer. Function with >1 level of indirection without justification = violation.

**Why:** The project uses AI to generate and review code. Simple, predictable code is easier to generate correctly, review automatically, and maintain by small teams. Unnecessary complexity produces bugs that only appear in production.

**Correct example:**
```javascript
function isEmpty(value) {
    return value === '' || value === null || value === undefined;
}
```

**Incorrect example:**
```javascript
function isEmpty(value) {
    return new Validator(value).check('empty').result();
}
```

---

### JS-002 — DRY: one rule, one place [ERROR]

**Rule:** Logic is implemented in a single place. If the same calculation or validation appears in two files, extract to a shared module.

**Checks:** Grep for identical or near-identical code blocks in distinct files. Duplication >3 lines of logic = violation.

**Why:** Small teams cannot keep duplicated logic in sync. When AI generates code, duplication creates silent divergence — one point is updated, the other is not. Bugs like this have already cost hours of debugging.

**Correct example:**
```javascript
// utils/ui.js — reusable function
function setLoading(btn, loading) {
    if (loading) {
        btn.disabled = true;
        btn.dataset.originalText = btn.innerHTML;
        btn.innerHTML = '<span class="spinner-border spinner-border-sm"></span> Processing...';
    } else {
        btn.disabled = false;
        btn.innerHTML = btn.dataset.originalText;
    }
}
```

**Incorrect example:**
```javascript
// login.js — loading logic copied
btnLogin.disabled = true;
btnLogin.innerHTML = '<span class="spinner-border spinner-border-sm"></span> Processing...';

// signup.js — same logic duplicated
btnSignup.disabled = true;
btnSignup.innerHTML = '<span class="spinner-border spinner-border-sm"></span> Processing...';
```

---

### JS-003 — YAGNI: don't build what you don't need now [WARNING]

**Rule:** Never implement functions, classes, or parameters thinking about "future possibilities". Implement strictly what the current requirement demands.

**Checks:** Function with parameters no caller passes, or code branch with no test exercising it = violation.

**Why:** The project works with lean scope and incremental deliveries. Speculative code creates maintenance for something nobody uses. When AI suggests abstractions "for the future," the result is complexity without return.

**Correct example:**
```javascript
// requirement: format value in USD
function formatCurrency(value) {
    return value.toLocaleString('en-US', { style: 'currency', currency: 'USD' });
}
```

**Incorrect example:**
```javascript
// "what if we need another currency someday?"
function formatCurrency(value, currency, locale, decimalPlaces, symbolBefore) {
    currency = currency || 'USD';
    locale = locale || 'en-US';
    decimalPlaces = decimalPlaces !== undefined ? decimalPlaces : 2;
    symbolBefore = symbolBefore !== undefined ? symbolBefore : true;
    // 30 lines of logic that will never be used
    return value.toLocaleString(locale, { style: 'currency', currency: currency });
}
```

---

### JS-004 — Separation of concerns [ERROR]

**Rule:** Each JS file has a clear scope. A file never mixes form logic, DOM manipulation, and AJAX communication without structure. Separate into functions with single responsibility.

**Checks:** Function with >1 responsibility (validates + sends + renders) = violation. Each function should do one thing.

**Why:** AI generates and audits files individually. Files with mixed responsibilities are harder to generate correctly and to review. Clear separation allows each function to be tested and understood in isolation.

**Correct example:**
```javascript
// functions separated by responsibility
function validateForm(form) {
    var email = form.querySelector('[name="email"]').value;
    return email.includes('@');
}

function submitForm(form) {
    var formData = new FormData(form);
    return fetch(ajaxUrl, { method: 'POST', body: formData });
}

function showResult(container, message, type) {
    container.textContent = message;
    container.className = 'alert alert-' + type;
}
```

**Incorrect example:**
```javascript
// everything mixed in a single function
form.addEventListener('submit', function (e) {
    e.preventDefault();
    var email = form.querySelector('[name="email"]').value;
    if (!email.includes('@')) {
        document.getElementById('alert').innerHTML = '<div class="alert alert-danger">Invalid email</div>';
        return;
    }
    fetch(ajaxUrl, { method: 'POST', body: new FormData(form) })
        .then(function (r) { return r.json(); })
        .then(function (j) {
            document.getElementById('alert').innerHTML = '<div class="alert alert-success">' + j.data + '</div>';
        });
});
```

---

### JS-005 — Law of Demeter: only talk to your neighbors [WARNING]

**Rule:** Don't chain calls that traverse multiple objects. Only access properties and methods of the immediate object.

**Checks:** Grep for chains with 3+ consecutive dots (e.g., `a.b.c.d`). Chaining >2 levels without intermediate variable = violation.

**Why:** Deep chaining creates invisible coupling. When AI refactors part of the DOM or an object, long chains break silently. Code with direct access is more predictable and easier to maintain.

**Correct example:**
```javascript
var navbarHeight = navbar.offsetHeight;
```

**Incorrect example:**
```javascript
var height = document.querySelector('.container').firstChild.nextSibling.offsetHeight;
```

---

## 2. Style and naming

### JS-006 — Variables and functions in camelCase [ERROR]

**Rule:** Every variable and function must use camelCase. No exceptions.

**Checks:** Grep for `var [a-z]+_[a-z]` and `function [a-z]+_[a-z]`. snake_case in a variable or function = violation.

**Why:** Naming consistency is critical when AI generates code. If the convention is singular and predictable, the generated code integrates without friction. camelCase is the universal standard of the JavaScript ecosystem.

**Correct example:**
```javascript
var totalAmount = 0;
function calculateBalance() {}
```

**Incorrect example:**
```javascript
var total_amount = 0;
function calculate_balance() {}
```

---

### JS-007 — Constants in UPPER_SNAKE_CASE [WARNING]

**Rule:** Constant values that don't change during execution must use UPPER_SNAKE_CASE.

**Checks:** Grep for `var [a-z]` or `const [a-z]` assigned to a fixed literal value. Constant in camelCase = violation.

**Why:** Constants in UPPER_SNAKE_CASE are visually distinct from variables. In code review (human or AI), immediately identifying what is constant prevents reassignment errors.

**Correct example:**
```javascript
var MAX_ATTEMPTS = 5;
var EXPIRATION_TIME_MS = 600000;
```

**Incorrect example:**
```javascript
var maxAttempts = 5;
var expirationTimeMs = 600000;
```

---

### JS-008 — Descriptive names, no obscure abbreviations [WARNING]

**Rule:** Variables, functions, and parameters must have names that describe their purpose. Abbreviations are only accepted when universally known (url, id, btn).

**Checks:** Variables of 1-2 characters (except `i`, `j`, `e`, `_`) or non-universal abbreviations = violation.

**Why:** AI generates code that will be read by humans with limited context. Obscure names require the reader to deduce the meaning — that's wasted time on small teams. Use the project's namespace prefix on DOM selectors.

**Correct example:**
```javascript
var signupForm = document.getElementById('proj-signup-form');
var submitButton = document.getElementById('proj-btn-signup');
```

**Incorrect example:**
```javascript
var sf = document.getElementById('proj-signup-form');
var sb = document.getElementById('proj-btn-signup');
```

---

### JS-009 — Named functions, never loose anonymous ones [WARNING]

**Rule:** Functions should have descriptive names for debugging and stack traces. Exception: short one-line callbacks in `.then()` or `.forEach()`.

**Checks:** Grep for `function\s*\(` (anonymous) with body >1 line. Anonymous callback with >1 line = violation.

**Why:** Stack traces with anonymous functions are useless for debugging. In the project, where AI generates code and humans debug in production, clear function names are the difference between solving a bug in 5 minutes or 2 hours.

**Correct example:**
```javascript
document.addEventListener('DOMContentLoaded', initializeLogin);

function initializeLogin() {
    // initialization logic
}
```

**Incorrect example:**
```javascript
document.addEventListener('DOMContentLoaded', function () {
    // 50 lines of anonymous code
    // stack trace will show "anonymous" — useless
});
```

---

## 3. File structure

### JS-010 — One file per page/feature [ERROR]

**Rule:** Each JS file corresponds to one page or isolated feature. Never a monolithic file with all application logic.

**Checks:** JS file with >300 lines or with >2 distinct responsibilities = violation. Inspect directory structure.

**Why:** Small, focused files are easier to generate, review, and maintain. AI works better with limited, clear context. A monolithic file with 2000 lines is impossible to review with quality.

**Correct example:**
```
assets/js/
├── app.js                  # global behavior (navbar, scroll)
├── auth/
│   ├── login.js            # login page logic
│   ├── signup.js           # signup page logic
│   └── reset-password.js   # password reset page logic
└── dashboard/
    ├── overview.js          # main panel logic
    └── reports.js           # reports logic
```

**Incorrect example:**
```
assets/js/
└── app.js                  # 3000 lines with everything together
```

---

### JS-011 — Conditional script loading [ERROR]

**Rule:** Each JS file should be loaded only on the page or context that uses it. Never load all scripts on all pages. In WordPress, use `wp_enqueue_script()` with a page condition. In other contexts, use the equivalent strategy (dynamic import, lazy loading, routes).

**Checks:** Grep for `wp_enqueue_script` without page conditional, or global `<script>` without lazy/conditional = violation.

**Why:** Loading unnecessary scripts increases load time and the risk of errors on pages that don't need that code. In projects, performance matters because end users frequently access via mobile connections.

**Correct example:**
```php
// WordPress — conditional loading
if (is_page('login')) {
    wp_enqueue_script('login-js', get_template_directory_uri() . '/assets/js/auth/login.js', [], '1.0', true);
}
```

```javascript
// SPA/Node — dynamic import
if (route === '/dashboard') {
    import('./dashboard/overview.js').then(function (module) {
        module.initialize();
    });
}
```

**Incorrect example:**
```php
// Loads EVERYTHING on ALL pages
wp_enqueue_script('app', get_template_directory_uri() . '/assets/js/app.js');
wp_enqueue_script('login', get_template_directory_uri() . '/assets/js/auth/login.js');
wp_enqueue_script('signup', get_template_directory_uri() . '/assets/js/auth/signup.js');
wp_enqueue_script('dashboard', get_template_directory_uri() . '/assets/js/dashboard/overview.js');
```

---

### JS-012 — Encapsulated initialization pattern [ERROR]

**Rule:** Every frontend JS file must encapsulate its logic. In the browser, use `document.addEventListener('DOMContentLoaded', ...)` or IIFE. In Node.js, use modules (module.exports / export). Never pollute the global scope.

**Checks:** File without `DOMContentLoaded`, IIFE, or `module.exports` at the top = violation. `var` in global scope outside encapsulation = violation.

**Why:** Variables and functions in global scope collide between scripts. In the project, where multiple JS files coexist on the same page, global scope pollution causes intermittent bugs that are extremely hard to diagnose.

**Correct example:**
```javascript
// Frontend — DOMContentLoaded
document.addEventListener('DOMContentLoaded', function initializeLogin() {
    var form = document.getElementById('proj-login-form');
    if (!form) return;
    // encapsulated logic
});
```

```javascript
// Node.js — module
function processData(data) {
    // encapsulated logic
}
module.exports = { processData: processData };
```

**Incorrect example:**
```javascript
// Loose code in global scope
var form = document.getElementById('proj-login-form');
form.addEventListener('submit', submitLogin);
var result = null;
```

---

### JS-013 — Guard clause at the start [ERROR]

**Rule:** If the page's main element or required resource doesn't exist, return immediately. Never execute logic against elements that may be null.

**Checks:** Grep for `getElementById`/`querySelector` without `if (!el) return` in the following lines = violation.

**Why:** In the project, scripts may be loaded on unexpected pages (cache, condition error). The guard clause prevents `Cannot read property of null` errors that generate noise in the log and confuse debugging.

**Correct example:**
```javascript
document.addEventListener('DOMContentLoaded', function initializeLogin() {
    var form = document.getElementById('proj-login-form');
    if (!form) return; // guard clause — exits if element doesn't exist

    // rest of the logic, safe that form exists
    form.addEventListener('submit', handleSubmit);
});
```

**Incorrect example:**
```javascript
document.addEventListener('DOMContentLoaded', function () {
    var form = document.getElementById('proj-login-form');
    // no guard clause — if form is null, the line below explodes
    form.addEventListener('submit', handleSubmit);
});
```

---

## 4. DOM manipulation

### JS-014 — Selection by ID or semantic class, never by tag [ERROR]

**Rule:** Use `getElementById` or `querySelector` with semantic selectors. Never select by generic tag (`div`, `p`, `span`).

**Checks:** Grep for `querySelector('div')`, `querySelector('p')`, `querySelectorAll('span')` and similar without class/ID = violation.

**Why:** Selection by tag is fragile — any change to the HTML breaks the JS. In the project, where AI generates both HTML and JS, semantic selectors create a clear contract between markup and behavior.

**Correct example:**
```javascript
var alert = document.getElementById('proj-login-alert');
var cards = document.querySelectorAll('.proj-benefit-card');
```

**Incorrect example:**
```javascript
var divs = document.querySelectorAll('div');
var paragraph = document.querySelector('p');
```

---

### JS-015 — IDs and classes with project namespace prefix [WARNING]

**Rule:** Elements manipulated by JS should use the project's defined namespace prefix to avoid collision with external libraries or other scripts.

**Checks:** Grep for `getElementById` and `querySelector` whose selector doesn't start with the project prefix = violation.

**Why:** The project uses Bootstrap and potentially other third-party scripts. Without a prefix, generic IDs like `login-form` or `submit` collide with framework classes or other plugins. Each project defines its prefix (e.g., `proj-`, `app-`, `dash-`).

**Correct example:**
```html
<!-- project prefix avoids collision -->
<form id="proj-login-form">
<button id="proj-btn-signup">
```

**Incorrect example:**
```html
<!-- may collide with Bootstrap or other scripts -->
<form id="login-form">
<button id="submit">
```

---

### JS-016 — addEventListener, never inline onclick [ERROR]

**Rule:** Events must be registered via `addEventListener`. Never use `onclick`, `onsubmit`, or similar attributes in HTML.

**Checks:** Grep for `onclick=`, `onsubmit=`, `onchange=` and similar in HTML/PHP files = violation.

**Why:** Inline events mix HTML and JS, breaking separation of concerns. Additionally, a strict Content Security Policy (CSP) blocks inline handlers — and the project should always use strict CSP in production.

**Correct example:**
```javascript
document.getElementById('proj-btn-submit').addEventListener('click', handleClick);
```

**Incorrect example:**
```html
<button onclick="handleClick()">Submit</button>
```

---

### JS-017 — Create elements via DOM API, never innerHTML for dynamic data [ERROR]

**Rule:** To insert dynamic user data, use `textContent` or DOM API (`createElement`, `appendChild`). `innerHTML` is only acceptable for static templates without user data.

**Checks:** Grep for `innerHTML\s*=` followed by a variable (not a static string literal) = violation.

**Why:** `innerHTML` with user data is an XSS vector. In the project, where applications handle financial and personal data, XSS is unacceptable. The rule is simple: user data always via `textContent`.

**Correct example:**
```javascript
// user data — textContent
element.textContent = userMessage;

// static template — innerHTML acceptable
container.innerHTML = '<span class="spinner-border spinner-border-sm"></span>';
```

**Incorrect example:**
```javascript
// user data via innerHTML — XSS vector
element.innerHTML = response.message;
```

---

## 5. AJAX communication

### JS-018 — fetch() for all communication, never XMLHttpRequest [ERROR]

**Rule:** All asynchronous communication must use `fetch()`. XMLHttpRequest is prohibited.

**Checks:** Grep for `XMLHttpRequest`, `new XMLHttpRequest`, `$.ajax`, `$.get`, `$.post` = violation.

**Why:** `fetch()` is the modern API, with a Promise-based interface. AI generates code with `fetch()` more predictably and consistently. XMLHttpRequest is verbose, error-prone, and not worth the maintenance.

**Correct example:**
```javascript
fetch(ajaxUrl, {
    method: 'POST',
    body: formData
})
    .then(function (resp) { return resp.json(); })
    .then(function (json) { /* handle response */ });
```

**Incorrect example:**
```javascript
var xhr = new XMLHttpRequest();
xhr.open('POST', url);
xhr.onreadystatechange = function () { /* ... */ };
xhr.send(formData);
```

---

### JS-019 — Nonce or token mandatory in every AJAX request [ERROR]

**Rule:** Every AJAX request must include an authentication/verification token (nonce in WordPress, CSRF token in other frameworks). Never hardcode tokens in HTML.

**Checks:** Grep for `fetch()` calls without `nonce`, `csrf`, `token`, or `_wpnonce` in body/headers = violation. Grep for hardcoded token in string literal = violation.

**Why:** Requests without origin verification allow CSRF. In the project, where applications handle financial data, every request must prove it came from a legitimate session. The token must be injected by the backend (e.g., `wp_localize_script()`, meta tag, template variable).

**Correct example:**
```javascript
// nonce injected by the backend — never hardcoded
var formData = new FormData();
formData.append('action', 'proj_login');
formData.append('nonce', appConfig.nonce);
```

**Incorrect example:**
```javascript
// hardcoded nonce — invalidates the protection
formData.append('nonce', 'abc123xyz');
```

---

### JS-020 — Action/endpoint with namespace prefix [ERROR]

**Rule:** Every AJAX action or endpoint name must use the project's namespace prefix to avoid collision. In WordPress, prefix the action. In REST APIs, use namespace in the URL.

**Checks:** Grep for `'action',` followed by string without project prefix = violation. REST endpoint without namespace in URL = violation.

**Why:** Without a prefix, actions like `login` or `signup` collide with other plugins or modules. In the project, each project defines its namespace and uses it consistently throughout the stack.

**Correct example:**
```javascript
// WordPress — action with project prefix
formData.append('action', 'proj_signup');

// REST API — namespace in URL
fetch('/api/proj/v1/signup', { method: 'POST', body: formData });
```

**Incorrect example:**
```javascript
// No prefix — guaranteed collision in multi-module environments
formData.append('action', 'signup');
```

---

### JS-021 — Error handling in every request [ERROR]

**Rule:** Every `fetch()` call must handle three paths: success, business error (`json.success === false` or HTTP status 4xx/5xx), and network error (`.catch()`).

**Checks:** Grep for `fetch(` and verify the chain includes `.catch(`. Fetch without `.catch()` = violation. Fetch without business error branch = violation.

**Why:** Requests without error handling leave the user without feedback. In the project, where user experience is a priority, it is never acceptable for an operation to fail silently. The user must always know what happened.

**Correct example:**
```javascript
fetch(url, { method: 'POST', body: formData })
    .then(function (resp) { return resp.json(); })
    .then(function (json) {
        if (json.success) {
            showAlert('Operation completed successfully.', 'success');
        } else {
            showAlert(json.data.message, 'danger');
        }
    })
    .catch(function () {
        showAlert('Connection error. Please try again.', 'danger');
    });
```

**Incorrect example:**
```javascript
fetch(url, { method: 'POST', body: formData })
    .then(function (resp) { return resp.json(); })
    .then(function (json) {
        // assumes it always succeeds — no catch, no error handling
        showAlert(json.data.message, 'success');
    });
```

---

### JS-022 — FormData for backend submission, never manual JSON without need [WARNING]

**Rule:** Prefer `FormData` for form submission. Manual JSON only when the API explicitly requires `application/json`. In WordPress, `FormData` is mandatory for `admin-ajax.php`.

**Checks:** Grep for `JSON.stringify` in fetch of form when `FormData` would suffice = violation. `admin-ajax.php` without `FormData` = violation.

**Why:** `FormData` automatically serializes form fields and supports file uploads without extra configuration. Manual JSON requires `JSON.stringify`, explicit headers, and backend parsing — unnecessary complexity for the majority of cases in the project.

**Correct example:**
```javascript
var formData = new FormData(document.getElementById('proj-form'));
formData.append('action', 'proj_save');
fetch(ajaxUrl, { method: 'POST', body: formData });
```

**Incorrect example:**
```javascript
// manual JSON when FormData would suffice
fetch(ajaxUrl, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ action: 'proj_save', name: name, email: email })
});
```

---

## 6. Visual feedback and UX

### JS-023 — Loading state in every async operation [ERROR]

**Rule:** While an async operation is in progress, the element that triggered it must be disabled and show a visual loading indicator. Prevents double clicks and informs the user.

**Checks:** Grep for `fetch(` and verify the button/element is disabled before and re-enabled in `.finally()`. Fetch without pre-send `disabled = true` = violation.

**Why:** Double clicks on financial operations (transfers, entries) cause record duplication. In the project, where applications handle money, loading state is security, not cosmetics.

**Correct example:**
```javascript
function setLoading(btn, loading) {
    if (loading) {
        btn.disabled = true;
        btn.dataset.originalText = btn.innerHTML;
        btn.innerHTML = '<span class="spinner-border spinner-border-sm"></span> Processing...';
    } else {
        btn.disabled = false;
        btn.innerHTML = btn.dataset.originalText;
    }
}

// usage
setLoading(button, true);
fetch(url, { method: 'POST', body: formData })
    .then(function (resp) { return resp.json(); })
    .then(function (json) { /* handle */ })
    .catch(function () { /* handle */ })
    .finally(function () { setLoading(button, false); });
```

**Incorrect example:**
```javascript
// no loading state — user clicks 5 times
fetch(url, { method: 'POST', body: formData })
    .then(function (resp) { return resp.json(); })
    .then(function (json) { /* handle */ });
```

---

### JS-024 — Feedback on every user action [ERROR]

**Rule:** Every user action must produce visual feedback: alert for errors, success message, or UI state change. The user must never be left without knowing the result of an action.

**Checks:** Each action handler (submit, click, etc.) must have a visual feedback call (alert, toast, CSS class). Handler without feedback = violation.

**Why:** Project users are regular people, not technicians. If an action produces no feedback, the user repeats it — generating duplications, frustration, and support tickets. Visual feedback is mandatory, not optional.

**Correct example:**
```javascript
function showAlert(container, message, type) {
    container.textContent = message;
    container.className = 'alert alert-' + type;
    container.classList.remove('d-none');
}

// after success
showAlert(alertContainer, 'Signup completed successfully!', 'success');

// after error
showAlert(alertContainer, 'Email already registered.', 'danger');
```

**Incorrect example:**
```javascript
// form submits, but no visual feedback
fetch(url, { method: 'POST', body: formData })
    .then(function (resp) { return resp.json(); })
    .then(function (json) {
        console.log(json); // console only — user sees nothing
    });
```

---

### JS-025 — Client validation as UX, not as security [WARNING]

**Rule:** JS validation serves for quick user feedback. Real validation always happens on the backend. Never rely solely on client validation.

**Checks:** Verify that the corresponding backend replicates all validation done in JS. Validation present only in JS = violation.

**Why:** Client-side validation is easily bypassed (DevTools, direct requests). In the project, where financial and personal data are at stake, security lives on the backend. JS only improves the user experience.

**Correct example:**
```javascript
// validates in JS for quick UX
if (password.length < 8) {
    showAlert(container, 'Password must be at least 8 characters.', 'danger');
    return;
}
// sends to backend which ALSO validates
submitForm(form);
```

**Incorrect example:**
```javascript
// validates only in JS — backend accepts anything
if (password.length >= 8) {
    submitForm(form);
}
// backend does not validate password length — security failure
```

---

## 7. Security

### JS-026 — Never store sensitive data on the client [ERROR]

**Rule:** Authentication tokens, passwords, API keys never go in `localStorage`, `sessionStorage`, or JS-accessible cookies. Sensitive data in memory (JS variable) dies with the page — and that's correct behavior.

**Checks:** Grep for `localStorage.setItem`, `sessionStorage.setItem`, `document.cookie` with token/password/key = violation.

**Why:** `localStorage` and `sessionStorage` are accessible by any script on the page, including compromised third-party scripts. In the project, where applications handle financial data, token leakage is a serious incident.

**Correct example:**
```javascript
// token in memory — dies with the page
var sessionToken = null;

function receiveToken(token) {
    sessionToken = token;
    // used for verification, never persisted
}
```

**Incorrect example:**
```javascript
// persisted token — accessible by any script on the page
localStorage.setItem('token', sessionToken);
// or
document.cookie = 'token=' + sessionToken;
```

---

### JS-027 — No eval(), Function(), or innerHTML with user data [ERROR]

**Rule:** Never execute dynamic code with `eval()` or `new Function()`. Never insert user data via `innerHTML`. These practices are XSS vectors.

**Checks:** Grep for `eval(`, `new Function(`, `innerHTML\s*=` with non-static data = violation. Zero tolerance.

**Why:** XSS allows an attacker to execute code in the user's browser, stealing sessions and data. In the project, with financial and personal data, XSS is unacceptable. The rule is absolute: no eval, no Function, no innerHTML with user data.

**Correct example:**
```javascript
// user data — textContent
var userName = response.name;
document.getElementById('proj-name').textContent = userName;

// conditional logic — no eval
var actions = {
    save: saveRecord,
    delete: deleteRecord
};
if (actions[action]) {
    actions[action]();
}
```

**Incorrect example:**
```javascript
// eval — executes arbitrary code
eval('var result = ' + serverResponse);

// innerHTML with user data — XSS
document.getElementById('proj-name').innerHTML = response.name;

// Function — same problem as eval
var fn = new Function('return ' + userData);
```

---

### JS-028 — Backend data is suspect [WARNING]

**Rule:** Even data from your own backend should be inserted with `textContent`, never with `innerHTML`. The database may have been compromised or contain malicious data inserted via another vector.

**Checks:** Grep for `innerHTML\s*=.*json` or `innerHTML\s*=.*response` or `innerHTML\s*=.*data` = violation. Any dynamic data via innerHTML = violation.

**Why:** Defense in depth. In the project, if the database is compromised and malicious data is inserted, the frontend should not amplify the attack by rendering malicious HTML. `textContent` neutralizes any payload.

**Correct example:**
```javascript
// backend data — still, textContent
var nameFromBackend = json.data.name;
document.getElementById('proj-user-name').textContent = nameFromBackend;
```

**Incorrect example:**
```javascript
// blindly trusts the backend
document.getElementById('proj-user-name').innerHTML = json.data.name;
// if the database has <script>alert('xss')</script>, it executes
```

---

## 8. Compatibility and performance

### JS-029 — Modern JavaScript without unnecessary transpilation [WARNING]

**Rule:** Prefer vanilla JS compatible with modern browsers. ES6+ features (`const`, `let`, arrow functions, template literals) are acceptable. If the project doesn't use a build step, code must run directly in the browser. If it uses a build step, document it in the project's CLAUDE.md.

**Checks:** Grep for `await`, `?.`, `??` in a project without a build step = violation. Check the project's CLAUDE.md to confirm if a build step exists.

**Why:** The project prefers simplicity. Projects without a build step eliminate a layer of complexity (Webpack, Babel, configs). When a project requires a build step, the decision must be explicit and documented — never implicit.

**Correct example:**
```javascript
// ES6+ in a project without build step — works in modern browsers
var message = 'Operation completed';
var items = list.map(function (item) { return item.name; });
```

**Incorrect example:**
```javascript
// Syntax that requires transpilation without a configured build step
const result = await fetch(url);
// optional chaining without verifying support
var name = user?.profile?.name;
```

**Exceptions:** Projects with a documented build step (Next.js, Vite, etc.) can use any feature supported by the transpiler.

---

### JS-030 — No unnecessary external libraries [ERROR]

**Rule:** External libraries only enter when justified by complexity not worth reimplementing. jQuery is prohibited. Each dependency must be approved and documented.

**Checks:** Grep for `jquery`, `$.(`, `$.ajax` = violation. Grep for `<script src=` external not documented in the project's CLAUDE.md = violation.

**Why:** Each dependency is an attack surface, a maintenance point, and a supply chain risk. In the project, with small teams, fewer dependencies mean fewer things to update, audit, and maintain. Vanilla JS handles 90% of cases.

**Correct example:**
```javascript
// Vanilla JS — no dependency
var element = document.getElementById('proj-container');
element.classList.add('active');
element.addEventListener('click', handleClick);
```

**Incorrect example:**
```javascript
// jQuery for something vanilla JS handles
$('#proj-container').addClass('active').on('click', handleClick);
```

**Exceptions:** Specialized libraries (e.g., QR code generator, complex charts) are acceptable when reimplementation doesn't make economic sense.

---

### JS-031 — Event delegation for dynamic lists [WARNING]

**Rule:** For elements added/removed dynamically, use event delegation on the parent container. Never register listeners on each individual item.

**Checks:** Grep for `.forEach(` + `addEventListener` inside a loop on dynamic lists = violation. Verify the listener is on the parent container.

**Why:** Dynamic lists (tables, cards, search results) change constantly. Registering listeners on each item creates memory leaks and orphan elements. Delegation is more performant and works with elements added after initialization.

**Correct example:**
```javascript
// delegation — one listener on the container
document.getElementById('proj-table').addEventListener('click', function (e) {
    var btn = e.target.closest('[data-action]');
    if (!btn) return;
    var action = btn.dataset.action;
    var id = btn.dataset.id;
    // handle action
});
```

**Incorrect example:**
```javascript
// listener on each element — breaks with items added later
rows.forEach(function (row) {
    row.querySelector('.btn-edit').addEventListener('click', handleEdit);
    row.querySelector('.btn-delete').addEventListener('click', handleDelete);
});
```

---

### JS-032 — No polling, prefer events [WARNING]

**Rule:** Never use `setInterval` to check for state changes. Use DOM events, fetch callbacks, MutationObserver, or WebSockets when needed.

**Checks:** Grep for `setInterval` = violation (except UI timers like countdowns). Each occurrence must have documented justification.

**Why:** Polling wastes CPU and battery, especially on mobile devices. In the project, where users access via mobile, client performance matters. Events are more efficient and respond instantly.

**Correct example:**
```javascript
// event — reacts when it happens
document.getElementById('proj-input').addEventListener('input', function (e) {
    updatePreview(e.target.value);
});

// MutationObserver for DOM changes
var observer = new MutationObserver(function (mutations) {
    // react to changes
});
observer.observe(container, { childList: true });
```

**Incorrect example:**
```javascript
// polling — checks every second if something changed
setInterval(function () {
    var value = document.getElementById('proj-input').value;
    if (value !== lastValue) {
        updatePreview(value);
        lastValue = value;
    }
}, 1000);
```

---

## 9. Formatting

### JS-033 — Indentation with 4 spaces [ERROR]

**Rule:** All indentation must use 4 spaces. Tabs are prohibited.

**Checks:** Grep for `\t` (literal tab) in JS files = violation. Verify with editor/linter.

**Why:** Indentation consistency is mandatory so that diffs are clean and code review (human or AI) is efficient. 4 spaces is the project standard across all domains (PHP, JS, CSS) — a single standard eliminates discussion.

**Correct example:**
```javascript
function calculateTotal(items) {
    var total = 0;
    items.forEach(function (item) {
        total += item.amount;
    });
    return total;
}
```

**Incorrect example:**
```javascript
function calculateTotal(items) {
	var total = 0; // tab instead of 4 spaces
	items.forEach(function (item) {
		total += item.amount;
	});
	return total;
}
```

---

### JS-034 — Opening braces on the same line [WARNING]

**Rule:** Opening braces go on the same line as the declaration. Never on the next line.

**Checks:** Grep for `^\s*\{` on an isolated line after `if`, `else`, `function`, `for`, `while` = violation.

**Why:** K&R style is the standard of the JavaScript ecosystem and what AI generates by default. Keeping the same style that AI naturally produces reduces friction in code review and avoids unnecessary reformatting.

**Correct example:**
```javascript
if (condition) {
    // body
}

function myFunction() {
    // body
}
```

**Incorrect example:**
```javascript
if (condition)
{
    // body
}

function myFunction()
{
    // body
}
```

---

### JS-035 — Maximum 120 characters per line [WARNING]

**Rule:** Lines exceeding 120 characters should be wrapped with logical alignment.

**Checks:** `grep -P '.{121,}' *.js`. Line >120 characters = violation.

**Why:** Long lines make code review difficult on split screens and in GitHub diffs. In the project, where review happens on various screens (including small laptops), 120 characters is the practical limit.

**Correct example:**
```javascript
var message = buildMessage(
    user.name,
    user.email,
    'Your operation was completed successfully.'
);
```

**Incorrect example:**
```javascript
var message = buildMessage(user.name, user.email, 'Your operation was completed successfully.', new Date().toISOString(), true);
```

---

### JS-036 — Semicolons mandatory [ERROR]

**Rule:** Every statement ends with `;`. Never rely on ASI (Automatic Semicolon Insertion).

**Checks:** Grep for statement lines (assignment, call, return) that don't end with `;` = violation.

**Why:** ASI has counter-intuitive rules that cause subtle bugs (e.g., return followed by a line break). In the project, where AI generates code and humans review, explicit semicolons eliminate an entire class of bugs.

**Correct example:**
```javascript
var name = 'your organization';
var amount = 1500;
var items = [1, 2, 3];
```

**Incorrect example:**
```javascript
var name = 'your organization'
var amount = 1500
var items = [1, 2, 3]
```

---

### JS-037 — Single quotes for strings [WARNING]

**Rule:** Prefer single quotes for strings. Template literals (backticks) only when interpolation or multiline strings are needed.

**Checks:** Grep for strings with double quotes (`"..."`) without need = violation. Backtick without `${` = violation.

**Why:** A single quote convention eliminates visual inconsistency. Single quotes are the most common standard in JavaScript projects and what AI tends to generate. Maintaining consistency reduces noise in diffs.

**Correct example:**
```javascript
var message = 'Operation completed successfully.';
var url = '/api/v1/users';

// template literal — justified by interpolation
var greeting = `Hello, ${user.name}!`;
```

**Incorrect example:**
```javascript
// double quotes without need
var message = "Operation completed successfully.";
var url = "/api/v1/users";

// template literal without interpolation — unnecessary
var name = `your organization`;
```

---

## Definition of Done — Delivery Checklist

> PRs that don't meet the DoD don't enter review. They are returned.

| # | Item | Rules | Verification |
|---|------|-------|--------------|
| 1 | Semicolons on all statements | JS-036 | Search for lines without `;` at the end |
| 2 | Indentation with 4 spaces, no tabs | JS-033 | Verify with editor/linter |
| 3 | No `eval()`, `Function()`, or `innerHTML` with user data | JS-027 | Grep for `eval(`, `new Function(`, `innerHTML =` |
| 4 | No sensitive data in localStorage/sessionStorage | JS-026 | Grep for `localStorage`, `sessionStorage` |
| 5 | Nonce/token in every AJAX request | JS-019 | Verify every `fetch()` call |
| 6 | Error handling (success + error + catch) in every fetch | JS-021 | Verify `.catch()` in every fetch chain |
| 7 | Loading state in async operations | JS-023 | Verify `disabled` and spinner on submit buttons |
| 8 | Visual feedback on every user action | JS-024 | Manually test each flow |
| 9 | Guard clause at the start of each initialization | JS-013 | Verify `if (!element) return;` |
| 10 | No unapproved external libraries | JS-030 | Verify imports and external scripts |
| 11 | Variables in camelCase, constants in UPPER_SNAKE_CASE | JS-006, JS-007 | Visual inspection |
| 12 | Named functions (no long anonymous ones) | JS-009 | Verify `function () {` with more than 1 line |
| 13 | DOMContentLoaded or equivalent encapsulation | JS-012 | Verify start of file |
| 14 | Semantic selectors with project prefix | JS-014, JS-015 | Verify `querySelector` and `getElementById` |
| 15 | Lines with maximum 120 characters | JS-035 | Verify with editor/linter |
