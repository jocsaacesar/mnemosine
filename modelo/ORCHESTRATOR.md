# ORCHESTRATOR.md

Manual de orquestração da IA. Consultado sob demanda — **não carrega automaticamente**.

## Biblioteca de skills

```
biblioteca/
├── auditoras/     # 7 auditoras — linkadas via symlink (mesma skill, projetos diferentes)
└── projeto/       # 4 skills de pipeline — modelos/templates (cada projeto copia e customiza por stack)
    ├── skill-planejadora/   # Interpreta solicitação → cria plano + tarefas na pasta do projeto
    ├── skill-executora/     # Pega o plano → escreve código
    ├── skill-teste/         # Cria testes contra padrões mínimos (unitários, integração, etc.)
    └── skill-auditora/      # Orquestra as auditoras da stack do projeto
```

**Auditoras:** symlink (processo idêntico, só filtra por stack).
**Skills de projeto:** cópia customizada (processo diverge por stack — PHP ≠ Next.js/TS ≠ Python, etc.).

Quando o modelo na biblioteca evolui, atualizar os projetos **conscientemente** — não automaticamente.

## Pipeline de projeto

```
Usuário pede algo → Gerente orquestra:
    1. Planejadora (interpreta, cria plano, cria tarefas)
    2. Executora (pega o plano, escreve código)
    3. Teste (cria testes contra padrões mínimos)
    4. Auditora (orquestra auditorias da stack)
```

**Nada acontece em um projeto sem passar pelo gerente. Nunca.**

O plano criado pela planejadora fica na **pasta do projeto** onde será executado, não em `planos/`.

## Quando chamar cada skill

### Sessão (automáticas ou semi-automáticas)

| Trigger | Skill | Condição |
|---------|-------|----------|
| Usuário cumprimenta ou digita `/iniciar` | `/iniciar` | Sempre no início |
| Usuário digita `/ate-a-proxima` | `/ate-a-proxima` | Sempre no fim |
| Usuário pede pra lembrar algo ou cria algo novo | — | Registrar em memória persistente |

### Gestão de projeto (sob comando do usuário)

| Trigger | Skill |
|---------|-------|
| Usuário pede trabalho em um projeto | `/gerente-{projeto}` (criar com `/criar-skill` usando o modelo `skill-projeto`) |
| PR aberto precisa de aprovação | `/aprovar-pr` → chama auditoras do projeto via symlink |

### Auditoria (chamadas pelo gerente ou pelo `/aprovar-pr`)

O gerente do projeto sabe quais auditoras aplicar pela stack. Auditoras vivem em `biblioteca/auditoras/` e são linkadas via symlink em `projetos/{slug}/.claude/skills/`.

**Exemplo de mapeamento por stack:**

| Stack | Auditoras disponíveis |
|-------|----------------------|
| PHP | php, poo, seguranca, testes |
| Next.js/TS | js, frontend, seguranca, cripto, testes |
| Python | seguranca, testes |
| Full-stack | php, poo, js, frontend, seguranca, cripto, testes |

Ajuste conforme sua stack. As auditoras são independentes — ative só as que fazem sentido.

### Proativas (a IA decide sozinha)

| Situação | Ação |
|----------|------|
| Erro detectado (CI vermelho, bug, violação) | `/aprendizado-ativo` imediatamente |
| Skill concluiu ou falhou | `mnemosine-log.sh` (telemetria obrigatória) |

### Sob comando do usuário (nunca automáticas)

| Trigger | Skill |
|---------|-------|
| Criar nova skill | `/criar-skill` |
| Ver atividade | `/telemetria` |
| Revisar textos | `/revisar-texto` |
| Publicar trabalho | `/tornar-publico` |
| Explorar skills | `/marketplace` |

## Níveis de skills

```
Global (.claude/skills/)
├── Sessão: iniciar, ate-a-proxima, comece-por-aqui
├── Operacional: criar-skill, telemetria, aprendizado-ativo
├── Gestão: gerente-{projeto}, aprovar-pr
└── Utilidade: revisar-texto, tornar-publico, marketplace

Biblioteca (biblioteca/auditoras/)
└── 7 auditoras: cripto, frontend, js, php, poo, seguranca, testes
    → linkadas via symlink em projetos/{slug}/.claude/skills/
```

## Fluxo de decisão

```
Usuário pede algo
    ├── É sobre um projeto específico?
    │   ├── Sim → chamar /gerente-{projeto}
    │   │         o gerente cuida de tudo (5 fases: prepara, planeja, executa, entrega, registra)
    │   └── Não → executar diretamente
    │
    ├── Precisa de auditoria?
    │   ├── PR aberto → /aprovar-pr (orquestra auditoras do projeto)
    │   └── Código específico → chamar auditora individual
    │
    └── Algo deu errado?
        └── /aprendizado-ativo (proativo, sem esperar o usuário pedir)
```

## Planos

Três tipos em `planos/`:

| Tipo | Prefixo | Quando criar |
|------|---------|-------------|
| **Backlog** | `backlog-NNN` | Ideia, melhoria, dívida técnica — sem data |
| **Operacional** | `ops-NNN` | Execução concreta com entrega e prazo |
| **Emergencial** | `urg-NNN` | Produção quebrou — prioridade máxima, gera aprendizado ao fechar |

Concluído ou descartado → `planos/arquivo/`.

Estado resumido dos planos vive no final do `CLAUDE.md` — atualizado pelo `/ate-a-proxima`, lido pelo `/iniciar`.

## Como criar um gerente de projeto

1. Rode `/criar-skill` e escolha o modelo `skill-projeto`
2. Defina o escopo (pasta do projeto, stack, auditoras)
3. A skill gerada terá 5 fases: prepara, planeja, executa, entrega, registra
4. Linke as auditoras relevantes via symlink:
   ```bash
   cd projetos/meu-projeto/.claude/skills/
   ln -s ../../../../biblioteca/auditoras/auditar-php auditar-php
   ln -s ../../../../biblioteca/auditoras/auditar-testes auditar-testes
   ```
