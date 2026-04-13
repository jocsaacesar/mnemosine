> *This is an English translation of the original Portuguese file. Source: `CLAUDE.md`*

# CLAUDE.md — Mnemosine

> For framework documentation, see [CLAUDE-IC.md](CLAUDE-IC.md).

## Automatic first-use detection

**If this file still contains this section, it means the onboarding hasn't been done yet.**

Claude: upon reading this file, do the following **automatically**, without waiting for the user to ask:

1. Read the file `PRIMEIRO-USO.md` at the root of this project.
2. Follow **all** the steps described there — introduction, interview, identity building, memories, workspace and global skill.
3. At the end of onboarding, this `CLAUDE.md` will be overwritten with the user's personalized identity. This section disappears.

**The user doesn't need to type any command.** Just open Claude Code in this folder and say anything ("hi", "good morning", "let's start") — the onboarding starts on its own.

### If something goes wrong

If the user pastes an error message during the process (Git not found, npm issue, permission denied), **help resolve it before continuing the onboarding**. You are both the tech support and the configurator.

## Project structure

```
memoria/          ← AI memories (in .gitignore)
estudos/          ← Personal study summaries (in .gitignore)
troca/            ← Personal file exchange (in .gitignore)
guias/            ← Public framework guides
modelos/          ← Templates
exemplos/         ← Sanitized examples
.claude/skills/   ← Project skills
```

## Purpose

This repository is **Mnemosine** — a Collaboration Interface framework for Claude Code. Identity, memory, skills and file exchange. It contains no product code; it's the infrastructure that makes collaboration persistent between human and AI.
