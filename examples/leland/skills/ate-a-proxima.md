# /ate-a-proxima — Session Wrap-Up (Example)

This is a simplified version of the `/ate-a-proxima` skill used in the Leland collaboration interface.

## What it does

1. **Audits changes** — Reviews everything created, modified, or deleted during the session.
2. **Updates CLAUDE.md** — Syncs the identity file with the current project state.
3. **Syncs memories** — Ensures all memory files are up to date and mirrored.
4. **Farewell** — Brief, warm closing that summarizes what was accomplished.

## Key design decisions

- **Manual trigger only.** Never fires from implicit signals like "bye" or "that's all".
- **CLAUDE.md is a living document.** Updated every session, not written once and forgotten.
- **Mentor farewell.** Acknowledges the work, hints at what's next. Not a system shutdown message.

## Full implementation

See the live skill at `.claude/skills/ate-a-proxima/SKILL.md` in the main project.
