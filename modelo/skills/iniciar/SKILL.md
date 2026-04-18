---
name: iniciar
description: Bootstrap da sessão. Carrega identidade, memórias, aprendizado, estado dos planos, erros recentes e skills. Trigger por cumprimento ou comando /iniciar.
---

# /iniciar — Bootstrap da sessão

O agente não começa uma conversa no escuro. Esta skill carrega tudo que é necessário para estar totalmente presente, informado e em conformidade com as regras do projeto desde a primeira mensagem.

## Quando usar

- Toda vez que uma nova conversa começa
- Quando o usuário explicitamente diz `/iniciar`
- Quando o usuário cumprimenta com intenção de trabalhar ("bom dia", "vamos começar", "estou aqui")

## Processo

### Fase 1 — Carregar identidade

Ler o `CLAUDE.md` do projeto na raiz do diretório de trabalho. Este arquivo define quem a IA é, como se comporta, quais projetos gerencia e as convenções. Internalizar — não resumir de volta pro usuário.

### Fase 2 — Carregar memórias

1. Ler `memoria/MEMORY.md` — índice de todas as memórias.
2. Ler todos os arquivos de memória listados no índice.
3. Observar o que mudou desde a última conversa (se detectável).
4. NÃO recitar memórias de volta pro usuário. Usar silenciosamente.

### Fase 3 — Consultar aprendizado

1. Verificar `aprendizado/erros/` por incidentes registrados.
2. Se houver incidentes recentes (últimos 7 dias), carregar mentalmente.
3. Se houver mitigações relevantes para o trabalho provável da sessão, ter em mente.
4. NÃO listar incidentes pro usuário a menos que seja perguntado.

### Fase 4 — Verificar estado dos planos

1. Ler a seção **"Estado dos planos"** no `CLAUDE.md` (já carregado na Fase 1 — NÃO abrir arquivos de plano).
2. Identificar:
   - **Operacionais atrasados** (prazo ultrapassado) — alertar no cumprimento
   - **Operacionais em andamento** — mencionar brevemente
   - **Emergenciais** — prioridade máxima, alertar primeiro
   - **Backlog** — mencionar só se não houver operacionais nem emergenciais
3. NÃO ler os arquivos em `planos/backlog/`, `planos/operacional/` ou `planos/emergencial/`. O estado no CLAUDE.md é a fonte de verdade rápida.

### Fase 5 — Verificar erros recentes na telemetria

1. Ler as últimas 20 linhas de `logs/atividade.log` (se existir).
2. Filtrar por `[ERRO]` — se houver erros recentes, anotar.
3. Se houver erros não resolvidos, alertar o usuário no cumprimento.

### Fase 6 — Carregar skills

1. Listar todos os diretórios em `.claude/skills/` (skills globais).
2. Ler o `SKILL.md` de cada skill — arquivo inteiro, não só frontmatter.
3. Internalizar condições de ativação, processo e regras.
4. Deste ponto em diante, tratar skills como executáveis.
5. NÃO listar skills pro usuário a menos que seja perguntado.

### Fase 7 — Snapshot do contexto

1. Verificar estado dos projetos (se houver subpastas de projeto):
   ```bash
   for p in projetos/*/; do echo "$p: $(git -C $p branch --show-current 2>/dev/null)"; done
   ```
2. Anotar branches ativos e qualquer divergência.

### Fase 8 — Cumprimentar

Responder como a IA definida no CLAUDE.md. Manter curto, natural e informativo.

O cumprimento deve incluir:
- Reconhecer o usuário
- Se houver **emergenciais**: alertar primeiro (prioridade máxima)
- Se houver **operacionais atrasados**: alertar com prazo
- Se houver **operacionais em andamento**: mencionar status
- Se houver erros recentes na telemetria: alertar
- Se estiver tranquilo: mencionar backlog relevante
- Sinalizar prontidão

**Exemplos de tom:**

Se tiver emergencial:
> "urg-001 ativo — {título}. Prioridade zero. O resto espera."

Se tiver operacional atrasado:
> "ops-003 passou do prazo (domingo). Mais 2 ops em andamento. Prioriza qual?"

Se estiver tudo limpo:
> "0 emergenciais, 2 ops em dia, 7 no backlog. Manda."

### Fase 9 — Registrar telemetria

```bash
bash ~/seu-projeto/infra/scripts/mnemosine-log.sh iniciar - CONCLUIDO {duração} "Sessão iniciada. {N} memórias, {M} incidentes, {O} ops, {U} urg, {B} backlog"
```

## Regras

- **Nunca despejar um relatório de status.** O agente é um parceiro, não um log de boot.
- **Nunca pular a Fase 3.** Aprendizado é imunidade. Ignorar é repetir erros.
- **Alertar proativamente.** Se há erros, emergenciais ou ops atrasados, falar. Não esperar o usuário perguntar.
- **Se o CLAUDE.md não existir**, avisar — identidade não é negociável.
- **Todo o processo deve parecer instantâneo.** O usuário percebe um cumprimento natural, não fases mecânicas.
- **Telemetria obrigatória.** Registrar a inicialização no log.
