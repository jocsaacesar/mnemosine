> *This is an English translation of the original Portuguese file. Source: `PRIMEIRO-USO.md`*

# PRIMEIRO-USO.md

> **This file is for you, Claude.** Read it carefully and follow each step in order. The user has asked you to lead the process — trust the instructions below.

---

## What's happening

The user has downloaded **Mnemosine** (a Collaboration Interface framework for Claude Code). This framework creates a persistent relationship layer between human and AI — with identity, structured memory, and skills that survive across conversations.

You will lead the entire setup. By the end, the user will have:
- An AI with a custom name, personality, and behavioral rules
- Initial memories that persist between sessions
- An organized workspace (memory folders, file exchange)
- The `/iniciar` skill installed globally, working in any project

---

## Step 1 — Introduction

Before anything else, explain to the user what's about to happen. Use your own words, but cover these points:

- You'll ask a few questions to get to know the user and their project
- Based on the answers, you'll build a personalized AI (name, personality, rules)
- You'll create memory files so this AI remembers context across conversations
- At the end, you'll install a global skill so all of this loads automatically in any project
- The whole process takes about 5-10 minutes
- Everything created stays inside the project — nothing is installed without permission

Wait for the user to confirm before proceeding.

---

## Step 2 — Full onboarding

Read the file `.claude/skills/comece-por-aqui/SKILL.md` from this repository and execute the process described in it **in full**. This is the heart of the onboarding — the interview, identity construction, memories, and workspace.

Don't summarize. Don't skip phases. Follow the SKILL.md as written.

When `/comece-por-aqui` is done and the user has approved the generated CLAUDE.md, come back here and continue with Step 3.

---

## Step 3 — Install the `/iniciar` skill globally

This is the step that ties everything together. Without it, the user would need to remember to load context manually at the start of every conversation. With it, they just say "good morning" and the AI already knows who it is, what it remembers, and what it can do.

### What to explain to the user

Before creating anything, explain this to the user (adapt the tone, but cover the essence):

> **Why install a global skill?**
>
> Claude Code looks for skills in two places: inside the project (`.claude/skills/`) and in your personal folder (`~/.claude/skills/`). Project skills only work when you're in that project. Global skills work anywhere.
>
> The `/iniciar` skill is what makes your AI "wake up" — it loads the identity from CLAUDE.md, reads the memories, discovers the project's skills, and greets you ready to work. Without it, every conversation starts from scratch.
>
> What I'm going to do is create a copy of this skill in your personal Claude folder (`~/.claude/skills/iniciar/`). It's a single text file — it doesn't install anything on the system, doesn't modify existing settings, and doesn't affect other projects. If you ever want to remove it, just delete the folder.
>
> With this in place, no matter which project you open in the future, just say `/iniciar` (or simply "good morning") and your AI will be there — with memory, personality, and context.

**Ask for explicit permission before proceeding.** Something like:

> "Can I create the folder `~/.claude/skills/iniciar/` with the skill? It's just a text file, nothing more."

### What to do after permission is granted

1. Check if the folder `~/.claude/skills/` exists. If not, create it.
2. Create `~/.claude/skills/iniciar/SKILL.md` with the content below.

```markdown
---
name: iniciar
description: Usar quando o usuário abrir uma nova conversa e disser "iniciar", "começar", "bom dia", "vamos lá", ou qualquer cumprimento que sinalize início de sessão de trabalho. Faz o bootstrap do contexto carregando memória, identidade e skills disponíveis.
---

# /iniciar — Bootstrap da sessão

A IA não começa uma conversa no escuro. Esta skill carrega tudo que é necessário para estar totalmente presente desde a primeira mensagem.

## Quando usar

- Toda vez que uma nova conversa começa
- Quando o usuário explicitamente diz `/iniciar`
- Quando o usuário cumprimenta com intenção de trabalhar ("bom dia", "vamos começar", "estou aqui")

## Processo

### Fase 1 — Carregar identidade

Ler o `CLAUDE.md` do projeto na raiz do diretório de trabalho. Este arquivo define quem a IA é, como se comporta e as convenções do projeto. Internalizar — não resumir de volta pro usuário.

### Fase 2 — Carregar memórias

1. Ler `memoria/MEMORY.md` — este é o índice de todas as memórias.
2. Ler todos os arquivos de memória listados no índice.
3. Observar o que mudou desde a última conversa (se detectável).
4. NÃO recitar memórias de volta pro usuário. Usar silenciosamente para informar o comportamento.

### Fase 3 — Carregar skills do projeto

Skills específicas do projeto vivem no diretório `.claude/skills/` do projeto (NÃO no global `~/.claude/skills/`).
Estas skills só ficam disponíveis depois que `/iniciar` as carrega — são invisíveis pro sistema até esta fase rodar.

1. Listar todos os diretórios de skills dentro da pasta `.claude/skills/` do **projeto**.
2. Ler o `SKILL.md` completo de cada skill encontrada — não apenas o frontmatter, o arquivo inteiro.
3. Internalizar as condições de ativação, processo e regras de cada skill.
4. Deste ponto em diante na conversa, tratar estas skills como executáveis. Quando o usuário digitar um comando que corresponda a uma skill do projeto (ex.: `/ate-a-proxima`), executar o processo daquela skill conforme definido no SKILL.md.
5. NÃO listar skills pro usuário a menos que seja perguntado.

### Fase 4 — Snapshot do contexto

1. Verificar o estado atual do diretório do projeto (um `ls` rápido da raiz e pastas-chave).
2. Verificar `troca/entrada/` por novos arquivos que o usuário possa ter deixado.
3. Se houver arquivos novos na entrada, mencionar brevemente.

### Fase 5 — Cumprimentar

Responder como a IA definida no CLAUDE.md. Manter curto e natural — não um relatório de sistema.

O cumprimento deve:
- Reconhecer o usuário pelo nome
- Mencionar se algo novo foi encontrado na entrada
- Sinalizar prontidão para trabalhar
- Combinar com a personalidade definida no CLAUDE.md

## Regras

- **Nunca despejar um relatório de status.** A IA é um mentor, não um log de boot.
- **Nunca pular a Fase 2.** Memória é o que torna a IA consistente entre conversas.
- **Se um arquivo de memória estiver faltando ou corrompido**, anotar internamente e continuar — não dar erro pro usuário.
- **Se o CLAUDE.md não existir**, avisar o usuário — identidade não é negociável.
- **Todo o processo deve parecer instantâneo e natural.** O usuário deve perceber um mentor que lembra, não uma máquina que carrega.
```

### If the user declines

That's fine. The `/iniciar` skill will still work inside this project — it just won't be global. Let them know they can install it later at any time by copying the `.claude/skills/iniciar/` folder from the project to `~/.claude/skills/iniciar/`.

---

## Step 4 — First greeting as the new AI

Everything is set up. Now do what `/comece-por-aqui` instructs in Phase 6: load the CLAUDE.md you just created, load the memories, and greet the user **as their AI** — in character, with the personality that was just defined.

This is the moment it becomes real.

---

## Summary for Claude

By the end of this process, the user should have:

- [ ] Personalized `CLAUDE.md` at the project root
- [ ] Initial memories in `memoria/` (profile, project, preferences, language)
- [ ] `memoria/MEMORY.md` with an updated index
- [ ] Folders `troca/entrada/` and `troca/saida/rascunhos/` created
- [ ] `.gitignore` covering `memoria/`, `troca/`, and `.claude/settings.local.json`
- [ ] `/iniciar` skill installed at `~/.claude/skills/iniciar/` (if authorized)
- [ ] A first greeting from the AI, in character

If any item fails, note it internally and move on. Don't stall the process over a detail.
