---
name: auditar-frontend
description: Audita HTML, CSS, JavaScript e UX do PR aberto contra as regras definidas em docs/padroes-ux-ui.md. Cobre identidade visual, framework CSS, UX, formularios, acessibilidade e interatividade. Trigger manual apenas.
---

# /auditar-frontend — Auditora de padroes frontend e UX/UI

Le as regras de `docs/padroes-ux-ui.md`, identifica os arquivos HTML, CSS e JavaScript alterados no PR aberto (nao mergeado) e compara cada arquivo contra cada regra aplicavel. Foco em: tokens visuais da marca, convencoes do framework CSS, UX, formularios, tabelas, dashboards, acessibilidade e JavaScript.

## Quando usar

- **APENAS** quando o usuario digitar `/auditar-frontend` explicitamente.
- Rodar antes de mergear um PR — funciona como gate de qualidade visual e de UX.
- **Nunca** disparar automaticamente, nem como parte de outra skill.

## Padroes minimos exigidos

> Esta secao contem os padroes completos usados pela auditoria. Edite para personalizar ao seu projeto.

# Padrao de UX/UI e estilos visuais

## Descricao

Documento de referencia para auditoria de interface, experiencia do usuario e estilos visuais no projeto. Define tokens visuais da marca, convencoes do framework CSS, padroes de UX e acessibilidade. A skill `/auditar-frontend` le este documento e compara contra o codigo-alvo.

## Escopo

- Todo HTML em templates e paginas do projeto
- Todo CSS em `assets/css/`
- Todo JavaScript em `assets/js/`

## Referencias

- [WCAG 2.1 — Web Content Accessibility Guidelines](https://www.w3.org/TR/WCAG21/)
- [HTML Living Standard — Input modes](https://html.spec.whatwg.org/multipage/interaction.html#input-modalities:-the-inputmode-attribute)

## Severidade

- **ERRO** — Violacao bloqueia aprovacao. Deve ser corrigida antes de merge.
- **AVISO** — Recomendacao forte. Deve ser justificada se ignorada.

---

## 1. Tokens visuais da marca

### UI-001 — Cores definidas como CSS custom properties [ERRO]

Todas as cores da marca sao declaradas como variaveis CSS na raiz. Nunca usar valores hexadecimais direto nos componentes.

```css
/* assets/css/estilo.css */
:root {
    /* Cores da marca */
    --app-primary: #XXXXXX;
    --app-primary-hover: #XXXXXX;
    --app-primary-light: #XXXXXX;

    /* Semanticas */
    --app-sucesso: #198754;
    --app-erro: #dc3545;
    --app-info: #0dcaf0;

    /* Neutras */
    --app-bg: #faf8f6;
    --app-bg-card: #ffffff;
    --app-texto: #3d3d3d;
    --app-texto-muted: #939393;
    --app-borda: #e8e0da;
}
```

```html
<!-- correto — usa variavel -->
<div style="color: var(--app-sucesso);">Operacao concluida</div>

<!-- incorreto — cor hardcoded -->
<div style="color: #198754;">Operacao concluida</div>
```

### UI-002 — Cores semanticas para dados do dominio [ERRO]

Cada tipo de dado do dominio tem uma cor semantica fixa. Nunca misturar significados.

### UI-003 — Tipografia da marca [AVISO]

A fonte do projeto e declarada via CSS custom property. Corpo usa stack de fontes segura como fallback.

```css
:root {
    --app-font-family: 'SuaFonte', sans-serif;
    --app-font-mono: monospace;
}

body {
    font-family: var(--app-font-family);
    color: var(--app-texto);
    background-color: var(--app-bg);
}
```

### UI-004 — Valores numericos em fonte monospace [AVISO]

Numeros que precisam de alinhamento visual usam fonte monospace.

```html
<!-- correto -->
<span class="font-monospace">1.500,00</span>
```

### UI-005 — Logotipo e icone da marca [ERRO]

O logotipo e um asset grafico — nunca recriado via CSS ou texto. Servido como SVG ou PNG otimizado.

### UI-006 — Elementos visuais da marca [AVISO]

A identidade visual inclui icones, patterns e slogan. Usar como elementos decorativos conforme o guia de marca.

---

## 2. Framework CSS — melhores praticas

### UI-007 — Utility-first, CSS custom so quando necessario [AVISO]

Preferir classes utilitarias do framework CSS. CSS custom apenas quando a utility nao cobre.

### UI-008 — Grid system para layout, nunca posicionamento manual [ERRO]

Layouts usam o grid system do framework. Nunca usar `float`, `position: absolute` para layout de pagina.

### UI-009 — Breakpoints responsivos padrao do framework [ERRO]

Usar os breakpoints nativos do framework. Nunca criar media queries com valores custom.

### UI-010 — Componentes nativos do framework, sem reinventar [AVISO]

Usar os componentes do framework (cards, modals, alerts, tables, badges) antes de criar componentes custom.

### UI-011 — Sem !important [ERRO]

Nunca usar `!important` em CSS custom. Se precisar sobrescrever, usar especificidade maior ou CSS custom properties.

### UI-012 — Sem CSS inline em HTML [ERRO]

Estilos vivem em arquivos CSS ou em classes utilitarias. Nunca `style=""` direto no HTML, exceto para valores dinamicos injetados por codigo (ex.: largura de barra de progresso).

### UI-013 — Dark mode preparado [AVISO]

Usar atributo de tema no `<html>` e respeitar as variaveis CSS do framework. Quando dark mode for implementado, basta trocar o atributo.

---

## 3. UX do dominio

### UI-014 — Modo privacidade (ocultacao de dados sensiveis) [ERRO]

Se o dominio exige, o dashboard deve ter um botao que oculta/exibe dados sensiveis.

### UI-015 — Acoes rapidas no dashboard [AVISO]

A tela inicial exibe acoes primarias em destaque. Sempre acessiveis sem scroll ou navegacao profunda.

### UI-016 — Friccao positiva em operacoes criticas [ERRO]

Toda operacao que altera estado critico exige confirmacao explicita do usuario via modal.

### UI-017 — Feedback visual em toda acao [ERRO]

Toda acao do usuario produz feedback visual: toast de sucesso, alert de erro, spinner de loading. O usuario nunca fica sem saber se a acao funcionou.

### UI-018 — Estados vazios com orientacao [AVISO]

Quando uma lista esta vazia, exibir uma mensagem orientando o usuario sobre o que fazer.

---

## 4. Formularios

### UI-019 — inputmode correto para campos numericos [ERRO]

Campos de valor numerico usam `inputmode="decimal"` ou `inputmode="numeric"` para invocar teclado numerico em dispositivos moveis.

### UI-020 — inputmode="numeric" para campos de codigo/PIN [AVISO]

### UI-021 — Labels obrigatorios em todo campo de formulario [ERRO]

Todo `<input>`, `<select>` e `<textarea>` tem um `<label>` associado via `for`/`id`. Nunca placeholder como substituto de label.

### UI-022 — Validacao visual via framework CSS [AVISO]

Usar classes de validacao do framework CSS para mensagens de erro.

### UI-023 — Formularios agrupados com fieldset e legend [AVISO]

Formularios complexos usam `<fieldset>` e `<legend>` para agrupar campos relacionados.

---

## 5. Tabelas e listagens

### UI-024 — Tabelas responsivas [ERRO]

Toda tabela usa mecanismo responsivo para scroll horizontal em telas pequenas.

### UI-025 — Valores alinhados a direita em tabelas [ERRO]

Colunas com valores numericos sao alinhadas a direita e usam fonte monospace.

### UI-026 — Status com badges coloridos [AVISO]

Status sao exibidos com badges usando cores semanticas.

---

## 6. Dashboards e graficos

### UI-027 — Cards para metricas do dashboard [AVISO]

Metricas principais sao exibidas em cards com layout responsivo.

### UI-028 — Graficos com alternativa textual acessivel [ERRO]

Todo grafico deve ter uma descricao textual acessivel via `aria-label` ou texto oculto.

### UI-029 — Cores de grafico consistentes com tokens da marca [AVISO]

Graficos usam as mesmas cores definidas nas CSS custom properties.

---

## 7. Acessibilidade

### UI-030 — Contraste minimo WCAG AA [ERRO]

Todo texto tem contraste minimo de 4.5:1 contra o fundo (WCAG AA). Texto grande (18px+) aceita 3:1.

### UI-031 — Navegacao por teclado funcional [ERRO]

Todo elemento interativo e acessivel via teclado (Tab, Enter, Escape). Ordem de tabulacao logica.

### UI-032 — ARIA roles em componentes dinamicos [AVISO]

Componentes dinamicos (modais, toasts, dropdowns) usam roles ARIA corretos.

### UI-033 — Sem informacao transmitida apenas por cor [ERRO]

Indicadores nunca dependem apenas de cor. Sempre acompanhados de icone, sinal (+/-) ou texto.

```html
<!-- correto — cor + sinal -->
<span class="text-success font-monospace">+1.500,00</span>
<span class="text-danger font-monospace">-800,00</span>

<!-- incorreto — so cor -->
<span class="text-success font-monospace">1.500,00</span>
<span class="text-danger font-monospace">800,00</span>
```

---

## 8. JavaScript e interatividade

### UI-034 — Vanilla JS ou framework declarado [ERRO]

Todo JavaScript segue a convencao do projeto (vanilla, framework especifico, etc.). Sem bibliotecas nao autorizadas.

### UI-035 — Eventos via addEventListener, sem onclick inline [ERRO]

```javascript
// correto
document.getElementById('btn').addEventListener('click', handleClick);

// incorreto
// <button onclick="handleClick()">
```

### UI-036 — Fetch para AJAX, nunca XMLHttpRequest [AVISO]

Comunicacao com o backend via `fetch()`.

### UI-037 — Loading state em toda operacao assincrona [ERRO]

Enquanto uma operacao assincrona esta em andamento, o botao que disparou fica desabilitado com spinner.

---

## Checklist de auditoria

A skill `/auditar-frontend` deve verificar, para cada arquivo:

**Tokens visuais:**
- [ ] Cores via CSS custom properties, nunca hardcoded
- [ ] Cores semanticas corretas
- [ ] Valores numericos em fonte monospace

**Framework CSS:**
- [ ] Utilities-first, CSS custom so quando necessario
- [ ] Grid system para layout
- [ ] Breakpoints nativos do framework
- [ ] Sem `!important`
- [ ] Sem CSS inline estatico

**UX do dominio:**
- [ ] Friccao positiva em operacoes criticas
- [ ] Feedback visual em toda acao
- [ ] Estados vazios com orientacao

**Formularios:**
- [ ] `inputmode` correto em campos numericos
- [ ] Labels associados via for/id em todo campo
- [ ] Validacao visual via framework

**Tabelas:**
- [ ] Tabelas responsivas
- [ ] Valores alinhados a direita em monospace

**Dashboards:**
- [ ] Graficos com alternativa textual acessivel
- [ ] Cores de grafico consistentes com tokens

**Acessibilidade:**
- [ ] Contraste minimo WCAG AA (4.5:1)
- [ ] Navegacao por teclado funcional
- [ ] Sem informacao transmitida apenas por cor

**JavaScript:**
- [ ] Convencao JS do projeto respeitada
- [ ] addEventListener, sem onclick inline
- [ ] fetch() para AJAX
- [ ] Loading state em operacoes assincronas

## Processo

### Fase 1 — Carregar a regua

1. Ler a secao **Padroes minimos exigidos** deste documento.
2. Internalizar todas as regras com seus IDs, descricoes, exemplos e severidades (ERRO/AVISO).
3. Nao resumir nem recitar o documento de volta.

### Fase 2 — Identificar o PR aberto

1. Executar `gh pr list --state open --base develop --json number,title,headBranch --limit 1`.
2. Se houver mais de um PR aberto, listar todos e perguntar ao usuario qual auditar.
3. Se nao houver PR aberto, informar o usuario e encerrar.
4. Executar `gh pr diff <numero>` para obter o diff completo do PR.
5. Filtrar arquivos `.php` (templates com HTML), `.css`, `.js` do projeto.

### Fase 3 — Auditar arquivo por arquivo

Para cada arquivo alterado no PR:

1. Ler o arquivo completo (nao apenas o diff — contexto importa).
2. Comparar contra **cada regra** de `docs/padroes-ux-ui.md`, uma por uma, na ordem do documento.
3. Para cada violacao encontrada, registrar:
   - **Arquivo** e **linha(s)** onde ocorre
   - **ID da regra** violada (ex.: padroes-ux-ui.md, UI-012)
   - **Severidade** (ERRO ou AVISO)
   - **O que esta errado** — descricao concisa
   - **Como corrigir** — correcao especifica para aquele trecho
4. Se o arquivo nao viola nenhuma regra, registrar como aprovado.

### Fase 4 — Relatorio

Apresentar o relatorio ao usuario no formato padrao de auditoria.

### Fase 5 — Plano de correcoes

Se houver violacoes do tipo ERRO:

1. Listar as correcoes necessarias agrupadas por arquivo.
2. Ordenar por severidade (ERROs primeiro, AVISOs depois).
3. Perguntar ao usuario: "Quer que eu execute as correcoes agora?"

## Regras

- **Nunca alterar codigo durante a auditoria.** A skill e read-only ate o usuario pedir correcao explicitamente.
- **Nunca auditar arquivos fora do PR.** Apenas arquivos alterados no PR aberto.
- **Sempre referenciar o ID da regra violada.** O relatorio deve ser rastreavel ao documento de padroes.
- **Nunca inventar regras.** A regua e exclusivamente o `docs/padroes-ux-ui.md`.
- **Ser metodica e processual.** Cada arquivo e comparado contra cada regra, na ordem do documento, sem pular.
- **Fidelidade ao documento.** Se o codigo viola uma regra do documento, reportar. Se o documento nao cobre o caso, nao reportar.
- **Verificar consistencia com a identidade visual.** Cores devem usar as custom properties da marca, nunca hex direto.
- **Mostrar o relatorio completo antes de qualquer acao.** Nunca executar correcoes sem aprovacao explicita.
