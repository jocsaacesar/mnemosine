# Spec: {titulo}

> Gerada por: Interpretadora
> Data: {data}
> Projeto: {projeto}
> Pedido original: "{pedido do Joc, ipsis litteris}"

---

## Contexto

> O que existe hoje, o que muda, por que muda. A construtora precisa entender o cenário sem ler mais nada.

- **Estado atual:** {o que existe no código hoje — arquivos, classes, rotas, templates}
- **O que muda:** {descrição funcional da mudança}
- **Motivação:** {por que essa mudança é necessária}
- **Arquivos afetados:** {lista exaustiva de arquivos que serão criados, editados ou removidos}

---

## Tarefas Backend (→ construtora-backend)

> Cada tarefa é atômica. A construtora executa na ordem, sem interpretar.

### Tarefa B1: {titulo}

- **Arquivo:** `{caminho completo}`
- **Ação:** criar | editar | remover
- **Classe/Método:** `{NomeDaClasse::metodo()}`
- **Assinatura:** `public function metodo(int $param): ReturnType`
- **Lógica:** {descrição passo a passo do que o método faz — sem ambiguidade}
- **Dependências:** {outras classes, tabelas, funções WP que usa}
- **Validações:** {input validation, sanitização, type checks}
- **Tenant isolation:** {sim/não — se sim, como: for_site(), blog_id, empresa_id}
- **Retorno:** {o que retorna em sucesso e em erro}

### Tarefa B2: {titulo}
{mesmo formato}

### Migration (se aplicável)

- **Arquivo:** `{caminho}`
- **Tabelas:** {nome, engine, charset}
- **Colunas:** {nome, tipo, nullable, default, índice — EXATO como no DDL}
- **Idempotência:** {como garantir que rodar 2x não duplica — CREATE IF NOT EXISTS, SELECT COUNT, etc.}
- **Multisite:** {roda 1x global ou 1x por blog? Como evitar duplicação?}

---

## Tarefas Frontend (→ construtora-frontend)

> Cada tarefa especifica arquivo, estrutura HTML, classes Tailwind, estados Alpine.

### Tarefa F1: {titulo}

- **Arquivo:** `{caminho completo}`
- **Tipo:** página | componente | partial | template-part
- **Estrutura HTML:**
```html
<!-- Estrutura esquelética com classes Tailwind exatas -->
<section class="bg-gray-900 px-6 py-12 md:px-12 lg:px-24">
  <h2 class="text-2xl font-bold text-white mb-6">{titulo}</h2>
  <!-- ... -->
</section>
```
- **Classes Tailwind:** {lista das classes usadas, referenciando tokens do design system}
- **Alpine.js (se aplicável):**
  - `x-data`: `{ estado: 'inicial', items: [] }`
  - Eventos: `@click`, `@submit.prevent`
  - Transições: `x-show`, `x-transition`
- **Responsividade:**
  - Mobile (< 768px): {comportamento}
  - Tablet (768-1024px): {comportamento}
  - Desktop (> 1024px): {comportamento}
- **Acessibilidade:** {aria-labels, roles, contraste mínimo, touch target 44px}
- **Auth guard:** {rota protegida? qual role? redirect se não autorizado?}

### Tarefa F2: {titulo}
{mesmo formato}

---

## Tarefas Testes (→ testadora)

> Especifica o que testar, não como testar. A testadora escolhe a abordagem.

### Teste T1: {titulo}

- **Tipo:** unitário
- **Classe alvo:** `{NomeDaClasse}`
- **Método alvo:** `{metodo()}`
- **Cenários:**
  1. {input → output esperado}
  2. {input inválido → exceção/erro esperado}
  3. {edge case → comportamento esperado}
- **Dados de teste:** {valores concretos, não "dados válidos"}

### Teste T2: {titulo}
{mesmo formato}

---

## Tarefas Segurança (→ seguranca)

> Superfície de ataque da mudança. A skill de segurança usa como checklist além da varredura automática.

- **Inputs do usuário:** {quais campos, de onde vêm, sanitização esperada}
- **Queries SQL:** {tabelas tocadas, parâmetros interpolados — verificar prepared statements}
- **Endpoints AJAX/REST:** {ações, nonces, capability checks}
- **Uploads:** {tipos permitidos, validação MIME, tamanho máximo}
- **Auth boundaries:** {rotas protegidas, roles necessárias, redirect}
- **Dados sensíveis:** {PII, tokens, senhas — criptografia esperada}

---

## Tarefas Integração (→ integradora)

> O que verificar quando backend + frontend estiverem prontos.

### Integração I1: {titulo}

- **Fluxo:** {passo a passo do usuário: clica X → vê Y → submete Z → recebe W}
- **Backend chamado:** `{Classe::metodo()}`
- **Frontend envolvido:** `{arquivo template}`
- **Dados transitam:** {o que vai do form pro handler pro banco e volta}
- **Teste de integração:**
  - **Setup:** {estado do banco antes}
  - **Ação:** {o que o teste faz}
  - **Asserção:** {o que o teste verifica}
- **Env/Infra:** {variáveis de ambiente necessárias, serviços externos}

### Integração I2: {titulo}
{mesmo formato}

---

## Critérios de aceite

> O Gerente usa esta lista pra validar a entrega final. Cada item é sim/não.

- [ ] {Critério funcional 1 — o que o usuário vê/faz}
- [ ] {Critério funcional 2}
- [ ] {Critério técnico — ex: "tenant isolation testado com 2 blogs"}
- [ ] {Critério de segurança — ex: "nonce validado em todos os endpoints AJAX"}
- [ ] {Critério de responsividade — ex: "funciona em viewport 375px"}
- [ ] {Critério de integração — ex: "CI verde com todos os testes passando"}
- [ ] Auditoria 0 ERROs
- [ ] Telemetria registrada

---

## Anti-padroes (extraidos dos incidentes BGR)

> Checklist negativo. Se algum destes acontecer, a spec falhou.

- [ ] Construtora inventou lógica que não está na spec (→ incidente 0053)
- [ ] Construtora usou replace_all sem verificar contexto (→ incidente 0054)
- [ ] Coluna/método referenciado na spec não existe no código real (→ incidente 0008)
- [ ] Rota protegida sem auth guard na spec (→ incidente 0045)
- [ ] Seed/migration sem idempotência (→ incidente 0052)
- [ ] Template sem teste mobile (→ incidente 0015)
- [ ] Texto sobre fundo sem verificar contraste (→ incidente 0026)
- [ ] Merge sem CI verde (→ incidentes 0021, 0043)
