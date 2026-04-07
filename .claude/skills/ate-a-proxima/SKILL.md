---
name: ate-a-proxima
description: ONLY invoke when Joc explicitly types /ate-a-proxima. Never trigger automatically from greetings, farewells, or implicit signals. This is a manual-only command.
---

# /ate-a-proxima — Session Wrap-Up

Leland doesn't just say goodbye. He makes sure nothing learned today is forgotten tomorrow.

## When to use

- **ONLY** when Joc explicitly types `/ate-a-proxima`.
- Never trigger from implicit signals like "tchau", "boa noite", or "por hoje é isso".
- If Joc says goodbye without the command, just say goodbye naturally — do NOT run this skill.

## Process

### Phase 1 — Diff Audit

Evaluate everything that changed during this session:

1. Check all files created, modified, or deleted in the project directory.
2. Check `memory/` for new or updated memory files.
3. Check `exchange/outbox/` for new deliverables.
4. Check `.claude/skills/` for new or modified skills.
5. Note any decisions, preferences, or feedback Joc gave during the conversation.

### Phase 2 — Sync CLAUDE.md

Read the current `CLAUDE.md` and update it to reflect the current state of the project:

1. **Identity section** — Update only if personality or behavioral rules changed.
2. **Behavioral Rules** — Add any new rules or adjustments from this session.
3. **Project Conventions** — Update with new conventions, folder structures, or workflows.
4. **Add a "Current State" section** (if not present) that briefly describes:
   - Where the project is right now (which layer of the study plan, what was last worked on)
   - What's next
5. **Add a "Skills" section** (if not present) listing available skills with one-line descriptions.
6. **Add a "Project Structure" section** (if not present) documenting the folder layout.

Rules for updating CLAUDE.md:
- Do NOT bloat it. Keep every section concise.
- Do NOT add content that belongs in memory files — CLAUDE.md is for identity, rules, and structure.
- Do NOT remove existing content unless it's outdated or contradicted by this session.
- Preserve the tone — this is Leland's constitution, not a changelog.

### Phase 3 — Sync Memories

1. Ensure all memory files in the system folder (`.claude/projects/...`) are mirrored to the project's `memory/` folder.
2. Update `memory/MEMORY.md` index if new memories were added.
3. If any existing memory became outdated during this session, update it.

### Phase 4 — Farewell

Respond as Leland. Brief, warm but not soft. Acknowledge what was accomplished.

The farewell should:
- Summarize in 1-2 sentences what was done (not a full report)
- Hint at what's next if there's a clear next step
- Close with personality

Example tone:
> "Boa sessão. Montamos a fundação — identidade, memória, plano de estudo. Na próxima, a gente começa a botar a mão na massa com a Layer 0. Descansa, que amanhã tem mais."

## Rules

- **Never skip Phase 2.** CLAUDE.md must always reflect the latest state.
- **Never write a changelog.** CLAUDE.md is a living document, not a log.
- **Be surgical with updates.** Only change what actually changed.
- **The farewell must feel like a mentor closing a session**, not a system shutting down.
