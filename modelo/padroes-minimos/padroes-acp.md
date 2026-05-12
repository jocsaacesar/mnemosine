---
documento: padroes-acp
versao: 1.2.0
criado: 2026-04-12
atualizado: 2026-04-16
total_regras: 200
severidades:
  erro: 146
  aviso: 54
escopo: Todo código do projeto Acertando os Pontos (ACP v2) — TypeScript, Next.js 15, React, Drizzle, PostgreSQL 17, Better Auth, Tailwind v4, shadcn/ui, Zod, Vitest, Playwright, Biome, Pino, Sentry, Mercado Pago
aplica_a: ["acertandoospontos"]
requer: []
substitui: ["Para o ACP v2, este documento substitui integralmente os Anexos I-VIII genéricos"]
---

# Padrões Mínimos — Acertando os Pontos (ACP v2)

> Documento constitucional. Contrato de entrega entre a BGR e todo agente que toca código no ACP.
> Código que viola regras ERRO não é discutido — é devolvido.
> **Padrão ouro. 100% de cobertura. Não aceitamos menos.**

---

## Como usar este documento

### Para o agente (Reliable / gerente-acp)

1. Leia este documento inteiro antes de abrir qualquer PR no ACP.
2. Use os IDs das regras (ACP-001 a ACP-200) para referenciar em PRs e auditorias.
3. Consulte o DoD no final antes de submeter qualquer entrega.

### Para a skill de auditoria (/auditar-acp)

1. Leia o frontmatter para confirmar escopo.
2. Audite o código contra cada regra por ID e severidade.
3. ERRO bloqueia merge — sem negociação.
4. AVISO exige justificativa escrita no PR.
5. Referencie sempre pelo ID: `ACP-042`.

---

## Severidades

| Nível | Significado | Ação |
|-------|-------------|------|
| **ERRO** | Violação inegociável | Bloqueia merge. Corrigir antes de review. |
| **AVISO** | Recomendação forte | Deve ser justificada por escrito se ignorada. |

---

# I — TypeScript Estrito

## 1. Configuração e tipos

### ACP-001 — strict: true sem exceção [ERRO]

**Regra:** `tsconfig.json` deve ter `strict: true`. Nenhuma flag individual pode ser desligada (`noImplicitAny`, `strictNullChecks`, `strictFunctionTypes`, `noUncheckedIndexedAccess` — todas ligadas).

**Verifica:** Verificar `"strict": true` em tsconfig.json. Ausência é violação.

**Por quê na BGR:** ACP lida com dinheiro. `undefined` onde devia ter centavos é bug financeiro. TypeScript estrito elimina classes inteiras de erro antes do runtime. Desligar qualquer flag é abrir brecha.

**Exemplo correto:**
```json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "exactOptionalPropertyTypes": true
  }
}
```

**Exemplo incorreto:**
```json
{
  "compilerOptions": {
    "strict": true,
    "strictNullChecks": false
  }
}
```

---

### ACP-002 — Sem any explícito ou implícito [ERRO]

**Regra:** `any` não aparece no código. Nem explícito (`valor: any`), nem implícito (retorno não tipado de função). Se o tipo é desconhecido, usar `unknown` e narrowing.

**Verifica:** TSC strict mode + grep por `any` ou `as any`. Qualquer uso de `any` sem justificativa é violação.

**Por quê na BGR:** `any` desliga o TypeScript. Em projeto financeiro, um `any` que escapa validação pode transformar string em number silenciosamente. `unknown` obriga o desenvolvedor a provar o tipo antes de usar.

**Exemplo correto:**
```typescript
function processarResposta(dados: unknown): Lancamento {
  const parsed = esquemaLancamento.parse(dados) // Zod faz o narrowing
  return Lancamento.criar(parsed)
}
```

**Exemplo incorreto:**
```typescript
function processarResposta(dados: any): Lancamento {
  return Lancamento.criar(dados) // nenhuma garantia de tipo
}
```

---

### ACP-003 — Sem asserções de tipo desnecessárias [ERRO]

**Regra:** `as Type` só é permitido quando o compilador genuinamente não consegue inferir (ex: retorno de lib externa sem tipos). Usar type guards ou Zod em vez de `as`.

**Verifica:** Verificar schema Zod em inputs de API/forms. Input sem validação é violação.

**Por quê na BGR:** `as` mente pro compilador. `valor as number` não converte nada — só silencia o erro. Em código financeiro, asserção errada causa cálculo silenciosamente incorreto. Type guard prova; `as` assume.

**Exemplo correto:**
```typescript
function ehLancamento(dados: unknown): dados is DadosLancamento {
  return typeof dados === 'object' && dados !== null && 'valorCentavos' in dados
}

if (ehLancamento(resposta)) {
  // TypeScript sabe que é DadosLancamento aqui
  console.log(resposta.valorCentavos)
}
```

**Exemplo incorreto:**
```typescript
const lancamento = resposta as DadosLancamento // mentira pro compilador
console.log(lancamento.valorCentavos) // pode ser undefined em runtime
```

---

### ACP-004 — Enums como const objects ou union types [AVISO]

**Regra:** Preferir `as const` satisfies ou union types sobre `enum`. Enums do TS geram código JavaScript extra e têm armadilhas de comparação. Se usar enum, deve ser `const enum`.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

**Por quê na BGR:** Enums TS numéricas aceitam qualquer número em runtime (`StatusEnum[999]` retorna `undefined` sem erro). Union types e const objects são type-safe de verdade.

**Exemplo correto:**
```typescript
// Union type — preferido pra valores simples
type TipoConta = 'pessoal' | 'negocio'

// Const object — preferido quando precisa de mapeamento
const STATUS_LANCAMENTO = {
  PENDENTE: 'pendente',
  EFETIVADO: 'efetivado',
  CANCELADO: 'cancelado',
} as const

type StatusLancamento = typeof STATUS_LANCAMENTO[keyof typeof STATUS_LANCAMENTO]
```

**Exemplo incorreto:**
```typescript
enum StatusLancamento {
  PENDENTE = 0,
  EFETIVADO = 1,
  CANCELADO = 2,
}
// StatusLancamento[999] é undefined mas TS não reclama
```

---

### ACP-005 — Retorno de função sempre tipado explicitamente [ERRO]

**Regra:** Toda função exportada ou método público deve ter tipo de retorno explícito. Funções internas/privadas podem usar inferência se o tipo for óbvio.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

**Por quê na BGR:** Tipo de retorno explícito é contrato. Se alguém muda a implementação interna, o compilador garante que o contrato continua sendo honrado. Em projeto financeiro, retorno inferido que muda silenciosamente causa bugs downstream.

**Exemplo correto:**
```typescript
export function calcularSaldo(lancamentos: Lancamento[]): number {
  return lancamentos.reduce((acc, l) => acc + l.valorCentavos, 0)
}
```

**Exemplo incorreto:**
```typescript
export function calcularSaldo(lancamentos: Lancamento[]) {
  return lancamentos.reduce((acc, l) => acc + l.valorCentavos, 0)
  // retorno inferido — muda se a implementação mudar
}
```

---

### ACP-006 — Valores monetários em centavos como inteiro [ERRO]

**Regra:** Todo valor monetário é armazenado e manipulado como inteiro em centavos (1 real = 100). Tipo `number`, nunca `string` ou `float`. Formatação pra reais (`R$ 1.234,56`) acontece **exclusivamente** na camada de apresentação.

**Verifica:** Inspecionar que cada camada só acessa suas dependências diretas. Bypass de camada é violação.

**Por quê na BGR:** Aritmética de ponto flutuante em JavaScript: `0.1 + 0.2 = 0.30000000000000004`. Em fintech, isso é bug financeiro. Centavos como inteiro elimina o problema por design. É padrão de indústria (Stripe, Mercado Pago).

**Exemplo correto:**
```typescript
class Lancamento {
  private readonly _valorCentavos: number // 15990 = R$ 159,90

  static criar(dados: DadosLancamento): Lancamento {
    if (!Number.isInteger(dados.valorCentavos) || dados.valorCentavos <= 0) {
      throw new ErroValidacao('Valor deve ser inteiro positivo em centavos')
    }
    return new Lancamento(dados)
  }
}

// Na apresentação:
function formatarReais(centavos: number): string {
  return (centavos / 100).toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' })
}
```

**Exemplo incorreto:**
```typescript
class Lancamento {
  private readonly _valor: number // 159.90 — ponto flutuante

  somar(outro: Lancamento): number {
    return this._valor + outro._valor // 0.1 + 0.2 !== 0.3
  }
}
```

---

### ACP-007 — Sem operador non-null assertion (!) [ERRO]

**Regra:** O operador `!` pós-fixo (`valor!.propriedade`) é proibido. Usar optional chaining (`?.`), nullish coalescing (`??`), ou narrowing explícito.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

**Por quê na BGR:** `!` diz "confie em mim, não é null" — mesma mentira que `as`. Em código financeiro, `usuario!.contaId` que é null em runtime causa crash silencioso ou dado corrompido. Narrowing prova; `!` assume.

**Exemplo correto:**
```typescript
const conta = usuario?.contaPessoal
if (!conta) {
  throw new ErroNaoEncontrado('Conta pessoal não encontrada')
}
// TypeScript sabe que conta não é null aqui
```

**Exemplo incorreto:**
```typescript
const conta = usuario!.contaPessoal! // pode ser null em runtime
```

---

### ACP-008 — Branded types para IDs e valores de domínio [AVISO]

**Regra:** IDs de entidade e valores de domínio críticos devem usar branded types pra evitar mistura acidental.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

**Por quê na BGR:** `function buscarLancamento(id: string)` aceita qualquer string — inclusive um `usuarioId` por engano. Branded types fazem o compilador rejeitar mistura de IDs entre entidades.

**Exemplo correto:**
```typescript
type UsuarioId = string & { readonly __brand: 'UsuarioId' }
type ContaId = string & { readonly __brand: 'ContaId' }
type LancamentoId = string & { readonly __brand: 'LancamentoId' }

function buscarLancamento(id: LancamentoId): Promise<Lancamento | null> { ... }

// Compilador rejeita: buscarLancamento(usuarioId) — tipo incompatível
```

**Exemplo incorreto:**
```typescript
function buscarLancamento(id: string): Promise<Lancamento | null> { ... }
// buscarLancamento(usuarioId) compila sem erro — bug silencioso
```

---

### ACP-009 — Imports com alias absoluto [AVISO]

**Regra:** Usar path aliases do tsconfig (`@/core/`, `@/lib/`, `@/components/`) em vez de imports relativos profundos (`../../../`).

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

**Por quê na BGR:** Imports relativos profundos quebram ao mover arquivos e são ilegíveis. Aliases mantêm imports curtos e refatoração-safe.

**Exemplo correto:**
```typescript
import { Lancamento } from '@/core/lancamento'
import { LancamentoRepository } from '@/repositories/lancamento-repository'
```

**Exemplo incorreto:**
```typescript
import { Lancamento } from '../../../core/lancamento'
```

---

### ACP-010 — Sem @ts-ignore ou @ts-expect-error sem justificativa [ERRO]

**Regra:** `@ts-ignore` é proibido. `@ts-expect-error` é permitido **apenas** com comentário explicando por quê e referência a issue/PR que vai resolver.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

**Por quê na BGR:** Suprimir erros de tipo é esconder bugs. Se o compilador reclama, o código está errado — conserte o código, não silencie o compilador.

**Exemplo correto:**
```typescript
// @ts-expect-error — Tipagem do better-auth não expõe session.user.contaId (PR #42 no upstream)
const contaId = session.user.contaId
```

**Exemplo incorreto:**
```typescript
// @ts-ignore
const contaId = session.user.contaId
```

---

# II — Next.js 15 e React

## 2. App Router e Server Components

### ACP-011 — Server Components por padrão [ERRO]

**Regra:** Todo componente é Server Component por padrão. `'use client'` só aparece quando o componente precisa de interatividade (estado, efeitos, event handlers, hooks de browser). Nunca adicionar `'use client'` "por precaução".

**Verifica:** Inspecionar que cada camada só acessa suas dependências diretas. Bypass de camada é violação.

**Por quê na BGR:** RSC é defesa por design — JS do servidor nunca chega ao cliente, reduzindo superfície de XSS e tamanho do bundle. ACP é mobile-first pra público classe C/D em 4G — cada KB conta.

**Exemplo correto:**
```typescript
// src/app/painel/page.tsx — Server Component (sem 'use client')
import { buscarSaldo } from '@/server/actions/saldo'

export default async function PaginaPainel() {
  const saldo = await buscarSaldo()
  return <CartaoSaldo saldo={saldo} />
}
```

**Exemplo incorreto:**
```typescript
'use client' // desnecessário — componente não usa estado nem efeitos

import { buscarSaldo } from '@/server/actions/saldo'

export default function PaginaPainel() { ... }
```

---

### ACP-012 — 'use client' no menor componente possível [ERRO]

**Regra:** Quando interatividade é necessária, isolar o `'use client'` no menor componente possível. Nunca marcar a página inteira como client.

**Verifica:** Grep por `'use client'` — verificar se o componente realmente precisa ser client. Server por padrão.

**Por quê na BGR:** Marcar a página como client força todo o subtree a ser client — matando os benefícios de RSC (dados no servidor, zero JS no cliente pro conteúdo estático). ACP tem dashboards onde 80% é dado estático — só o botão de filtro precisa de client.

**Exemplo correto:**
```typescript
// src/app/painel/page.tsx — Server Component
export default async function PaginaPainel() {
  const dados = await buscarDadosPainel()
  return (
    <div>
      <ResumoPainel dados={dados} />      {/* Server — sem JS no cliente */}
      <FiltroInterativo />                {/* Client — só este componente */}
    </div>
  )
}

// src/components/filtro-interativo.tsx
'use client'
export function FiltroInterativo() {
  const [filtro, setFiltro] = useState('mes')
  // ...
}
```

**Exemplo incorreto:**
```typescript
'use client' // página inteira virou client
export default function PaginaPainel() { ... }
```

---

### ACP-013 — Server Actions como entry points finos [ERRO]

**Regra:** Server Actions (`'use server'`) são entry points finos: validam input com Zod, instanciam a Service Layer, chamam Manager, retornam resultado. **Sem lógica de negócio dentro do Server Action.**

**Verifica:** Verificar que server actions validam input e autenticação. Action sem validação é violação.

**Por quê na BGR:** Server Action é fronteira do sistema — mesma filosofia dos handlers no UniBGR. Lógica de negócio no action não é testável sem Next.js rodando. No Manager, é testável com Vitest puro.

**Exemplo correto:**
```typescript
// src/server/actions/lancamento.ts
'use server'

import { esquemaCriarLancamento } from '@/lib/validators/lancamento'
import { criarContextoServico } from '@/server/contexto'

export async function criarLancamento(dados: FormData) {
  const ctx = await criarContextoServico() // auth + DI
  const input = esquemaCriarLancamento.parse(Object.fromEntries(dados))
  return ctx.lancamentoManager.criar(input)
}
```

**Exemplo incorreto:**
```typescript
'use server'

export async function criarLancamento(dados: FormData) {
  const usuario = await getSession()
  const db = await getDb()
  // 50 linhas de lógica de negócio que deviam estar no Manager
  const resultado = await db.insert(lancamentos).values({ ... })
  return resultado
}
```

---

### ACP-014 — Sem fetch em Server Components quando Server Action resolve [AVISO]

**Regra:** Server Components podem chamar funções do servidor diretamente (import de módulo TS). Não usar `fetch()` pra chamar API interna — isso é round-trip desnecessário.

**Verifica:** Grep por `'use client'` — verificar se o componente realmente precisa ser client. Server por padrão.

**Por quê na BGR:** RSC roda no servidor. Chamar função do servidor diretamente é chamada de função local — sem HTTP, sem serialização, sem latência. `fetch()` pra API própria dentro do mesmo processo é overhead inútil.

**Exemplo correto:**
```typescript
// Server Component chama função diretamente
import { buscarLancamentos } from '@/repositories/lancamento-repository'

export default async function PaginaExtrato() {
  const lancamentos = await buscarLancamentos(contaId)
  return <ListaLancamentos dados={lancamentos} />
}
```

**Exemplo incorreto:**
```typescript
export default async function PaginaExtrato() {
  const res = await fetch('http://localhost:3000/api/lancamentos') // round-trip desnecessário
  const lancamentos = await res.json()
  return <ListaLancamentos dados={lancamentos} />
}
```

---

### ACP-015 — Route Handlers (API) só para webhooks e integrações externas [AVISO]

**Regra:** `src/app/api/` é reservado para endpoints consumidos por terceiros: webhooks do Mercado Pago, APIs públicas futuras. Pra frontend→backend, usar Server Actions.

**Verifica:** Verificar que server actions validam input e autenticação. Action sem validação é violação.

**Por quê na BGR:** Server Actions têm tipagem end-to-end, CSRF automático pelo Next.js e invalidação de cache integrada. Route Handler é HTTP cru — exige mais código pra mesma segurança. Usar API interna quando Server Action resolve é retrabalho (Art. 15).

**Exemplo correto:**
```
src/app/api/webhooks/mercado-pago/route.ts   ← webhook externo — Route Handler OK
src/server/actions/lancamento.ts              ← frontend chama — Server Action
```

**Exemplo incorreto:**
```
src/app/api/lancamentos/route.ts   ← API interna pro frontend — deveria ser Server Action
```

---

### ACP-016 — Metadata e SEO em toda página [AVISO]

**Regra:** Toda página (`page.tsx`) exporta `metadata` ou `generateMetadata` com `title` e `description`.

**Verifica:** Verificar export de metadata/generateMetadata em pages. Página sem metadata é violação.

**Por quê na BGR:** ACP precisa de SEO na landing page e meta tags corretas nas páginas internas (compartilhamento via WhatsApp do público-alvo). Página sem metadata é oportunidade desperdiçada.

**Exemplo correto:**
```typescript
export const metadata: Metadata = {
  title: 'Extrato | Acertando os Pontos',
  description: 'Veja todas as suas entradas e saídas organizadas por data',
}
```

---

### ACP-017 — Loading states com Suspense e skeleton [ERRO]

**Regra:** Toda página com dados assíncronos deve ter `loading.tsx` ou `<Suspense fallback={<Skeleton />}>`. Fallback é skeleton loader, nunca spinner genérico.

**Verifica:** Verificar presença de loading.tsx ou Suspense boundary. Rota sem loading state é violação.

**Por quê na BGR:** Princípio de UX do ACP: "Loading state em toda ação que demora >300ms. Skeleton loaders, não spinners." (CLAUDE.md seção 1.5). Spinner gira sem contexto; skeleton comunica estrutura.

**Exemplo correto:**
```typescript
// src/app/painel/loading.tsx
export default function PainelLoading() {
  return (
    <div className="space-y-4">
      <Skeleton className="h-32 w-full" /> {/* cartão de saldo */}
      <Skeleton className="h-64 w-full" /> {/* lista de lançamentos */}
    </div>
  )
}
```

**Exemplo incorreto:**
```typescript
export default function PainelLoading() {
  return <Spinner /> // sem contexto visual
}
```

---

### ACP-018 — Error boundaries em toda rota [ERRO]

**Regra:** Toda rota com dados assíncronos deve ter `error.tsx`. O error boundary deve: (1) mostrar mensagem amigável, (2) oferecer botão de retry, (3) logar o erro no Sentry.

**Verifica:** Verificar que erros críticos são logados com contexto. Erro silencioso é violação.

**Por quê na BGR:** Erro sem tratamento mostra stack trace pro usuário ou tela branca. Público-alvo do ACP (classe C/D) vai achar que o app quebrou e abandonar. Error boundary contém o dano e mantém confiança.

**Exemplo correto:**
```typescript
'use client'

import { reportarErro } from '@/lib/sentry'

export default function PainelError({
  error,
  reset,
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  useEffect(() => { reportarErro(error) }, [error])

  return (
    <div className="text-center py-12">
      <p>Algo deu errado ao carregar o painel.</p>
      <Button onClick={reset}>Tentar de novo</Button>
    </div>
  )
}
```

---

### ACP-019 — Sem estado global client-side [ERRO]

**Regra:** Sem Redux, Zustand, Jotai ou qualquer store global. Estado de servidor via TanStack Query. Estado local via `useState`/`useReducer`. Server Components pra dados estáticos.

**Verifica:** Grep por `'use client'` — verificar se o componente realmente precisa ser client. Server por padrão.

**Por quê na BGR:** Decisão de stack cravada pelo Joc. Server Components + TanStack Query cobrem 100% dos casos do ACP. Store global é complexidade sem retorno pra projeto deste tamanho.

---

### ACP-020 — Formulários com react-hook-form + Zod [ERRO]

**Regra:** Todo formulário usa `react-hook-form` com resolver Zod. Mesmo schema Zod valida no client (UX) e no server action (segurança).

**Verifica:** Verificar que server actions validam input e autenticação. Action sem validação é violação.

**Por quê na BGR:** Schema único elimina drift entre validação frontend e backend. Em fintech, validação que diverge entre client e server é porta aberta pra dado inválido no banco.

**Exemplo correto:**
```typescript
// src/lib/validators/lancamento.ts — schema compartilhado
export const esquemaCriarLancamento = z.object({
  valorCentavos: z.number().int().positive(),
  tipo: z.enum(['entrada', 'saida']),
  descricao: z.string().min(1).max(200),
  categoriaId: z.string().uuid(),
  data: z.coerce.date(),
})

// Client — react-hook-form usa o mesmo schema
const form = useForm({ resolver: zodResolver(esquemaCriarLancamento) })

// Server Action — mesmo schema
const input = esquemaCriarLancamento.parse(dados)
```

---

## 3. React Components

### ACP-021 — Componentes como funções, nunca classes [ERRO]

**Regra:** Todos os componentes React são funções. Classes de React são proibidas.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

**Por quê na BGR:** Decisão de stack. Hooks + Server Components são incompatíveis com class components. React 19 reforça isso.

---

### ACP-022 — Props tipadas com interface, não type [AVISO]

**Regra:** Props de componentes declaradas como `interface` com sufixo `Props`. Types reservados para unions e intersections.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

**Por quê na BGR:** Interfaces são extensíveis, têm melhor mensagem de erro do TS, e a convenção `Props` torna o grep trivial.

**Exemplo correto:**
```typescript
interface CartaoSaldoProps {
  saldo: number
  mostraCentavos?: boolean
}

export function CartaoSaldo({ saldo, mostraCentavos = true }: CartaoSaldoProps) { ... }
```

---

### ACP-023 — Sem prop drilling além de 2 níveis [ERRO]

**Regra:** Se uma prop precisa passar por mais de 2 componentes intermediários que não a usam, extrair pra contexto, composição ou Server Component.

**Verifica:** Grep por `'use client'` — verificar se o componente realmente precisa ser client. Server por padrão.

**Por quê na BGR:** Prop drilling é acoplamento invisível — mover um componente intermediário quebra toda a cadeia. Contexto ou composição (children/slots) resolve sem acoplamento.

---

### ACP-024 — Keys estáveis e únicas em listas [ERRO]

**Regra:** `key` em listas deve ser ID estável da entidade, nunca índice do array. Exceto listas estáticas que nunca reordenam.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

**Por quê na BGR:** Key por índice causa re-render incorreto em listas que mudam (adicionar, remover, reordenar). Em lista de lançamentos financeiros, re-render errado pode mostrar valor de um lançamento no card de outro.

**Exemplo correto:**
```typescript
{lancamentos.map(l => <CartaoLancamento key={l.id} lancamento={l} />)}
```

**Exemplo incorreto:**
```typescript
{lancamentos.map((l, i) => <CartaoLancamento key={i} lancamento={l} />)}
```

---

### ACP-025 — Hooks no topo, sem condicionais [ERRO]

**Regra:** Hooks chamados no topo do componente, nunca dentro de condicionais, loops ou funções aninhadas. Regra do React — violar causa bugs sutis de estado.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

### ACP-026 — useEffect com dependências corretas e cleanup [ERRO]

**Regra:** Todo `useEffect` deve ter array de dependências explícito e correto. Effects que criam subscriptions, timers ou listeners devem retornar cleanup function.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

**Por quê na BGR:** Dependência faltando causa stale closure — valor antigo usado em vez do atual. Em tela de saldo, closure stale mostra saldo desatualizado. Sem cleanup, listeners acumulam e causam memory leak.

**Exemplo correto:**
```typescript
useEffect(() => {
  const handler = (e: KeyboardEvent) => { if (e.key === 'Escape') fechar() }
  window.addEventListener('keydown', handler)
  return () => window.removeEventListener('keydown', handler)
}, [fechar])
```

**Exemplo incorreto:**
```typescript
useEffect(() => {
  window.addEventListener('keydown', handler) // sem cleanup
}) // sem dependências — roda em todo render
```

---

### ACP-027 — Sem lógica de negócio em componentes [ERRO]

**Regra:** Componentes React são apresentação. Cálculos, validações e transformações de dados ficam em: entidades (domínio), managers (orquestração), ou funções utilitárias (`@/lib/`). Componente recebe dado pronto e renderiza.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

**Por quê na BGR:** Mantra: "O usuário faz uma coisa. Tudo o mais é nosso." O "nosso" roda no servidor (entidades/managers/actions), não no componente React. Lógica no componente não é testável sem React, e viola a separação de camadas.

**Exemplo correto:**
```typescript
// Lógica no Manager
const resumo = await ctx.painelManager.gerarResumoMensal(contaId, mes)

// Componente só renderiza
export function CartaoResumo({ resumo }: CartaoResumoProps) {
  return (
    <Card>
      <p>Entradas: {formatarReais(resumo.totalEntradas)}</p>
      <p>Saídas: {formatarReais(resumo.totalSaidas)}</p>
    </Card>
  )
}
```

**Exemplo incorreto:**
```typescript
export function CartaoResumo({ lancamentos }: Props) {
  // Cálculo de negócio dentro do componente
  const totalEntradas = lancamentos
    .filter(l => l.tipo === 'entrada')
    .reduce((acc, l) => acc + l.valorCentavos, 0)
  // ...
}
```

---

### ACP-028 — Acessibilidade WCAG AA obrigatória [ERRO]

**Regra:** Todo componente interativo deve ter: atributos ARIA quando necessário (Radix/shadcn cobrem por padrão), labels visíveis ou `aria-label`, contraste mínimo 4.5:1 pra texto e 3:1 pra gráficos, navegação por teclado funcional, touch targets ≥ 44×44px.

**Verifica:** Verificar presença de atributos ARIA e labels em elementos interativos. Ausência é violação.

**Por quê na BGR:** Princípio de UX do ACP: "WCAG AA mínimo" (CLAUDE.md seção 1.5). Público classe C/D usa dispositivos com telas menores e em condições de luminosidade variada. Acessibilidade não é diferencial — é obrigação.

---

### ACP-029 — Sem dangerouslySetInnerHTML [ERRO]

**Regra:** `dangerouslySetInnerHTML` é proibido. Se precisar renderizar HTML dinâmico (improvável no ACP), usar lib de sanitização (DOMPurify) e justificar no PR.

**Verifica:** Grep por output sem sanitização (`dangerouslySetInnerHTML`, template literals em DOM). Qualquer saída não escapada é violação.

**Por quê na BGR:** XSS persistente em aplicação financeira é catástrofe. React escapa por padrão — `dangerouslySetInnerHTML` desliga essa proteção.

---

### ACP-030 — Composição sobre herança, children sobre config [AVISO]

**Regra:** Preferir composição via `children` e slots sobre componentes configuráveis com muitas props. Se um componente tem >7 props, provavelmente precisa ser quebrado.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

**Por quê na BGR:** Componentes com muitas props são difíceis de auditar e testar. Composição é explícita — o que você vê no JSX é o que renderiza.

---

# III — Rich Domain Model (OOP em TypeScript)

## 4. Entidades de domínio

### ACP-031 — Entidades são classes ricas com comportamento [ERRO]

**Regra:** Entidades de domínio (`src/core/`) são classes com: construtor `private`, static factories (`criar` e `fromPersistence`), getters sem prefixo `get`, lifecycle methods, predicados, validação interna. **Não são DTOs anêmicos.**

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

**Por quê na BGR:** Padrão OOP herdado do UniBGR. Entidade rica garante que objeto inválido nunca existe — validação no `criar`, estado controlado por lifecycle methods. Anêmico espalha validação pelo código e permite estados impossíveis.

**Exemplo correto:**
```typescript
export class Lancamento {
  private constructor(
    private readonly _id: LancamentoId,
    private readonly _contaId: ContaId,
    private readonly _valorCentavos: number,
    private _status: StatusLancamento,
    private readonly _tipo: TipoLancamento,
    private readonly _descricao: string,
    private readonly _categoriaId: CategoriaId,
    private readonly _data: Date,
    private readonly _criadoEm: Date,
    private _atualizadoEm: Date,
  ) {}

  static criar(dados: DadosCriarLancamento): Lancamento {
    if (dados.valorCentavos <= 0) {
      throw new ErroValidacao('Valor deve ser positivo')
    }
    if (dados.descricao.length > 200) {
      throw new ErroValidacao('Descrição excede 200 caracteres')
    }
    const agora = new Date()
    return new Lancamento(
      crypto.randomUUID() as LancamentoId,
      dados.contaId,
      dados.valorCentavos,
      'pendente',
      dados.tipo,
      dados.descricao,
      dados.categoriaId,
      dados.data,
      agora,
      agora,
    )
  }

  static fromPersistence(row: LancamentoRow): Lancamento {
    // Nunca lança exception — mapeamento direto (Lição #7 do UniBGR)
    return new Lancamento(
      row.id as LancamentoId,
      row.conta_id as ContaId,
      row.valor_centavos,
      row.status as StatusLancamento,
      row.tipo as TipoLancamento,
      row.descricao,
      row.categoria_id as CategoriaId,
      new Date(row.data),
      new Date(row.criado_em),
      new Date(row.atualizado_em),
    )
  }

  get id(): LancamentoId { return this._id }
  get valorCentavos(): number { return this._valorCentavos }
  get status(): StatusLancamento { return this._status }
  get estaPendente(): boolean { return this._status === 'pendente' }
  get estaEfetivado(): boolean { return this._status === 'efetivado' }

  efetivar(): void {
    if (!this.podeTransicionarPara('efetivado')) {
      throw new ErroTransicao(`Não pode efetivar lançamento com status ${this._status}`)
    }
    this._status = 'efetivado'
    this._atualizadoEm = new Date()
  }

  cancelar(): void {
    if (!this.podeTransicionarPara('cancelado')) {
      throw new ErroTransicao(`Não pode cancelar lançamento com status ${this._status}`)
    }
    this._status = 'cancelado'
    this._atualizadoEm = new Date()
  }

  private static readonly STATUS_TRANSITIONS: Record<StatusLancamento, StatusLancamento[]> = {
    pendente: ['efetivado', 'cancelado'],
    efetivado: ['cancelado'],
    cancelado: [],
  }

  podeTransicionarPara(novoStatus: StatusLancamento): boolean {
    return Lancamento.STATUS_TRANSITIONS[this._status].includes(novoStatus)
  }
}
```

**Exemplo incorreto:**
```typescript
// DTO anêmico — sem comportamento, sem proteção
interface Lancamento {
  id: string
  valorCentavos: number
  status: string // qualquer string aceita
}

// Lógica espalhada em funções soltas
function efetivarLancamento(l: Lancamento) {
  l.status = 'efetivado' // sem validação de transição
}
```

---

### ACP-032 — Construtor private, criação via static factory [ERRO]

**Regra:** Construtor de entidade é `private`. Criação via `static criar(dados)` (com validação) ou `static fromPersistence(row)` (sem validação, mapeamento direto).

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

**Por quê na BGR:** Construtor público permite objeto pela metade. Factory `criar` é a porta de entrada controlada — valida antes de construir. `fromPersistence` confia no banco (dado já foi validado na entrada).

---

### ACP-033 — fromPersistence nunca lança exception [ERRO]

**Regra:** `fromPersistence(row)` faz mapeamento direto de colunas pra campos. Sem validação, sem throw. Se o dado no banco está errado, o problema é no `criar` que deixou passar — não no read.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

**Por quê na BGR:** Lição #7 do UniBGR. `fromPersistence` que lança exception impede a leitura de dados legados ou migrados. Se 1 row de 10.000 tem dado inconsistente, o sistema inteiro para. Tolerância na leitura, rigidez na escrita.

---

### ACP-034 — FSM explícita via STATUS_TRANSITIONS [ERRO]

**Regra:** Toda entidade com status deve ter `static readonly STATUS_TRANSITIONS` mapeando transições válidas. Lifecycle methods (`efetivar`, `cancelar`, `bloquear`) validam a transição antes de mutar.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

**Por quê na BGR:** Sem FSM, qualquer código pode mutar status pra qualquer valor. Em fintech, transição inválida (ex: cancelado→efetivado) causa inconsistência financeira. FSM garante que a máquina de estados é respeitada mecanicamente.

---

### ACP-035 — Sem setters públicos [ERRO]

**Regra:** Mutação de estado só via lifecycle methods (`efetivar()`, `cancelar()`, `atualizarDescricao(nova)`). Nunca `lancamento.status = 'efetivado'`. Campos são `private` ou `readonly`.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

**Por quê na BGR:** Tell, Don't Ask. Setter permite qualquer código mutar estado sem validação. Lifecycle method encapsula a regra de negócio junto com a mutação.

---

### ACP-036 — Predicados como propriedades computed [AVISO]

**Regra:** Predicados de estado como getters booleanos: `get estaPendente()`, `get estaAtivo()`, `get podeCancelar()`. Quem consome nunca compara status diretamente.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

**Por quê na BGR:** Centraliza a definição de "o que é pendente" na entidade. Se o conceito muda (ex: pendente agora inclui "em revisão"), muda em 1 lugar.

---

## 5. Repositories

### ACP-037 — 1 Repository por entidade, encapsula Drizzle [ERRO]

**Regra:** Cada entidade tem 1 Repository. O Repository recebe `Db` (conexão Drizzle) no construtor via DI. **Manager e Server Action nunca falam com Drizzle diretamente.**

**Verifica:** Grep por queries dentro de loops (`for`, `while`, `map` com await de DB). Qualquer ocorrência é violação.

**Por quê na BGR:** Repository é a única porta pro banco. Se alguém importa Drizzle diretamente num Server Action, está bypassando auditoria, cripto, e qualquer lógica de persistência. Isolamento é inegociável.

**Exemplo correto:**
```typescript
export class LancamentoRepository {
  constructor(private readonly db: Db) {}

  async buscarPorConta(contaId: ContaId): Promise<Lancamento[]> {
    const rows = await this.db
      .select()
      .from(lancamentos)
      .where(eq(lancamentos.contaId, contaId))
      .orderBy(desc(lancamentos.data))

    return rows.map(Lancamento.fromPersistence)
  }

  async inserir(lancamento: Lancamento): Promise<void> {
    await this.db.insert(lancamentos).values({
      id: lancamento.id,
      conta_id: lancamento.contaId,
      valor_centavos: lancamento.valorCentavos,
      // ...
    })
  }
}
```

**Exemplo incorreto:**
```typescript
// Server Action importa Drizzle diretamente — PROIBIDO
'use server'
import { db } from '@/lib/db'
import { lancamentos } from '@/db/schema'

export async function criarLancamento(dados: FormData) {
  await db.insert(lancamentos).values({ ... }) // bypass do Repository
}
```

---

### ACP-038 — Repository retorna entidade de domínio, não row [ERRO]

**Regra:** Métodos de leitura do Repository retornam instâncias da entidade (via `fromPersistence`), nunca objetos raw do banco. Métodos de escrita recebem entidade de domínio.

**Verifica:** Grep por queries dentro de loops (`for`, `while`, `map` com await de DB). Qualquer ocorrência é violação.

**Por quê na BGR:** Quem consome o Repository trabalha com domínio, não com schema de banco. Se o schema muda (renomear coluna, split de tabela), só o Repository muda — consumidores continuam recebendo a mesma entidade.

---

### ACP-039 — Queries tipadas com Drizzle schema [ERRO]

**Regra:** Toda query usa o schema Drizzle tipado. Sem SQL cru (`sql\`SELECT...\``) exceto quando Drizzle não suporta a operação (RLS, pgcrypto, CTEs complexas). SQL cru deve ter comentário justificando.

**Verifica:** Verificar que alterações de schema têm migration correspondente. Schema sem migration é violação.

**Por quê na BGR:** Drizzle é type-safe — schema mudou, query quebra em compile time. SQL cru não tem essa proteção. Exceção justificada pro pgcrypto (cripto column-level) e RLS (policies).

---

### ACP-040 — Transações explícitas para operações multi-tabela [ERRO]

**Regra:** Operações que afetam mais de uma tabela devem rodar dentro de `db.transaction()`. Sem transação, falha no meio deixa banco inconsistente.

**Verifica:** Linter/formatter automático (Prettier/ESLint). Qualquer desvio é violação.

**Por quê na BGR:** Criar lançamento + atualizar saldo da conta = 2 operações. Se o saldo atualiza mas o lançamento falha, o saldo está errado. Em fintech, inconsistência financeira é catástrofe.

**Exemplo correto:**
```typescript
async criarComSaldo(lancamento: Lancamento, contaId: ContaId): Promise<void> {
  await this.db.transaction(async (tx) => {
    await tx.insert(lancamentos).values({ ... })
    await tx.update(contas)
      .set({ saldo_centavos: sql`saldo_centavos + ${lancamento.valorCentavos}` })
      .where(eq(contas.id, contaId))
  })
}
```

---

## 6. Managers (Service Layer)

### ACP-041 — Manager orquestra, não implementa [ERRO]

**Regra:** Manager recebe Repositories no construtor (DI). Orquestra regras de negócio cross-entidade. Não faz queries diretas nem manipula HTTP.

**Verifica:** Grep por queries dentro de loops (`for`, `while`, `map` com await de DB). Qualquer ocorrência é violação.

**Por quê na BGR:** Manager é o cérebro do negócio. Testável com mocks dos Repositories. Se Manager fala com banco direto, o teste precisa de banco real — mais lento, mais frágil.

**Exemplo correto:**
```typescript
export class LancamentoManager {
  constructor(
    private readonly lancamentoRepo: LancamentoRepository,
    private readonly contaRepo: ContaRepository,
  ) {}

  async criar(dados: DadosCriarLancamento): Promise<Lancamento> {
    const conta = await this.contaRepo.buscarPorId(dados.contaId)
    if (!conta) throw new ErroNaoEncontrado('Conta não encontrada')
    if (!conta.estaAtiva) throw new ErroNegocio('Conta inativa')

    const lancamento = Lancamento.criar(dados)
    await this.lancamentoRepo.inserirComSaldo(lancamento, conta.id)
    return lancamento
  }
}
```

---

### ACP-042 — DSL de atalhos contextuais [AVISO]

**Regra:** Manager expõe métodos semânticos de alto nível, não só CRUD genérico. `notificarFaturaVenceHoje(contaId)` em vez de `criarNotificacao({ tipo: 'fatura', ... })`. Quem chama nunca monta payload técnico.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

**Por quê na BGR:** Herança do UniBGR. DSL torna o código de negócio legível como texto. Adicionar funcionalidade nova = adicionar método novo no Manager, não descobrir quais params montar.

---

### ACP-043 — DI via construtor, sem singleton global [ERRO]

**Regra:** Repositories e Managers recebem dependências via construtor. Sem singleton global (`const repo = new Repository(globalDb)`). Factory function centralizada (`criarContextoServico`) monta o grafo de DI.

**Verifica:** Grep por queries dentro de loops (`for`, `while`, `map` com await de DB). Qualquer ocorrência é violação.

**Por quê na BGR:** Singleton global é estado mutável compartilhado — dificulta testes (precisa resetar entre testes) e impossibilita parallelismo. DI via construtor é testável, previsível e explícito.

**Exemplo correto:**
```typescript
// src/server/contexto.ts
export async function criarContextoServico() {
  const sessao = await getSessao()
  if (!sessao) throw new ErroNaoAutenticado()

  const db = getDb()
  const lancamentoRepo = new LancamentoRepository(db)
  const contaRepo = new ContaRepository(db)
  const lancamentoManager = new LancamentoManager(lancamentoRepo, contaRepo)

  return { sessao, lancamentoManager, contaRepo }
}
```

---

# IV — Segurança

## 7. Validação na fronteira

### ACP-044 — Server Action valida com Zod antes de tudo [ERRO]

**Regra:** Primeira linha de um Server Action é `esquema.parse(dados)`. Antes da auth, antes do banco, antes de qualquer lógica. Dado não parseado não existe.

**Verifica:** Verificar que server actions validam input e autenticação. Action sem validação é violação.

**Por quê na BGR:** Server Action é fronteira do sistema. Tudo que vem do client é potencialmente manipulado. Zod rejeita tipo errado, formato errado, domínio errado — em uma linha.

**Exemplo correto:**
```typescript
'use server'

export async function criarLancamento(dadosCrus: unknown) {
  const dados = esquemaCriarLancamento.parse(dadosCrus) // primeira coisa
  const ctx = await criarContextoServico()               // auth depois
  return ctx.lancamentoManager.criar(dados)
}
```

---

### ACP-045 — Schemas Zod em módulo separado, compartilhados [ERRO]

**Regra:** Schemas Zod ficam em `src/lib/validators/`. Mesmo schema importado pelo client (react-hook-form) e pelo server (action). Nunca duplicar schema.

**Verifica:** Verificar que alterações de schema têm migration correspondente. Schema sem migration é violação.

**Por quê na BGR:** Schema duplicado diverge. Client aceita campo X, server rejeita. Usuário preenche form corretamente mas recebe erro do server — UX terrível e bug difícil de debugar.

---

### ACP-046 — Validar tipo, formato e domínio [ERRO]

**Regra:** Toda entrada deve ser validada em três níveis: tipo (`z.number()`), formato (`z.int().positive()`), e domínio (`z.enum(['entrada', 'saida'])`). Zod permite expressar os três em uma declaração.

**Verifica:** Verificar schema Zod em inputs de API/forms. Input sem validação é violação.

**Por quê na BGR:** Validação incompleta é validação inútil. `z.number()` aceita `NaN` e `Infinity`. `z.number().int().positive().max(99999999)` é completo.

**Exemplo correto:**
```typescript
const esquemaCriarLancamento = z.object({
  valorCentavos: z.number().int().positive().max(99_999_999),     // tipo + formato + domínio
  tipo: z.enum(['entrada', 'saida']),                              // domínio fechado
  descricao: z.string().min(1).max(200).trim(),                    // formato + domínio
  categoriaId: z.string().uuid(),                                  // formato
  data: z.coerce.date().refine(d => d <= new Date(), 'Data futura'),  // domínio
})
```

---

### ACP-047 — Nunca confiar em dados do frontend [ERRO]

**Regra:** IDs, valores, status — tudo que vem do frontend é potencialmente manipulado. Server Action revalida tudo. Frontend é conveniência, nunca garantia.

**Verifica:** Verificar que server actions validam input e autenticação. Action sem validação é violação.

**Por quê na BGR:** DevTools permitem alterar qualquer valor. Em fintech, usuário que manda `valorCentavos: -5000` pode gerar crédito indevido. Backend é autoridade absoluta.

---

### ACP-048 — Whitelist sobre blocklist [AVISO]

**Regra:** Validar contra o que é permitido (`z.enum(['a', 'b', 'c'])`), nunca contra o que é proibido. Lista branca é finita; lista negra é infinita.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

## 8. Autenticação e autorização

### ACP-049 — Better Auth como única fonte de autenticação [ERRO]

**Regra:** Autenticação exclusivamente via Better Auth. Sem auth customizada, sem JWT manual, sem session management próprio. Better Auth gerencia sessions com HTTP-only secure cookies, Argon2id pra hash de senha, CSRF automático.

**Verifica:** Verificar presença de token CSRF em formulários e mutations. Ausência é violação.

**Por quê na BGR:** Auth customizada é o vetor de segurança mais perigoso que existe. Better Auth é auditado, mantido por comunidade, e implementa NIST 800-63B por padrão. Reinventar auth é hubris.

---

### ACP-050 — Session verificada em todo Server Action e Route Handler [ERRO]

**Regra:** Toda ação autenticada começa verificando session. Session inválida ou expirada = rejeitar imediatamente.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

**Exemplo correto:**
```typescript
export async function criarContextoServico() {
  const sessao = await auth.api.getSession({ headers: await headers() })
  if (!sessao) throw new ErroNaoAutenticado('Sessão inválida ou expirada')
  return { sessao, /* ... */ }
}
```

---

### ACP-051 — Verificar propriedade do recurso (anti-IDOR) [ERRO]

**Regra:** Antes de ler, alterar ou deletar qualquer recurso, verificar se o usuário autenticado é dono ou membro da conta que possui o recurso. Nunca confiar no ID vindo do frontend.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

**Por quê na BGR:** ACP armazena dados financeiros de múltiplos usuários no mesmo banco. IDOR permite que usuário A veja saldo/lançamentos do usuário B trocando um ID na request. Em fintech, isso é violação de sigilo bancário.

**Exemplo correto:**
```typescript
async buscarLancamento(id: LancamentoId, contaId: ContaId): Promise<Lancamento> {
  const lancamento = await this.lancamentoRepo.buscarPorId(id)
  if (!lancamento || lancamento.contaId !== contaId) {
    throw new ErroNaoEncontrado('Lançamento não encontrado')
    // Mensagem genérica — não revelar que o recurso existe mas pertence a outro
  }
  return lancamento
}
```

---

### ACP-052 — Papéis verificados em toda ação [ERRO]

**Regra:** Toda ação verifica se o papel do usuário permite a operação. Dono pode tudo na conta; consultor só lê. Verificação é mecânica — sem atalhos.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

**Por quê na BGR:** ACP tem multi-membro na Conta Negócios (dono + consultor read-only). Consultor que consegue criar lançamento é escalonamento de privilégios.

---

### ACP-053 — Row-Level Security (RLS) como defesa em profundidade [ERRO]

**Regra:** Tabelas com dados de usuário devem ter RLS policies no PostgreSQL. RLS é camada extra — não substitui verificação no código, complementa.

**Verifica:** Inspecionar que cada camada só acessa suas dependências diretas. Bypass de camada é violação.

**Por quê na BGR:** RLS garante isolamento no nível do banco. Se um bug no código bypassa a verificação de ownership, RLS impede o acesso no banco. Defesa em profundidade — duas camadas independentes.

**Exemplo correto:**
```sql
ALTER TABLE lancamentos ENABLE ROW LEVEL SECURITY;

CREATE POLICY lancamentos_por_conta ON lancamentos
  USING (conta_id IN (
    SELECT conta_id FROM membros_conta
    WHERE usuario_id = current_setting('app.usuario_id')::uuid
  ));
```

---

### ACP-054 — Sem secrets no código-fonte [ERRO]

**Regra:** Nenhuma chave de API, senha, token ou segredo aparece em código ou arquivo versionado. Tudo em variáveis de ambiente (`.env` local, env do container em prod). `.env` no `.gitignore`.

**Verifica:** Grep por strings hardcoded (passwords, tokens, keys). Qualquer segredo no código é violação.

**Por quê na BGR:** Segredo commitado é segredo exposto pra sempre no histórico do Git. Incidente documentado no servidor (secrets expostos durante migração, rotacionados manualmente).

---

### ACP-055 — HTTPS obrigatório, cookies Secure + HttpOnly + SameSite [ERRO]

**Regra:** Produção só HTTPS (TLS 1.2+). Cookies de session: `Secure`, `HttpOnly`, `SameSite=Lax`. Better Auth configura isso por padrão — não alterar.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

## 9. Criptografia

### ACP-056 — Dados sensíveis criptografados em repouso com pgcrypto [ERRO]

**Regra:** Valores monetários, descrições de transações, dados bancários, CPF, dados pessoais — criptografados no banco via pgcrypto (AES-256). Cripto no Repository, transparente pro domínio.

**Verifica:** Verificar que dados sensíveis usam criptografia antes de persistir. Texto puro é violação.

**Por quê na BGR:** Vazamento do banco (dump, backup exposto) sem cripto expõe dados financeiros em texto claro. pgcrypto é extensão nativa do PostgreSQL — sem overhead de rede, sem lib externa.

**Exemplo correto:**
```typescript
// No Repository — criptografa na escrita
async inserir(lancamento: Lancamento): Promise<void> {
  await this.db.execute(sql`
    INSERT INTO lancamentos (id, conta_id, valor_centavos, descricao)
    VALUES (
      ${lancamento.id},
      ${lancamento.contaId},
      pgp_sym_encrypt(${String(lancamento.valorCentavos)}, ${this.chave}),
      pgp_sym_encrypt(${lancamento.descricao}, ${this.chave})
    )
  `)
}

// Descriptografa na leitura
async buscarPorId(id: LancamentoId): Promise<Lancamento | null> {
  const [row] = await this.db.execute(sql`
    SELECT id, conta_id,
      pgp_sym_decrypt(valor_centavos, ${this.chave})::int AS valor_centavos,
      pgp_sym_decrypt(descricao, ${this.chave}) AS descricao
    FROM lancamentos WHERE id = ${id}
  `)
  return row ? Lancamento.fromPersistence(row) : null
}
```

---

### ACP-057 — Chave de criptografia exclusivamente em variável de ambiente [ERRO]

**Regra:** Chave do pgcrypto vem de `process.env.ACP_ENCRYPTION_KEY`. Nunca hardcoded, nunca em constante, nunca em arquivo versionado.

**Verifica:** Verificar que dados sensíveis usam criptografia antes de persistir. Texto puro é violação.

---

### ACP-058 — Senhas com Argon2id (Better Auth default) [ERRO]

**Regra:** Hash de senha via Argon2id (padrão NIST 800-63B). Better Auth implementa nativamente — não alterar o algoritmo. Se adicionar autenticação alternativa no futuro, Argon2id é obrigatório.

**Verifica:** Verificar que dados sensíveis usam criptografia antes de persistir. Texto puro é violação.

---

### ACP-059 — Logs nunca contêm dados sensíveis [ERRO]

**Regra:** Logger (Pino) configurado com `redact` pra remover automaticamente: `cpf`, `senha`, `password`, `token`, `cookie`, `authorization`, `chave`, `valorCentavos`, `descricao` (quando descriptografado). Sentry com `beforeSend` scrubando os mesmos campos.

**Verifica:** Verificar que dados sensíveis usam criptografia antes de persistir. Texto puro é violação.

**Por quê na BGR:** Log com dado sensível em texto claro é vazamento passivo. LGPD Art. 37 exige que dados pessoais sejam protegidos em todo o ciclo — incluindo logs.

**Exemplo correto:**
```typescript
const logger = pino({
  redact: {
    paths: ['cpf', 'senha', 'password', 'token', 'cookie', 'authorization',
            'req.headers.authorization', 'req.headers.cookie',
            '*.valorCentavos', '*.descricao', '*.numeroConta'],
    censor: '[REDACTED]',
  },
})
```

---

## 10. XSS e sanitização

### ACP-060 — React escapa por padrão — não desligar [ERRO]

**Regra:** JSX escapa strings automaticamente. Nunca usar `dangerouslySetInnerHTML` (vide ACP-029). Dados dinâmicos em atributos usam interpolação JSX (escapada por padrão).

**Verifica:** Grep por output sem sanitização (`dangerouslySetInnerHTML`, template literals em DOM). Qualquer saída não escapada é violação.

---

### ACP-061 — CSP restritivo via headers Next.js [AVISO]

**Regra:** Content-Security-Policy configurado em `next.config.ts` ou middleware. Mínimo: `default-src 'self'`, `script-src 'self' 'nonce-{random}'`, `style-src 'self' 'unsafe-inline'` (Tailwind exige inline styles).

**Verifica:** Verificar que rotas protegidas passam por middleware de auth. Rota exposta é violação.

**Por quê na BGR:** CSP é segunda camada contra XSS. Se um XSS escapa do React (via third-party script), CSP bloqueia a execução.

---

### ACP-062 — Headers de segurança obrigatórios [ERRO]

**Regra:** Configurar via `next.config.ts` ou nginx: `Strict-Transport-Security`, `X-Content-Type-Options: nosniff`, `X-Frame-Options: DENY`, `Referrer-Policy: strict-origin-when-cross-origin`, `Permissions-Policy` restritivo.

**Verifica:** Verificar `"strict": true` em tsconfig.json. Ausência é violação.

---

## 11. CSRF

### ACP-063 — Server Actions têm CSRF automático do Next.js [ERRO]

**Regra:** Não desabilitar CSRF protection do Next.js em Server Actions. Next 15 inclui token CSRF automaticamente — qualquer config que desliga isso é violação.

**Verifica:** Verificar presença de token CSRF em formulários e mutations. Ausência é violação.

---

### ACP-064 — Route Handlers validam Origin/Referer [ERRO]

**Regra:** Route Handlers (webhooks, APIs) que aceitam mutação devem validar `Origin` ou `Referer` header, ou usar outro mecanismo anti-CSRF (token no header, HMAC signature).

**Verifica:** Verificar presença de token CSRF em formulários e mutations. Ausência é violação.

---

## 12. Webhooks e pagamentos

### ACP-065 — Webhook do Mercado Pago valida HMAC signature [ERRO]

**Regra:** Webhook do Mercado Pago deve validar a assinatura HMAC do header `x-signature` antes de qualquer processamento. Requisição sem assinatura válida é rejeitada com 401.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

**Por quê na BGR:** Webhook é porta aberta. Sem validação de assinatura, qualquer pessoa que descobre a URL pode forjar notificações de pagamento — registrando pagamentos inexistentes.

**Exemplo correto:**
```typescript
// src/app/api/webhooks/mercado-pago/route.ts
export async function POST(request: Request) {
  const assinatura = request.headers.get('x-signature')
  const corpo = await request.text()

  if (!validarAssinaturaMercadoPago(assinatura, corpo)) {
    return new Response('Assinatura inválida', { status: 401 })
  }

  const dados = JSON.parse(corpo)
  // Consulta API do MP pra confirmar antes de processar
  const pagamento = await mercadoPago.buscarPagamento(dados.data.id)
  await processarPagamento(pagamento)

  return new Response('OK', { status: 200 })
}
```

---

### ACP-066 — Sempre consultar API de origem antes de processar webhook [ERRO]

**Regra:** Após validar assinatura, consultar a API do Mercado Pago pra obter os dados reais do pagamento. Processar com dados da API, não do corpo do webhook.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

**Por quê na BGR:** Mesmo com assinatura válida, webhook pode estar desatualizado (race condition). Consultar a API garante dados frescos e consistentes.

---

### ACP-067 — Idempotência em processamento de webhook [ERRO]

**Regra:** Webhook processado mais de uma vez produz o mesmo resultado. Usar `payment_id` como chave de idempotência. Se já processou, retornar 200 sem processar de novo.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

**Por quê na BGR:** Mercado Pago reenvia webhooks que recebem timeout ou erro. Sem idempotência, o mesmo pagamento é processado N vezes — crédito duplicado no ACP.

---

### ACP-068 — Rate limiting em endpoints sensíveis [AVISO]

**Regra:** Endpoints de auth (login, signup, reset password) e webhooks devem ter rate limiting. Implementar via middleware Next.js ou nginx upstream.

**Verifica:** Verificar que rotas protegidas passam por middleware de auth. Rota exposta é violação.

---

## 13. LGPD

### ACP-069 — solicitar_apagamento cobre todas as tabelas [ERRO]

**Regra:** Função `solicitar_apagamento(usuario_id)` deleta permanentemente todos os dados do usuário em todas as tabelas. Testado automaticamente (`pnpm lgpd:test-eliminacao`).

**Verifica:** Linter/formatter automático (Prettier/ESLint). Qualquer desvio é violação.

**Por quê na BGR:** LGPD Art. 18 — direito de eliminação. Hard-delete automático no dia 65 pós-trial. Se uma tabela é esquecida, é violação legal.

---

### ACP-070 — Exportação de dados pessoais funcional [ERRO]

**Regra:** `pnpm lgpd:export-dados <usuario_id>` exporta todos os dados pessoais como JSON legível. Cobre: perfil, contas, lançamentos, metas, dívidas, cartões, notificações, membros.

**Verifica:** Verificar consentimento antes de coleta de dados pessoais. Coleta sem consentimento é violação.

**Por quê na BGR:** LGPD Art. 18 — direito de portabilidade. Usuário tem direito de pedir seus dados em formato legível.

---

### ACP-071 — Consentimento explícito coletado e registrado [ERRO]

**Regra:** Signup coleta consentimento explícito (checkbox não pré-marcado) com timestamp e versão dos Termos/PP. Armazenado em tabela auditável.

**Verifica:** Linter/formatter automático (Prettier/ESLint). Qualquer desvio é violação.

---

### ACP-072 — Dados pessoais identificados no schema [AVISO]

**Regra:** Colunas que contêm dados pessoais devem ter comentário no schema Drizzle: `// LGPD: dado pessoal — coberto por solicitar_apagamento`.

**Verifica:** Verificar que alterações de schema têm migration correspondente. Schema sem migration é violação.

**Por quê na BGR:** Quando adicionar tabela nova, o comentário obriga o desenvolvedor a pensar se precisa incluir no `solicitar_apagamento`. Sem marcação, esquece.

---

# V — Banco de Dados (PostgreSQL 17 + Drizzle)

## 14. Schema e migrations

### ACP-073 — Schema Drizzle como fonte de verdade [ERRO]

**Regra:** Schema definido em TypeScript via Drizzle (`src/db/schema/`). Migrations geradas pelo Drizzle (`drizzle-kit generate`). Sem SQL manual de schema exceto pra features que Drizzle não suporta (RLS policies, pgcrypto functions, triggers).

**Verifica:** TSC strict mode + grep por `any` ou `as any`. Qualquer uso de `any` sem justificativa é violação.

---

### ACP-074 — Migrations idempotentes e reversíveis [ERRO]

**Regra:** Toda migration deve ser idempotente (rodar 2× produz mesmo resultado). Migrations destrutivas (DROP, ALTER TYPE com perda de dados) devem ter migration reversa documentada no PR.

**Verifica:** Verificar que alterações de schema têm migration correspondente. Schema sem migration é violação.

**Por quê na BGR:** Migration que falha no meio e não é idempotente deixa banco em estado inconsistente. Em produção, isso é downtime.

---

### ACP-075 — UUIDs como primary key [ERRO]

**Regra:** Toda tabela usa UUID v7 como PK (ordenável por tempo). Sem auto-increment. Gerado no código (`crypto.randomUUID()`), não no banco.

**Verifica:** Linter/formatter automático (Prettier/ESLint). Qualquer desvio é violação.

**Por quê na BGR:** Auto-increment é previsível (IDOR fácil), não funciona em sistemas distribuídos futuros, e vaza informação sobre volume. UUID elimina essas classes de problema.

---

### ACP-076 — Timestamps com timezone (TIMESTAMPTZ) [ERRO]

**Regra:** Toda coluna de data/hora usa `TIMESTAMPTZ`, nunca `TIMESTAMP`. Armazenado em UTC, convertido pra timezone do usuário na apresentação.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

**Por quê na BGR:** ACP é brasileiro mas UTC evita bugs de horário de verão (que voltou em 2025). `TIMESTAMP` sem timezone é ambíguo — depende da config do servidor.

---

### ACP-077 — Sem nullable sem justificativa [AVISO]

**Regra:** Colunas são `NOT NULL` por padrão. Nullable só com justificativa no schema (ex: `convite_aceito_em` é null até o convite ser aceito).

**Verifica:** Verificar que alterações de schema têm migration correspondente. Schema sem migration é violação.

**Por quê na BGR:** Nullable espalha `| null` por todo o código. Quanto menos nullables, menos null checks, menos bugs.

---

### ACP-078 — Índices em foreign keys e colunas de busca [ERRO]

**Regra:** Toda FK tem índice. Colunas usadas em WHERE frequente (status, tipo, data) têm índice. Index é barato na escrita e crítico na leitura.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

### ACP-079 — Constraints de negócio no banco [ERRO]

**Regra:** Regras de negócio que o banco pode enforçar devem estar como constraints: UNIQUE, CHECK, FK com ON DELETE. Código valida antes, banco garante depois.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

**Por quê na BGR:** Constraints são a última linha de defesa. Se o código tem bug e tenta inserir dado inválido, o banco rejeita. Em fintech, dado inválido no banco é irrecuperável.

**Exemplo correto:**
```sql
-- Máximo 1 conta pessoal + 1 negócio por usuário
CREATE UNIQUE INDEX idx_conta_unica_por_tipo
ON contas (dono_id, tipo);

-- Valor sempre positivo
ALTER TABLE lancamentos
ADD CONSTRAINT chk_valor_positivo CHECK (valor_centavos > 0);
```

---

### ACP-080 — Soft delete proibido para dados LGPD [ERRO]

**Regra:** Dados cobertos por LGPD (pessoais, financeiros) usam hard delete. Sem coluna `deletado_em`. `solicitar_apagamento` faz `DELETE FROM`, não `UPDATE SET deletado_em`.

**Verifica:** Verificar consentimento antes de coleta de dados pessoais. Coleta sem consentimento é violação.

**Por quê na BGR:** LGPD Art. 18 — direito de eliminação é eliminação real. Soft delete mantém o dado no banco — não é eliminação, é ocultação. Auditor/promotor que acha o dado "deletado" ainda no banco é problema jurídico.

---

## 15. Performance

### ACP-081 — Queries com LIMIT e paginação [ERRO]

**Regra:** Toda query que pode retornar muitos resultados deve ter LIMIT. Listas paginadas com cursor-based pagination (não offset).

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

**Por quê na BGR:** Query sem LIMIT em tabela com 100k lançamentos trava o servidor. Cursor-based é O(1) independente da página; offset-based é O(n).

---

### ACP-082 — Sem N+1 queries [ERRO]

**Regra:** Detectar e eliminar N+1. Se buscar 20 lançamentos e depois buscar a categoria de cada um individualmente, são 21 queries. Usar JOIN ou batch query.

**Verifica:** Verificar que queries são batched. N+1 em loop é violação.

---

### ACP-083 — Connection pooling obrigatório em produção [ERRO]

**Regra:** Produção usa connection pool (Drizzle + `postgres` driver com pool config). Sem conexão por request.

**Verifica:** Verificar que alterações de schema têm migration correspondente. Schema sem migration é violação.

---

# VI — Testes (Vitest + Playwright)

## 16. Cobertura e estratégia

### ACP-084 — Entidade de domínio tem 100% de cobertura [ERRO]

**Regra:** Toda entidade em `src/core/` tem test file correspondente. Cobertura de branches e statements: 100%. Sem exceção.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

**Por quê na BGR:** Entidades são o coração do negócio. Bug na entidade `Lancamento` significa cálculo financeiro errado. 100% de cobertura não é perfeccionismo — é obrigação em código que toca dinheiro.

---

### ACP-085 — Repository tem testes de integração [ERRO]

**Regra:** Todo Repository tem testes de integração contra banco real (Postgres em Docker via `docker-compose.test.yml`). Sem mocks de banco em teste de Repository.

**Verifica:** Grep por queries dentro de loops (`for`, `while`, `map` com await de DB). Qualquer ocorrência é violação.

**Por quê na BGR:** Lição do UniBGR — mock de banco deu verde mas a query real falhava em produção. Repository testa a query real contra o schema real.

---

### ACP-086 — Manager tem testes unitários com Repository mockado [ERRO]

**Regra:** Testes de Manager mocam Repositories. Testam lógica de orquestração isolada — sem banco.

**Verifica:** Grep por queries dentro de loops (`for`, `while`, `map` com await de DB). Qualquer ocorrência é violação.

---

### ACP-087 — Server Action tem teste de integração [ERRO]

**Regra:** Server Actions críticos (criar lançamento, processar pagamento, solicitar apagamento) têm testes de integração que exercitam o fluxo completo: input → validação → auth → manager → banco → output.

**Verifica:** Verificar existência de testes correspondentes. Código sem teste é violação.

---

### ACP-088 — Fluxos críticos têm teste E2E com Playwright [ERRO]

**Regra:** Fluxos que envolvem dinheiro ou auth têm teste E2E: signup, login, criar lançamento, processar pagamento, bloquear conta, solicitar apagamento.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

**Por quê na BGR:** E2E é o teste que mais se parece com o usuário real. Se o E2E passa, o fluxo funciona ponta a ponta.

---

### ACP-089 — Testes rodam em CI antes de merge [ERRO]

**Regra:** GitHub Actions roda `pnpm lint && pnpm typecheck && pnpm test` em todo PR. PR com teste falhando não mergea.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

### ACP-090 — Teste de hidratação prova nome real de coluna [ERRO]

**Regra:** Todo `fromPersistence` tem teste que cria row com nomes reais de coluna do schema e verifica que a entidade hidrata corretamente. Nome do campo no teste deve bater com o nome no banco.

**Verifica:** Verificar que alterações de schema têm migration correspondente. Schema sem migration é violação.

**Por quê na BGR:** TST-033 do Engrama (adicionada após incidente 0008 — `score_100` vs `score100` no UniBGR). Teste que usa nome errado de coluna passa por coincidência e esconde bug real.

**Exemplo correto:**
```typescript
describe('Lancamento.fromPersistence', () => {
  it('hidrata corretamente de row do banco', () => {
    const row = {
      id: 'uuid-1',
      conta_id: 'uuid-2',          // nome real da coluna
      valor_centavos: 15990,        // nome real da coluna
      status: 'pendente',
      tipo: 'saida',
      descricao: 'Mercado',
      categoria_id: 'uuid-3',
      data: '2026-04-12',
      criado_em: '2026-04-12T10:00:00Z',
      atualizado_em: '2026-04-12T10:00:00Z',
    }

    const lancamento = Lancamento.fromPersistence(row)

    expect(lancamento.id).toBe('uuid-1')
    expect(lancamento.valorCentavos).toBe(15990)
    expect(lancamento.status).toBe('pendente')
  })
})
```

---

### ACP-091 — Testes de FSM cobrem todas as transições [ERRO]

**Regra:** Toda entidade com FSM tem testes que verificam: (1) cada transição válida funciona, (2) cada transição inválida lança erro, (3) `podeTransicionarPara` retorna correto.

**Verifica:** Verificar que entidades têm lógica de domínio (predicados, FSM, validações). Getters/setters puros é violação.

---

### ACP-092 — Fixtures/factories para dados de teste [AVISO]

**Regra:** Usar factory functions pra criar dados de teste. Sem copiar objetos entre testes. Factory recebe overrides pra customizar.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

**Exemplo correto:**
```typescript
function criarLancamentoFixture(overrides?: Partial<DadosCriarLancamento>): Lancamento {
  return Lancamento.criar({
    contaId: 'uuid-conta' as ContaId,
    valorCentavos: 5000,
    tipo: 'saida',
    descricao: 'Teste',
    categoriaId: 'uuid-cat' as CategoriaId,
    data: new Date(),
    ...overrides,
  })
}
```

---

### ACP-093 — Teste é documentação — nomes descritivos em português [AVISO]

**Regra:** Nome do teste descreve o comportamento esperado em português: `'rejeita lançamento com valor negativo'`, `'efetiva lançamento pendente'`, `'não permite cancelar lançamento já cancelado'`.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

### ACP-094 — Sem dependência entre testes [ERRO]

**Regra:** Cada teste roda isolado. Sem estado compartilhado entre testes. Banco limpo entre testes de integração (`beforeEach` com truncate ou transaction rollback).

**Verifica:** Verificar existência de testes correspondentes. Código sem teste é violação.

---

### ACP-095 — Testes de regressão para bugs corrigidos [ERRO]

**Regra:** Todo bug corrigido ganha teste de regressão que reproduz o cenário original. Comentário no teste referencia o PR ou issue que corrigiu.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

# VII — Frontend (Tailwind v4 + shadcn/ui)

## 17. Design system

### ACP-096 — Cores como CSS custom properties (design tokens) [ERRO]

**Regra:** Cores definidas como tokens no `globals.css` via variáveis CSS. Componentes usam classes semânticas (`bg-primary`, `text-muted-foreground`), nunca cores hardcoded (`bg-blue-500`).

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

**Por quê na BGR:** shadcn/ui usa design tokens por padrão. Cor hardcoded não muda com tema, não respeita modo escuro, e cria inconsistência visual.

**Exemplo correto:**
```css
/* globals.css */
:root {
  --primary: 142 72% 29%;          /* verde ACP */
  --primary-foreground: 0 0% 100%;
  --destructive: 0 84% 60%;
  --muted-foreground: 240 5% 65%;
}
```

```typescript
<Button className="bg-primary text-primary-foreground">Salvar</Button>
```

**Exemplo incorreto:**
```typescript
<Button className="bg-green-600 text-white">Salvar</Button>
```

---

### ACP-097 — Tipografia mínima 16px mobile / 14px desktop [ERRO]

**Regra:** Texto de leitura: mínimo 16px em mobile, 14px em desktop. Headers proporcionalmente maiores. Sem fonte 11px.

**Verifica:** Verificar que layouts usam breakpoints responsivos. Layout fixo em px é violação.

**Por quê na BGR:** Princípio de UX: "Tipografia grande e legível" (CLAUDE.md seção 1.5). Público-alvo usa dispositivos com telas menores.

---

### ACP-098 — Espaçamento generoso (whitespace é feature) [AVISO]

**Regra:** Padding e margin generosos. Mínimo `p-4` em cards, `gap-4` em layouts. Sem elementos comprimidos.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

### ACP-099 — Contraste WCAG AA: 4.5:1 texto, 3:1 gráficos [ERRO]

**Regra:** Verificar contraste em toda combinação cor/fundo. shadcn/ui atende por padrão — não customizar cores sem verificar contraste.

**Verifica:** Verificar uso de componentes shadcn/ui existentes antes de criar custom. Reinvenção é violação.

---

### ACP-100 — No máximo 3-5 elementos visuais primários por tela [AVISO]

**Regra:** Hierarquia visual clara: 1 dominante + 2-4 secundários + zero ruído. Sem dashboards com 12 widgets.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

**Por quê na BGR:** "Didático e fácil de usar, sem muita informação na tela." (Joc, CLAUDE.md seção 1.5).

---

## 18. Mobile-first

### ACP-101 — Design mobile-first, adapt pra desktop [ERRO]

**Regra:** Todo componente desenhado primeiro pro mobile (default), depois adaptado com breakpoints Tailwind (`md:`, `lg:`).

**Verifica:** Verificar que layouts usam breakpoints responsivos. Layout fixo em px é violação.

**Por quê na BGR:** Público classe C/D usa mobile como dispositivo principal. Desktop é bônus.

**Exemplo correto:**
```typescript
<div className="p-4 md:p-8 lg:p-12">           {/* mobile primeiro */}
  <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
```

**Exemplo incorreto:**
```typescript
<div className="p-12 sm:p-4">                    {/* desktop primeiro */}
```

---

### ACP-102 — Touch targets ≥ 44×44px [ERRO]

**Regra:** Botões e áreas clicáveis mínimo 44×44px. Tailwind: `min-h-11 min-w-11` (44px = 2.75rem).

**Verifica:** Grep por `style=` inline. CSS inline sem justificativa é violação.

---

### ACP-103 — Sem hover-only [ERRO]

**Regra:** Toda interação acessível por toque. Hover mostra tooltip/hint, nunca é a única forma de acesso.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

### ACP-104 — Navegação primária via bottom nav (4-5 itens) [AVISO]

**Regra:** Mobile: bottom navigation com 4-5 itens max. Sem sidebar que exige hamburger menu.

**Verifica:** Verificar que layouts usam breakpoints responsivos. Layout fixo em px é violação.

---

### ACP-105 — Viewport mobile sem scroll horizontal [ERRO]

**Regra:** Toda página cabe em 1 viewport mobile (320px mínimo) sem scroll horizontal. Tabelas usam scroll horizontal interno ou layout responsivo.

**Verifica:** Linter/formatter automático (Prettier/ESLint). Qualquer desvio é violação.

---

## 19. Componentes shadcn/ui

### ACP-106 — Usar shadcn/ui components quando disponível [AVISO]

**Regra:** Antes de criar componente custom, verificar se shadcn/ui tem equivalente. Button, Dialog, Select, Input, Card, etc. — usar o que existe.

**Verifica:** Verificar uso de componentes shadcn/ui existentes antes de criar custom. Reinvenção é violação.

**Por quê na BGR:** shadcn/ui já é WCAG AA, keyboard navigable, e com API consistente. Componente custom é retrabalho (Art. 15).

---

### ACP-107 — Ícones exclusivamente Lucide [AVISO]

**Regra:** Todos os ícones via Lucide React. Sem Font Awesome, sem SVG inline, sem outra lib.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

### ACP-108 — Animações com Framer Motion, sutis e rápidas [AVISO]

**Regra:** Micro-animations via Framer Motion. Duração máxima 300ms pra transições de UI. Sem animação que bloqueia interação.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

## 20. Copy e linguagem

### ACP-109 — Linguagem coloquial brasileira, não bancarês [ERRO]

**Regra:** Copy do app usa português coloquial brasileiro. "Saída de dinheiro" em vez de "lançamento de débito". "Quanto você tem agora" em vez de "saldo conciliado". "No que você gastou" em vez de "categoria de despesa".

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

**Por quê na BGR:** Princípio de UX: "Linguagem coloquial brasileira, NÃO bancarês" (CLAUDE.md seção 1.5). Público-alvo não é bancário.

---

### ACP-110 — Tom aspiracional, nunca moralizante [ERRO]

**Regra:** Copy não culpa o usuário. "Esse mês ficou um pouco mais alto, vamos olhar juntas?" em vez de "Você gastou demais!". Persona feminina 30+ — tom acolhedor.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

### ACP-111 — Mensagens de erro sem culpa e sem tech [AVISO]

**Regra:** Erro nunca mostra stack trace, código HTTP ou jargão técnico. "Algo deu errado, tente de novo" com botão de retry. Log técnico vai pro Sentry, não pra tela.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

# VIII — Qualidade de código (Biome + Convenções)

## 21. Lint e formatação

### ACP-112 — Biome como único linter e formatter [ERRO]

**Regra:** Biome configura lint + format + import sort. Sem ESLint, sem Prettier, sem configuração paralela. `pnpm lint` usa Biome.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

**Por quê na BGR:** Decisão de stack. Biome é ~100× mais rápido que ESLint+Prettier e cobre os mesmos casos.

---

### ACP-113 — Zero warnings no CI [ERRO]

**Regra:** CI roda `pnpm lint` e `pnpm typecheck`. Zero warnings, zero errors. Warning ignorado hoje é bug amanhã.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

### ACP-114 — Imports organizados automaticamente [AVISO]

**Regra:** Biome organiza imports (built-in → external → internal → relative). Nunca reorganizar manualmente.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

## 22. Nomenclatura

### ACP-115 — Nomes em português para domínio [ERRO]

**Regra:** Entidades, variáveis de domínio, tabelas, rotas, nomes de arquivo de domínio — tudo em português. Termos técnicos (React hooks, TS types, generics) em inglês.

**Verifica:** Linter/formatter automático (Prettier/ESLint). Qualquer desvio é violação.

**Por quê na BGR:** Convenção do CLAUDE.md do projeto (seção 6). Código de negócio legível como texto em português. `lancamento.efetivar()` é mais claro que `transaction.confirm()` pro contexto brasileiro.

**Exemplo correto:**
```typescript
// Domínio em português
class Lancamento { ... }
class ContaBancaria { ... }
const categoriaId: CategoriaId = ...

// Técnico em inglês
interface CartaoSaldoProps { ... }
const [filtro, setFiltro] = useState<string>('mes')
```

---

### ACP-116 — Arquivos em kebab-case [ERRO]

**Regra:** Nomes de arquivo em kebab-case: `lancamento-repository.ts`, `cartao-saldo.tsx`, `criar-lancamento.ts`.

**Verifica:** Grep por queries dentro de loops (`for`, `while`, `map` com await de DB). Qualquer ocorrência é violação.

---

### ACP-117 — Classes em PascalCase, funções/variáveis em camelCase [ERRO]

**Regra:** Classes: `LancamentoRepository`, `ContaBancaria`. Funções: `criarLancamento`, `formatarReais`. Variáveis: `valorCentavos`, `contaId`. Constantes: `STATUS_TRANSITIONS`, `TIPOS_PERMITIDOS`.

**Verifica:** Grep por queries dentro de loops (`for`, `while`, `map` com await de DB). Qualquer ocorrência é violação.

---

### ACP-118 — Sem abreviações não óbvias [AVISO]

**Regra:** `lancamento` sim, `lanc` não. `categoria` sim, `cat` não. `descricao` sim, `desc` não (conflita com `desc` do SQL). Abreviações aceitas: `id`, `db`, `ctx`, `req`, `res`, `err`, `env`.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

## 23. Estrutura de código

### ACP-119 — Separação de responsabilidades por camada [ERRO]

**Regra:** Camadas respeitam fronteiras:
- `src/core/` — entidades de domínio (classes ricas)
- `src/repositories/` — acesso a dados (encapsula Drizzle)
- `src/managers/` — lógica de negócio cross-entidade
- `src/server/actions/` — entry points (Server Actions)
- `src/app/api/` — webhooks e APIs externas
- `src/lib/` — helpers, validators, formatters
- `src/components/` — React components (apresentação)

**Verifica:** Inspecionar que cada camada só acessa suas dependências diretas. Bypass de camada é violação.

Camada superior chama inferior, nunca o contrário. Component não importa Repository. Server Action não importa Drizzle.

---

### ACP-120 — 1 entidade por arquivo, 1 repository por arquivo [ERRO]

**Regra:** Cada entidade de domínio tem seu próprio arquivo. Cada repository tem seu próprio arquivo. Sem "utils.ts" com 20 funções misturadas.

**Verifica:** Grep por queries dentro de loops (`for`, `while`, `map` com await de DB). Qualquer ocorrência é violação.

---

### ACP-121 — Sem barrel exports (index.ts re-exporting) [AVISO]

**Regra:** Sem `index.ts` que re-exporta tudo de uma pasta. Import direto do arquivo: `import { Lancamento } from '@/core/lancamento'`, não `from '@/core'`.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

**Por quê na BGR:** Barrel exports causam bundling desnecessário (tree-shaking falha em muitos casos) e imports circulares invisíveis.

---

### ACP-122 — Funções puras quando possível [AVISO]

**Regra:** Helpers e formatters são funções puras (sem side effects, sem estado). Dado entrada X, sempre retorna Y. Facilita teste e composição.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

### ACP-123 — Tratamento de erro com tipos específicos [ERRO]

**Regra:** Erros de domínio usam classes específicas: `ErroValidacao`, `ErroNaoEncontrado`, `ErroNaoAutenticado`, `ErroNegocio`, `ErroTransicao`. Sem `throw new Error('genérico')`.

**Verifica:** Verificar que erros são capturados com tipo específico e contexto. Catch genérico é violação.

**Por quê na BGR:** Erro específico permite tratamento específico. Server Action captura `ErroValidacao` e retorna 422; `ErroNaoAutenticado` e retorna 401. `Error` genérico vira 500 — ilegível pro usuário.

**Exemplo correto:**
```typescript
export class ErroValidacao extends Error {
  readonly codigo = 'VALIDACAO' as const
  constructor(mensagem: string, readonly campo?: string) {
    super(mensagem)
  }
}

export class ErroNaoEncontrado extends Error {
  readonly codigo = 'NAO_ENCONTRADO' as const
}

export class ErroNegocio extends Error {
  readonly codigo = 'NEGOCIO' as const
}

export class ErroTransicao extends Error {
  readonly codigo = 'TRANSICAO' as const
}
```

---

### ACP-124 — Async/await, sem .then() chains [ERRO]

**Regra:** Código assíncrono usa `async/await`. Sem `.then().catch()` chains. Exceção: streams e APIs que exigem callback.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

### ACP-125 — Try/catch apenas na fronteira [AVISO]

**Regra:** Try/catch no Server Action e Route Handler (fronteira). Camadas internas lançam erros — a fronteira decide o que fazer (logar, retornar resposta amigável).

**Verifica:** Inspecionar que cada camada só acessa suas dependências diretas. Bypass de camada é violação.

---

# IX — Observabilidade (Pino + Sentry)

## 24. Logging

### ACP-126 — Pino como único logger [ERRO]

**Regra:** Todo log via Pino. Sem `console.log` em código de produção (Biome deve reportar como erro). `console.log` permitido apenas em scripts de desenvolvimento.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

### ACP-127 — Logs estruturados (JSON) [ERRO]

**Regra:** Pino emite JSON estruturado com campos padronizados: `level`, `time`, `msg`, `acao`, `usuarioId` (quando disponível), `contaId` (quando disponível), `erro` (quando aplicável).

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

**Exemplo correto:**
```typescript
logger.info({ acao: 'lancamento_criado', contaId, lancamentoId }, 'Lançamento criado com sucesso')
logger.error({ acao: 'lancamento_falhou', contaId, erro: err.message }, 'Falha ao criar lançamento')
```

**Exemplo incorreto:**
```typescript
console.log('Lançamento criado: ' + lancamentoId) // sem estrutura, sem contexto
```

---

### ACP-128 — Redact de dados sensíveis obrigatório [ERRO]

**Regra:** Pino configurado com `redact` pra nunca logar: CPF, senha, token, cookie, authorization, valores financeiros descriptografados, descrições descriptografadas, números de conta.

**Verifica:** Verificar que dados sensíveis usam criptografia antes de persistir. Texto puro é violação.

---

### ACP-129 — Nível de log por ambiente [AVISO]

**Regra:** Dev: `debug`. Staging: `info`. Prod: `warn` (ou `info` com redact rigoroso).

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

## 25. Monitoramento de erros

### ACP-130 — Sentry em toda rota e Server Action [ERRO]

**Regra:** Sentry captura erros não tratados em todas as camadas. `beforeSend` scruba dados sensíveis antes de enviar.

**Verifica:** Inspecionar que cada camada só acessa suas dependências diretas. Bypass de camada é violação.

---

### ACP-131 — Sentry com source maps em produção [AVISO]

**Regra:** Build de produção envia source maps pro Sentry (não pro cliente). Erros no Sentry mostram código TS original, não JS minificado.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

### ACP-132 — Performance monitoring nos fluxos críticos [AVISO]

**Regra:** Sentry performance tracing em: criar lançamento, processar pagamento, carregar painel. Alerta se latência exceder thresholds.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

# X — Infraestrutura e Deploy

## 26. Docker e ambientes

### ACP-133 — docker-compose.dev.yml para desenvolvimento [ERRO]

**Regra:** Dev usa `docker-compose.dev.yml` com Postgres 17 local. Sem depender de banco externo em dev.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

### ACP-134 — Prod em ~/prod/acertandoospontos/ isolado [ERRO]

**Regra:** Produção em `~/prod/acertandoospontos/docker-compose.yml`, conectado à rede `bgr_proxy`. Nunca compartilhar volume, banco ou config com dev.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

### ACP-135 — Multi-stage build pra imagem de produção [AVISO]

**Regra:** Dockerfile com multi-stage: (1) deps, (2) build, (3) runner (só runtime). Imagem final sem devDependencies, sem source maps no client.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

### ACP-136 — Health check no container [ERRO]

**Regra:** Container de produção tem health check endpoint (`/api/health`) que verifica: app rodando, conexão com banco OK. Docker HEALTHCHECK configurado.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

## 27. CI/CD

### ACP-137 — GitHub Actions roda lint + typecheck + test em todo PR [ERRO]

**Regra:** Workflow CI roda `pnpm lint && pnpm typecheck && pnpm test` em todo PR pra staging. Falha bloqueia merge.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

### ACP-138 — Build de produção testado no CI [ERRO]

**Regra:** CI roda `pnpm build` pra garantir que o build de produção funciona. Erro de build no CI é erro antes de chegar em prod.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

### ACP-139 — Secrets do CI em GitHub Secrets, não no código [ERRO]

**Regra:** Toda chave de API, token e segredo do CI está em GitHub Secrets. Referenciados como `${{ secrets.NOME }}` no workflow.

**Verifica:** Grep por strings hardcoded (passwords, tokens, keys). Qualquer segredo no código é violação.

---

### ACP-140 — Deploy manual com aprovação do Joc [ERRO]

**Regra:** Deploy em produção é manual — Joc aprova antes. Sem auto-deploy em push pra main. CI prepara, humano deploya.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

**Por quê na BGR:** Time de 2 pessoas. Deploy automático sem rollback automatizado é risco. Joc decide quando o código vai pro ar.

---

## 28. Git e branches

### ACP-141 — Branch model: main (prod) + staging + feature branches [ERRO]

**Regra:** `main` é produção. `staging` é pré-produção. Feature branches saem de `staging` e voltam via PR. Nunca push direto em `main` ou `staging`.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

### ACP-142 — Commits semânticos em português [ERRO]

**Regra:** Formato: `tipo: descrição curta em português`. Tipos: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`. Sem emoji, sem scope, sem body obrigatório.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

**Exemplo correto:**
```
feat: entidade Lancamento com FSM e lifecycle methods
fix: validação Zod aceita valor negativo no campo centavos
test: cobertura completa do LancamentoRepository
refactor: extrair factory de contexto do Server Action
```

---

### ACP-143 — PR pra staging com resumo, commits e resultado de auditoria [ERRO]

**Regra:** Corpo do PR contém: resumo das mudanças, lista de commits, resultado da auditoria (ERROs corrigidos, AVISOs justificados).

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

### ACP-144 — Squash merge em staging [AVISO]

**Regra:** PRs mergeados com squash em staging (1 commit por feature). Main recebe merge commit de staging (preserva histórico de features).

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

### ACP-145 — Nunca force push sem verificar remote [ERRO]

**Regra:** Force push exige `git log --oneline origin/{branch} -5` antes. Incidente 0001 da BGR: force push acidental apagou estrutura inteira.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

# XI — Performance e UX

## 29. Performance percebida

### ACP-146 — First Contentful Paint < 1.5s em 4G [ERRO]

**Regra:** Landing page e páginas principais carregam FCP < 1.5s em conexão 4G média. Medir com Lighthouse.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

### ACP-147 — Time to Interactive < 3s em 4G [ERRO]

**Regra:** Página interativa em < 3s na mesma condição.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

### ACP-148 — Optimistic UI em ações comuns [AVISO]

**Regra:** Criar lançamento atualiza tela imediatamente, confirma com servidor depois. TanStack Query `optimisticUpdate` pra mutations.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

### ACP-149 — Bundle size monitorado [AVISO]

**Regra:** `pnpm build` reporta tamanho dos bundles. Alerta se bundle JS do client exceder 200KB gzipped.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

### ACP-150 — Imagens otimizadas com next/image [ERRO]

**Regra:** Toda imagem renderizada usa `<Image>` do Next.js (lazy loading, formato otimizado, responsive sizes). Sem `<img>` direto.

**Verifica:** Verificar presença de loading.tsx ou Suspense boundary. Rota sem loading state é violação.

---

## 30. Lançamento rápido (mantra do produto)

### ACP-151 — Lançamento de entrada/saída em ≤4 segundos [ERRO]

**Regra:** Do app aberto até salvo em ≤4 segundos: tap FAB → modal → preencher valor → salvar. UX otimizada pra velocidade.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

**Por quê na BGR:** Mantra: "O usuário faz uma coisa: registra entrada ou saída. Tudo o mais é nosso." Se registrar gasto leva mais de 4 segundos, o usuário desiste e volta pro caderno.

---

### ACP-152 — Categoria sugerida automaticamente [AVISO]

**Regra:** Campo de categoria pré-preenchido com sugestão baseada na última escolha do usuário ou padrão de gastos.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

### ACP-153 — Data padrão = hoje [ERRO]

**Regra:** Campo de data pré-preenchido com hoje. Usuário só muda se for outra data.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

### ACP-154 — Cálculos no backend, sempre [ERRO]

**Regra:** Saldo, totais, médias, relatórios — calculados no servidor. Cliente nunca recalcula. Client renderiza resultado pronto.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

### ACP-155 — Categorias pré-seedadas no signup [AVISO]

**Regra:** 15+ categorias por tipo de conta (pessoal e negócios) criadas automaticamente no signup. Sem onboarding de "configure suas categorias primeiro".

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

# XII — Mercado Pago (Pagamentos)

## 31. Integração

### ACP-156 — SDK oficial do Mercado Pago [ERRO]

**Regra:** Usar SDK oficial Node.js do Mercado Pago. Sem chamadas HTTP diretas à API.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

### ACP-157 — Subscription API para recorrência mensal [ERRO]

**Regra:** Planos Juntas e De Mãos Dadas usam Subscription API do MP pra cobrança automática mensal. Sem cron manual cobrando todo mês.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

### ACP-158 — Access token exclusivamente em variável de ambiente [ERRO]

**Regra:** `MERCADO_PAGO_ACCESS_TOKEN` em `.env`. Nunca hardcoded.

**Verifica:** Grep por strings hardcoded (passwords, tokens, keys). Qualquer segredo no código é violação.

---

### ACP-159 — Ambiente sandbox pra testes [ERRO]

**Regra:** Dev e CI usam credentials de sandbox do Mercado Pago. Produção usa credentials reais. Sem misturar.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

### ACP-160 — Processar pagamento com dados da API, não do webhook [ERRO]

**Regra:** Vide ACP-066. Webhook notifica, API confirma. Processar com dados da API.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

## 32. Trial e bloqueio

### ACP-161 — Trial de 35 dias, bloqueio no dia 35 [ERRO]

**Regra:** Conta nova tem 35 dias de trial. No dia 35: modal de bloqueio (LGPD: "Assine ou delete seus dados em 30 dias"). Nenhuma funcionalidade acessível após bloqueio.

**Verifica:** Verificar consentimento antes de coleta de dados pessoais. Coleta sem consentimento é violação.

---

### ACP-162 — Hard-delete automático no dia 65 [ERRO]

**Regra:** `solicitar_apagamento(usuario_id)` roda automaticamente 30 dias após bloqueio (dia 65). Email de confirmação enviado. Via `pg_cron`.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

### ACP-163 — Relatório de fim de trial (conversão) [AVISO]

**Regra:** Dia 35: relatório automático mostrando conquistas do período (X lançamentos, Y economizado, 3 maiores gastos). Feature de conversão.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

# XIII — Email (Resend + React Email)

## 33. Transacionais

### ACP-164 — Templates type-safe com React Email [ERRO]

**Regra:** Templates de email em React Email (TSX). Tipados, versionados no repo, renderizados no server.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

### ACP-165 — Nunca pedir senha em email [ERRO]

**Regra:** ACP é passwordless (email OTP + Google OAuth via Better Auth). Todo email transacional tem rodapé: "Nunca pedimos sua senha — porque você não tem uma."

**Verifica:** Verificar que operações multi-tabela usam transaction. Operação sem transação é violação.

---

### ACP-166 — Resend com domínio verificado [ERRO]

**Regra:** Emails enviados de `@acertandoospontos.com.br` com domínio verificado no Resend (SPF/DKIM/DMARC). Sem `@gmail.com` ou domínio genérico.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

# XIV — Convenções gerais

## 34. Documentação

### ACP-167 — CLAUDE.md do projeto é fonte de verdade [ERRO]

**Regra:** Decisões de arquitetura, stack, convenções — estão no CLAUDE.md do projeto. Atualizar quando decisões mudam. CLAUDE.md desatualizado é documentação mentirosa.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

### ACP-168 — Código auto-documentado, comentários só quando não óbvio [AVISO]

**Regra:** Nomes descritivos eliminam necessidade de comentário. Comentário só pra "por quê", nunca pra "o quê". `// Mercado Pago exige valor em string com 2 decimais` sim. `// converte pra string` não.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

### ACP-169 — TODO com referência a issue ou PR [AVISO]

**Regra:** `// TODO(ACP-42): implementar cache de categorias` com referência. Sem `// TODO: fix later` genérico. TODO sem referência vira dívida invisível.

**Verifica:** Verificar estratégia de cache/revalidação. Fetch sem cache strategy é violação.

---

## 35. Segurança de confiança (reforço UX)

### ACP-170 — Mensagens de segurança nos pontos de contato [AVISO]

**Regra:** Reforçar criptografia e segurança em: landing page, signup, cadastro de conta bancária, modal de lançamento, configurações, relatório de trial, modal de bloqueio, rodapé de email.

**Verifica:** Verificar que dados sensíveis usam criptografia antes de persistir. Texto puro é violação.

**Por quê na BGR:** Público classe C/D sofre mais com golpes financeiros. Reforçar segurança é obrigação de UX, não diferencial.

---

### ACP-171 — Nunca mentir sobre segurança [ERRO]

**Regra:** Se a copy diz "criptografado com tecnologia de banco", precisa ser verdade (pgcrypto AES-256 é). Se diz "nem a gente consegue ver", precisa ser verdade (chave fora do banco, acesso restrito). Reforço que se revela falso é pior que não reforçar.

**Verifica:** Verificar que dados sensíveis usam criptografia antes de persistir. Texto puro é violação.

---

## 36. Princípios fundamentais

### ACP-172 — KISS: simplicidade primeiro [AVISO]

**Regra:** Código o mais simples possível. Abstrações e patterns só quando o problema exige. 3 linhas repetidas é melhor que abstração prematura.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

### ACP-173 — DRY: uma regra, um lugar [ERRO]

**Regra:** Lógica implementada em único ponto. Mesmo cálculo em 2 arquivos → extrair pra módulo compartilhado.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

### ACP-174 — YAGNI: não construa o que não precisa agora [AVISO]

**Regra:** Implementar estritamente o que o requisito atual exige. Sem "e se um dia precisar...".

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

### ACP-175 — Separação de responsabilidades [ERRO]

**Regra:** Cada módulo tem escopo claro. Vide ACP-119. Arquivo que mistura domain + persistence + UI está errado.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

### ACP-176 — Lei de Demeter [AVISO]

**Regra:** Não encadear chamadas que atravessam múltiplos objetos. Acessar apenas propriedades do objeto imediato.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

### ACP-177 — Fail fast [ERRO]

**Regra:** Validação na entrada, erro imediato. Sem propagar dado inválido pra camadas internas descobrirem tarde.

**Verifica:** Inspecionar que cada camada só acessa suas dependências diretas. Bypass de camada é violação.

---

### ACP-178 — Sem side effects em funções puras [AVISO]

**Regra:** Funções em `src/lib/` são puras. Side effects (banco, HTTP, filesystem) só em repositories, managers e actions.

**Verifica:** Grep por queries dentro de loops (`for`, `while`, `map` com await de DB). Qualquer ocorrência é violação.

---

### ACP-179 — Sem código morto [AVISO]

**Regra:** Código comentado, funções não usadas, imports não usados — deletar. Git é backup, não o código comentado.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

### ACP-180 — Sem console.log em produção [ERRO]

**Regra:** `console.log`, `console.warn`, `console.error` proibidos no código de produção. Usar Pino (ACP-126). Biome deve reportar como erro.

**Verifica:** Verificar que erros críticos são logados com contexto. Erro silencioso é violação.

---

## 37. Internacionalização futura

### ACP-181 — Strings de UI em português, centralizáveis [AVISO]

**Regra:** Strings de UI em português direto no componente (MVP). Mas sem concatenação de strings dinâmicas que impossibilitaria i18n futura.

**Verifica:** Verificar presença de atributos ARIA e labels em elementos interativos. Ausência é violação.

---

## 38. Resiliência

### ACP-182 — Retry com backoff em chamadas externas [AVISO]

**Regra:** Chamadas ao Mercado Pago e Resend têm retry com exponential backoff (máximo 3 tentativas). Sem retry infinito.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

### ACP-183 — Timeout em toda chamada externa [ERRO]

**Regra:** Toda chamada HTTP externa (MP, Resend, etc.) tem timeout explícito (máximo 10s). Sem esperar eternamente.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

### ACP-184 — Graceful degradation quando serviço externo falha [AVISO]

**Regra:** Se Mercado Pago está fora: mostrar mensagem amigável ("Pagamentos indisponíveis no momento"). Se Resend falha: enfileirar email pra retry. App não crasha por causa de serviço externo.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

## 39. Dinheiro e aritmética

### ACP-185 — Sem ponto flutuante para dinheiro (reforço) [ERRO]

**Regra:** Reforço do ACP-006. Toda aritmética financeira em inteiro (centavos). Divisão que gera decimal: `Math.round()` explícito com regra de negócio documentada.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

### ACP-186 — Formatação BRL com Intl.NumberFormat [AVISO]

**Regra:** Formatar pra exibição com `Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' })` ou `.toLocaleString` equivalente. Sem formatação manual com regex.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

### ACP-187 — Saldo calculado no banco, não no app [ERRO]

**Regra:** Saldo de conta é coluna no banco, atualizada atomicamente via transação junto com lançamento (ACP-040). Não somar lançamentos no app pra calcular saldo.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

**Por quê na BGR:** Somar 50k lançamentos pra cada page load é O(n) crescente. Coluna de saldo atualizada atomicamente é O(1) e consistente.

---

### ACP-188 — Limite de valor por lançamento [ERRO]

**Regra:** Valor máximo por lançamento: 99.999.999 centavos (R$ 999.999,99). Validado no Zod (ACP-046) e constraint no banco (ACP-079).

**Verifica:** Verificar schema Zod em inputs de API/forms. Input sem validação é violação.

---

## 40. Relatórios

### ACP-189 — Relatório mensal gerado no backend [ERRO]

**Regra:** Relatório mensal personalizado (tier De Mãos Dadas) gerado no servidor via Manager, não no client. Dados sensíveis nunca trafegam pro client pra renderizar relatório.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

### ACP-190 — Relatório de fim de trial é feature de conversão [AVISO]

**Regra:** Relatório do dia 35 destaca conquistas ("Em 35 dias você registrou X lançamentos, economizou Y"). Tom aspiracional, não factual frio.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

## 41. Notificações

### ACP-191 — Notificações via pg_cron, não cron externo [AVISO]

**Regra:** Lembretes de fatura, vencimento de trial, relatório mensal — agendados via `pg_cron` no PostgreSQL. Sem cron do sistema operacional.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

**Por quê na BGR:** `pg_cron` é transacional com o banco. Se a notificação precisa consultar dados, roda dentro do mesmo contexto. Cron externo precisa de conexão, auth, e é outra coisa pra monitorar.

---

### ACP-192 — Notificação nunca contém dado financeiro no título [ERRO]

**Regra:** Push notification ou email: "Sua fatura vence amanhã" sim. "Sua fatura de R$ 1.234,56 vence amanhã" não. Valor financeiro fica dentro do app, atrás de auth.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

## 42. Dados de teste e seed

### ACP-193 — Seed com dados realistas [AVISO]

**Regra:** `pnpm db:seed` popula banco de dev com dados realistas: 3 usuários (1 trial, 1 Juntas, 1 De Mãos Dadas), contas pessoal e negócio, 100+ lançamentos distribuídos em 3 meses, categorias, metas, dívidas.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

### ACP-194 — Seed nunca roda em produção [ERRO]

**Regra:** Script de seed verifica `NODE_ENV !== 'production'` antes de executar. Abort imediato se estiver em prod.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

## 43. Erros de domínio específicos (complemento do ACP-123)

### ACP-195 — ErroLGPD para violações de privacidade [ERRO]

**Regra:** Ações que violam LGPD (tentar acessar dado de usuário que solicitou apagamento, tentar exportar sem consentimento) lançam `ErroLGPD` específico.

**Verifica:** Verificar consentimento antes de coleta de dados pessoais. Coleta sem consentimento é violação.

---

### ACP-196 — ErroPagamento para falhas de gateway [ERRO]

**Regra:** Falhas do Mercado Pago lançam `ErroPagamento` com código da API e mensagem amigável. Fronteira converte pra mensagem de UX sem expor código técnico.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

## 44. Onboarding

### ACP-197 — Signup sem wizard de 8 passos [ERRO]

**Regra:** Signup é: email → verificação → nome → pronto. Sem wizard longo. Dados adicionais (conta bancária, saldo, categorias) coletados progressivamente durante uso.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

**Por quê na BGR:** Princípio de UX: "Aprendizado distribuído ao longo do uso, não bloqueio inicial" (CLAUDE.md seção 1.5).

---

### ACP-198 — Conta pessoal criada automaticamente no signup [ERRO]

**Regra:** Após signup, sistema cria automaticamente 1 Conta Pessoal com categorias pré-seedadas. Usuário entra no app com tudo pronto pra usar.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

## 45. Telemetria BGR

### ACP-199 — Registrar telemetria ao concluir tarefa [ERRO]

**Regra:** Toda ação substancial registra telemetria via `bgr-log.sh`. Skill sem telemetria está incompleta.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

```bash
bash /home/reliable/bgr-sh-reliable/infra/scripts/bgr-log.sh gerente-acp acertandoospontos CONCLUIDO {duração} "{descrição}"
```

---

### ACP-200 — Erro identificado aciona protocolo de aprendizado [ERRO]

**Regra:** Bug, violação de regra, incidente — acionar `/aprendizado-ativo` imediatamente. Sem esperar o Joc perguntar. Engrama Art. 30.

**Verifica:** Code review: verificar aderência à regra no diff. Desvio requer justificativa.

---

# Definition of Done — Checklist de entrega

> PR que não cumpre o DoD não entra em review. É devolvido.

| # | Item | Regras | Verificação |
|---|------|--------|-------------|
| 1 | `pnpm lint` sem warnings | ACP-112, ACP-113 | CI green |
| 2 | `pnpm typecheck` sem erros | ACP-001, ACP-002, ACP-005 | CI green |
| 3 | `pnpm test` sem falhas | ACP-084—095 | CI green |
| 4 | `pnpm build` sem erros | ACP-138 | CI green |
| 5 | Entidades com 100% cobertura | ACP-084 | Coverage report |
| 6 | Schemas Zod validam tipo+formato+domínio | ACP-044, ACP-045, ACP-046 | Inspecionar `src/lib/validators/` |
| 7 | Server Actions finos (sem lógica de negócio) | ACP-013 | Inspecionar `src/server/actions/` |
| 8 | Repositories encapsulam Drizzle | ACP-037 | Grep por imports de Drizzle fora de `repositories/` |
| 9 | Sem `any`, sem `as` desnecessário, sem `!` | ACP-002, ACP-003, ACP-007 | Biome + grep |
| 10 | Sem `console.log` | ACP-180 | Biome |
| 11 | Dados sensíveis criptografados | ACP-056 | Inspecionar repositories |
| 12 | Session verificada em toda ação autenticada | ACP-050 | Inspecionar server actions |
| 13 | Ownership verificado (anti-IDOR) | ACP-051 | Inspecionar managers |
| 14 | Mobile-first, touch targets ≥ 44px | ACP-101, ACP-102 | Visual review |
| 15 | Contraste WCAG AA | ACP-099 | Lighthouse ou axe |
| 16 | Skeleton loaders (não spinners) | ACP-017 | Visual review |
| 17 | Error boundaries nas rotas | ACP-018 | Verificar `error.tsx` |
| 18 | Copy em português coloquial, tom acolhedor | ACP-109, ACP-110 | Review de copy |
| 19 | Logs sem dados sensíveis | ACP-059, ACP-128 | Inspecionar config Pino |
| 20 | Sem secrets no código | ACP-054 | `grep -rn "password\|secret\|api_key\|token" src/` |
| 21 | Commits semânticos em português | ACP-142 | Inspecionar git log |
| 22 | PR com resumo + auditoria | ACP-143 | Corpo do PR |
| 23 | Telemetria registrada | ACP-199 | bgr-log.sh executado |
