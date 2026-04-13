> *This is an English translation of the original Portuguese file. Source: `guias/instalacao-projeto-existente.md`*

# Installing in an existing project

This guide is for those who **already have a project running** and want to add the collaboration framework without breaking anything. If you're starting from scratch, the simplest path is to clone the repository directly -- see the [README](../README.md#quick-start).

---

## What you need to copy

Not everything in the framework repository belongs in your project. Most files are documentation, examples, and infrastructure for the repository itself. What actually needs to be in your project is very little:

### Essential (the framework won't work without these)

| What | Why |
|------|-----|
| `.claude/skills/` | The skills -- `/comece-por-aqui`, `/iniciar`, `/ate-a-proxima`, `/criar-skill`, `/marketplace`. Without them, there's no framework. |
| Entries in `.gitignore` | To protect your memory and file exchange folders. **Don't copy the entire file** -- add the lines to your existing `.gitignore`. |

### Recommended (reference and documentation)

| What | Why |
|------|-----|
| `CLAUDE-IC.md` | Complete framework documentation. Unique name, doesn't conflict with anything. |
| `GLOSSARIO_DE_SKILLS.md` | User guide for all skills. |

### Don't copy (these belong to the framework repo, not your project)

| What | Why not |
|------|---------|
| `README.md` | It's the framework's presentation, not your project's. You already have your own. |
| `LICENSE` | Your project has its own license. |
| `CONTRIBUTING.md` | Contribution rules for the framework, not your project. |
| `CODE_OF_CONDUCT.md` | Same. |
| `SECURITY.md` | Same. |
| `.github/` | PR and issue templates for the framework. You may already have your own. |
| `JOURNAL.md` | Optional. If you want to keep a decision journal, create your own from scratch. |
| `guias/` | Reference material. Read it in the original repository; it doesn't need to be in your project. |
| `modelos/` | Templates. Use when needed; no need to copy. |
| `exemplos/` | Reference implementation. Doesn't belong in your project. |

---

## Step by step

### 1. Download the framework

```bash
# Anywhere outside your project
git clone https://github.com/jocsaacesar/mnemosine.git
```

### 2. Copy the skills

```bash
# Inside your project folder
# If you already have .claude/skills/, the skills are added without overwriting existing ones
cp -r /path/to/mnemosine/.claude/skills/* .claude/skills/
```

If the `.claude/skills/` folder doesn't exist, create it:

```bash
mkdir -p .claude/skills
cp -r /path/to/mnemosine/.claude/skills/* .claude/skills/
```

### 3. Update your .gitignore

**Don't overwrite your `.gitignore`.** Add these lines at the end:

```gitignore
# === Mnemosine -- personal data ===
/memoria/
/memory/
/troca/
/exchange/
```

The leading slash (`/`) is important -- it ensures only these folders at the project root are ignored, without affecting subfolders with the same names.

### 4. Copy the reference documentation (optional)

```bash
cp /path/to/mnemosine/CLAUDE-IC.md .
cp /path/to/mnemosine/GLOSSARIO_DE_SKILLS.md .
```

### 5. Run the onboarding

Open Claude Code in your project folder and type:

```
/comece-por-aqui
```

The skill will interview you and generate a personalized `CLAUDE.md`. If you **already have a `CLAUDE.md`**, the skill should detect it and ask what to do. If it doesn't ask, see the [Cautions](#cautions) section below.

---

## Cautions

### You already have a `CLAUDE.md`

If your project already uses a `CLAUDE.md` with instructions for Claude Code, `/comece-por-aqui` will try to create a new one. Before running it:

1. **Read your current `CLAUDE.md`** -- note what's important.
2. **Rename it temporarily** -- `mv CLAUDE.md CLAUDE.backup.md`.
3. **Run `/comece-por-aqui`** -- let the skill generate the new one.
4. **Merge manually** -- take the instructions from the backup and add them to the newly generated `CLAUDE.md`.

This is the only file that requires manual attention. Everything else either doesn't conflict or doesn't need to be copied.

### You already have `.claude/skills/`

No problem. The `cp -r` adds the framework's skills alongside yours. No existing skill is overwritten -- unless you already have a folder with the same name (unlikely, since the names are in Portuguese).

### You already have `.github/`

Don't copy the framework's `.github/`. The issue and PR templates were written for the framework repository, not your project.

### Marketplace in an existing project

The marketplace works the same way:

```bash
git clone https://github.com/jocsaacesar/interface-colaboracao-skills.git marketplace
```

Or, after installing the core skills, type `/marketplace` in the conversation and the AI takes care of the rest.

---

## What the framework creates in your project

After `/comece-por-aqui`, these new folders and files will exist:

```
your-project/
├── .claude/skills/          <- Framework skills (you copied these)
├── CLAUDE.md                <- Your AI's identity (generated by the skill)
├── CLAUDE-IC.md             <- Framework documentation (you copied this)
├── memoria/                 <- Created by /comece-por-aqui (in .gitignore)
│   └── MEMORY.md
└── troca/                   <- Created by /comece-por-aqui (in .gitignore)
    ├── entrada/
    └── saida/
```

The `memoria/` and `troca/` folders are protected by `.gitignore` -- they'll never go to your repository. Everything else coexists with the files you already have.

---

## How to uninstall

If you want to remove the framework from your project:

```bash
# Remove skills
rm -rf .claude/skills/comece-por-aqui
rm -rf .claude/skills/iniciar
rm -rf .claude/skills/ate-a-proxima
rm -rf .claude/skills/criar-skill
rm -rf .claude/skills/marketplace

# Remove framework files
rm -f CLAUDE-IC.md GLOSSARIO_DE_SKILLS.md

# Remove created folders (optional -- they contain your data)
rm -rf memoria/ troca/

# Remove .gitignore entries (edit manually)
# Remove the lines /memoria/, /memory/, /troca/, /exchange/

# Remove CLAUDE.md (your call -- you might want to keep it)
```

If you synced memories to the system folder:
```bash
rm -rf ~/.claude/projects/<your-project-name>/memory/
```

No residue. No global state. Your project goes back to exactly how it was before.
