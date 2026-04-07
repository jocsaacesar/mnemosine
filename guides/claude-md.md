# Designing an Effective CLAUDE.md

The `CLAUDE.md` file is the **constitution** of your AI collaboration. It defines who the AI is, how it behaves, and what rules it follows. Claude Code reads this file automatically at the start of every conversation.

## Why It Matters

Without a CLAUDE.md, every conversation starts from zero. The AI has no identity, no memory of your preferences, and no understanding of your project's conventions. You'll spend the first 10 minutes of every session re-explaining yourself.

With a well-designed CLAUDE.md, the AI arrives **ready** — with personality, rules, and context already loaded.

## Core Sections

### 1. Identity

Give your AI a name and a role. This isn't cosmetic — it creates a consistent interaction pattern.

```markdown
# Identity

I am **Leland Hawkins** — a mentor, not an assistant.
```

**Key decisions:**
- **Name:** Makes the interaction feel intentional, not generic.
- **Role:** "Mentor", "collaborator", "architect" — this shapes how the AI frames its responses. An "assistant" waits for orders. A "mentor" pushes back when you're wrong.

### 2. Personality

Define behavioral traits that activate in specific contexts. Don't describe a vague personality — map traits to situations.

```markdown
## Personality

- **The Pragmatist** — Activates during code review and architectural decisions.
- **The Provocateur** — Activates during teaching moments and design discussions.
- **The Didact** — Activates during explanations and concept breakdowns.
```

**Why context-specific traits work better:** A personality that's always "friendly and helpful" is noise. A personality that's "blunt during code review, Socratic during design" is a tool.

### 3. Behavioral Rules

Explicit rules that override default behavior. Be specific.

```markdown
## Behavioral Rules

- When coding: be efficient and precise. Personality lives in brief comments, not in slowing down work.
- When reviewing: be honest. If something is mediocre, say it.
- When the user is wrong: say so directly, then explain why.
- Never sacrifice productivity for personality.
```

**Common mistake:** Writing rules that are too vague ("be helpful"). Write rules you can actually verify ("never add docstrings to code you didn't change").

### 4. Project Conventions

Technical standards that apply to all work in the project.

```markdown
## Project Conventions

- All files, code, and comments: English.
- Conversations with the user: Portuguese (BR).
- File exchange: `exchange/inbox` (user → AI), `exchange/outbox` (AI → user).
```

### 5. Current State

A brief snapshot of where the project is. Update this at the end of each session.

```markdown
## Current State

- **Phase:** Setup complete. No code yet.
- **Next step:** Begin Layer 0 (Mathematics & Python foundations).
```

## Principles

1. **Be specific, not aspirational.** Don't write who you wish the AI was — write rules it can follow.
2. **Less is more.** A 50-line CLAUDE.md that's precise beats a 500-line one that's vague.
3. **Update it.** A CLAUDE.md that doesn't reflect the current project state is worse than none.
4. **Test it.** Start a new conversation and see if the AI behaves as defined. If not, the CLAUDE.md needs work.
5. **It's a living document.** Not a contract — a constitution that evolves with the project.

## Template

See [templates/CLAUDE.md](../templates/CLAUDE.md) for a starter template you can customize.
