> *This is an English translation of the original Portuguese file. Source: `GLOSSARIO_DE_SKILLS.md`*

# Skills Glossary

A practical reference for every skill available in Mnemosine. Each entry explains what the skill does, when to use it, what to expect, and what it will never do.

**Core skills** come included and work right away. **Marketplace skills** are optional — you install them by copying the folder into `.claude/skills/`.

---

## How skills work

Skills are custom commands. You type `/<skill-name>` in a Claude Code conversation, and it runs a multi-step workflow defined in `.claude/skills/<skill-name>/SKILL.md`.

Skills **are not magic** — they are structured instructions that make the AI behave consistently. Think of them as recipes: same ingredients, same steps, same result every time.

### Key principles

- **All skills in this repository are project-local.** They live in `.claude/skills/` inside the project folder. They do NOT modify your global `~/.claude/` configuration. Your existing Claude Code setup is not affected.
- **Claude Code auto-discovers skills** from the `.claude/skills/` folder when it opens a project. You don't need to install or register anything — they become available immediately.
- **`/iniciar` reloads skills** at the start of each session, ensuring they are fresh in the conversation context. But the very first skill — `/comece-por-aqui` — works without `/iniciar` because it was designed to run in a blank environment.
- **Each skill has explicit activation rules.** Some run automatically (like `/iniciar` when you greet), others only fire when you type the exact command.
- **Skills don't stack.** Run one at a time. Wait for it to finish before calling another.
- **You are always in control.** No skill commits, publishes, or deletes anything without your explicit approval.
- **Want a global skill?** If you want `/iniciar` available in any project (not just this one), manually copy it to `~/.claude/skills/iniciar/`. This is entirely optional and is never done automatically.

---

## /comece-por-aqui

> **Your first command. Run it once after cloning the repository. No prior setup needed.**

### Purpose

Builds your entire personalized collaboration interface from scratch — identity, memories, workspace — through a guided conversation.

### When to use

- Right after installing Mnemosine (the CLAUDE.md automatically detects first use and starts onboarding).
- If you want to redo your setup from scratch.

### Bootstrap note

This is the **only skill that runs without `/iniciar`**. It was designed to work in a completely empty environment — no personalized CLAUDE.md, no memories, no prior context. Claude Code auto-discovers it from the `.claude/skills/` folder. In the default installation, CLAUDE.md detects first use and triggers onboarding automatically — the user doesn't need to type any command.

### What happens

1. The AI greets you and explains what will happen (~5 minutes).
2. It asks **five questions**, one at a time:
   - **Who are you?** Your role, experience, what you do.
   - **What are you building?** Your project, goals, motivation.
   - **How do you like to work?** Your preferred collaboration style.
   - **What should the AI avoid?** Things that annoy you in AI interactions.
   - **Name and language?** What to call your AI and which language for conversations.
3. Based on your answers, it generates a personalized `CLAUDE.md` and **shows it to you for approval**.
4. After approval, it creates your initial memory files and workspace folders.
5. It greets you for the first time **in character** — as your newly created AI.

### What it will never do

- Dump all the questions at once. It's a conversation, one question at a time.
- Write files without showing you first. You approve the CLAUDE.md before it's saved.
- Force a specific personality template. Your AI is shaped by your answers, not by a template.

### After it's done

You're set up. From now on, start each session with `/iniciar`.

---

## /iniciar

> **Session start. The first thing you type.**

### Purpose

Loads everything the AI needs to be fully present: identity, memories, skills, and inbox. The AI arrives ready to work, not blank.

### When to use

- Every time you open a new conversation.
- You can also simply say "good morning", "let's go", or any greeting — the AI recognizes the intent.

### What happens

1. **Loads identity** — Reads `CLAUDE.md`. Internalizes personality, rules, and conventions.
2. **Loads memories** — Reads all memory files from the index. Applies them silently.
3. **Loads skills** — Discovers and internalizes all available skills for the session.
4. **Checks inbox** — Looks in `troca/entrada/` for files you may have left. Mentions them if found.
5. **Greets you** — A short, natural greeting, in character. Not a system report.

### What it will never do

- Recite your memories back to you. It uses them silently.
- List all loaded skills. It knows them — you don't need a boot log.
- Skip loading. Even for a quick question, `/iniciar` ensures consistency.

### What it looks like in practice

> "Joc. Inbox empty, everything loaded. What are we working on?"

Or if there's something new:

> "Joc. Saw you left a file in the inbox — already took a look. Where do we start?"

---

## /tornar-publico

> **Publish your work. Run it when you have something worth sharing.**

### Purpose

Takes the session's work, separates personal from public, sanitizes sensitive content, and prepares everything for the public repository. Nothing is committed without your approval.

### When to use

- When you created or modified content during a session that has value for other users.
- Usually run near the end of a session, before `/ate-a-proxima`.
- **Manual command only** — type `/tornar-publico` explicitly.

### What happens

1. **Audits** — Identifies every file created or modified during the session.
2. **Classifies** — Places each file into one of three categories:
   - *Already public* — guides, templates, README, JOURNAL.
   - *Personal, with public value* — memories, skills, deliverables that teach something.
   - *Personal, no public value* — drafts, configs, temporary items.
3. **Sanitizes** — Creates clean versions of valuable personal content:
   - Real names -> "the user" or "the project owner".
   - Emails, company names, identifiable URLs -> removed.
   - Structure, lessons, and format -> preserved.
4. **Updates JOURNAL.md** — Adds new decision entries from the session.
5. **Verifies** — Checks that `.gitignore` covers all personal folders. Asks: "If someone clones this repo, can they identify the user?"
6. **Reports** — Shows exactly what will be published, what was sanitized, and what was skipped.
7. **Waits** — Does nothing until you say "go ahead."

### What it will never do

- Commit without your approval. Always shows and waits.
- Publish personal data. When in doubt, it skips and asks.
- Overwrite your original files. Sanitized versions go to `exemplos/`, originals stay untouched.
- Sanitize in a way that destroys the lesson. If cleaning a file makes it useless, it skips it entirely.

### What it looks like in practice

```
## Ready to publish

### New/updated public files:
- guias/novo-guia.md
- JOURNAL.md (2 new entries)

### Sanitized from personal:
- memoria/objetivos_projeto.md -> exemplos/leland/memoria/objetivos_projeto.md

### Skipped (personal, no public value):
- troca/saida/rascunhos/notas-brutas.md (draft, not ready)

### Protection verified:
- .gitignore covers: memoria/, troca/, .claude/settings.local.json

Confirm to proceed?
```

---

## /ate-a-proxima

> **Session end. The last thing you type.**

### Purpose

Closes the session cleanly: audits what changed, updates `CLAUDE.md` to reflect the current state, syncs all memories, and says goodbye like a mentor — not like a machine shutting down.

### When to use

- At the end of a work session.
- **Manual command only** — type `/ate-a-proxima` explicitly.
- Never fires on implicit signals. If you say "bye" or "that's it for today", the AI simply says goodbye naturally without running the full shutdown.

### What happens

1. **Audits** — Reviews all files created, modified, or deleted during the session.
2. **Updates CLAUDE.md** — Syncs the identity file with the current project state. Changes only what actually changed — surgical, not wholesale.
3. **Syncs memories** — Ensures all memory files are up to date and mirrored between the project folder and the system folder.
4. **Says goodbye** — A brief, warm closing that acknowledges what was accomplished and hints at what's next.

### What it will never do

- Fire automatically. You must type the command.
- Write a changelog. CLAUDE.md is a living document, not a log.
- Bloat CLAUDE.md. Only updates what actually changed in this session.
- Give a cold, robotic goodbye. The farewell comes from the AI's personality.

### What it looks like in practice

> "Good session. We built the skills glossary and tweaked the onboarding flow. Next time, we push to GitHub. Get some rest."

---

## /criar-skill

> **Create new skills without writing the SKILL.md by hand.**

### Purpose

A meta-skill that creates other skills through a guided interview. It reads the patterns from the project's existing skills, asks questions one at a time, suggests rules and improvements, and generates the complete SKILL.md.

### When to use

- When you want to create a new skill for the project.
- **Manual command only** — type `/criar-skill` explicitly.

### What happens

1. **Reads patterns** — Analyzes all existing skills to understand the project's naming, format, complexity, and tone.
2. **Interviews** — Asks 5 questions, one at a time:
   - What does the skill do?
   - What do you want to call it? (suggests names based on patterns)
   - When should it fire? When should it NOT?
   - What's the step-by-step?
   - What rules should it follow? (proactively suggests based on purpose)
3. **Generates** — Creates the complete SKILL.md following the project's format.
4. **Shows** — Presents the result for approval before saving.
5. **Saves** — Creates the folder in `.claude/skills/` and confirms.

### What it will never do

- Dump all questions at once. One at a time, always.
- Save without approval. Shows the full result first.
- Bloat the skill. If you described something simple with 2 phases, it won't turn it into 6.
- Add rules you didn't ask for without checking first.

---

## /marketplace

> **Discover extra skills without leaving the conversation.**

### Purpose

Explores the `marketplace/` folder, describes each available skill in plain language, shows which ones are already active, and recommends the ones that make sense for your profile and project.

### When to use

- When you want to know what's available beyond the core skills.
- **Manual command only** — type `/marketplace` explicitly.

### What happens

1. **Inventory** — Reads all skills in `marketplace/` and checks which are already active in `.claude/skills/`.
2. **Context** — Reads your CLAUDE.md and memories to understand your profile and project.
3. **Catalog** — Presents each skill with its name, plain-language description, when it's useful, and status (activated / available).
4. **Recommendation** — Suggests at most 2 skills with a concrete reason based on your context. If none make sense, it says so honestly.
5. **Activation** — If you want, copies the skill to `.claude/skills/` and confirms. Also deactivates if you ask.

### What it will never do

- Activate without asking. Always asks first.
- Deactivate core skills (/iniciar, /comece-por-aqui, /ate-a-proxima, /criar-skill).
- Push skills on you. If nothing makes sense, it says so.
- Use technical jargon. Describes everything in language anyone can understand.

---

## Marketplace skills

The skills below live in a separate repository: **[interface-colaboracao-skills](https://github.com/jocsaacesar/interface-colaboracao-skills)**. To explore and activate, type `/marketplace` or install manually.

---

## /tornar-publico *(marketplace)*

> **Publish your work. Available in the [marketplace](https://github.com/jocsaacesar/interface-colaboracao-skills).**

Takes the session's work, separates personal from public, sanitizes sensitive content, and prepares everything for the public repository. Nothing is committed without your approval.

---

## /revisar-texto *(marketplace)*

> **Spelling and convention review. Available in the [marketplace](https://github.com/jocsaacesar/interface-colaboracao-skills).**

Scans all Markdown files in the project, identifies spelling errors, convention inconsistencies, and formatting issues. Ambiguous corrections ask for individual approval. Consolidated report at the end.

See the [full documentation](https://github.com/jocsaacesar/interface-colaboracao-skills/blob/main/revisar-texto/SKILL.md).

---

## Skills lifecycle summary

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│   First time:    /comece-por-aqui                           │
│                  (interview -> identity -> memories -> done) │
│                                                             │
│   Each session:  /iniciar                                   │
│                  (identity -> memories -> skills -> greeting)│
│                       │                                     │
│                       ▼                                     │
│                  [ your work ]                              │
│                       │                                     │
│                       ▼                                     │
│                  /ate-a-proxima                              │
│                  (audit -> CLAUDE.md -> sync -> goodbye)     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Creating your own skills

The fastest way: type `/criar-skill` and the AI guides you through an interview that generates the complete SKILL.md.

If you prefer to create them by hand:

- **[guias/skills.md](guias/skills.md)** — Complete guide on skill design.
- **[modelos/skill-modelo/SKILL.md](modelos/skill-modelo/SKILL.md)** — Starter template.

Good candidates for new skills:
- Code review with criteria specific to your project.
- Planning flows (breaking a task into steps before executing).
- Deploy checklists.
- Any multi-step process you repeat and want to be consistent.

The golden rule: **if you've explained the same process to the AI three times, it's a skill.**
