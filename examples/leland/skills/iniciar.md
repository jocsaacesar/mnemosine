# /iniciar — Session Bootstrap (Example)

This is a simplified version of the `/iniciar` skill used in the Leland collaboration interface.

## What it does

1. **Loads identity** — Reads CLAUDE.md to remember who it is.
2. **Loads memories** — Reads the memory index and all memory files.
3. **Loads skills** — Discovers and internalizes all available skills.
4. **Checks inbox** — Looks for new files the user may have dropped.
5. **Greets** — Short, natural greeting that signals readiness.

## Key design decisions

- **No status dumps.** The AI greets like a person, not a boot sequence.
- **Silent loading.** Memories and identity are internalized, not recited back.
- **Inbox awareness.** If the user left something, acknowledge it immediately.

## Full implementation

See the live skill at `.claude/skills/iniciar/SKILL.md` in the main project.
