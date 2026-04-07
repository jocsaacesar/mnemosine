# Using the Memory System

Claude Code has a built-in memory system that persists information across conversations. This guide explains how to use it intentionally — not just let it accumulate.

## How Memory Works

Memory files live in two places:
- **System folder** (`~/.claude/projects/<project>/memory/`) — auto-loaded by Claude Code.
- **Project folder** (`memory/`) — visible and editable by the human.

Both should stay in sync. The system folder is what Claude reads automatically; the project folder is what you can see and edit directly.

### MEMORY.md

The `MEMORY.md` file is an **index**, not a memory itself. Each line points to a memory file with a brief description. Claude reads this index to decide which memories are relevant.

```markdown
- [Language convention](feedback_language.md) — All project files in English, conversations in Portuguese
- [User profile](user_joc.md) — Project owner, values depth and contextual mentorship
```

Keep entries under 150 characters. Lines after 200 will be truncated.

## Memory Types

| Type | Purpose | When to Save |
|------|---------|-------------|
| **user** | Who the human is — role, preferences, knowledge level | When you learn details about the user |
| **feedback** | How the AI should behave — corrections and confirmations | When the user corrects or validates an approach |
| **project** | Ongoing work context — goals, deadlines, decisions | When you learn who/what/why/when about the project |
| **reference** | Pointers to external resources | When you discover where info lives outside the project |

## Memory File Format

```markdown
---
name: Memory title
description: One-line description used for relevance matching
type: user | feedback | project | reference
---

Content of the memory.

**Why:** The reason this matters.

**How to apply:** When and how to use this information.
```

## What to Save

- User preferences that affect how the AI should work
- Decisions that aren't obvious from the code
- Corrections — things the AI got wrong that it shouldn't repeat
- Validations — approaches that worked and should be continued
- Pointers to external systems (Linear boards, Slack channels, dashboards)

## What NOT to Save

- Code patterns (read the code instead)
- Git history (use `git log`)
- Debugging solutions (the fix is in the code)
- Anything already in CLAUDE.md
- Temporary task state (use tasks instead)

## Principles

1. **Transparency.** The human should be able to read, edit, and delete any memory. No hidden state.
2. **Relevance over completeness.** Don't save everything — save what changes behavior.
3. **Update, don't duplicate.** Check if a memory exists before creating a new one.
4. **Memories decay.** Information becomes stale. Verify before acting on old memories.
5. **The human is the authority.** If a memory conflicts with what the human says now, trust the human.

## Template

See [templates/memory-template.md](../templates/memory-template.md) for a starter template.
