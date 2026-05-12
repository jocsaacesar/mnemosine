# Pipeline de Desenvolvimento BGR

> Versão 0.1 — Extraído de 54 incidentes documentados.
> Cada skill é surda pro resto. Só enxerga a spec e seu escopo.

## Visão geral

```
Joc (pedido em linguagem natural)
  │
  ▼
Gerente (orquestra — não executa)
  │
  ├─► Interpretadora (lê pedido + código existente → spec completa)
  │       │
  │       ▼ gera: .specs/{timestamp}-{titulo}.md
  │
  ├─► Construtora Backend (lê spec § Backend → executa)
  │
  ├─► Construtora Frontend (lê spec § Frontend → executa)
  │
  ├─► Testadora (lê spec § Testes → unitários + edge cases)
  │
  ├─► Segurança (varre código novo → corrige vulnerabilidades)
  │
  ├─► Integradora (cola backend+frontend + testes de integração)
  │
  ├─► Auditoras (10 existentes — validação final por anexo)
  │
  └─► Gerente (valida, PR, deploy, telemetria)
```

## Princípios

1. **A Interpretadora pensa. As outras executam.** Nenhuma construtora decide o que fazer. A spec é o contrato.
2. **Spec incompleta = trabalho interrompido.** Se a construtora não encontra informação suficiente na spec, para e reporta — não inventa. (Lição: incidentes 0053, 0050)
3. **Cada skill lê só sua seção.** A construtora backend ignora a seção frontend. A testadora ignora a seção backend. Escopo fechado.
4. **Segurança corrige, não só reporta.** Diferente das auditoras (que listam findings), a skill de segurança aplica os fixes e documenta o que mudou.
5. **Integradora é a última antes do PR.** Garante que backend + frontend conversam, env carrega, CI passa. (Lição: incidentes 0021, 0043, 0031)
6. **Nenhuma skill pula protocolo.** CI vermelho bloqueia. Auditoria ERRO bloqueia. Sem atalho, sem "depois a gente corrige". (Lição: incidentes 0005, 0009)

## Ordem de execução

| Ordem | Skill | Entrada | Saída | Paralelo? |
|-------|-------|---------|-------|-----------|
| 1 | Interpretadora | Pedido do Joc + código existente | `.specs/{spec}.md` | — |
| 2 | Construtora Backend | Spec § Backend | Código PHP/OOP commitado | Sim (com Frontend) |
| 3 | Construtora Frontend | Spec § Frontend | Templates/CSS/JS commitados | Sim (com Backend) |
| 4 | Testadora | Spec § Testes + código gerado | Testes unitários commitados | Após 2+3 |
| 5 | Segurança | Código novo (diff da branch) | Fixes aplicados + relatório | Após 2+3 |
| 6 | Integradora | Tudo junto | Testes integração + validação | Após 4+5 |
| 7 | Auditoras | Código final | Relatório ERRO/AVISO | Após 6 |
| 8 | Gerente | Tudo validado | PR + merge + telemetria | Após 7 |

## Contrato: o arquivo de spec

A Interpretadora gera um `.md` em `.specs/` do projeto. Formato padronizado em `spec-modelo.md`.

**Regra de ouro:** se não está na spec, não existe. Construtora que executa algo fora da spec está em violação.

## Quando o pipeline não se aplica

- **Hotfix emergencial:** Gerente executa direto, registra depois. Máximo 1 arquivo, 1 fix cirúrgico.
- **Docs/config:** Gerente edita direto. Não precisa de pipeline pra editar um CLAUDE.md.
- **Investigação/diagnóstico:** Gerente investiga direto. Pipeline é pra construção, não pra leitura.

## Erros que este pipeline previne

| Incidente | Causa raiz | Skill que previne |
|-----------|-----------|-------------------|
| 0053 | Lógica inventada sem ler existente | Interpretadora (lê padrão real antes de especificar) |
| 0050 | Domínios/URLs inventados | Interpretadora (verifica existência antes de incluir na spec) |
| 0012 | Feature sem CRUD completo | Interpretadora (checklist obrigatório na spec) |
| 0045 | Página sem auth guard | Interpretadora (spec inclui auth por rota) |
| 0054 | replace_all corrompeu código | Construtora Backend (edição cirúrgica, sem replace_all cego) |
| 0008 | Coluna inexistente no from_row | Construtora Backend (lê schema real antes de mapear) |
| 0044 | Tenant leak cross-blog | Construtora Backend (for_site obrigatório) |
| 0052 | Seed duplicado multisite | Construtora Backend (idempotência obrigatória) |
| 0015 | Botão inacessível no mobile | Construtora Frontend (mobile-first, min 44px touch) |
| 0026 | Texto ilegível fundo escuro | Construtora Frontend (contraste WCAG obrigatório) |
| 0037 | Tokens de borda reincidentes | Construtora Frontend (só tokens do design system) |
| 0027 | Blocklist insuficiente | Segurança (varre endpoints, valida guards) |
| 0031 | getenv() vazio em prod | Segurança (valida env carrega com chars especiais) |
| 0034 | .env no build Docker | Segurança (verifica .dockerignore + .gitignore) |
| 0021 | Merge sem CI verde | Integradora (bloqueia merge sem CI) |
| 0043 | Reincidência merge sem CI | Integradora (checklist anti-reincidência) |
| 0046 | Schema stale nos testes CI | Integradora (recria banco no CI, não IF NOT EXISTS) |
| 0029 | docker cp como deploy | Integradora (rebuild imagem, nunca cp) |
