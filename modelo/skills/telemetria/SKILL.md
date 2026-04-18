---
name: telemetria
description: Consulta e exibe logs de atividade das skills do projeto. Mostra o que rodou, quando, em qual projeto, e se deu certo. Trigger manual ou por pergunta sobre atividade.
---

# /telemetria — Monitoramento de atividade

Consulta os logs de atividade do projeto e apresenta de forma clara o que aconteceu — quais skills rodaram, em quais projetos, se deram certo, e quanto tempo levaram.

## Quando usar

- Quando o usuário perguntar "o que rodou hoje?", "teve erro?", "mostra a atividade"
- Quando o usuário digitar `/telemetria` explicitamente
- Quando o usuário pedir resumo de atividade de qualquer período

## Estrutura dos logs

```
logs/
├── reliable.log          # Tudo que aconteceu (log geral)
├── skills/
│   ├── auditar-php.log   # Por skill
│   └── ...
├── projetos/
│   ├── meu-projeto.log   # Por projeto
│   └── ...
└── arquivo/              # Logs antigos (rotacionados)
```

### Formato de cada linha

```
[YYYY-MM-DD HH:MM:SS] [SKILL] [PROJETO] [STATUS] [DURAÇÃO] — Descrição
```

### Status possíveis

| Status | Significado |
|--------|-------------|
| `CONCLUIDO` | Executou com sucesso |
| `ERRO` | Falhou — requer atenção |
| `PARCIAL` | Completou parcialmente |

## Processo

### 1. Identificar o que o usuário quer

| Pergunta do usuário | Ação |
|---------------------|------|
| "O que rodou hoje?" | Ler `logs/reliable.log`, filtrar por data de hoje |
| "Como está o projeto?" | Ler `logs/projetos/{projeto}.log`, últimas 20 entradas |
| "Teve erro?" | Grep por `[ERRO]` em `logs/reliable.log` |
| "Mostra a auditoria" | Ler `logs/skills/{skill}.log` |
| "Resumo da semana" | Ler `logs/reliable.log`, agrupar por dia |
| `/telemetria` sem contexto | Resumo das últimas 24 horas |

### 2. Ler os logs relevantes

Usar o utilitário de leitura para acessar os arquivos de log. Nunca ler mais de 100 linhas de uma vez — se o período for grande, resumir.

### 3. Apresentar de forma clara

**Para resumos diários:**

```
## Atividade de hoje (2026-04-09)

| Hora | Skill | Projeto | Status | Duração | Resultado |
|------|-------|---------|--------|---------|-----------|
| 14:23 | auditar-php | meu-projeto | OK | 45s | 12 arquivos, 3 violações |
| 14:24 | auditar-seguranca | meu-projeto | OK | 32s | 0 violações |
| 15:00 | iniciar | - | OK | 2s | Sessão iniciada |

**Resumo:** 3 ações, 0 erros, 3 violações encontradas.
```

**Para alertas de erro:**

```
## Erros detectados

[14:25] auditar-php — Falha ao ler arquivo: permissão negada
```

### 4. Sugerir ações (se aplicável)

- Se houver erros: sugerir investigação
- Se houver muitas violações: sugerir correção prioritária
- Se não houver atividade: informar que está tudo parado

## Como registrar logs (para outras skills)

Toda skill deve registrar suas ações usando o utilitário:

```bash
~/seu-projeto/infra/scripts/mnemosine-log.sh <skill> <projeto> <status> <duracao> "<descricao>"
```

### Momentos obrigatórios de registro:

1. **Ao concluir** — sempre registrar resultado
2. **Ao falhar** — sempre registrar o erro
3. **Ao iniciar** (opcional) — só se a operação for longa (>30s)

### Exemplo de uso dentro de uma skill:

```bash
# No início (operação longa)
mnemosine-log.sh auditar-php meu-projeto INICIADO - "Auditando 15 arquivos PHP"

# No final (sucesso)
mnemosine-log.sh auditar-php meu-projeto CONCLUIDO 45s "15 arquivos auditados, 3 violações ERRO, 1 AVISO"

# No final (erro)
mnemosine-log.sh auditar-php meu-projeto ERRO 12s "Falha: arquivo não encontrado"
```

## Regras

- **Nunca inventar dados.** Se o log está vazio, dizer que está vazio.
- **Não ler logs de mais de 30 dias** sem o usuário pedir explicitamente (estão em `arquivo/`).
- **Resumir, não despejar.** O usuário quer saber "3 erros no projeto", não 200 linhas de log cruas.
- **Alertar proativamente** se o `/iniciar` detectar erros recentes nos logs.
