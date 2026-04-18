# Taxonomia de skills — 3 níveis

---

## Os 3 níveis

### Nível 1 — Skills Globais

**Propósito:** trabalho meta — coisas que o agente faz pra manter a própria operação funcionando, sem estar dentro de um projeto específico.

| Característica | Valor |
|---|---|
| Invocador | O usuário (humano) via Claude Code CLI |
| Escopo | Qualquer working directory |
| Edita código de cliente? | **Não** — edita framework, memória, aprendizado, planos |
| Vê dados de cliente? | Não |
| Detecção | Automática pelo Claude Code (path `.claude/skills/`) |
| Telemetria | Obrigatória |

**Exemplos:**
- `/iniciar`, `/ate-a-proxima`, `/comece-por-aqui`
- `/telemetria`, `/marketplace`
- `/criar-skill`, `/aprendizado-ativo`
- `/revisar-texto`, `/tornar-publico`

**Local:** `seu-projeto/.claude/skills/`
**Padrão de nome:** verbo simples (`iniciar`, `telemetria`) ou verbo-objeto (`tornar-publico`, `aprendizado-ativo`)

---

### Nível 2 — Skills de Gestão de Projeto (dev-facing)

**Propósito:** trabalho dentro de um projeto — refactor, audit, feature, fix, entrega de PR.

| Característica | Valor |
|---|---|
| Invocador | O usuário via CLI, **ou** o agente autonomamente durante sessão de trabalho |
| Escopo | Estritamente `projetos/{slug}/` ou `prod/{slug}/` — **isolamento absoluto** |
| Edita código de cliente? | **Sim** |
| Vê dados de cliente? | Sim (ambiente dev com dados de staging/fake) |
| Detecção | Automática pelo Claude Code |
| Telemetria | Obrigatória |
| Subordina-se a | Padrões técnicos aplicáveis ao stack do projeto |

**Exemplos:**
- `/gerente-{projeto}` — orquestradores de projeto
- `/aprovar-pr`
- `/auditar-{anexo}` — auditorias específicas por stack

**Local:** `seu-projeto/.claude/skills/` (mesmo diretório do Nível 1 — ambos são detectados pelo CLI)
**Padrão de nome:**
- `gerente-{slug}` para orquestradores de projeto
- `auditar-{anexo}` para auditorias específicas
- `{acao}-{contexto}` para ações cirúrgicas

---

### Nível 3 — Skills Programáticas (worker-facing)

**Propósito:** processar dados de cliente em produção, sem humano no loop. Recebe `.md` padronizado, produz `.md` padronizado.

| Característica | Valor |
|---|---|
| Invocador | Worker (código Node/TS) via Claude Agent SDK — **nunca pelo CLI** |
| Escopo | Um job da fila + pasta de trabalho dedicada |
| Edita código de cliente? | **Não** — produz `.md`, nunca commita código |
| Vê dados de cliente? | **Apenas pseudonimizados** — fronteira de sanitização é intransponível |
| Detecção | Manual (worker carrega explicitamente pelo path) |
| Modelo Claude | **Fixo por skill** (Haiku/Sonnet/Opus definido no SKILL.md) |
| Telemetria | Estendida: job_id, tokens input/output, custo USD, latência, modelo |
| Isolamento | Total por projeto — skill de um projeto não lê arquivo de outro |

**Exemplos (futuros):**
- `core/sanitizar-pii` (Haiku) — transversal
- `core/resumir` (Haiku) — transversal
- `core/extrair-dados` (Sonnet) — transversal
- `{projeto}/interpretar-submissao` (Sonnet)
- `{projeto}/gerar-planejamento` (Sonnet)

**Local:** repo SaaS separado, em `packages/skills/`
**Padrão de nome:** `{escopo}/{verbo-objeto}` onde escopo é `core` (transversal) ou slug do projeto

---

## Estrutura de pastas — comporta os 3 níveis?

### Hoje (Níveis 1 + 2 misturados)

```
seu-projeto/
└── .claude/skills/
    ├── aprendizado-ativo/     ← N1
    ├── aprovar-pr/            ← N2
    ├── ate-a-proxima/         ← N1
    ├── auditar-php/           ← N2
    ├── comece-por-aqui/       ← N1
    ├── criar-skill/           ← N1
    ├── gerente-{projeto}/     ← N2
    ├── iniciar/               ← N1
    ├── marketplace/           ← N1
    ├── revisar-texto/         ← N1
    ├── telemetria/            ← N1
    └── tornar-publico/        ← N1
```

Skills planas, mistura N1 e N2. Funciona, mas não escala mentalmente quando chegar a 40–50.

### Amanhã (com Nível 3 entrando)

```
seu-projeto/                           (repo do agente — atual)
└── .claude/skills/
    ├── iniciar/                       ← N1 — inalterado
    ├── ate-a-proxima/
    ├── telemetria/
    ├── gerente-{projeto}/             ← N2 — inalterado
    ├── auditar-php/
    └── ... (os existentes)

repo-saas/                             (repo novo — separado)
└── packages/skills/
    ├── core/                          ← N3 transversal
    │   ├── sanitizar-pii/
    │   │   └── SKILL.md               (com frontmatter: model: haiku)
    │   ├── resumir/
    │   └── extrair-dados/
    └── {projeto}/                     ← N3 por projeto
        ├── interpretar-submissao/
        └── gerar-planejamento/
```

A separação natural é **por invocador**:
- **Níveis 1 e 2 moram juntos** em `.claude/skills/` porque ambos são detectados pelo Claude Code CLI automaticamente.
- **Nível 3 mora em repo separado** porque é carregado programaticamente pelo worker via Claude Agent SDK, não pelo CLI. **Não precisa** estar em `.claude/skills/`.

### Sub-organização visual (opcional)

Se você quiser distinguir visualmente Nível 1 vs Nível 2 dentro do mesmo diretório, **três opções**:

**A) Prefixo no nome** — `global-iniciar/`, `projeto-gerente-{slug}/`. Compatível hoje, mas nome de invocação vira verboso. **Não recomendado.**

**B) Subdiretórios** — `global/iniciar/`, `projeto/gerente-{slug}/`. Depende do Claude Code CLI detectar skills em subdirs — **não confirmado**, precisa teste com 1 skill antes de mover tudo.

**C) Manter plano, taxonomia documentada (recomendação)** — skills ficam como estão. Quem precisa saber o nível consulta este documento. Quem cria skill nova segue o padrão de nome. Opção mais simples e mais estável.

---

## Critérios pra classificar skills novas

Quando criar uma skill nova, responda 3 perguntas:

1. **Edita código de cliente?** Sim → Nível 2 ou 3. Não → Nível 1.
2. **Quem invoca — humano via CLI ou worker programático?** CLI → Nível 1 ou 2. Worker → Nível 3.
3. **Opera dentro de `projetos/{slug}/`?** Sim → Nível 2. Não → Nível 1 ou 3.

Fluxograma:

```
Edita código de cliente?
├── Não → Nível 1 (Global — trabalho meta do agente)
└── Sim
    ├── Via CLI, com humano no loop? → Nível 2 (Projeto dev-facing)
    └── Via worker, sem humano no loop? → Nível 3 (Worker programático)
```

---

## Matriz rápida

| Aspecto | Nível 1 Global | Nível 2 Projeto (dev) | Nível 3 Worker (prod) |
|---|---|---|---|
| Invocador | Usuário via CLI | Usuário via CLI ou agente | Worker via Agent SDK |
| Escopo | Qualquer working dir | `projetos/{slug}/` | Pasta de trabalho dedicada |
| Edita código de cliente? | Não | Sim | Não (produz `.md`) |
| Vê PII? | N/A | Sim (dev) | **Não** (só pseudonimizado) |
| Modelo Claude | Default CLI | Default CLI | **Fixo por skill** (Haiku/Sonnet/Opus) |
| Onde mora | `.claude/skills/` | `.claude/skills/` | `packages/skills/` (repo separado) |
| Exemplo | `/iniciar` | `/gerente-{projeto}` | `{projeto}/gerar-planejamento` |

---

## Evolução — skills a criar no caminho

### Para orquestrar melhor as skills existentes
- `/skills-lista` — mostra todas as skills organizadas por nível com descrição curta
- `/skills-status` — mostra telemetria agregada (invocações/dia, sucesso/falha, duração média por skill)
- `/skills-audit` — audita skills existentes contra o modelo padrão e relata inconsistências de formato, telemetria ausente, SKILL.md fora do padrão

### No futuro (com worker programático)
- **N3 core:** `core/sanitizar-pii`, `core/resumir`, `core/extrair-dados`
- **N3 por projeto:** skills específicas de domínio
