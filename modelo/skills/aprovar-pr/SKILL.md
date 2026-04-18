---
name: aprovar-pr
description: Orquestra auditorias no PR aberto, aplica correções automaticamente, roda testes e mergea. Trigger manual apenas.
---

# /aprovar-pr — Pipeline de qualidade e merge

Assume o fluxo completo de um PR aberto: roda as auditorias de padrão do projeto, aplica correções automaticamente, executa os testes e — se tudo passar — faz o merge. É o maestro que orquestra as skills auditoras e leva o código até produção.

## Quando usar

- **APENAS** quando o usuário digitar `/aprovar-pr` explicitamente.
- Rodar quando o PR está pronto para revisão final e merge.
- **Nunca** disparar automaticamente, nem como parte de outra skill.

## Processo

### Fase 1 — Identificar o PR

1. Executar `gh pr list --state open --json number,title,headBranch,baseRefName --limit 5` para listar PRs abertos.
2. Se houver mais de um PR aberto, listar todos e perguntar ao usuário qual aprovar.
3. Se não houver PR aberto, informar e encerrar.
4. Executar `gh pr diff <numero>` para obter o diff completo.
5. Informar ao usuário:

> "PR #<numero> — <titulo> (branch: <branch> → <base>). Iniciando pipeline de qualidade."

### Fase 2 — Rodar as auditorias

Executar **todas** as auditorias disponíveis no projeto em sequência, coletando o relatório de cada uma.

Para cada auditoria:
- Carregar a régua correspondente (padrões mínimos embutidos no SKILL.md de cada skill auditora)
- Auditar todos os arquivos do PR contra as regras
- Coletar violações (ERRO e AVISO) com arquivo, linha, regra e correção

**Nota:** As auditorias disponíveis dependem da stack do projeto. Adapte esta fase às skills auditoras instaladas no seu `.claude/skills/` ou linkadas no projeto.

### Fase 3 — Relatório consolidado

Apresentar um relatório unificado ao usuário:

```
## Relatório consolidado — PR #<numero>

**Auditorias executadas:** N/N
**Total de ERROs:** <quantidade>
**Total de AVISOs:** <quantidade>

### Por auditoria

| Auditoria | ERROs | AVISOs | Status |
|-----------|-------|--------|--------|
| [nome]    | X     | X      | OK/ERRO|

### Violações (ERROs)

[Lista detalhada com arquivo, linha, regra, descrição e correção proposta]

### Avisos

[Lista de AVISOs — não bloqueiam o merge]
```

Se houver **zero ERROs**, pular para a Fase 5 (testes).

### Fase 4 — Aplicar correções

Se houver ERROs com correção automática possível:

1. Aplicar todas as correções automaticamente, sem pedir confirmação individual.
2. Informar ao usuário o que foi corrigido.
3. Commitar as correções em um **commit separado** (não misturar com o código original do PR).
   - Mensagem: `Corrigir violações de auditoria (<IDs das regras>)`

Se houver ERROs que **não podem ser corrigidos automaticamente**:

4. **Parar o pipeline.** Não mergear.
5. Listar os ERROs pendentes com detalhes e o que precisa de intervenção manual.

> "Pipeline bloqueado. <X> erro(s) precisam de correção manual antes de mergear. Veja acima."

Encerrar aqui — o usuário corrige manualmente e roda `/aprovar-pr` de novo.

### Fase 5 — Rodar testes

1. Executar a suite de testes relevante do projeto.
2. Se todos os testes passarem, informar:

> "Testes: todos passando."

3. Se algum teste falhar:

> "Pipeline bloqueado. <X> teste(s) falhando após correções. Veja os detalhes abaixo."

Listar os testes que falharam e encerrar. Não mergear.

### Fase 6 — Merge

Se todas as auditorias passaram (zero ERROs) e todos os testes passaram:

1. Apresentar resumo final:

```
## Pronto para merge

**PR:** #<numero> — <titulo>
**ERROs corrigidos:** <quantidade>
**AVISOs (não bloqueantes):** <quantidade>
**Testes:** passando
**Commits de correção:** <quantidade>

Executar o merge.
```

2. Executar `gh pr merge <numero> --merge` (ou `--squash` conforme convenção do projeto).
3. Confirmar:

> "PR #<numero> mergeado com sucesso."

## Regras

- **Nunca mergear com ERROs não resolvidos.** Se sobrou ERRO que não deu pra corrigir automaticamente, o pipeline bloqueia.
- **Nunca mergear sem testes passando.** Se os testes falharem após correções, o pipeline bloqueia.
- **Sempre commitar correções em commit separado.** Não misturar correções de auditoria com o código original do PR.
- **Nunca mergear sem mostrar o relatório final consolidado.** O usuário vê o resultado antes do merge acontecer.
- **AVISOs não bloqueiam.** São listados no relatório mas não impedem o merge.
- **Nunca inventar regras.** As réguas são exclusivamente os padrões mínimos embutidos no SKILL.md de cada skill auditora.
- **Nunca rodar auditorias em arquivos fora do PR.** Apenas o que está no diff.
