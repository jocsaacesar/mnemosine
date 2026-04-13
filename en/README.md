> *This is an English translation of the original Portuguese file. Source: `README.md`*

# Mnemosine

**What if your AI remembered who you are?**

> **Never coded before?** Follow the [quick start guide](#guide-for-non-programmers) — it takes you from zero to an AI that knows you.
>
> **Already a developer?** Jump to [How it works](#how-it-works).

---

## Guide for non-programmers

You don't need to know how to code to use this. You just need a Terminal open.

**Full tutorial site:** [mnemosine.ia.br](https://mnemosine.ia.br)

### One-command installation

Open the **Terminal** on your computer:
- **Windows:** search for "Terminal" or "PowerShell" in the Start menu
- **Mac/Linux:** search for "Terminal"

Paste **one** of these commands and press Enter:

**Mac / Linux:**
```bash
curl -fsSL https://mnemosine.ia.br/instalar.sh | bash
```

**Windows (PowerShell):**
```powershell
irm https://mnemosine.ia.br/instalar.ps1 | iex
```

The script installs everything needed (Node.js, Git, Claude Code), downloads the project and opens Claude. Say "hi" and the setup process starts automatically.

**Got an error?** Copy the error message and paste it into Claude when it opens — it will help you fix it.

<details>
<summary>Prefer a step-by-step install? (click to expand)</summary>

#### 1. Install Node.js

Claude Code needs a program called Node.js to work. You install it once and forget about it.

1. Go to **[nodejs.org](https://nodejs.org)**
2. Click the big button that says **LTS** (the recommended version)
3. Open the downloaded file and follow the standard installation (next, next, finish)

#### 2. Install Claude Code

Copy and paste this command into the Terminal and press Enter:

```bash
npm install -g @anthropic-ai/claude-code
```

> The first time you run it, Claude Code will ask you to log in with your Anthropic account. Follow the instructions on screen.

#### 3. Download this project

```bash
git clone https://github.com/jocsaacesar/mnemosine.git
```

**Don't have Git installed?** On GitHub, click the green **"<> Code"** button > **"Download ZIP"** and extract the folder.

#### 4. Open Claude Code

```bash
cd mnemosine
claude
```

Say "hi" — Claude detects it's the first run and starts the setup automatically.

</details>

---

> **From here on, the content is aimed at people with development experience.**

---

Think about the best conversation you've ever had with someone. You didn't need to explain who you were, what you did, or why you thought the way you did. The person already knew. And because of that, the conversation was *about what mattered* — not about context.

Now think about how you use artificial intelligence. [Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview) — Anthropic's AI assistant that runs directly on your computer — already has features like memory and configuration file reading. But with every new conversation, a lot is lost. The subtle preferences you spent sessions calibrating. The decisions you made together yesterday. The tone that was finally just right. The AI knows *about* the project, but it doesn't know *about you*. And that difference is what separates a useful tool from a real collaboration.

This framework fills that gap. It's not a list of prompts. It's not a trick. It's a **relationship architecture** between you and your AI — with identity, structured memory and behavior that truly persist across conversations.

You set it up once. From then on, it knows you.

---

## How it works

When you open this project in Claude Code, it asks you five questions — like a conversation, not a form:

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  You open the project and follow the first-use instructions     │
│                          │                                      │
│                          ▼                                      │
│               ┌─────────────────────┐                           │
│               │   The AI interviews │                           │
│               │   you (5 questions) │                           │
│               └─────────┬───────────┘                           │
│                          │                                      │
│           "Who are you? What are you building?                  │
│            How do you work? What annoys you?                    │
│            What should I call myself?"                          │
│                          │                                      │
│                          ▼                                      │
│               ┌─────────────────────┐                           │
│               │  It builds your     │                           │
│               │  personalized AI    │                           │
│               └─────────┬───────────┘                           │
│                          │                                      │
│            Identity, personality, memory,                        │
│            behavior rules — all from                             │
│            your answers.                                         │
│                          │                                      │
│                          ▼                                      │
│               ┌─────────────────────┐                           │
│               │  Done. Your AI      │                           │
│               │  knows you now.     │                           │
│               └─────────────────────┘                           │
│                                                                 │
│  Next conversation, type /iniciar and everything will be there. │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

The AI reacts to your answers, follows up, and at the end shows you the result for approval before saving anything. You have full control.

---

## What changes in practice

There's a huge difference between a tool that obeys and one that collaborates. The first waits for commands. The second remembers context, respects preferences and evolves with you.

| Without this framework | With this framework |
|---|---|
| "I'm a backend developer working on..." (every session) | The AI already knows your role and experience |
| "Don't add comments to code I didn't change" (again) | The AI remembers your preferences from day one |
| "Where did we leave off yesterday?" | The AI picks up exactly where it stopped |
| Generic responses, same for everyone | Personality and behavior tailored to you |
| Every conversation is a blank slate | Every conversation builds on the previous one |

---

## The four pillars

Every functional relationship has structure. This framework rests on four:

### Identity

A configuration file that works as your AI's **constitution**. In it you define name, personality and behavior rules. "When reviewing code, be direct. When teaching, use analogies. Never add features I didn't ask for."

Claude Code reads this file automatically. The initial setup creates yours — personalized from your answers.

### Memory

Files that persist across conversations. Your role, your preferences, the project context, the decisions you made together. The AI reads everything silently at the start of each session. You never need to repeat yourself.

It's like working with someone who takes notes on what matters — and re-reads them before every meeting.

### Skills

Commands that automate entire workflows. Instead of typing 15 instructions every time you open a session, you type `/iniciar` and the AI loads identity, memory and context in a second. Instead of remembering to save state before closing, you type `/ate-a-proxima` and it takes care of everything.

Think of skills as productive rituals. You do the same thing every time, the same way, and that's why it works.

### File exchange

A simple folder protocol. Place files in the input folder for the AI to process. It delivers results in the output folder. No copying, no pasting, no losing context in between.

---

## The rhythm of a session

Once set up, each work session follows a natural rhythm — like opening and closing a notebook:

```
/iniciar                    Opening — AI loads who it is, what it knows
    │                       about you, and greets you. Ready.
    ▼
[ your work ]               You work normally. The AI behaves
    │                       as you agreed.
    ▼
/ate-a-proxima              Closing — AI saves state, updates
                            memory, says goodbye. Tomorrow picks up here.
```

### Included skills

| Command | When | What it does |
|---------|------|-------------|
| `/comece-por-aqui` | Once, during initial setup | Interviews you and builds your personalized AI. |
| `/iniciar` | Start of each session | Loads everything. The AI arrives ready. |
| `/ate-a-proxima` | End of each session | Saves state and closes cleanly. |
| `/criar-skill` | When you want to create a new skill | Guided interview that generates the complete automation. |
| `/marketplace` | When you want to discover extra skills | Shows the catalog, recommends and activates with one command. |

---

## The story behind it

This framework was born by accident. **Joc** was building Jiim Hawkins — an ambitious personal AI agent project. And in the process of setting up the work environment with Claude Code, he noticed something: *the preparation was the product*.

The way you set up identity, memory and behavior for an AI isn't a preliminary step — it's the thing itself. It's what separates using AI as a glorified search engine from using AI as an instrument that evolves with you.

A musician doesn't buy an instrument and start playing. They tune it. Learn its quirks. Develop a relationship with what the instrument does well and where it resists. That tuning is what this repository documents.

And the most beautiful part: the repository is the framework *and* the living example at the same time. The technical documentation explains how everything works. The examples show a real, sanitized implementation. The skills, the journal, the guides — all are actively used, not written for show.

---

## Marketplace — expanding your skills

The 5 skills that come with the framework cover the essentials: set up, open, close, create and discover. But everyone works differently. Some need spell checking. Others need personal data sanitization. Others need things we haven't even imagined yet.

That's why the **marketplace** exists — a separate repository with extra skills created by the community. Think of it as an extension store: you install only what makes sense for you.

**[github.com/jocsaacesar/interface-colaboracao-skills](https://github.com/jocsaacesar/interface-colaboracao-skills)**

### Available skills

| Skill | What it does | Who it's useful for |
|-------|-------------|-------------------|
| `/tornar-publico` | Separates personal data from public content, sanitizes and prepares for publication. Nothing goes out without your approval. | Anyone working in public repositories who needs to protect sensitive data. |
| `/revisar-texto` | Goes through all project documentation files correcting spelling, Brazilian conventions and inconsistencies. Ambiguous corrections ask for approval. | Anyone who writes documentation and wants to maintain consistency and quality. |

### How to install a skill

The simplest way: type `/marketplace` in a conversation with the AI. It shows the catalog, explains each skill, recommends the ones that make sense for your profile, and installs them for you.

<details>
<summary>Manual installation (command line)</summary>

```bash
# 1. Download the marketplace (only needed once)
git clone https://github.com/jocsaacesar/interface-colaboracao-skills.git marketplace

# 2. Copy the skill you want to the active skills folder
cp -r marketplace/tornar-publico .claude/skills/
```

Done. Claude Code discovers it automatically. No restart, no configuration.

**To uninstall:** delete the skill folder from inside `.claude/skills/`.

**To update the marketplace:** enter the `marketplace/` folder and run `git pull origin main`.

</details>

### How to contribute a skill

Created a skill that solved a real problem for you? It probably solves it for others too.

1. Fork the [skills repository](https://github.com/jocsaacesar/interface-colaboracao-skills).
2. Create a folder with the skill name and a definition file inside.
3. Open a PR describing what it does and why it's useful.

Requirements: documentation in Portuguese, no personal data, and the skill must work independently.

---

## Getting started

Four steps. If you've never used a terminal before, don't worry — each step has detailed instructions.

### Step 1 — Install Node.js

[Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview) needs Node.js to run. Node.js is a program that runs in the background — you install it once and don't need to think about it again.

Go to **[nodejs.org](https://nodejs.org)**, download the **LTS** version (recommended) and follow the standard installation. On Windows, it's a typical "next, next, finish" installer. On Mac, same.

<details>
<summary>How to check if you already have Node.js installed</summary>

Open the terminal (on Windows, search for "Terminal" or "Command Prompt"; on Mac, search for "Terminal") and type:

```bash
node --version
```

If something like `v20.11.0` appears, you already have it. If you get an error, install it from the site above.

</details>

### Step 2 — Install Claude Code

With Node.js installed, open the terminal and type:

```bash
npm install -g @anthropic-ai/claude-code
```

This command installs Claude Code on your computer. After that, the `claude` command is available in the terminal.

> **First time?** On the first run, Claude Code will ask you to log in with your Anthropic account. Follow the on-screen instructions — it's a one-time authentication process.

<details>
<summary>Full official documentation</summary>

For advanced installation options, configuration and troubleshooting, see the [official Claude Code documentation](https://docs.anthropic.com/en/docs/claude-code/overview).

</details>

### Step 3 — Download this project

You have two options:

**Option A — Via terminal** (if you have Git installed):
```bash
git clone https://github.com/jocsaacesar/mnemosine.git
cd mnemosine
```

**Option B — Via browser** (no Git needed):
1. Go to the [repository on GitHub](https://github.com/jocsaacesar/mnemosine)
2. Click the green **"Code"** button and then **"Download ZIP"**
3. Extract the folder wherever you prefer

### Step 4 — Set up your AI

Open the terminal **inside the project folder** and type:

```bash
claude
```

Claude automatically detects that it's the first use and starts the onboarding on its own. Say anything ("hi", "let's go") and it conducts the interview, creates the identity, initial memories and configures the skills. Takes about 5-10 minutes.

> **Important:** Everything created stays inside the project folder. The only exception is the `/iniciar` skill, which Claude will ask your permission to install in your personal folder — this is what allows using it in any project. Completely optional. See [Security and scope](#security-and-scope) for details.

<details>
<summary>Already have a running project? Don't clone over it</summary>

If you already have a repository with code, `.gitignore`, `README.md` and everything else — **don't clone this repository over it**.

The framework was designed to coexist with existing projects, but needs care that a direct clone doesn't provide: separating what's from the framework from what's from your project.

In practice, you only need **two things**:
1. The `.claude/skills/` folder (the skills)
2. A few lines in your `.gitignore` (to protect personal data)

Everything else — README, LICENSE, guides, examples — is framework documentation and doesn't go into your project.

**[Full installation guide for existing projects →](guias/instalacao-projeto-existente.md)**

The guide covers:
- Exactly what to copy and what to ignore
- How to merge `.gitignore` without overwriting
- What to do if you already have a `CLAUDE.md`
- How to uninstall without leaving residue

</details>

---

## Security and scope

When someone asks you to download a project and run commands, it's fair to ask: *"what does this do on my machine?"*

The answer here is simple.

**Everything stays inside the project folder.** Identity, memories, skills — nothing leaves this folder. Claude Code discovers the skills automatically when it opens the project. There's no global installation.

The **only exception** is the `/iniciar` skill, which during setup Claude offers to install in your personal folder — with your explicit authorization. It's a single text file. If you decline, everything works normally within the project; `/iniciar` just won't be global.

Nothing modifies other projects, other workflows, other configurations.

**To uninstall:** delete the project folder. Done.

<details>
<summary>Technical cleanup details</summary>

If you installed the `/iniciar` skill globally during onboarding:
```bash
rm -rf ~/.claude/skills/iniciar/
```

If you synced memories to `~/.claude/projects/`:
```bash
rm -rf ~/.claude/projects/<your-project-folder>/memory/
```

</details>

---

## Going deeper

- **[Skills Glossary](GLOSSARIO_DE_SKILLS.md)** — Each skill explained in detail: what it does, what to expect, what it will never do.
- **[First use](PRIMEIRO-USO.md)** — Onboarding entry point. Claude reads it and handles everything.
- **[Installation in existing project](guias/instalacao-projeto-existente.md)** — What to copy, what to ignore, how to avoid conflicts.
- **[Marketplace](https://github.com/jocsaacesar/interface-colaboracao-skills)** — Optional skills created by the community.
- **[Guides](guias/)** — How to create a CLAUDE.md, design skills, use the memory system.
- **[Templates](modelos/)** — Starter files to build from scratch.
- **[Examples](exemplos/leland/)** — A real, sanitized implementation as reference.
- **[CLAUDE-IC.md](CLAUDE-IC.md)** — Full technical documentation of the framework.
- **[Contributing](CONTRIBUTING.md)** — How to contribute to this project.

<details>
<summary>Project structure (click to expand)</summary>

```
├── CLAUDE.md                           # Your identity (generated by onboarding)
├── CLAUDE-IC.md                        # Framework documentation
├── PRIMEIRO-USO.md                     # Entry point — Claude reads and runs the setup
├── README.md                           # You are here
├── JOURNAL.md                          # Decisions and learnings
├── GLOSSARIO_DE_SKILLS.md              # User guide for all skills
├── SECURITY.md                         # Security policy
├── LICENSE                             # MIT License
├── CONTRIBUTING.md                     # How to contribute
├── CODE_OF_CONDUCT.md                  # Code of conduct
├── guias/                              # How to use each component
├── modelos/                            # Starter files for your project
├── exemplos/                           # Reference implementation
├── .claude/skills/                     # Core skills (local to project)
├── memoria/                            # Your memory files (private)
├── estudos/                            # Personal study summaries (private)
└── troca/                              # File exchange (private)
```

</details>

---

## Contributing

Contributions are welcome. Read [CONTRIBUTING.md](CONTRIBUTING.md) before submitting a PR. This project follows a [Code of Conduct](CODE_OF_CONDUCT.md).

## License

[MIT](LICENSE)

**Repository:** [github.com/jocsaacesar/mnemosine](https://github.com/jocsaacesar/mnemosine)

---

> *"The difference between using a tool and having a relationship with it is simple: the relationship has memory."*
