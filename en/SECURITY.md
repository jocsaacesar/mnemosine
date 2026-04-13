> *This is an English translation of the original Portuguese file. Source: `SECURITY.md`*

# Security Policy

## Scope

This project is a documentation framework — it contains no executable code, dependencies or production services. The main security concern is **accidental exposure of personal data** through memory files, exchange files or misconfigured `.gitignore`.

## Reporting a vulnerability

If you discover a security issue — such as personal data exposed in a public file, a gap in `.gitignore` coverage, or a skill that could leak sensitive information — report it privately:

1. Go to the **Security** tab of this repository.
2. Click **Report a vulnerability**.
3. Describe what you found and where.

We will respond within 48 hours and resolve the issue as quickly as possible.

## What counts as a security issue

- Personal data (names, emails, credentials) visible in any public file.
- A `.gitignore` rule that fails to protect `memoria/`, `troca/` or local configurations.
- A skill definition that could publish private content without user confirmation.
- Any file in `exemplos/` that contains personally identifiable information.

## What does NOT count

- Typos, formatting or broken links — use a [Bug Report](../../issues/new?template=bug-report.md).
- Feature suggestions — use a [Feature Request](../../issues/new?template=feature-request.md).

## Design principles

This project follows a strict public/private separation:

- **Public:** guides, templates, examples, skills, CLAUDE.md, JOURNAL.md
- **Private (in gitignore):** memoria/, troca/, .claude/settings.local.json
- **Sanitization:** The `/tornar-publico` skill checks protection before each publication and never commits without explicit user approval.

If you believe any of these boundaries can be bypassed, that's a security issue worth reporting.
