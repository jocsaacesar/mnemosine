---
name: auditar-acp
description: Audita código do ACP v2 contra as 200 regras do padroes-acp.md. Lê o documento constitucional, aplica regra por regra nos arquivos alterados, reporta violações por ID (ACP-001 a ACP-200). ERRO bloqueia merge, AVISO exige justificativa. Trigger manual apenas.
---

> **Engrama — BGR Software House**
> Art. 1° — Padrão de qualidade muito acima da média em tudo que faz.
> Art. 8° — Proibido assumir sem ler.
> Art. 22 — Toda skill é subordinada ao Engrama.
> Art. 25 — Todo projeto herda o Engrama e os padrões mínimos.

# /auditar-acp — Auditoria do Acertando os Pontos (v2)

Skill de auditoria exclusiva do projeto **Acertando os Pontos v2**. Lê o documento constitucional `padroes-acp.md` (200 regras, 132 ERRO, 68 AVISO) e audita o código entregue contra cada regra aplicável.

**Substitui as 8 auditorias separadas (PHP, POO, segurança, testes, cripto, WordPress, frontend, JS) por uma única auditoria consolidada pro stack TypeScript/Next.js.**

## Escopo de acesso

```
PODE LER:
  projetos/acertandoospontos/**                          ← código a auditar
  constitutional/padroes-minimos/padroes-acp.md          ← as 200 regras
  constitutional/ENGRAMA.md                              ← lei suprema
  aprendizado/**                                         ← incidentes anteriores

NÃO PODE LER NEM EDITAR:
  projetos/{outro-projeto}/**                            ← isolamento total
  memoria/                                               ← pessoal da Reliable
  troca/                                                 ← canal do Joc
```

## Quando usar

- Chamada pela `/gerente-acp` na Fase 3 (após execução, antes do PR)
- Chamada manualmente pelo Joc: `/auditar-acp`
- Chamada pela `/aprovar-pr` quando o PR é do repo ACP
- **Nunca** disparar automaticamente
- **Nunca** operar fora de `projetos/acertandoospontos/`

## Protocolo de auditoria

### Fase 1 — Carregar régua

1. **Ler `constitutional/padroes-minimos/padroes-acp.md`**
   - Absorver as 200 regras organizadas em 14 seções
   - Identificar severidades: ERRO (bloqueia merge) vs AVISO (exige justificativa)

2. **Consultar `aprendizado/`** por incidentes do ACP
   - Incidentes anteriores geram atenção redobrada nas áreas afetadas

### Fase 2 — Identificar escopo da auditoria

1. **Determinar o que auditar:**
   - Se chamada pela `/gerente-acp`: auditar os arquivos alterados nos commits da sessão
   - Se chamada manualmente: perguntar ao Joc o escopo (PR específico, arquivo, pasta, ou projeto inteiro)
   - Se chamada pela `/aprovar-pr`: auditar o diff do PR

2. **Listar arquivos no escopo:**
   ```bash
   cd ~/bgr-sh-reliable/projetos/acertandoospontos
   git diff --name-only staging  # ou o range de commits relevante
   ```

3. **Classificar cada arquivo por camada** (determina quais regras se aplicam):

   | Camada | Path | Seções do padrão aplicáveis |
   |---|---|---|
   | Entidades de domínio | `src/core/` | I (TS), III (Rich Domain), VI (Testes) |
   | Repositories | `src/repositories/` | I (TS), V (Banco), III (Repository) |
   | Managers | `src/managers/` | I (TS), III (Manager), IV (Segurança) |
   | Server Actions | `src/server/actions/` | I (TS), II (Next.js), IV (Segurança) |
   | Route Handlers | `src/app/api/` | I (TS), II (Next.js), IV (Segurança), XII (Pagamentos) |
   | Validators (Zod) | `src/lib/validators/` | I (TS), IV (Validação) |
   | Components React | `src/components/` | II (React), VII (Frontend), XI (Performance) |
   | Pages | `src/app/**/page.tsx` | II (Next.js), VII (Frontend), XI (Performance) |
   | Schema Drizzle | `src/db/schema/` | V (Banco) |
   | Migrations | `drizzle/` | V (Banco) |
   | Config | `*.config.*`, `biome.json` | I (TS), VIII (Qualidade) |
   | Testes | `**/*.test.ts` | VI (Testes) |
   | Email templates | `src/emails/` | XIII (Email) |

### Fase 3 — Auditar regra por regra

Para cada arquivo no escopo:

1. **Ler o arquivo**
2. **Aplicar cada regra da seção relevante** (conforme classificação da Fase 2)
3. **Registrar violação** no formato:

   ```
   arquivo:linha — ACP-XXX [ERRO|AVISO] — descrição curta da violação
   ```

4. **Regras de checagem rápida** (aplicar em TODOS os arquivos):

   | Verificação | Regras | Como checar |
   |---|---|---|
   | Sem `any` | ACP-002 | `grep -n ': any\|as any' arquivo` |
   | Sem `as Type` desnecessário | ACP-003 | Buscar `as ` seguido de tipo |
   | Sem `!` non-null assertion | ACP-007 | `grep -n '\w!' arquivo` (filtrar falsos positivos) |
   | Sem `@ts-ignore` | ACP-010 | `grep -n '@ts-ignore' arquivo` |
   | Sem `console.log` | ACP-180 | `grep -n 'console\.' arquivo` |
   | Sem `dangerouslySetInnerHTML` | ACP-029 | `grep -n 'dangerouslySetInnerHTML' arquivo` |
   | Sem secrets hardcoded | ACP-054 | `grep -n 'password\|secret\|api_key\|token.*=.*["\x27]' arquivo` |
   | Imports com alias `@/` | ACP-009 | Buscar `from '\.\./\.\./` (imports relativos profundos) |

5. **Regras estruturais** (verificar na visão geral do projeto):

   | Verificação | Regras |
   |---|---|
   | Entidades com construtor private + static factories | ACP-031, ACP-032 |
   | `fromPersistence` sem throw | ACP-033 |
   | FSM com `STATUS_TRANSITIONS` | ACP-034 |
   | Sem setters públicos | ACP-035 |
   | Repository encapsula Drizzle (ninguém mais importa Drizzle) | ACP-037 |
   | Repository retorna entidade, não row | ACP-038 |
   | Transações em operações multi-tabela | ACP-040 |
   | Manager recebe Repos via DI, não importa Drizzle | ACP-041, ACP-043 |
   | Server Action valida com Zod primeiro | ACP-044 |
   | Session verificada em toda ação autenticada | ACP-050 |
   | Ownership verificado (anti-IDOR) | ACP-051 |

6. **Regras de testes** (verificar se existem testes correspondentes):

   | Verificação | Regras |
   |---|---|
   | Entidade tem test file com 100% cobertura | ACP-084 |
   | Repository tem teste de integração | ACP-085 |
   | Manager tem teste unitário | ACP-086 |
   | `fromPersistence` tem teste de hidratação com nomes reais | ACP-090 |
   | FSM tem testes de todas transições (válidas e inválidas) | ACP-091 |
   | Bug corrigido tem teste de regressão | ACP-095 |

7. **Regras de frontend** (verificar em componentes e pages):

   | Verificação | Regras |
   |---|---|
   | Server Component por padrão, `'use client'` mínimo | ACP-011, ACP-012 |
   | Loading states com skeleton | ACP-017 |
   | Error boundaries | ACP-018 |
   | Acessibilidade WCAG AA | ACP-028 |
   | Mobile-first (breakpoints Tailwind) | ACP-101 |
   | Touch targets ≥ 44px | ACP-102 |
   | Copy em português coloquial | ACP-109 |
   | Tom aspiracional, não moralizante | ACP-110 |
   | Cores via design tokens, não hardcoded | ACP-096 |

### Fase 4 — Classificar e reportar

1. **Agrupar violações por severidade:**

   ```
   ## ERROS (bloqueiam merge)

   src/server/actions/lancamento.ts:15 — ACP-044 [ERRO] — Server Action não valida com Zod antes da auth
   src/core/lancamento.ts:42 — ACP-035 [ERRO] — Setter público `set status()`
   src/repositories/lancamento-repository.ts:28 — ACP-040 [ERRO] — Insert + update sem transação

   ## AVISOS (exigem justificativa)

   src/components/cartao-saldo.tsx:8 — ACP-022 [AVISO] — Props declaradas como type em vez de interface

   ## RESUMO

   | Severidade | Quantidade |
   |---|---|
   | ERRO | 3 |
   | AVISO | 1 |
   | Total | 4 |
   ```

2. **Se ERRO > 0:**
   > "Auditoria encontrou {N} ERROs bloqueantes. PR não pode ser mergeado. Corrijo agora?"

3. **Se ERRO = 0 e AVISO > 0:**
   > "Auditoria limpa — 0 ERRO. {N} AVISOs encontrados. Joc, quer justificar no PR ou quer que eu corrija?"

4. **Se ERRO = 0 e AVISO = 0:**
   > "Auditoria limpa — 0 violações. Código em conformidade com as 200 regras. Pode mergear."

### Fase 5 — Telemetria

```bash
bash /home/reliable/bgr-sh-reliable/infra/scripts/bgr-log.sh auditar-acp acertandoospontos {CONCLUIDO|FALHOU} {duração} "Auditoria: {N} ERRO, {M} AVISO em {X} arquivos"
```

---

## Regras da skill

- **Ler o padrão antes de auditar.** Sem exceção. Não auditar de memória — ler `padroes-acp.md` nesta sessão.
- **Cada violação referencia o ID.** `ACP-044`, não "falta validação". ID é rastreável.
- **ERRO é inegociável.** Não existe "ERRO que pode passar". ERRO bloqueia. Ponto.
- **AVISO é negociável com justificativa.** Se o Joc justificar por escrito no PR, AVISO é aceito.
- **Auditoria não corrige.** Reporta. Correção é responsabilidade da `/gerente-acp` ou do Joc. Se pedirem, aí corrijo.
- **Isolamento absoluto.** Não ler, não referenciar outros projetos.
- **Telemetria obrigatória.** Toda auditoria registrada.

---

## Diferença das auditorias antigas

| Antes (PHP stack) | Agora (TS stack) |
|---|---|
| 8 skills separadas (`/auditar-php`, `/auditar-poo`, etc.) | 1 skill consolidada (`/auditar-acp`) |
| 8 anexos separados (254 regras) | 1 documento único (`padroes-acp.md`, 200 regras) |
| Regras genéricas pra qualquer projeto | Regras específicas pro ACP e seu stack |
| Exemplos em PHP/WordPress | Exemplos em TypeScript/Next.js/Drizzle |
| Sem cobertura de React/RSC/Server Actions | Cobertura completa do paradigma Next.js 15 |
