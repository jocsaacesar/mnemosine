---
name: skill-executora
description: Skill de execucao para projetos. Recebe plano aprovado ou comando direto, implementa codigo seguindo padroes, commita por grupos logicos e apresenta resultado. Trigger manual apenas.
---

# /skill-executora — Executora de projeto

Recebe um plano aprovado (da `skill-planejadora`) ou comando direto do usuario e implementa o codigo seguindo os padroes do projeto. Commita por grupos logicos, apresenta resultado e delega para auditoria.

## Quando usar

- Quando houver um plano aprovado para executar.
- Quando o usuario der um comando direto de implementacao.
- **Nunca** disparar automaticamente.

## Processo

### Fase 1 — Preparar (conhecimento minimo)

1. **Ler o CLAUDE.md do projeto** — stack, arquitetura, convencoes, estado atual.
2. **Ler os padroes aplicaveis** em `docs/` — cada stack tem seu documento de padroes.
3. **Consultar `aprendizado/`** por incidentes relacionados a area de trabalho.
4. **Consultar ultimo PR:**
   ```bash
   gh pr list --state all --limit 5
   ```

### Fase 2 — Executar

1. **Implementar a tarefa** seguindo os padroes carregados na Fase 1.
2. **Aplicar os principios de codigo** (ver `principios-codigo.md` neste diretorio).
3. **Verificar conformidade** com os padroes durante a edicao (auditoria passiva).

### Fase 3 — Commitar por grupos logicos

Nao fazer um commitao no final — agrupar por contexto:
- "feat: novas entidades X e Y"
- "refactor: migracao de Z pra OOP"
- "fix: sanitizacao em handler W"

Cada commit e um ponto de progresso registrado no repositorio.

### Fase 4 — Apresentar resultado

Ao finalizar, apresentar resumo completo:

```
Tarefa concluida. {N} commits, {M} arquivos alterados:
- Commit 1: {mensagem} ({arquivos})
- Commit 2: {mensagem} ({arquivos})
Chamando auditoria...
```

### Fase 5 — Auditoria

1. Chamar as skills de auditoria relevantes para a stack.
2. Se a auditoria encontrar violacoes **ERRO**: corrigir antes de prosseguir.
3. Se encontrar **AVISO**: reportar para o usuario decidir.
4. Referenciar violacoes pelo ID do padrao (ex.: padroes-php.md, PHP-025).

### Fase 6 — Entregar PR

1. Criar PR:
   ```bash
   gh pr create --base staging --title "{titulo}" --body "{corpo}"
   ```
2. Esperar CI/CD rodar:
   ```bash
   gh pr checks {PR_NUMBER}
   ```
3. Se testes passarem: reportar sucesso.
4. Se falharem: reportar o erro ao usuario.

## Regras

- **Fase 1 e obrigatoria.** Sem preparo, sem trabalho. Assumir sem ler e violacao.
- **Padroes sao lei.** Consultar os documentos de padroes e auditar o proprio codigo.
- **Aprendizado e obrigatorio.** Consultar `aprendizado/` antes de agir em areas com historico.
- **Commits logicos, nao monoliticos.** Cada commit e um grupo coerente.
- **Sem push direto.** Push acontece via PR para staging. Nunca push direto em main/production.
- **Auditoria antes do PR.** A auditoria roda antes de criar o PR, nao depois.
- **Mostrar antes de entregar.** Apresentar resumo completo antes de criar o PR.
