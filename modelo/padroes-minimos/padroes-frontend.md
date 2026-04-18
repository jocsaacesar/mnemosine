---
documento: padroes-frontend
versao: 2.2.0
criado: 2025-06-01
atualizado: 2026-04-16
total_regras: 38
severidades:
  erro: 21
  aviso: 17
escopo: HTML, CSS e UX de todos os projetos web
stack: frontend
aplica_a: ["todos"]
requer: [padroes-seguranca, padroes-js]
substitui: [padroes-frontend-v1]
---

# Padrões de Frontend/UX/UI — sua organização

> Documento constitucional. Contrato de entrega para todo
> desenvolvedor que toca frontend nos nossos projetos.
> Código que viola regras ERRO não é discutido — é devolvido.

---

## Como usar este documento

### Para o desenvolvedor

1. Leia este documento antes de tocar em HTML, CSS ou UX de qualquer projeto. Regras de JavaScript vivem em `padroes-js.md`.
2. Consulte os IDs das regras durante o desenvolvimento e antes de abrir PR.
3. Verifique o DoD no final deste documento antes de solicitar review.

### Para o auditor (humano ou IA)

1. Leia o frontmatter para entender escopo e dependências.
2. Audite cada arquivo contra as regras por ID e severidade.
3. Classifique violações: ERRO bloqueia merge, AVISO exige justificativa escrita.
4. Referencie violações pelo ID da regra (ex.: "viola UI-011").

### Para o Claude Code

1. Leia o frontmatter para identificar escopo e dependências.
2. Ao gerar código frontend, aplique todas as regras deste documento automaticamente. Para JS, aplique `padroes-js.md`.
3. Em code review, referencie violações pelo ID (ex.: "UI-012 — sem CSS inline estático").
4. Nunca gere código que viole regras ERRO. Regras AVISO podem ser flexibilizadas com justificativa explícita no PR.

---

## Severidades

| Nível | Significado | Ação |
|-------|-------------|------|
| **ERRO** | Violação inegociável | Bloqueia merge. Corrigir antes de review. |
| **AVISO** | Recomendação forte | Deve ser justificada por escrito se ignorada. |

---

## 1. Design tokens e identidade visual

### UI-001 — Cores definidas como CSS custom properties [ERRO]

**Regra:** Todas as cores do projeto são declaradas como variáveis CSS no `:root`. Nunca usar valores hexadecimais, RGB ou HSL direto nos componentes.

**Verifica:** Buscar `#[0-9a-fA-F]`, `rgb(`, `hsl(` fora do bloco `:root`. Qualquer ocorrência em componente é violação.

**Por quê:** O projeto trabalha com múltiplos projetos, cada um com sua identidade visual. Design tokens centralizados permitem que o Claude Code gere componentes sem conhecer a paleta específica — basta referenciar as variáveis. Quando o designer muda uma cor, a mudança propaga automaticamente.

**Exemplo correto:**
```css
/* tokens do projeto — definidos uma vez */
:root {
    --brand-primary: #E2C5B0;
    --brand-primary-hover: #d4b39e;
    --brand-secondary: #EFD7D3;
    --color-text: #3d3d3d;
    --color-text-muted: #939393;
    --color-bg: #faf8f6;
    --color-bg-card: #ffffff;
    --color-border: #e8e0da;
}
```

```html
<!-- uso correto — referencia o token -->
<div style="color: var(--color-success);">Operação concluída</div>
```

**Exemplo incorreto:**
```html
<!-- cor hardcoded — quebra ao mudar paleta -->
<div style="color: #198754;">Operação concluída</div>
```

### UI-002 — Cores semânticas para dados com significado [ERRO]

**Regra:** Dados que carregam significado (status, categorias, indicadores) usam tokens semânticos (ex.: `--color-success`, `--color-danger`, `--color-info`). Nunca misturar significados — verde sempre significa positivo/sucesso, vermelho sempre significa negativo/erro.

**Verifica:** Inspecionar badges/spans de status. Cor aplicada contradiz o texto exibido? Violação.

**Por quê:** Projetos frequentemente envolvem dados financeiros, status e métricas. Se cada desenvolvedor escolhe cores arbitrárias, o usuário perde a capacidade de escanear a interface rapidamente. Consistência semântica reduz erros de interpretação.

**Exemplo correto:**
```css
:root {
    --color-success: #198754;
    --color-danger: #dc3545;
    --color-info: #0dcaf0;
    --color-warning: #ffc107;
}
```

```html
<span style="color: var(--color-success);">Aprovado</span>
<span style="color: var(--color-danger);">Rejeitado</span>
```

**Exemplo incorreto:**
```html
<!-- verde para "rejeitado" — contradiz a semântica -->
<span style="color: var(--color-success);">Rejeitado</span>
```

### UI-003 — Tipografia via design tokens [AVISO]

**Regra:** Fontes do projeto são declaradas como variáveis CSS. O corpo da aplicação usa a font stack definida no token `--font-family-base`. Fontes de marca (logotipo, headings especiais) são servidas como asset gráfico ou web font declarada no token.

**Verifica:** Buscar `font-family:` fora do `:root`. Valor que não usa `var(--font-family-*)` é violação.

**Por quê:** Time pequeno gera código via IA. Se a fonte não está tokenizada, o Claude Code vai chutar uma font stack diferente a cada arquivo. Token centralizado garante consistência sem esforço manual.

**Exemplo correto:**
```css
:root {
    --font-family-base: system-ui, -apple-system, "Segoe UI", Roboto, sans-serif;
    --font-family-mono: "SFMono-Regular", "Cascadia Code", monospace;
}

body {
    font-family: var(--font-family-base);
    color: var(--color-text);
    background-color: var(--color-bg);
}
```

**Exemplo incorreto:**
```css
body {
    font-family: Arial, sans-serif;
}

.sidebar {
    font-family: "Helvetica Neue", sans-serif;
}
```

### UI-004 — Valores numéricos alinhados em fonte monospace [AVISO]

**Regra:** Números que precisam de alinhamento visual (valores monetários, quantidades em tabelas, métricas) usam fonte monospace via token `--font-family-mono` ou classe utilitária equivalente.

**Verifica:** Inspecionar colunas numéricas em tabelas e cards. Fonte renderizada é proporcional? Violação.

**Por quê:** Projetos lidam com valores financeiros e métricas. Fonte proporcional desalinha casas decimais em colunas, dificultando a leitura e comparação de valores.

**Exemplo correto:**
```html
<span class="font-monospace">R$ 1.500,00</span>
```

**Exemplo incorreto:**
```html
<span>R$ 1.500,00</span>
```

### UI-005 — Logotipo como asset gráfico, nunca recriado em CSS [ERRO]

**Regra:** O logotipo do projeto é servido como SVG ou PNG otimizado. Nunca recriar logotipos via CSS, texto estilizado ou ícones combinados.

**Verifica:** Buscar elemento com classe `logo` ou `brand`. É `<img>` com `src` apontando pra SVG/PNG? Se não, violação.

**Por quê:** Logotipos são criados por designers e têm proporções, cores e formas exatas. Recriar via CSS gera inconsistências entre páginas e quebra em diferentes navegadores. SVG escala sem perda e mantém fidelidade à marca.

**Exemplo correto:**
```html
<img src="/assets/img/logo.svg" alt="Nome do Projeto" class="logo" width="180" height="40">
```

**Exemplo incorreto:**
```html
<!-- logotipo falso via CSS -->
<div style="font-family: cursive; font-size: 2rem; color: pink;">
    Nome do Projeto
</div>
```

**Exceções:** Ícones de favicon podem ser simplificações do logo, servidos como SVG separado.

### UI-006 — Elementos visuais da marca seguem o guia do projeto [AVISO]

**Regra:** Cada projeto tem um guia de identidade visual (fornecido pelo designer). Ícones decorativos, patterns, slogans e elementos gráficos da marca devem seguir esse guia. Não inventar elementos visuais de marca sem referência ao guia.

**Verifica:** Elemento decorativo/ícone de marca tem correspondência no guia de identidade do projeto? Se não, violação.

**Por quê:** O projeto trabalha com designers externos. Elementos visuais inventados pelo desenvolvedor desrespeitam o trabalho do designer e criam inconsistência visual. O guia de identidade é a fonte de verdade.

**Exemplo correto:**
```html
<!-- usa asset do guia de identidade -->
<img src="/assets/img/icon-brand.svg" alt="" class="decorative-icon" aria-hidden="true">
```

**Exemplo incorreto:**
```html
<!-- emoji como substituto de ícone da marca -->
<span class="brand-icon">🌸</span>
```

---

## 2. CSS — convenções e restrições

### UI-007 — Utility-first, CSS custom só quando necessário [AVISO]

**Regra:** Preferir classes utilitárias do framework CSS adotado no projeto (Bootstrap, Tailwind, etc.). CSS custom apenas quando a utility não cobre (animações, pseudo-elementos, layouts muito específicos).

**Verifica:** CSS custom recém-adicionado tem equivalente em utility do framework? Se sim, violação.

**Por quê:** Time pequeno mantém múltiplos projetos. CSS custom cresce indefinidamente e se torna impossível de auditar. Utilities são padronizadas, documentadas e removíveis. O Claude Code gera utilities com mais precisão do que CSS custom.

**Exemplo correto:**
```html
<!-- utilities do framework -->
<div class="card shadow-sm border-0 mb-3">
    <div class="card-body p-4">
        <h5 class="card-title fw-bold">Título</h5>
    </div>
</div>
```

**Exemplo incorreto:**
```html
<!-- CSS custom desnecessário -->
<div class="meu-card">
    <!-- .meu-card { box-shadow: 0 .125rem .25rem rgba(0,0,0,.075); border: none; margin-bottom: 1rem; } -->
</div>
```

### UI-008 — Grid system para layout, nunca posicionamento manual [ERRO]

**Regra:** Layouts de página usam o grid system do framework CSS (`container`, `row`, `col-*`, ou equivalentes em Flexbox/Grid). Nunca usar `float` ou `position: absolute` para layout de página.

**Verifica:** Buscar `float:` e `position: absolute` em CSS de layout de página. Qualquer ocorrência é violação.

**Por quê:** Layouts com float e position absolute quebram em telas diferentes e são impossíveis de manter. O Claude Code gera código responsivo correto quando usa grid system — com float, gera bugs visuais que só aparecem em produção.

**Exemplo correto:**
```html
<div class="container">
    <div class="row g-4">
        <div class="col-md-8"><!-- conteúdo principal --></div>
        <div class="col-md-4"><!-- sidebar --></div>
    </div>
</div>
```

**Exemplo incorreto:**
```html
<div style="float: left; width: 66%;"><!-- conteúdo --></div>
<div style="float: right; width: 33%;"><!-- sidebar --></div>
```

### UI-009 — Breakpoints responsivos do framework, sem valores custom [ERRO]

**Regra:** Usar os breakpoints nativos do framework CSS adotado no projeto. Nunca criar media queries com valores arbitrários.

**Verifica:** Buscar `@media` em CSS custom. Valor do breakpoint coincide com os do framework? Se não, violação.

**Por quê:** Breakpoints custom criam fragmentação — cada desenvolvedor escolhe um valor diferente, e o layout quebra entre eles. Breakpoints padronizados garantem que todos os componentes se adaptam nos mesmos pontos.

**Exemplo correto:**
```html
<!-- breakpoints padrão do framework -->
<div class="col-12 col-md-6 col-lg-4">...</div>
```

**Exemplo incorreto:**
```css
/* breakpoint inventado — não coincide com o framework */
@media (min-width: 850px) {
    .minha-classe { width: 50%; }
}
```

### UI-010 — Componentes do framework antes de componentes custom [AVISO]

**Regra:** Usar os componentes nativos do framework CSS (cards, modals, alerts, tables, badges, dropdowns, toasts) antes de criar componentes custom. Criar do zero apenas quando o framework não oferece solução.

**Verifica:** Componente custom recém-criado tem equivalente nativo no framework? Se sim, violação.

**Por quê:** Componentes custom exigem manutenção, testes de acessibilidade e documentação própria. O o time é pequeno — cada componente custom é dívida técnica. Componentes do framework já são testados, acessíveis e documentados.

**Exemplo correto:**
```html
<!-- modal do framework -->
<div class="modal" id="confirmacao" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">...</div>
    </div>
</div>
```

**Exemplo incorreto:**
```html
<!-- modal custom do zero -->
<div class="meu-overlay" style="position: fixed; top: 0; left: 0; width: 100%; height: 100%;">
    <div class="meu-popup" style="position: absolute; top: 50%; left: 50%;">...</div>
</div>
```

### UI-011 — Sem !important [ERRO]

**Regra:** Nunca usar `!important` em CSS custom. Para sobrescrever estilos do framework, usar especificidade maior ou CSS custom properties.

**Verifica:** Buscar `!important` em arquivos CSS/SCSS do projeto. Qualquer ocorrência é violação.

**Por quê:** `!important` cria cascatas impossíveis de depurar. Quando dois `!important` conflitam, a solução é outro `!important` — espiral de complexidade. No projeto, especificidade resolve conflitos de forma previsível.

**Exemplo correto:**
```css
/* especificidade maior */
.dashboard .card-title {
    font-size: 1.25rem;
}
```

**Exemplo incorreto:**
```css
.card-title {
    font-size: 1.25rem !important;
}
```

### UI-012 — Sem CSS inline em HTML [ERRO]

**Regra:** Estilos vivem em arquivos CSS ou em classes utilitárias do framework. Nunca usar atributo `style=""` direto no HTML, exceto para valores dinâmicos injetados por backend/JS (ex.: largura de barra de progresso, cor definida pelo usuário).

**Verifica:** Buscar `style="` no HTML. Valor é estático (não injetado por backend/JS)? Violação.

**Por quê:** CSS inline não é auditável, não é reutilizável e não respeita design tokens. O Claude Code tende a gerar `style=""` como atalho — esta regra força a disciplina de usar tokens e classes.

**Exemplo correto:**
```html
<!-- classe utilitária -->
<div class="text-success fw-bold">Aprovado</div>

<!-- dinâmico (aceitável) -->
<div class="progress-bar" style="width: 75%"></div>
```

**Exemplo incorreto:**
```html
<!-- estilo estático inline -->
<div style="color: green; font-weight: bold;">Aprovado</div>
```

### UI-013 — Dark mode preparado via atributo de tema [AVISO]

**Regra:** Usar atributo de tema no `<html>` (ex.: `data-bs-theme="light"`, `data-theme="light"`) e respeitar as variáveis CSS do framework. Design tokens do projeto devem ter variantes para ambos os temas.

**Verifica:** Tokens em `:root` têm variante `[data-theme="dark"]` correspondente? Se não, violação.

**Por quê:** Projetos eventualmente pedem dark mode. Se os tokens não são preparados desde o início, a implementação exige reescrever CSS de todos os componentes. Preparar desde o início custa zero e economiza dias no futuro.

**Exemplo correto:**
```css
:root {
    --color-bg: #faf8f6;
    --color-bg-card: #ffffff;
    --color-text: #3d3d3d;
    --color-border: #e8e0da;
}

[data-theme="dark"] {
    --color-bg: #212529;
    --color-bg-card: #2b3035;
    --color-text: #dee2e6;
    --color-border: #495057;
}
```

**Exemplo incorreto:**
```css
/* cores hardcoded sem variantes de tema */
body { background: white; color: black; }
.card { background: #f8f9fa; }
```

---

## 3. UX — interação e feedback

### UI-014 — Modo privacidade para dados sensíveis [ERRO]

**Regra:** Interfaces que exibem dados sensíveis (valores financeiros, dados pessoais, métricas confidenciais) devem ter um controle que oculta/exibe esses dados. Quando oculto, valores são substituídos por `•••••`. O estado persiste no `localStorage`.

**Verifica:** Tela exibe valor financeiro ou dado pessoal? Existe botão toggle de privacidade? Se não, violação.

**Por quê:** Projetos lidam com dados financeiros e pessoais. Usuários abrem a aplicação em ambientes públicos (escritório, transporte). Sem modo privacidade, dados ficam expostos para quem estiver ao lado.

**Exemplo correto:**
```html
<!-- botão de toggle -->
<button id="togglePrivacidade" aria-label="Ocultar valores sensíveis">
    <i class="bi bi-eye"></i>
</button>

<!-- visível -->
<span class="dado-sensivel" data-visible="true">R$ 12.450,00</span>

<!-- oculto -->
<span class="dado-sensivel" data-visible="false">•••••</span>
```

**Exemplo incorreto:**
```html
<!-- valores sempre expostos, sem controle de privacidade -->
<span>R$ 12.450,00</span>
```

**Exceções:** Interfaces internas sem dados sensíveis (ex.: painel de configuração de sistema).

### UI-015 — Ações primárias acessíveis sem scroll [AVISO]

**Regra:** A tela inicial de qualquer aplicação exibe as ações primárias em destaque, acessíveis sem scroll ou navegação profunda.

**Verifica:** Abrir tela inicial em viewport 375px. Ação primária visível sem scroll? Se não, violação.

**Por quê:** Usuários de projetos são frequentemente não-técnicos. Se a ação principal está escondida em menus ou abaixo do fold, o usuário liga para o suporte. Ações primárias visíveis reduzem chamados e aumentam adoção.

**Exemplo correto:**
```html
<!-- ações primárias no topo do dashboard -->
<div class="d-flex gap-2 mb-4">
    <a href="/novo" class="btn btn-primary">Nova entrada</a>
    <a href="/relatorio" class="btn btn-outline-secondary">Ver relatório</a>
</div>
```

**Exemplo incorreto:**
```html
<!-- ação principal escondida em submenu -->
<nav>
    <ul>
        <li>Menu
            <ul>
                <li>Submenu
                    <ul>
                        <li><a href="/novo">Nova entrada</a></li>
                    </ul>
                </li>
            </ul>
        </li>
    </ul>
</nav>
```

### UI-016 — Fricção positiva em operações destrutivas ou irreversíveis [ERRO]

**Regra:** Toda operação que altera estado de forma significativa (confirmar transação, cancelar, deletar, arquivar) exige confirmação explícita do usuário via modal ou etapa intermediária.

**Verifica:** Clicar em botão destrutivo (delete, cancel, arquivar). Aparece modal/step de confirmação? Se não, violação.

**Por quê:** Projetos lidam com dados financeiros e registros críticos. Um clique acidental em "deletar" sem confirmação gerou perda de dados em produção. Fricção positiva previne erros que custam horas de suporte e restauração.

**Exemplo correto:**
```html
<!-- modal de confirmação antes de deletar -->
<div class="modal" id="confirmarExclusao" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Confirmar exclusão</h5>
            </div>
            <div class="modal-body">
                <p>Tem certeza que deseja excluir este registro?</p>
            </div>
            <div class="modal-footer">
                <button class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                <button class="btn btn-danger" id="btnExcluir">Excluir</button>
            </div>
        </div>
    </div>
</div>
```

**Exemplo incorreto:**
```html
<!-- ação destrutiva direta sem confirmação -->
<button onclick="deletarRegistro(id)">Excluir</button>
```

### UI-017 — Feedback visual em toda ação do usuário [ERRO]

**Regra:** Toda ação do usuário produz feedback visual imediato: toast de sucesso, alert de erro, spinner de loading. O usuário nunca fica sem saber se a ação funcionou.

**Verifica:** Executar cada ação do fluxo. Aparece toast/alert/spinner? Se não, violação.

**Por quê:** Sem feedback, o usuário clica duas vezes, fecha a aba ou liga para o suporte achando que "travou". Isso já aconteceu — o usuário duplicou transações financeiras por clicar duas vezes num botão sem feedback.

**Exemplo correto:**
```html
<!-- toast de sucesso -->
<div class="toast align-items-center text-bg-success" role="alert" aria-live="assertive">
    <div class="d-flex">
        <div class="toast-body">Registro salvo com sucesso.</div>
        <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>
    </div>
</div>

<!-- spinner durante operação -->
<button class="btn btn-primary" disabled>
    <span class="spinner-border spinner-border-sm" role="status"></span>
    Processando...
</button>
```

**Exemplo incorreto:**
```html
<!-- botão sem feedback — usuário não sabe se funcionou -->
<button onclick="salvar()">Salvar</button>
<!-- nenhum toast, nenhum spinner, nenhuma indicação -->
```

### UI-018 — Estados vazios com orientação [AVISO]

**Regra:** Quando uma lista, tabela ou seção está vazia, exibir uma mensagem orientando o usuário sobre o que fazer para preenchê-la.

**Verifica:** Esvaziar lista/tabela (filtro sem resultado ou dado novo). Aparece mensagem orientativa? Se não, violação.

**Por quê:** Usuários não-técnicos interpretam tela vazia como "erro" ou "sistema quebrado". Estado vazio com orientação transforma confusão em ação.

**Exemplo correto:**
```html
<div class="text-center py-5 text-muted">
    <p class="mb-3">Nenhum registro encontrado.</p>
    <a href="/novo" class="btn btn-primary">Criar primeiro registro</a>
</div>
```

**Exemplo incorreto:**
```html
<!-- tabela vazia sem explicação -->
<table>
    <thead><tr><th>Nome</th><th>Valor</th></tr></thead>
    <tbody></tbody>
</table>
```

---

## 4. Formulários

### UI-019 — inputmode correto para valores numéricos e monetários [ERRO]

**Regra:** Campos de valor monetário usam `inputmode="decimal"` para invocar teclado numérico com separador decimal em dispositivos móveis. Campos de quantidades inteiras usam `inputmode="numeric"`.

**Verifica:** Buscar `<input>` de valor monetário. Tem `inputmode="decimal"`? Se não, violação.

**Por quê:** Projetos são usados em celular. Sem `inputmode`, o usuário recebe teclado QWERTY para digitar números — experiência frustrante que gera erros de digitação e reclamações.

**Exemplo correto:**
```html
<input type="text" inputmode="decimal" name="valor" placeholder="0,00"
       class="form-control" autocomplete="off">
```

**Exemplo incorreto:**
```html
<!-- type number com setas de incremento — péssimo para valores monetários -->
<input type="number" name="valor">
```

### UI-020 — inputmode="numeric" para campos de código/PIN [AVISO]

**Regra:** Campos de código numérico (PIN, código de verificação, CEP) usam `inputmode="numeric"` para invocar teclado numérico sem separador decimal.

**Verifica:** Buscar `<input>` de PIN/CEP/código. Tem `inputmode="numeric"`? Se não, violação.

**Por quê:** Teclado correto reduz atrito. Usuários de projetos acessam via celular — cada campo com teclado errado é uma micro-frustração que acumula.

**Exemplo correto:**
```html
<input type="text" inputmode="numeric" name="codigo" maxlength="6"
       class="form-control" placeholder="000000" autocomplete="one-time-code">
```

**Exemplo incorreto:**
```html
<input type="text" name="codigo" placeholder="Digite o código">
```

### UI-021 — Labels obrigatórios em todo campo de formulário [ERRO]

**Regra:** Todo `<input>`, `<select>` e `<textarea>` tem um `<label>` associado via atributos `for`/`id`. Nunca usar placeholder como substituto de label.

**Verifica:** Inspecionar todo `<input>`/`<select>`/`<textarea>`. Tem `<label for="...">` correspondente? Se não, violação.

**Por quê:** Placeholder desaparece quando o usuário digita — ele não sabe mais o que o campo pede. Leitores de tela dependem de `<label>` para identificar campos. Sem label, o formulário é inacessível.

**Exemplo correto:**
```html
<label for="descricao" class="form-label">Descrição</label>
<input type="text" class="form-control" id="descricao" name="descricao">
```

**Exemplo incorreto:**
```html
<!-- placeholder como label — inacessível -->
<input type="text" class="form-control" placeholder="Descrição">
```

### UI-022 — Validação visual com classes do framework [AVISO]

**Regra:** Usar classes de validação do framework CSS (`is-valid`, `is-invalid` ou equivalentes) com mensagens de erro visíveis junto ao campo.

**Verifica:** Submeter formulário com campo inválido. Classe `is-invalid` (ou equivalente) + mensagem visível? Se não, violação.

**Por quê:** Validação visual padronizada permite que o Claude Code gere formulários com feedback de erro consistente em todos os projetos. Validação custom por projeto gera inconsistência e retrabalho.

**Exemplo correto:**
```html
<input type="text" class="form-control is-invalid" id="valor" name="valor">
<div class="invalid-feedback">Valor é obrigatório.</div>
```

**Exemplo incorreto:**
```html
<input type="text" class="form-control" id="valor" name="valor">
<span style="color: red; font-size: 12px;">Campo obrigatório</span>
```

### UI-023 — Formulários complexos agrupados com fieldset e legend [AVISO]

**Regra:** Formulários com múltiplas seções usam `<fieldset>` e `<legend>` para agrupar campos relacionados.

**Verifica:** Formulário com >1 seção lógica. Usa `<fieldset>`+`<legend>` pra agrupar? Se não, violação.

**Por quê:** Formulários longos sem agrupamento são intimidadores. `<fieldset>` e `<legend>` criam separação visual e semântica que ajuda tanto o usuário quanto leitores de tela a entender a estrutura.

**Exemplo correto:**
```html
<form>
    <fieldset>
        <legend>Dados pessoais</legend>
        <label for="nome" class="form-label">Nome</label>
        <input type="text" class="form-control" id="nome" name="nome">
    </fieldset>
    <fieldset>
        <legend>Endereço</legend>
        <label for="cep" class="form-label">CEP</label>
        <input type="text" class="form-control" id="cep" name="cep" inputmode="numeric">
    </fieldset>
</form>
```

**Exemplo incorreto:**
```html
<form>
    <h4>Dados pessoais</h4>
    <input type="text" name="nome" placeholder="Nome">
    <h4>Endereço</h4>
    <input type="text" name="cep" placeholder="CEP">
</form>
```

---

## 5. Tabelas e listagens

### UI-024 — Tabelas responsivas [ERRO]

**Regra:** Toda tabela usa wrapper responsivo (ex.: `.table-responsive`) para scroll horizontal em telas pequenas.

**Verifica:** Buscar `<table>` sem wrapper `.table-responsive` (ou equivalente). Qualquer ocorrência é violação.

**Por quê:** Tabelas sem wrapper responsivo estouram o layout em celular. O usuário não consegue ver colunas à direita e acha que os dados não existem. Já aconteceu — usuário reclamou que "faltava coluna de status" porque estava fora da tela.

**Exemplo correto:**
```html
<div class="table-responsive">
    <table class="table table-hover align-middle">
        <thead class="table-light">
            <tr>
                <th>Data</th>
                <th>Descrição</th>
                <th class="text-end">Valor</th>
                <th>Status</th>
            </tr>
        </thead>
        <tbody><!-- dados --></tbody>
    </table>
</div>
```

**Exemplo incorreto:**
```html
<!-- tabela sem wrapper responsivo -->
<table class="table">
    <thead><tr><th>Data</th><th>Descrição</th><th>Valor</th><th>Status</th></tr></thead>
    <tbody><!-- dados --></tbody>
</table>
```

### UI-025 — Valores numéricos alinhados à direita em tabelas [ERRO]

**Regra:** Colunas com valores numéricos (monetários, quantidades, percentuais) são alinhadas à direita e usam fonte monospace.

**Verifica:** Inspecionar `<td>` com valor numérico. Tem `text-end` + `font-monospace` (ou equivalente)? Se não, violação.

**Por quê:** Alinhamento à direita permite comparação visual instantânea de grandezas. Sem alinhamento, o usuário precisa ler cada número individualmente para comparar — lento e propenso a erro.

**Exemplo correto:**
```html
<td class="text-end font-monospace">R$ 1.500,00</td>
```

**Exemplo incorreto:**
```html
<td>R$ 1.500,00</td>
```

### UI-026 — Status com badges coloridos e semânticos [AVISO]

**Regra:** Status de registros são exibidos com badges usando cores semânticas consistentes em todo projeto.

**Verifica:** Buscar exibição de status. Usa badge com classe semântica do framework? Se não, violação.

**Por quê:** Badges padronizados criam linguagem visual que o usuário aprende uma vez e aplica em todas as telas. Se cada tela usa um estilo diferente para status, o usuário precisa reaprender a cada página.

**Exemplo correto:**
```html
<span class="badge text-bg-warning">Pendente</span>
<span class="badge text-bg-success">Confirmado</span>
<span class="badge text-bg-danger">Cancelado</span>
```

**Exemplo incorreto:**
```html
<!-- status como texto solto sem destaque visual -->
<span>pendente</span>
<span style="color: green;">ok</span>
```

---

## 6. Dashboards e visualização de dados

### UI-027 — Cards para métricas de dashboard [AVISO]

**Regra:** Métricas principais do dashboard (KPIs, totais, contadores) são exibidas em cards padronizados do framework, organizados em grid responsivo.

**Verifica:** Dashboard exibe métricas? Estão em cards do framework + grid responsivo? Se não, violação.

**Por quê:** Cards criam hierarquia visual clara. Métricas soltas na página competem por atenção e confundem o usuário. Cards em grid responsivo funcionam tanto em desktop quanto em celular sem ajuste.

**Exemplo correto:**
```html
<div class="row g-4">
    <div class="col-sm-6 col-xl-3">
        <div class="card border-0 shadow-sm">
            <div class="card-body">
                <p class="text-muted small mb-1">Total de registros</p>
                <h3 class="fw-bold font-monospace dado-sensivel" data-visible="true">
                    1.247
                </h3>
            </div>
        </div>
    </div>
    <!-- mais cards -->
</div>
```

**Exemplo incorreto:**
```html
<!-- métricas soltas sem estrutura -->
<p>Total: 1247</p>
<p>Ativos: 89</p>
<p>Pendentes: 34</p>
```

### UI-028 — Gráficos com alternativa textual acessível [ERRO]

**Regra:** Todo gráfico (canvas, SVG, biblioteca de charts) deve ter uma descrição textual acessível via `aria-label` ou texto oculto com classe `visually-hidden`.

**Verifica:** Buscar `<canvas>` ou container de gráfico. Tem `aria-label` ou `visually-hidden` com descrição? Se não, violação.

**Por quê:** Gráficos sem alternativa textual são invisíveis para leitores de tela. Além de excluir usuários com deficiência visual, prejudica SEO e impede que ferramentas de IA extraiam informações do gráfico.

**Exemplo correto:**
```html
<div id="grafico-categorias"
     role="img"
     aria-label="Gráfico de distribuição por categoria: Alimentação 35%, Transporte 20%, Moradia 30%, Lazer 15%">
</div>
```

**Exemplo incorreto:**
```html
<!-- gráfico sem alternativa textual -->
<div id="grafico-categorias"></div>
```

### UI-029 — Cores de gráfico consistentes com design tokens [AVISO]

**Regra:** Gráficos usam as mesmas cores definidas nos design tokens do projeto. Cores semânticas (sucesso, erro, alerta) mantêm o mesmo significado dos demais componentes.

**Verifica:** Config de cores do gráfico usa `getComputedStyle` + `getPropertyValue('--color-*')`? Cor hardcoded é violação.

**Por quê:** Se o gráfico usa uma paleta diferente do resto da interface, o usuário perde a referência visual. Verde no gráfico deve significar o mesmo que verde no badge e no texto.

**Exemplo correto:**
```javascript
const chartColors = {
    positivo: getComputedStyle(document.documentElement).getPropertyValue('--color-success').trim(),
    negativo: getComputedStyle(document.documentElement).getPropertyValue('--color-danger').trim(),
    neutro: getComputedStyle(document.documentElement).getPropertyValue('--color-info').trim(),
};
```

**Exemplo incorreto:**
```javascript
// cores hardcoded que não coincidem com os tokens do projeto
const chartColors = {
    positivo: '#00ff00',
    negativo: '#ff0000',
    neutro: '#0000ff',
};
```

---

## 7. Acessibilidade

### UI-030 — Contraste mínimo WCAG AA [ERRO]

**Regra:** Todo texto tem contraste mínimo de 4.5:1 contra o fundo (WCAG AA). Texto grande (18px+ ou 14px+ bold) aceita 3:1.

**Verifica:** Testar pares cor-de-texto/cor-de-fundo com ferramenta de contraste. Ratio <4.5:1 (ou <3:1 pra texto grande) é violação.

**Por quê:** Projetos são usados por público diverso, incluindo pessoas com baixa visão. Contraste insuficiente gera reclamações de "não consigo ler" e exclui usuários. WCAG AA é o mínimo legal em muitos contextos.

**Exemplo correto:**
```css
/* texto escuro em fundo claro — contraste 10.5:1 */
.content {
    color: #3d3d3d;
    background-color: #ffffff;
}
```

**Exemplo incorreto:**
```css
/* texto cinza claro em fundo branco — contraste 2.1:1 */
.content {
    color: #c0c0c0;
    background-color: #ffffff;
}
```

### UI-031 — Navegação por teclado funcional [ERRO]

**Regra:** Todo elemento interativo (botões, links, inputs, modais) é acessível via teclado (Tab, Enter, Escape). Ordem de tabulação segue a ordem visual lógica. Nenhum elemento interativo fica inacessível por teclado.

**Verifica:** Navegar pela página só com Tab/Enter/Escape. Algum interativo não recebe foco ou não responde? Violação.

**Por quê:** Usuários com deficiência motora dependem de teclado. Além disso, power users preferem teclado por velocidade. Se um modal não fecha com Escape ou um dropdown não navega com setas, a experiência é quebrada.

**Exemplo correto:**
```html
<!-- botão nativo — acessível por teclado automaticamente -->
<button type="button" class="btn btn-primary">Salvar</button>

<!-- link com destino — acessível por Tab e Enter -->
<a href="/relatorio" class="btn btn-outline-secondary">Ver relatório</a>
```

**Exemplo incorreto:**
```html
<!-- div como botão — não recebe foco via Tab, não responde a Enter -->
<div class="btn-fake" onclick="salvar()">Salvar</div>
```

### UI-032 — ARIA roles em componentes dinâmicos [AVISO]

**Regra:** Componentes dinâmicos (modais, toasts, dropdowns, abas, accordions) usam roles e atributos ARIA corretos. Componentes do framework CSS já implementam ARIA — não remover esses atributos. Componentes custom devem implementar ARIA equivalente.

**Verifica:** Inspecionar componente dinâmico. Tem `role`, `aria-*` conforme spec do framework? Se não, violação.

**Por quê:** O Claude Code gera componentes dinâmicos frequentemente. Sem regra explícita sobre ARIA, o código gerado omite roles e atributos, criando componentes visualmente corretos mas inacessíveis para leitores de tela.

**Exemplo correto:**
```html
<!-- toast com ARIA correto -->
<div class="toast" role="alert" aria-live="assertive" aria-atomic="true">
    <div class="toast-body">Registro salvo.</div>
</div>

<!-- accordion com ARIA -->
<div class="accordion-item">
    <h2 class="accordion-header">
        <button class="accordion-button" type="button"
                data-bs-toggle="collapse" data-bs-target="#secao1"
                aria-expanded="true" aria-controls="secao1">
            Seção 1
        </button>
    </h2>
    <div id="secao1" class="accordion-collapse collapse show"
         aria-labelledby="heading1">
        <div class="accordion-body">Conteúdo</div>
    </div>
</div>
```

**Exemplo incorreto:**
```html
<!-- toast sem roles ARIA -->
<div class="toast">
    <div class="toast-body">Registro salvo.</div>
</div>

<!-- accordion custom sem ARIA -->
<div class="meu-accordion">
    <div class="meu-accordion-header" onclick="toggle()">Seção 1</div>
    <div class="meu-accordion-body">Conteúdo</div>
</div>
```

### UI-033 — Sem informação transmitida apenas por cor [ERRO]

**Regra:** Indicadores visuais (status, sucesso/erro, categorias) nunca dependem apenas de cor. Sempre acompanhados de ícone, sinal (+/-), texto ou padrão visual.

**Verifica:** Remover cores mentalmente (grayscale). Indicadores ainda distinguíveis por ícone/sinal/texto? Se não, violação.

**Por quê:** 8% dos homens têm algum grau de daltonismo. Se receita é verde e despesa é vermelha sem nenhum outro diferenciador, um usuário daltônico não distingue os dois. Já recebemos essa reclamação em produção.

**Exemplo correto:**
```html
<!-- cor + sinal textual -->
<span class="text-success font-monospace">+R$ 1.500,00</span>
<span class="text-danger font-monospace">-R$ 800,00</span>
```

**Exemplo incorreto:**
```html
<!-- apenas cor — daltônico não distingue -->
<span class="text-success font-monospace">R$ 1.500,00</span>
<span class="text-danger font-monospace">R$ 800,00</span>
```

---

## 8. Documentação

### UI-038 — Comentários explicam o "por quê", nunca o "o quê" [AVISO]

**Regra:** Comentários em CSS explicam decisões não óbvias ("por quê"), nunca descrevem o que o código faz ("o quê"). Código autoexplicativo não precisa de comentário.

**Verifica:** Comentário recém-adicionado descreve o que a linha faz (ex.: "define cor")? Se sim, violação — reescrever ou remover.

**Por quê:** Comentários que descrevem o óbvio viram ruído e ficam desatualizados. Comentários que explicam decisões (ex.: "overflow hidden por causa do bug no Safari 16") permanecem úteis e evitam que alguém remova a linha sem entender a consequência.

**Exemplo correto:**
```css
/* Força GPU compositing para evitar flickering no scroll em iOS Safari */
.sidebar {
    transform: translateZ(0);
}
```

**Exemplo incorreto:**
```css
/* Define a cor do texto como cinza */
.text-muted {
    color: #6c757d;
}
```

---

## 9. Mobile-first (regras adicionadas em 2026-04-12, incidente 0015)

### UI-040 — Botão de ação nunca é filho direto de flex-row em card [ERRO]

**Regra:** Botões de ação (CTA, logout, delete, configurar) nunca são filhos diretos de um container `flex-row` horizontal dentro de cards ou seções de perfil/info. Devem ocupar bloco próprio abaixo do conteúdo.

**Verifica:** Inspecionar cards com botão de ação. Botão é filho direto de container `flex-row`? Se sim, violação.

**Por quê:** No mobile (viewport ≤640px), flex-row comprime o botão lateralmente, reduzindo touch target e quebrando o layout. 

**Exemplo correto:**
```tsx
<CardContent className="space-y-4">
  <div className="flex items-center gap-4">
    <Avatar />
    <Info />
  </div>
  <BotaoAcao className="w-full min-h-11" />
</CardContent>
```

**Exemplo incorreto:**
```tsx
<CardContent>
  <div className="flex items-center gap-4">
    <Avatar />
    <Info />
    <BotaoAcao /> {/* espremido no mobile */}
  </div>
</CardContent>
```


---

### UI-041 — Touch target mínimo de 44×44px em todo elemento interativo [ERRO]

**Regra:** Todo botão, link, toggle, checkbox e elemento clicável deve ter área de toque mínima de 44×44px (largura × altura). Usar `min-h-11` (44px) no Tailwind.

**Verifica:** DevTools mobile 375px. Elemento interativo com dimensão renderizada <44px em qualquer eixo é violação.

**Por quê:** WCAG 2.5.5 (AAA) e Apple HIG recomendam 44px. Público mobile-first com telas menores precisa de alvos generosos. Botão de 32px no celular = erro de toque = frustração.

---

### UI-042 — Flex-row com >2 filhos interativos vira flex-col no mobile [AVISO]

**Regra:** Se um container flex-row tem mais de 2 elementos interativos (botões, links, inputs), deve usar `flex-col` ou wrap responsivo (`flex-wrap`) no breakpoint mobile (≤640px).

**Verifica:** Flex-row com >2 interativos. Tem `flex-col` ou `flex-wrap` no breakpoint mobile? Se não, violação.

**Por quê:** 3+ botões em linha no mobile ficam microscópicos. O layout deve priorizar legibilidade e área de toque sobre densidade visual.

**Exemplo correto:**
```tsx
<div className="flex flex-col gap-2 sm:flex-row sm:gap-3">
  <Button>Ação 1</Button>
  <Button>Ação 2</Button>
  <Button>Ação 3</Button>
</div>
```

### UI-043 — Campos de formulário vazios por padrão [ERRO]

**Regra:** Todo campo de formulário deve iniciar **vazio** (sem valor pré-preenchido). Valores como `0`, `0,00`, string vazia exibida como conteúdo, ou qualquer default que pareça dado real são proibidos. O campo deve mostrar apenas o **placeholder** (texto-dica em cor atenuada) até o usuário interagir.

**Verifica:** Abrir formulário de criação. Algum campo mostra valor visível (não placeholder) antes de interação? Se sim, violação.

**Por quê:** Campo com "0,00" como valor confunde o usuário — parece dado salvo, não campo vazio. Placeholder comunica formato esperado sem poluir o formulário. Formulário limpo = confiança visual.

**Exceções:**
- Campos de edição (edit mode) que carregam valor existente do banco
- Campos com valor padrão semântico explícito (ex: data = hoje, status = ativo) onde o default é a escolha mais provável do usuário

**Exemplo incorreto:**
```tsx
<Input value="0,00" />           // parece dado, não campo vazio
<InputMoeda valor={0} />         // se renderiza "0,00" como value, viola
```

**Exemplo correto:**
```tsx
<Input placeholder="0,00" />            // placeholder em cinza, campo vazio
<InputMoeda valor={0} />               // renderiza vazio, placeholder aparece
<InputMoeda valor={lancamento.valor} /> // edit mode: OK, carrega dado real
```

---

## Definition of Done — Checklist de entrega

> PR que não cumpre o DoD não entra em review. É devolvido.

| # | Item | Regras | Verificação |
|---|------|--------|-------------|
| 1 | Sem CSS inline estático | UI-012 | Buscar `style=` no HTML e verificar se é dinâmico |
| 2 | Sem `!important` | UI-011 | Buscar `!important` nos arquivos CSS |
| 3 | Cores via design tokens | UI-001, UI-002 | Buscar valores hexadecimais/RGB fora do `:root` |
| 4 | Labels em todos os campos | UI-021 | Inspecionar todo `<input>`, `<select>`, `<textarea>` |
| 5 | Tabelas responsivas | UI-024 | Verificar `.table-responsive` em toda `<table>` |
| 6 | Gráficos com texto acessível | UI-028 | Verificar `aria-label` ou `visually-hidden` em gráficos |
| 7 | Contraste WCAG AA | UI-030 | Testar com DevTools ou ferramenta de contraste |
| 8 | Navegação por teclado | UI-031 | Navegar pela página usando apenas Tab/Enter/Escape |
| 9 | Sem informação apenas por cor | UI-033 | Verificar que indicadores têm ícone/sinal/texto além de cor |
| 10 | Feedback visual em ações | UI-017 | Testar cada ação e verificar toast/alert/spinner |
| 11 | Fricção em operações destrutivas | UI-016 | Testar delete/cancel e verificar modal de confirmação |
| 12 | Layout via grid system | UI-008 | Buscar `float:` e `position: absolute` para layout |
| 13 | Botões fora de flex-row em cards | UI-040 | Inspecionar cards com botão: está em bloco próprio? |
| 14 | Touch targets ≥44px | UI-041 | DevTools mobile 375px: todo interativo ≥44×44px? |
| 15 | Flex-row responsivo | UI-042 | >2 interativos em row: tem flex-col no mobile? |
| 16 | Campos vazios por padrão | UI-043 | Formulário novo: algum campo inicia com valor visível (não placeholder)? |
