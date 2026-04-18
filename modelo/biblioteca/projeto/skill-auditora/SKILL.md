---
name: skill-auditora
description: Skill orquestradora de auditoria para projetos. Identifica quais auditoras aplicar com base na stack, executa cada uma, consolida resultados e apresenta relatorio unificado. Trigger manual apenas.
---

# /skill-auditora — Orquestradora de auditoria

Identifica quais skills de auditoria (`/auditar-*`) se aplicam ao projeto com base na stack, executa cada uma em sequencia, consolida os resultados e apresenta um relatorio unificado. Funciona como gate de qualidade antes de criar PR.

## Quando usar

- Apos a `skill-executora` finalizar uma implementacao.
- Quando o usuario pedir uma auditoria completa do PR.
- Como pre-requisito para criar PR em staging.
- **Nunca** disparar automaticamente.

## Processo

### Fase 1 — Identificar auditoras aplicaveis

Com base na stack do projeto, determinar quais auditoras rodar:

| Stack | Auditoras aplicaveis |
|-------|---------------------|
| PHP | `/auditar-php` |
| OOP/Entidades | `/auditar-poo` |
| Testes PHPUnit | `/auditar-testes` |
| Seguranca | `/auditar-seguranca` |
| Criptografia | `/auditar-cripto` |
| HTML/CSS | `/auditar-frontend` |
| JavaScript | `/auditar-js` |

### Fase 2 — Executar auditoras em sequencia

Para cada auditora aplicavel:

1. Executar a skill de auditoria.
2. Coletar o relatorio (violacoes ERRO e AVISO).
3. Acumular resultados.

Ordem recomendada (das mais criticas para as menos):
1. Seguranca (SEG-*)
2. Criptografia (CRIPTO-*)
3. PHP (PHP-*)
4. POO (POO-*)
5. Testes (TST-*)
6. Frontend (UI-*)
7. JavaScript (JS-*)

### Fase 3 — Consolidar relatorio

Apresentar relatorio unificado:

```
## Relatorio de auditoria completa

**PR:** #<numero> — <titulo>
**Branch:** <branch>
**Auditoras executadas:** <lista>

### Resumo geral

| Auditora | Erros | Avisos | Status |
|----------|-------|--------|--------|
| Seguranca | 0 | 2 | Aprovado |
| PHP | 1 | 3 | Bloqueado |
| POO | 0 | 1 | Aprovado |
| Testes | 2 | 0 | Bloqueado |

**Total:** {N} erros, {M} avisos

### Violacoes bloqueantes (ERRO)

#### padroes-php.md, PHP-024
- **Arquivo:** inc/entidades/Pedido.php:15
- **Descricao:** FSM nao definida
- **Correcao:** Adicionar STATUS_TRANSITIONS

#### padroes-testes.md, TST-005
- **Arquivo:** inc/gerenciadores/PedidoManager.php
- **Descricao:** Codigo novo sem teste correspondente
- **Correcao:** Criar PedidoManagerTest em testes/componentes/

### Avisos (recomendacoes)
{lista de avisos}

### Veredicto
{N} erros bloqueantes. PR nao pode ser mergeado ate correcao.
Quer que eu execute as correcoes agora?
```

### Fase 4 — Corrigir ou escalar

Se houver violacoes ERRO:
1. Perguntar ao usuario se deve corrigir.
2. Se autorizado, corrigir e re-auditar.
3. Repetir ate zerar ERROs.

Se houver apenas AVISOs:
> "Nenhum erro bloquante. Os avisos sao recomendacoes — quer que eu corrija algum?"

Se nenhuma violacao:
> "Auditoria completa. Nenhuma violacao encontrada. PR pronto para merge."

## Regras

- **Todas as auditoras aplicaveis rodam.** Nao pular nenhuma por pressa ou conveniencia.
- **ERROs bloqueiam.** PR com ERRO nao pode ser criado/mergeado.
- **AVISOs precisam de justificativa.** Se o usuario decidir ignorar um AVISO, registrar a justificativa.
- **Re-auditar apos correcao.** Se correcoes foram feitas, rodar auditoria novamente para confirmar.
- **Nunca inventar regras.** Cada auditora segue exclusivamente seu documento de padroes.
- **Relatorio consolidado antes de qualquer acao.** Mostrar tudo antes de corrigir.
