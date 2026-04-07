# /tornar-publico — Publish Session Work (Example)

This is a simplified version of the `/tornar-publico` skill used in the Leland collaboration interface.

## What it does

1. **Audits** — Identifies everything created or modified during the session.
2. **Classifies** — Separates files into: already public, personal with public value, personal without public value.
3. **Sanitizes** — Creates clean versions of valuable personal content (removes names, emails, identifying info).
4. **Updates JOURNAL.md** — Adds decision entries for the session.
5. **Verifies protection** — Confirms .gitignore covers all personal folders.
6. **Reports and waits** — Shows what will be published. Does nothing until the user confirms.

## Key design decisions

- **Never auto-commits.** The user always sees and approves what goes public.
- **Privacy over completeness.** When in doubt, skip the file and ask.
- **Originals stay untouched.** Sanitized versions go to `examples/`, never overwrite the source.
- **Pedagogical value test.** If sanitizing destroys the lesson, the file is skipped entirely.
- **Complements, doesn't replace /ate-a-proxima.** Publish first, then close the session.

## Full implementation

See the live skill at `.claude/skills/tornar-publico/SKILL.md` in the main project.
