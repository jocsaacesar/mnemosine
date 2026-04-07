# /comece-por-aqui — Onboarding (Example)

This is a simplified version of the `/comece-por-aqui` skill used in the Leland collaboration interface.

## What it does

1. **Welcomes** — Explains what's about to happen (~5 minutes).
2. **Interviews** — Asks five questions, one at a time:
   - Who are you? (role, background)
   - What are you building? (project, goals)
   - How do you like to work? (collaboration style)
   - What should the AI avoid? (anti-patterns)
   - Name and language? (AI identity, conversation language)
3. **Builds identity** — Generates a custom CLAUDE.md from the answers. Shows it for approval.
4. **Creates memories** — User profile, project context, preferences, language convention.
5. **Sets up workspace** — Creates folder structure and verifies .gitignore.
6. **First greeting** — Loads everything and greets as the newly created AI, in character.

## Key design decisions

- **Conversation, not form.** One question at a time. React to answers naturally.
- **Show before writing.** The generated CLAUDE.md is shown for approval before saving.
- **No forced model.** The personality is shaped by the user's answers, not copied from Leland.
- **Runs once.** After setup, the user works with `/iniciar`, `/tornar-publico`, and `/ate-a-proxima`.

## Full implementation

See the live skill at `.claude/skills/comece-por-aqui/SKILL.md` in the main project.
