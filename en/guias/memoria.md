> *This is an English translation of the original Portuguese file. Source: `guias/memoria.md`*

# Using the memory system

Claude Code has a built-in memory system that persists information across conversations. This guide explains how to use it intentionally -- not just let it accumulate.

## How memory works

Memory files live in two places:
- **System folder** (`~/.claude/projects/<project>/memory/`) -- loaded automatically by Claude Code.
- **Project folder** (`memoria/`) -- visible and editable by the human.

Both should stay in sync. The system folder is what Claude reads automatically; the project folder is what you can see and edit directly.

### MEMORY.md

The `MEMORY.md` file is an **index**, not a memory itself. Each line points to a memory file with a brief description. Claude reads this index to decide which memories are relevant.

```markdown
- [Language convention](feedback_idioma.md) -- Project files in Portuguese, technical terms in English when needed
- [User profile](usuario_perfil.md) -- Project owner, values depth and contextual mentoring
```

Keep entries under 150 characters. Lines past the 200th will be truncated.

## Memory types

| Type | Purpose | When to save |
|------|---------|--------------|
| **user** | Who the human is -- role, preferences, skill level | When you learn details about the user |
| **feedback** | How the AI should behave -- corrections and confirmations | When the user corrects or validates an approach |
| **project** | Work context -- goals, deadlines, decisions | When you learn who/what/why/when about the project |
| **reference** | Pointers to external resources | When you discover where information lives outside the project |

## Memory file format

```markdown
---
name: Memory title
description: One-line description used to determine relevance
type: user | feedback | project | reference
---

Memory content.

**Why:** The reason this matters.

**How to apply:** When and how to use this information.
```

## What to save

- User preferences that affect how the AI should work
- Decisions that aren't obvious from the code
- Corrections -- things the AI got wrong and shouldn't repeat
- Validations -- approaches that worked and should continue
- Pointers to external systems (Linear boards, Slack channels, dashboards)

## What NOT to save

- Code patterns (read the code instead)
- Git history (use `git log`)
- Debugging solutions (the fix is in the code)
- Anything that's already in the CLAUDE.md
- Temporary task state (use tasks instead)

## Principles

1. **Transparency.** The human should be able to read, edit, and delete any memory. No hidden state.
2. **Relevance over completeness.** Don't save everything -- save what changes behavior.
3. **Update, don't duplicate.** Check if a memory already exists before creating a new one.
4. **Memories age.** Information gets outdated. Verify before acting on old memories.
5. **The human is the authority.** If a memory conflicts with what the human says now, trust the human.

## Template

See [modelos/modelo-de-memoria.md](../modelos/modelo-de-memoria.md) for a starter template.
