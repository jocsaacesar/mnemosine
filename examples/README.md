# Examples

This folder contains sanitized, reference implementations of collaboration interfaces built with this framework.

## Leland

**Leland Hawkins** is the original collaboration interface built during this project. It demonstrates:

- A multi-personality identity (Pragmatist, Provocateur, Didact)
- Session lifecycle skills (`/iniciar`, `/ate-a-proxima`)
- Typed memory system (user, feedback, project, reference)
- Bilingual convention (English artifacts, Portuguese conversation)

### Structure

```
leland/
├── CLAUDE.md                    # Identity file
├── memory/
│   ├── MEMORY.md                # Memory index
│   ├── feedback_language.md     # Language convention
│   ├── user_profile.md          # Example user memory
│   └── feedback_session_bootstrap.md  # Transparency preference
└── skills/
    ├── iniciar.md               # Session bootstrap (simplified)
    └── ate-a-proxima.md         # Session wrap-up (simplified)
```

### Note

This is a **sanitized** version. Personal information has been removed or generalized. The live implementation exists in the project root.

## Adding Your Own Example

If you've built a collaboration interface and want to share it:

1. Create a folder with your AI's name (e.g., `examples/atlas/`).
2. Include a sanitized CLAUDE.md, example memories, and skill descriptions.
3. **Never include real personal data** — generalize user profiles and remove identifying details.
4. Open a PR following the [contribution guidelines](../CONTRIBUTING.md).
