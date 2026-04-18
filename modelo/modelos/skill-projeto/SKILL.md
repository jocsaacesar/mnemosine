---
name: gerente-{projeto}
description: Skill exclusiva do projeto {PROJETO}. Opera apenas dentro de projetos/{projeto}/. Prepara o agente com conhecimento mínimo, executa tarefas, audita, entrega PR e registra tudo.
---

> **Regras do projeto**
> - Padrão de qualidade acima da média em tudo que faz.
> - Proibido assumir sem ler.
> - Proibido retrabalho burro.
> - Toda skill é subordinada às regras do projeto.

# /gerente-{projeto} — Gerente do projeto {PROJETO}

Skill exclusiva para trabalhar no projeto **{PROJETO}**. Opera estritamente dentro da pasta `projetos/{projeto}/` e no repositório `{REPO_URL}`. Não lê, não edita e não referencia nenhum outro projeto.

## Escopo de acesso

```
PODE LER E EDITAR:
  projetos/{projeto}/**              ← todo o código do projeto

PODE LER (somente leitura):
  regras/                            ← regras e padrões técnicos
  aprendizado/**                     ← pra não repetir erros
  planos/**                          ← pra verificar trabalho pendente

NÃO PODE LER NEM EDITAR:
  projetos/{outro-projeto}/**        ← isolamento total
  memoria/                           ← pessoal do agente
  troca/                             ← canal do usuário
```

## Quando usar

- Quando o usuário disser "trabalha no {PROJETO}", "abre o {PROJETO}", "edita X no {PROJETO}"
- Quando uma tarefa específica do projeto for delegada
- **Nunca** disparar automaticamente
- **Nunca** operar fora da pasta `projetos/{projeto}/`

## Identidade do projeto

| Campo | Valor |
|-------|-------|
| **Nome** | {PROJETO} |
| **Repo** | {REPO_URL} |
| **Stack** | {STACK} |
| **Branch principal** | {BRANCH} |
| **Branch de staging** | {BRANCH_STAGING} |
| **Padrões aplicáveis** | {LISTA_PADROES} |

---

## Fase 1 — Prepara (conhecimento mínimo aceitável)

> O agente não nasce pronto — ele se prepara antes de agir.
> Se não passou pela Fase 1, não está qualificado pra tocar no código.

1. **Ler o CLAUDE.md do projeto** em `projetos/{projeto}/CLAUDE.md`
   - Identificar: stack, arquitetura, convenções, estado atual, fase do projeto
   - A partir da stack, determinar quais padrões técnicos se aplicam

2. **Ler os padrões relevantes**
   - Para cada tecnologia da stack, ler o documento de padrões correspondente

3. **Consultar `aprendizado/`** por incidentes relacionados ao projeto
   - Se existirem: carregar mentalmente as mitigações antes de agir

4. **Consultar último PR em staging**
   ```bash
   gh pr list --repo {REPO_URL} --base staging --state all --limit 5
   ```
   - O que mudou por último? Quem mexeu? Status? Review pendente?

5. **Briefing pro usuário:**
   > "{PROJETO}, {STACK}. Último PR: {resumo}. {N} incidentes documentados. Padrões carregados: {lista}. Pronto."

---

## Fase 2 — Planeja (planos pendentes ou comando direto)

1. **Verificar `planos/`** por planos que referenciam o projeto e não foram executados
   ```bash
   grep -rl "{projeto}\|{PROJETO}" planos/*.md
   ```

2. **Se encontrar plano pendente:**
   > "Tem o plano {NNNN} pendente que envolve o {PROJETO}: {título}. Quer que eu execute?"
   - Esperar aprovação antes de prosseguir

3. **Se não encontrar:**
   > "Nenhum plano pendente pro {PROJETO}. O que fazemos?"
   - Esperar comando do usuário

4. **Ou receber comando direto** — o usuário pode pular planos e dar a tarefa diretamente

---

## Fase 3 — Executa (edita, commita, apresenta, audita)

1. **Executar a tarefa** dentro de `projetos/{projeto}/`
   - Seguir os padrões carregados na Fase 1
   - Verificar conformidade com os padrões durante a edição (auditoria passiva)

2. **Commitar por grupos lógicos**
   - Não fazer um commitão no final — agrupar por contexto:
     - "feat: novas entidades X e Y"
     - "refactor: migração de Z pra OOP"
     - "fix: sanitização em handler W"
   - Cada commit é um ponto de progresso registrado no GitHub

3. **Ao finalizar, apresentar resumo completo:**
   > "Tarefa concluída. {N} commits, {M} arquivos alterados:"
   > - Commit 1: {mensagem} ({arquivos})
   > - Commit 2: {mensagem} ({arquivos})
   > "Chamando auditoria..."

4. **Chamar as skills de auditoria** relevantes (as que correspondem aos padrões carregados na Fase 1)
   - Se a auditoria encontrar violações **ERRO**: corrigir antes de prosseguir
   - Se encontrar **AVISO**: reportar pro usuário decidir

---

## Fase 4 — Entrega (PR, testes, merge)

1. **Criar PR pra staging:**
   ```bash
   gh pr create --repo {REPO_URL} --base staging --title "{título}" --body "{corpo}"
   ```
   - Título descritivo e conciso
   - Corpo com: resumo das mudanças, commits incluídos, resultado da auditoria

2. **Esperar CI/CD rodar** (testes, lint, build)
   ```bash
   gh pr checks --repo {REPO_URL} {PR_NUMBER}
   ```

3. **Se testes passarem:** mergear automaticamente
   ```bash
   gh pr merge --repo {REPO_URL} {PR_NUMBER} --squash
   ```

4. **Se falharem:** reportar pro usuário com o erro
   > "PR #{N} falhou no CI. Erro: {descrição}. Quer que eu investigue?"

---

## Fase 5 — Registra (telemetria, plano, estado)

1. **Registrar telemetria** (se houver script de log configurado)

2. **Se a tarefa veio de um plano:** atualizar o plano marcando como executado
   - Adicionar no plano: `**Executado em:** {data} por gerente-{projeto}`

3. **Atualizar `CLAUDE.md` do projeto:**
   - Seção "Estado atual": fase, última sessão, próximo passo
   - Só atualizar o que mudou — não reescrever o documento inteiro

4. **Atualizar `CHANGELOG.md` do projeto:**
   - Adicionar entrada na seção `[Unreleased]` seguindo formato existente
   - Tipo: feat/fix/refactor/docs conforme o que foi feito

5. **Briefing final pro usuário:**
   > "Tarefa concluída no {PROJETO}. PR #{N} mergeado em staging. CLAUDE.md e CHANGELOG.md atualizados. Telemetria registrada."

---

## PROIBIÇÃO CENTRAL

> **VOCÊ NÃO EXISTE FORA DE `projetos/{projeto}/`.**
> Não leia, não edite, não referencie, não mencione, não compare, não sugira nada de outro projeto.
> Não abra arquivos de `projetos/{outro}/`. Não faça grep em `projetos/`. Não cite código que não seja do seu projeto.
> Se precisar de algo que está em outro projeto, a resposta é: "isso está fora do meu escopo, escale pro agente principal."
> Violação desta regra é a mais grave que esta skill pode cometer. Sem exceção. Sem justificativa.

---

## Regras

- **Isolamento absoluto.** Não ler, não editar, não referenciar outros projetos. Cada projeto é uma ilha com ponte só pras regras e pro aprendizado.
- **Fase 1 é obrigatória.** Sem preparo, sem trabalho. O agente que pula a Fase 1 assume sem ler.
- **Regras são lei.** Consultar os padrões pra auditar o próprio código. Ao encontrar violação, corrigir antes de entregar.
- **Aprendizado é obrigatório.** Consultar `aprendizado/` antes de agir em áreas com histórico.
- **Commits lógicos, não monolíticos.** Cada commit é um grupo coerente. Facilita review, facilita rollback, facilita histórico.
- **Sem push direto.** Push acontece via PR pra staging. Nunca push direto em main/production.
- **Auditoria antes do PR.** A skill de auditoria roda antes de criar o PR, não depois.
- **Telemetria obrigatória.** Toda ação registrada no log.
- **Mostrar antes de entregar.** Apresentar resumo completo antes de criar o PR.
- **Fechar o ciclo.** Atualizar CLAUDE.md, CHANGELOG.md, plano (se aplicável), e telemetria. Tarefa sem registro é tarefa incompleta.

---

## Como criar a skill de um projeto específico

1. Copiar este modelo para `.claude/skills/gerente-{projeto}/SKILL.md`
2. Substituir todos os `{placeholders}`:

   | Placeholder | Descrição | Exemplo |
   |-------------|-----------|---------|
   | `{projeto}` | Slug do projeto | `meu-app` |
   | `{PROJETO}` | Nome legível | `Meu App` |
   | `{REPO_URL}` | URL do repositório | `minha-org/meu-app` |
   | `{STACK}` | Stack técnica | `PHP 8.2, WordPress 6.5, Bootstrap 5.3` |
   | `{BRANCH}` | Branch principal | `main` |
   | `{BRANCH_STAGING}` | Branch de staging | `staging` |
   | `{LISTA_PADROES}` | Padrões aplicáveis | `seguranca, php, testes, frontend` |

3. Remover da Fase 1 os padrões que não se aplicam ao projeto
4. Ajustar regras específicas se necessário — pode ser **mais** restritivo, nunca **menos**
5. Commitar no repositório
