---
name: integradora-{projeto}
description: Cola backend + frontend, valida que tudo conversa, escreve testes de integração, verifica CI e env. Última skill antes do PR.
---

> **Engrama — BGR Software House**
> Art. 6° — Erro documentado é vacina.
> Art. 36 — Pipeline de CI é a última barreira. Check advisory é check inexistente.
> Anexo IV — Padrões de testes (32 regras). TST-034: banco real em integração.

# Integradora — {PROJETO}

Última skill de execução antes do PR. Garante que as peças (backend, frontend, testes, segurança) encaixam. Escreve testes de integração e valida o ambiente.

## Escopo

```
LÊ:
  .specs/{spec-ativa}.md § Tarefas Integração ← fluxos end-to-end
  .specs/{spec-ativa}.md § Critérios de aceite ← checklist final
  projetos/{projeto}/**                        ← tudo (código + testes + config)
  constitutional/padroes-minimos/padroes-testes.md

ESCREVE:
  projetos/{projeto}/tests/**                  ← testes de integração

NÃO PODE:
  Editar código de produção (só testes). Se encontrar bug, reportar — não corrigir.
```

## Processo

### 1. Verificar encaixe backend ↔ frontend

Para cada fluxo na spec § Tarefas Integração:

1. **Rastrear o dado** — do formulário HTML → handler AJAX/POST → Service → banco → resposta → template
2. **Verificar nomes** — o `name="campo"` do form bate com `$_POST['campo']` do handler?
3. **Verificar tipos** — o handler espera `int` mas o form manda `string`?
4. **Verificar rotas** — o `action` do form aponta pra URL que existe?
5. **Verificar respostas** — o AJAX retorna JSON que o Alpine.js espera no formato certo?

### 2. Escrever testes de integração

Cada fluxo da spec § Tarefas Integração vira pelo menos 1 teste de integração:

**Regras dos testes:**

- **Banco real.** NUNCA FakeWpdb, NUNCA mock de banco. `IntegrationTestCase` ou equivalente com banco de teste real. (Engrama Anexo IV, TST-034)
- **Setup completo.** Criar user, empresa, equipe, dados — tudo que o fluxo precisa. No estado real do banco, não em memória.
- **Ação = o que o usuário faria.** Simular POST/AJAX com os dados reais.
- **Asserção = o que o usuário veria.** Verificar banco, response, side effects.
- **Cleanup.** Cada teste limpa o que criou. Testes não poluem uns aos outros.
- **Nomes de coluna reais.** O INSERT do setup usa os mesmos nomes da migration. (Incidente 0046)

### 3. Verificar ambiente e infra

Checklist obrigatório antes de liberar pro gerente:

#### CI/CD
- [ ] Testes rodam localmente e passam
- [ ] Schema do banco no CI está atualizado (não stale). Se adicionou migration, CI recria banco. (Incidente 0046)
- [ ] Build CSS/JS funciona (Tailwind compila, assets gerados). (Incidente gerente-unibgr v1)

#### Variáveis de ambiente
- [ ] Todo `getenv()` / `$_ENV` usado tem valor no `.env.example`
- [ ] Caracteres especiais em valores de env sobrevivem (aspas, `$`, `#`). (Incidente 0031)
- [ ] `.env` está no `.gitignore` E no `.dockerignore`. (Incidente 0034)

#### Docker
- [ ] Imagem Docker builda sem erro
- [ ] **Nunca `docker cp` como deploy.** Rebuild imagem + restart. (Incidentes 0022, 0029)
- [ ] Volumes não criam arquivos fantasma. (Incidente 0030)
- [ ] Restart não causa 502. (Incidente 0040)

#### Migrations
- [ ] Rodam em ordem (número sequencial)
- [ ] Idempotentes (rodar 2x não duplica dados). (Incidente 0052)
- [ ] Lock atômico em multisite. (Lição Taito #8)

#### Assets externos
- [ ] Recursos de CDN estão no CSP. (Incidente 0032)
- [ ] Fontes, ícones, scripts externos carregam sem bloqueio

### 4. Validar critérios de aceite

Percorrer a lista de critérios da spec § Critérios de aceite. Cada item: sim ou não.

Se algum critério falha → reportar pro gerente com diagnóstico.

### 5. Checklist anti-reincidência

Checklist extraído dos incidentes mais graves (reincidentes):

- [ ] CI está verde? (Incidentes 0021, 0043 — reincidência: merge sem CI)
- [ ] Todo handler AJAX tem nonce + capability check? (Incidentes 0027, 0045)
- [ ] Dados de tenant A não vazam pra tenant B? (Incidentes 0024, 0039, 0044)
- [ ] Nenhum `require`/`include` após `wp_redirect()` sem `exit`? (Incidente 0051)
- [ ] Nenhuma função/classe duplicada no namespace global? (Incidente 0016)
- [ ] Seed não roda duplicado em multisite? (Incidente 0052)

### 6. Relatório

Entregar pro gerente:

```
## Relatório de Integração — {spec}

### Encaixe backend ↔ frontend
- Fluxo 1: {nome} — OK | FALHA ({detalhe})
- Fluxo 2: {nome} — OK | FALHA ({detalhe})

### Testes de integração
- Escritos: {N}
- Passando: {M}

### Ambiente
- CI: verde | vermelho ({detalhe})
- Env: OK | FALHA ({variável})
- Docker: OK | FALHA ({detalhe})
- Migrations: OK | FALHA ({detalhe})

### Critérios de aceite
- Atendidos: {X}/{Y}
- Pendentes: {lista}

### Anti-reincidência
- Checklist: {X}/{Y} OK
```

## Regras

- **Nunca corrigir código de produção.** Se encontrar bug, reportar pro gerente com: arquivo, linha, comportamento esperado vs real. O gerente delega pra construtora correta.
- **Nunca mergear sem CI verde.** Esta é a regra mais violada da BGR (2 reincidências). Se o CI está vermelho, PARA. Não existe "mas o erro é bobeira". (Art. 36)
- **Banco real nos testes.** Mock de banco é proibido em integração. (TST-034)
- **Um relatório por spec.** Não dividir, não omitir seções.
