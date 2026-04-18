---
name: skill-planejadora
description: Skill de planejamento para projetos. Recebe demanda do usuario, analisa contexto, cria plano estruturado com modulos e entrega estimativa. Trigger manual apenas.
---

# /skill-planejadora — Planejadora de projeto

Recebe uma demanda (feature, refatoracao, migracao, correcao), analisa o estado atual do codigo, consulta padroes e historico, e produz um plano estruturado com modulos sequenciais.

## Quando usar

- Quando o usuario pedir para planejar uma feature, migracao ou mudanca significativa.
- Antes de executar tarefas complexas que envolvem multiplos arquivos ou camadas.
- **Nunca** disparar automaticamente.

## Processo

### Fase 1 — Entender a demanda

1. Ler o pedido do usuario e confirmar entendimento.
2. Se a demanda for ambigua, perguntar antes de planejar.
3. Identificar: escopo (quais camadas/arquivos), riscos (o que pode quebrar), dependencias (o que precisa existir antes).

### Fase 2 — Analisar o estado atual

1. Ler o `CLAUDE.md` do projeto para entender fase, stack, convencoes.
2. Consultar `docs/` por padroes aplicaveis.
3. Consultar `aprendizado/` por incidentes anteriores na area.
4. Verificar PRs recentes:
   ```bash
   gh pr list --state all --limit 5
   ```

### Fase 3 — Estruturar o plano

1. Dividir a demanda em **modulos sequenciais** (cada modulo e um PR independente).
2. Para cada modulo, definir:
   - **Titulo** — o que faz
   - **Arquivos afetados** — quais cria, altera ou deleta
   - **Dependencias** — quais modulos precisam estar prontos antes
   - **Riscos** — o que pode dar errado
   - **Criterio de aceite** — como saber que esta pronto
3. Ordenar modulos por dependencia (fundacao primeiro, polish por ultimo).

### Fase 4 — Apresentar ao usuario

Formato do plano:

```
## Plano: {titulo}

**Demanda:** {resumo do pedido}
**Modulos:** {quantidade}
**Estimativa:** {tempo aproximado}

### Modulo 0 — {titulo}
- **Faz:** {descricao}
- **Arquivos:** {lista}
- **Depende de:** nenhum
- **Risco:** {descricao}
- **Aceite:** {criterio}

### Modulo 1 — {titulo}
- **Faz:** {descricao}
- **Arquivos:** {lista}
- **Depende de:** Modulo 0
- **Risco:** {descricao}
- **Aceite:** {criterio}

### Proximo passo
Aprovar o plano e executar Modulo 0?
```

### Fase 5 — Aguardar aprovacao

1. **Nunca** executar sem aprovacao explicita do usuario.
2. O usuario pode aprovar o plano inteiro, modulo por modulo, ou pedir ajustes.
3. Se aprovado, delegar para a `skill-executora`.

## Regras

- **Plano antes de codigo.** Nunca pular para execucao sem plano aprovado em tarefas complexas.
- **Modulos independentes.** Cada modulo e um PR que pode ser revertido sem afetar os outros.
- **Riscos explicitos.** Se algo pode quebrar, dizer antes — nao depois.
- **Estimativa honesta.** Se nao sabe o tempo, dizer "nao sei estimar" em vez de chutar.
- **Consultar historico.** Verificar `aprendizado/` antes de planejar areas com incidentes anteriores.
- **Escopo apertado.** Planejar o minimo necessario para a demanda. Extras viram backlog, nao modulos.
