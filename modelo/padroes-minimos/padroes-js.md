---
documento: padroes-js
versao: 2.1.0
criado: 2025-06-01
atualizado: 2026-04-16
total_regras: 37
severidades:
  erro: 21
  aviso: 16
stack: js
escopo: Todo código JavaScript em projetos da BGR — vanilla JS, frameworks, Node.js, scripts de build
aplica_a: ["todos"]
requer: []
substitui: ["padroes-js v2.0.0"]
---

# Padroes de JavaScript — BGR Software House

> Documento constitucional. Contrato de entrega entre a BGR e todo
> desenvolvedor que toca JavaScript nos nossos projetos.
> Codigo que viola regras ERRO nao e discutido — e devolvido.

---

## Como usar este documento

### Para o desenvolvedor

1. Leia este documento antes de escrever JavaScript em qualquer projeto BGR.
2. Use os IDs das regras (JS-001 a JS-037) para referenciar em PRs e code reviews.
3. Consulte o DoD no final antes de abrir qualquer Pull Request.

### Para o auditor (humano ou IA)

1. Leia o frontmatter para entender escopo e dependencias.
2. Audite o codigo contra cada regra por ID.
3. Classifique violacoes pela severidade definida neste documento.
4. Referencie violacoes pelo ID da regra (ex.: "viola JS-014").

### Para o Claude Code

1. Leia o frontmatter para identificar escopo e severidades.
2. Ao revisar codigo JS, verifique cada regra por ID.
3. Violacoes ERRO bloqueiam merge — reporte como bloqueantes.
4. Violacoes AVISO devem ser reportadas, mas aceitam justificativa escrita.
5. Referencie sempre pelo ID (ex.: "viola JS-027").

---

## Severidades

| Nivel | Significado | Acao |
|-------|-------------|------|
| **ERRO** | Violacao inegociavel | Bloqueia merge. Corrigir antes de review. |
| **AVISO** | Recomendacao forte | Deve ser justificada por escrito se ignorada. |

---

## 1. Principios fundamentais

### JS-001 — KISS: simplicidade primeiro [AVISO]

**Regra:** O codigo deve ser o mais simples possivel. Se existe uma forma direta de resolver, usar essa. Abstracoes, patterns e indirecoes so entram quando o problema exige.

**Verifica:** Grep por classes wrapper, factories ou adapters sem mais de um consumidor. Funcao com >1 nivel de indirection sem justificativa = violacao.

**Por que na BGR:** A BGR usa IA para gerar e revisar codigo. Codigo simples e previsivel e mais facil de gerar corretamente, revisar automaticamente e manter por times pequenos. Complexidade desnecessaria gera bugs que so aparecem em producao.

**Exemplo correto:**
```javascript
function estaVazio(valor) {
    return valor === '' || valor === null || valor === undefined;
}
```

**Exemplo incorreto:**
```javascript
function estaVazio(valor) {
    return new Validator(valor).check('empty').result();
}
```

---

### JS-002 — DRY: uma regra, um lugar [ERRO]

**Regra:** Uma logica e implementada em um unico ponto. Se o mesmo calculo ou validacao aparece em dois arquivos, extrair para um modulo compartilhado.

**Verifica:** Grep por blocos de codigo identicos ou quase identicos em arquivos distintos. Duplicacao >3 linhas de logica = violacao.

**Por que na BGR:** Times pequenos nao tem capacidade de manter logica duplicada sincronizada. Quando a IA gera codigo, duplicacao gera divergencia silenciosa — um ponto e atualizado, o outro nao. Bugs assim ja custaram horas de debug.

**Exemplo correto:**
```javascript
// utils/ui.js — funcao reutilizavel
function setLoading(btn, loading) {
    if (loading) {
        btn.disabled = true;
        btn.dataset.originalText = btn.innerHTML;
        btn.innerHTML = '<span class="spinner-border spinner-border-sm"></span> Processando...';
    } else {
        btn.disabled = false;
        btn.innerHTML = btn.dataset.originalText;
    }
}
```

**Exemplo incorreto:**
```javascript
// login.js — logica de loading copiada
btnLogin.disabled = true;
btnLogin.innerHTML = '<span class="spinner-border spinner-border-sm"></span> Processando...';

// cadastro.js — mesma logica duplicada
btnCadastro.disabled = true;
btnCadastro.innerHTML = '<span class="spinner-border spinner-border-sm"></span> Processando...';
```

---

### JS-003 — YAGNI: nao construa o que nao precisa agora [AVISO]

**Regra:** Nunca implementar funcoes, classes ou parametros pensando em "possibilidades futuras". Implementar estritamente o que o requisito atual exige.

**Verifica:** Funcao com parametros sem caller que os passe, ou branch de codigo sem teste que o exercite = violacao.

**Por que na BGR:** A BGR trabalha com escopo enxuto e entregas incrementais. Codigo especulativo gera manutencao de algo que ninguem usa. Quando a IA sugere abstracoes "para o futuro", o resultado e complexidade sem retorno.

**Exemplo correto:**
```javascript
// requisito: formatar valor em BRL
function formatarMoeda(valor) {
    return valor.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' });
}
```

**Exemplo incorreto:**
```javascript
// "e se um dia precisar de outra moeda?"
function formatarMoeda(valor, moeda, locale, casasDecimais, simboloAntes) {
    moeda = moeda || 'BRL';
    locale = locale || 'pt-BR';
    casasDecimais = casasDecimais !== undefined ? casasDecimais : 2;
    simboloAntes = simboloAntes !== undefined ? simboloAntes : true;
    // 30 linhas de logica que nunca sera usada
    return valor.toLocaleString(locale, { style: 'currency', currency: moeda });
}
```

---

### JS-004 — Separacao de responsabilidades [ERRO]

**Regra:** Cada arquivo JS tem um escopo claro. Um arquivo nunca mistura logica de formulario, manipulacao de DOM e comunicacao AJAX sem estrutura. Separar em funcoes com responsabilidade unica.

**Verifica:** Funcao com >1 responsabilidade (valida + envia + renderiza) = violacao. Cada funcao deve fazer uma coisa.

**Por que na BGR:** A IA gera e audita arquivos individualmente. Arquivos com responsabilidades misturadas sao mais dificeis de gerar corretamente e de revisar. Separacao clara permite que cada funcao seja testada e entendida isoladamente.

**Exemplo correto:**
```javascript
// funcoes separadas por responsabilidade
function validarFormulario(form) {
    var email = form.querySelector('[name="email"]').value;
    return email.includes('@');
}

function enviarFormulario(form) {
    var formData = new FormData(form);
    return fetch(ajaxUrl, { method: 'POST', body: formData });
}

function mostrarResultado(container, mensagem, tipo) {
    container.textContent = mensagem;
    container.className = 'alert alert-' + tipo;
}
```

**Exemplo incorreto:**
```javascript
// tudo misturado numa funcao so
form.addEventListener('submit', function (e) {
    e.preventDefault();
    var email = form.querySelector('[name="email"]').value;
    if (!email.includes('@')) {
        document.getElementById('alerta').innerHTML = '<div class="alert alert-danger">Email invalido</div>';
        return;
    }
    fetch(ajaxUrl, { method: 'POST', body: new FormData(form) })
        .then(function (r) { return r.json(); })
        .then(function (j) {
            document.getElementById('alerta').innerHTML = '<div class="alert alert-success">' + j.data + '</div>';
        });
});
```

---

### JS-005 — Lei de Demeter: fale so com seus vizinhos [AVISO]

**Regra:** Nao encadear chamadas que atravessam multiplos objetos. Acessar apenas propriedades e metodos do objeto imediato.

**Verifica:** Grep por cadeias com 3+ pontos consecutivos (ex.: `a.b.c.d`). Encadeamento >2 niveis sem variavel intermediaria = violacao.

**Por que na BGR:** Encadeamento profundo cria acoplamento invisivel. Quando a IA refatora uma parte do DOM ou de um objeto, encadeamentos longos quebram silenciosamente. Codigo com acesso direto e mais previsivel e mais facil de manter.

**Exemplo correto:**
```javascript
var navbarHeight = navbar.offsetHeight;
```

**Exemplo incorreto:**
```javascript
var height = document.querySelector('.container').firstChild.nextSibling.offsetHeight;
```

---

## 2. Estilo e nomenclatura

### JS-006 — Variaveis e funcoes em camelCase [ERRO]

**Regra:** Toda variavel e funcao deve usar camelCase. Sem excecao.

**Verifica:** Grep por `var [a-z]+_[a-z]` e `function [a-z]+_[a-z]`. snake_case em variavel ou funcao = violacao.

**Por que na BGR:** Consistencia de nomenclatura e critica quando a IA gera codigo. Se o padrao e unico e previsivel, o codigo gerado se integra sem friccao. camelCase e o padrao universal do ecossistema JavaScript.

**Exemplo correto:**
```javascript
var valorTotal = 0;
function calcularSaldo() {}
```

**Exemplo incorreto:**
```javascript
var valor_total = 0;
function calcular_saldo() {}
```

---

### JS-007 — Constantes em UPPER_SNAKE_CASE [AVISO]

**Regra:** Valores constantes que nao mudam durante a execucao devem usar UPPER_SNAKE_CASE.

**Verifica:** Grep por `var [a-z]` ou `const [a-z]` atribuido a valor literal fixo. Constante em camelCase = violacao.

**Por que na BGR:** Constantes em UPPER_SNAKE_CASE sao visivelmente distintas de variaveis. Em code review (humano ou IA), identificar imediatamente o que e constante evita erros de reatribuicao.

**Exemplo correto:**
```javascript
var MAX_TENTATIVAS = 5;
var TEMPO_EXPIRACAO_MS = 600000;
```

**Exemplo incorreto:**
```javascript
var maxTentativas = 5;
var tempoExpiracaoMs = 600000;
```

---

### JS-008 — Nomes descritivos, sem abreviacoes obscuras [AVISO]

**Regra:** Variaveis, funcoes e parametros devem ter nomes que descrevem seu proposito. Abreviacoes so sao aceitas quando universalmente conhecidas (url, id, btn).

**Verifica:** Variavel de 1-2 caracteres (exceto `i`, `j`, `e`, `_`) ou abreviacao nao-universal = violacao.

**Por que na BGR:** A IA gera codigo que sera lido por humanos com contexto limitado. Nomes obscuros exigem que o leitor deduza o significado — isso e tempo perdido em times pequenos. Use o prefixo de namespace do projeto nos seletores de DOM.

**Exemplo correto:**
```javascript
var formularioCadastro = document.getElementById('proj-cadastro-form');
var botaoEnviar = document.getElementById('proj-btn-cadastrar');
```

**Exemplo incorreto:**
```javascript
var fc = document.getElementById('proj-cadastro-form');
var be = document.getElementById('proj-btn-cadastrar');
```

---

### JS-009 — Funcoes nomeadas, nunca anonimas soltas [AVISO]

**Regra:** Funcoes devem ter nomes descritivos para facilitar debugging e stack traces. Excecao: callbacks curtos de uma linha em `.then()` ou `.forEach()`.

**Verifica:** Grep por `function\s*\(` (anonima) com corpo >1 linha. Callback anonimo com >1 linha = violacao.

**Por que na BGR:** Stack traces com funcoes anonimas sao inuteis para debug. Na BGR, onde a IA gera codigo e humanos debugam em producao, nomes claros nas funcoes sao a diferenca entre resolver um bug em 5 minutos ou em 2 horas.

**Exemplo correto:**
```javascript
document.addEventListener('DOMContentLoaded', inicializarLogin);

function inicializarLogin() {
    // logica de inicializacao
}
```

**Exemplo incorreto:**
```javascript
document.addEventListener('DOMContentLoaded', function () {
    // 50 linhas de codigo anonimo
    // stack trace vai mostrar "anonymous" — inutil
});
```

---

## 3. Estrutura de arquivos

### JS-010 — Um arquivo por pagina/funcionalidade [ERRO]

**Regra:** Cada arquivo JS corresponde a uma pagina ou funcionalidade isolada. Nunca um arquivo monolitico com toda a logica da aplicacao.

**Verifica:** Arquivo JS com >300 linhas ou com >2 responsabilidades distintas = violacao. Inspecionar estrutura de diretorio.

**Por que na BGR:** Arquivos pequenos e focados sao mais faceis de gerar, revisar e manter. A IA trabalha melhor com contexto limitado e claro. Um arquivo monolitico com 2000 linhas e impossivel de revisar com qualidade.

**Exemplo correto:**
```
assets/js/
├── app.js                  # comportamento global (navbar, scroll)
├── auth/
│   ├── login.js            # logica da pagina de login
│   ├── cadastro.js         # logica da pagina de cadastro
│   └── resetar-senha.js    # logica da pagina de reset
└── dashboard/
    ├── resumo.js           # logica do painel principal
    └── relatorios.js       # logica de relatorios
```

**Exemplo incorreto:**
```
assets/js/
└── app.js                  # 3000 linhas com tudo junto
```

---

### JS-011 — Carregamento condicional de scripts [ERRO]

**Regra:** Cada arquivo JS deve ser carregado apenas na pagina ou contexto que o utiliza. Nunca carregar todos os scripts em todas as paginas. No WordPress, usar `wp_enqueue_script()` com condicao de pagina. Em outros contextos, usar a estrategia equivalente (import dinamico, lazy loading, rotas).

**Verifica:** Grep por `wp_enqueue_script` sem condicional de pagina, ou `<script>` global sem lazy/condicional = violacao.

**Por que na BGR:** Carregar scripts desnecessarios aumenta o tempo de carregamento e o risco de erros em paginas que nao precisam daquele codigo. Em projetos BGR, performance importa porque os usuarios finais frequentemente acessam por conexoes moveis.

**Exemplo correto:**
```php
// WordPress — carregamento condicional
if (is_page('login')) {
    wp_enqueue_script('login-js', get_template_directory_uri() . '/assets/js/auth/login.js', [], '1.0', true);
}
```

```javascript
// SPA/Node — import dinamico
if (rota === '/dashboard') {
    import('./dashboard/resumo.js').then(function (modulo) {
        modulo.inicializar();
    });
}
```

**Exemplo incorreto:**
```php
// Carrega TUDO em TODAS as paginas
wp_enqueue_script('app', get_template_directory_uri() . '/assets/js/app.js');
wp_enqueue_script('login', get_template_directory_uri() . '/assets/js/auth/login.js');
wp_enqueue_script('cadastro', get_template_directory_uri() . '/assets/js/auth/cadastro.js');
wp_enqueue_script('dashboard', get_template_directory_uri() . '/assets/js/dashboard/resumo.js');
```

---

### JS-012 — Padrao de inicializacao encapsulada [ERRO]

**Regra:** Todo arquivo JS de frontend deve encapsular sua logica. No navegador, usar `document.addEventListener('DOMContentLoaded', ...)` ou IIFE. Em Node.js, usar modulos (module.exports / export). Nunca poluir o escopo global.

**Verifica:** Arquivo sem `DOMContentLoaded`, IIFE ou `module.exports` no topo = violacao. `var` no escopo global fora de encapsulamento = violacao.

**Por que na BGR:** Variaveis e funcoes no escopo global colidem entre scripts. Na BGR, onde multiplos arquivos JS coexistem na mesma pagina, poluicao do escopo global causa bugs intermitentes extremamente dificeis de diagnosticar.

**Exemplo correto:**
```javascript
// Frontend — DOMContentLoaded
document.addEventListener('DOMContentLoaded', function inicializarLogin() {
    var form = document.getElementById('proj-login-form');
    if (!form) return;
    // logica encapsulada
});
```

```javascript
// Node.js — modulo
function processarDados(dados) {
    // logica encapsulada
}
module.exports = { processarDados: processarDados };
```

**Exemplo incorreto:**
```javascript
// Codigo solto no escopo global
var form = document.getElementById('proj-login-form');
form.addEventListener('submit', enviarLogin);
var resultado = null;
```

---

### JS-013 — Guard clause no inicio [ERRO]

**Regra:** Se o elemento principal da pagina ou o recurso necessario nao existe, retornar imediatamente. Nunca executar logica contra elementos que podem ser null.

**Verifica:** Grep por `getElementById`/`querySelector` sem `if (!el) return` nas linhas seguintes = violacao.

**Por que na BGR:** Na BGR, scripts podem ser carregados em paginas inesperadas (cache, erro de condicao). O guard clause evita erros `Cannot read property of null` que geram ruido no log e confundem o debug.

**Exemplo correto:**
```javascript
document.addEventListener('DOMContentLoaded', function inicializarLogin() {
    var form = document.getElementById('proj-login-form');
    if (!form) return; // guard clause — sai se o elemento nao existe

    // resto da logica, seguro que form existe
    form.addEventListener('submit', handleSubmit);
});
```

**Exemplo incorreto:**
```javascript
document.addEventListener('DOMContentLoaded', function () {
    var form = document.getElementById('proj-login-form');
    // nenhum guard clause — se form for null, a linha abaixo explode
    form.addEventListener('submit', handleSubmit);
});
```

---

## 4. Manipulacao de DOM

### JS-014 — Selecao por ID ou classe semantica, nunca por tag [ERRO]

**Regra:** Usar `getElementById` ou `querySelector` com seletores semanticos. Nunca selecionar por tag generica (`div`, `p`, `span`).

**Verifica:** Grep por `querySelector('div')`, `querySelector('p')`, `querySelectorAll('span')` e similares sem classe/ID = violacao.

**Por que na BGR:** Selecao por tag e fragil — qualquer mudanca no HTML quebra o JS. Na BGR, onde a IA gera tanto HTML quanto JS, seletores semanticos criam um contrato claro entre markup e comportamento.

**Exemplo correto:**
```javascript
var alerta = document.getElementById('proj-login-alerta');
var cards = document.querySelectorAll('.proj-benefit-card');
```

**Exemplo incorreto:**
```javascript
var divs = document.querySelectorAll('div');
var paragrafo = document.querySelector('p');
```

---

### JS-015 — IDs e classes com prefixo de namespace do projeto [AVISO]

**Regra:** Elementos manipulados por JS devem usar o prefixo de namespace definido pelo projeto para evitar colisao com bibliotecas externas ou outros scripts.

**Verifica:** Grep por `getElementById` e `querySelector` cujo seletor nao comeca com o prefixo do projeto = violacao.

**Por que na BGR:** A BGR usa Bootstrap e potencialmente outros scripts de terceiros. Sem prefixo, IDs genericos como `login-form` ou `submit` colidem com classes do framework ou outros plugins. Cada projeto BGR define seu prefixo (ex.: `proj-`, `app-`, `dash-`).

**Exemplo correto:**
```html
<!-- prefixo do projeto evita colisao -->
<form id="proj-login-form">
<button id="proj-btn-cadastrar">
```

**Exemplo incorreto:**
```html
<!-- pode colidir com Bootstrap ou outros scripts -->
<form id="login-form">
<button id="submit">
```

---

### JS-016 — addEventListener, nunca onclick inline [ERRO]

**Regra:** Eventos devem ser registrados via `addEventListener`. Nunca usar atributos `onclick`, `onsubmit` ou similares no HTML.

**Verifica:** Grep por `onclick=`, `onsubmit=`, `onchange=` e similares em arquivos HTML/PHP = violacao.

**Por que na BGR:** Eventos inline misturam HTML e JS, quebrando separacao de responsabilidades. Alem disso, Content Security Policy (CSP) restritiva bloqueia handlers inline — e a BGR deve sempre usar CSP restritiva em producao.

**Exemplo correto:**
```javascript
document.getElementById('proj-btn-enviar').addEventListener('click', handleClick);
```

**Exemplo incorreto:**
```html
<button onclick="handleClick()">Enviar</button>
```

---

### JS-017 — Criar elementos via DOM API, nunca innerHTML para dados dinamicos [ERRO]

**Regra:** Para inserir dados dinamicos do usuario, usar `textContent` ou DOM API (`createElement`, `appendChild`). `innerHTML` so e aceitavel para templates estaticos sem dados do usuario.

**Verifica:** Grep por `innerHTML\s*=` seguido de variavel (nao string literal estatica) = violacao.

**Por que na BGR:** `innerHTML` com dados do usuario e vetor de XSS. Na BGR, onde aplicacoes lidam com dados financeiros e pessoais, XSS e inaceitavel. A regra e simples: dado do usuario sempre via `textContent`.

**Exemplo correto:**
```javascript
// dado do usuario — textContent
elemento.textContent = mensagemDoUsuario;

// template estatico — innerHTML aceitavel
container.innerHTML = '<span class="spinner-border spinner-border-sm"></span>';
```

**Exemplo incorreto:**
```javascript
// dado do usuario via innerHTML — vetor de XSS
elemento.innerHTML = resposta.mensagem;
```

---

## 5. Comunicacao AJAX

### JS-018 — fetch() para toda comunicacao, nunca XMLHttpRequest [ERRO]

**Regra:** Toda comunicacao assíncrona deve usar `fetch()`. XMLHttpRequest e proibido.

**Verifica:** Grep por `XMLHttpRequest`, `new XMLHttpRequest`, `$.ajax`, `$.get`, `$.post` = violacao.

**Por que na BGR:** `fetch()` e a API moderna, com interface baseada em Promises. A IA gera codigo com `fetch()` de forma mais previsivel e consistente. XMLHttpRequest e verboso, propenso a erros e nao vale a manutencao.

**Exemplo correto:**
```javascript
fetch(ajaxUrl, {
    method: 'POST',
    body: formData
})
    .then(function (resp) { return resp.json(); })
    .then(function (json) { /* tratar resposta */ });
```

**Exemplo incorreto:**
```javascript
var xhr = new XMLHttpRequest();
xhr.open('POST', url);
xhr.onreadystatechange = function () { /* ... */ };
xhr.send(formData);
```

---

### JS-019 — Nonce ou token obrigatorio em toda requisicao AJAX [ERRO]

**Regra:** Toda requisicao AJAX deve incluir um token de autenticacao/verificacao (nonce no WordPress, CSRF token em outros frameworks). Nunca hardcodar tokens no HTML.

**Verifica:** Grep por chamadas `fetch()` sem `nonce`, `csrf`, `token` ou `_wpnonce` no body/headers = violacao. Grep por token hardcoded em string literal = violacao.

**Por que na BGR:** Requisicoes sem verificacao de origem permitem CSRF. Na BGR, onde aplicacoes lidam com dados financeiros, toda requisicao deve provar que veio de uma sessao legitima. O token deve ser injetado pelo backend (ex.: `wp_localize_script()`, meta tag, variavel de template).

**Exemplo correto:**
```javascript
// nonce injetado pelo backend — nunca hardcoded
var formData = new FormData();
formData.append('action', 'proj_login');
formData.append('nonce', appConfig.nonce);
```

**Exemplo incorreto:**
```javascript
// nonce hardcoded — invalida a protecao
formData.append('nonce', 'abc123xyz');
```

---

### JS-020 — Action/endpoint com prefixo de namespace [ERRO]

**Regra:** Toda action AJAX ou nome de endpoint deve usar o prefixo de namespace do projeto para evitar colisao. No WordPress, prefixar a action. Em APIs REST, usar namespace na URL.

**Verifica:** Grep por `'action',` seguido de string sem prefixo do projeto = violacao. Endpoint REST sem namespace na URL = violacao.

**Por que na BGR:** Sem prefixo, actions como `login` ou `cadastrar` colidem com outros plugins ou modulos. Na BGR, cada projeto define seu namespace e o usa consistentemente em todo o stack.

**Exemplo correto:**
```javascript
// WordPress — action com prefixo do projeto
formData.append('action', 'proj_cadastrar');

// REST API — namespace na URL
fetch('/api/proj/v1/cadastrar', { method: 'POST', body: formData });
```

**Exemplo incorreto:**
```javascript
// Sem prefixo — colisao garantida em ambientes com multiplos modulos
formData.append('action', 'cadastrar');
```

---

### JS-021 — Tratamento de erros em toda requisicao [ERRO]

**Regra:** Toda chamada `fetch()` deve tratar tres caminhos: sucesso, erro de negocio (`json.success === false` ou status HTTP 4xx/5xx) e erro de rede (`.catch()`).

**Verifica:** Grep por `fetch(` e verificar se a cadeia inclui `.catch(`. Fetch sem `.catch()` = violacao. Fetch sem branch de erro de negocio = violacao.

**Por que na BGR:** Requisicoes sem tratamento de erro deixam o usuario sem feedback. Na BGR, onde a experiencia do usuario e prioridade, nunca e aceitavel que uma operacao falhe silenciosamente. O usuario sempre deve saber o que aconteceu.

**Exemplo correto:**
```javascript
fetch(url, { method: 'POST', body: formData })
    .then(function (resp) { return resp.json(); })
    .then(function (json) {
        if (json.success) {
            mostrarAlerta('Operacao realizada com sucesso.', 'success');
        } else {
            mostrarAlerta(json.data.mensagem, 'danger');
        }
    })
    .catch(function () {
        mostrarAlerta('Erro de conexao. Tente novamente.', 'danger');
    });
```

**Exemplo incorreto:**
```javascript
fetch(url, { method: 'POST', body: formData })
    .then(function (resp) { return resp.json(); })
    .then(function (json) {
        // assume que sempre da certo — sem catch, sem tratamento de erro
        mostrarAlerta(json.data.mensagem, 'success');
    });
```

---

### JS-022 — FormData para envio ao backend, nunca JSON manual sem necessidade [AVISO]

**Regra:** Preferir `FormData` para envio de formularios. JSON manual so quando a API exige explicitamente `application/json`. No WordPress, `FormData` e obrigatorio para `admin-ajax.php`.

**Verifica:** Grep por `JSON.stringify` em fetch de formulario quando `FormData` resolveria = violacao. `admin-ajax.php` sem `FormData` = violacao.

**Por que na BGR:** `FormData` serializa automaticamente campos de formulario e suporta upload de arquivos sem configuracao extra. JSON manual exige `JSON.stringify`, headers explícitos e parsing no backend — complexidade desnecessaria para a maioria dos casos na BGR.

**Exemplo correto:**
```javascript
var formData = new FormData(document.getElementById('proj-form'));
formData.append('action', 'proj_salvar');
fetch(ajaxUrl, { method: 'POST', body: formData });
```

**Exemplo incorreto:**
```javascript
// JSON manual quando FormData resolveria
fetch(ajaxUrl, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ action: 'proj_salvar', nome: nome, email: email })
});
```

---

## 6. Feedback visual e UX

### JS-023 — Loading state em toda operacao assincrona [ERRO]

**Regra:** Enquanto uma operacao assincrona esta em andamento, o elemento que disparou deve ficar desabilitado e exibir indicacao visual de carregamento. Impede cliques duplos e informa o usuario.

**Verifica:** Grep por `fetch(` e verificar se o botao/elemento e desabilitado antes e reabilitado no `.finally()`. Fetch sem `disabled = true` pre-envio = violacao.

**Por que na BGR:** Cliques duplos em operacoes financeiras (transferencias, lancamentos) causam duplicacao de registros. Na BGR, onde aplicacoes lidam com dinheiro, loading state e seguranca, nao e cosmetico.

**Exemplo correto:**
```javascript
function setLoading(btn, loading) {
    if (loading) {
        btn.disabled = true;
        btn.dataset.originalText = btn.innerHTML;
        btn.innerHTML = '<span class="spinner-border spinner-border-sm"></span> Processando...';
    } else {
        btn.disabled = false;
        btn.innerHTML = btn.dataset.originalText;
    }
}

// uso
setLoading(botao, true);
fetch(url, { method: 'POST', body: formData })
    .then(function (resp) { return resp.json(); })
    .then(function (json) { /* tratar */ })
    .catch(function () { /* tratar */ })
    .finally(function () { setLoading(botao, false); });
```

**Exemplo incorreto:**
```javascript
// nenhum loading state — usuario clica 5 vezes
fetch(url, { method: 'POST', body: formData })
    .then(function (resp) { return resp.json(); })
    .then(function (json) { /* tratar */ });
```

---

### JS-024 — Feedback em toda acao do usuario [ERRO]

**Regra:** Toda acao do usuario deve produzir feedback visual: alerta para erros, mensagem de sucesso, ou mudanca de estado na UI. O usuario nunca deve ficar sem saber o resultado de uma acao.

**Verifica:** Cada handler de acao (submit, click, etc.) deve ter chamada de feedback visual (alert, toast, classe CSS). Handler sem feedback = violacao.

**Por que na BGR:** Usuarios da BGR sao pessoas comuns, nao tecnicos. Se uma acao nao produz feedback, o usuario repete — gerando duplicacoes, frustracoes e chamados de suporte. Feedback visual e obrigatorio, nao opcional.

**Exemplo correto:**
```javascript
function mostrarAlerta(container, mensagem, tipo) {
    container.textContent = mensagem;
    container.className = 'alert alert-' + tipo;
    container.classList.remove('d-none');
}

// apos sucesso
mostrarAlerta(alertaContainer, 'Cadastro realizado com sucesso!', 'success');

// apos erro
mostrarAlerta(alertaContainer, 'Email ja cadastrado.', 'danger');
```

**Exemplo incorreto:**
```javascript
// formulario envia, mas nenhum feedback visual
fetch(url, { method: 'POST', body: formData })
    .then(function (resp) { return resp.json(); })
    .then(function (json) {
        console.log(json); // so no console — usuario nao ve nada
    });
```

---

### JS-025 — Validacao no cliente como UX, nao como seguranca [AVISO]

**Regra:** Validacao no JS serve para feedback rapido ao usuario. A validacao real sempre acontece no backend. Nunca confiar apenas na validacao do cliente.

**Verifica:** Verificar se o backend correspondente replica toda validacao feita no JS. Validacao presente so no JS = violacao.

**Por que na BGR:** Validacao client-side e facilmente burlada (DevTools, requests diretos). Na BGR, onde dados financeiros e pessoais estao em jogo, a seguranca mora no backend. O JS so melhora a experiencia do usuario.

**Exemplo correto:**
```javascript
// valida no JS para UX rapida
if (senha.length < 8) {
    mostrarAlerta(container, 'A senha deve ter pelo menos 8 caracteres.', 'danger');
    return;
}
// envia pro backend que TAMBEM valida
enviarFormulario(form);
```

**Exemplo incorreto:**
```javascript
// valida so no JS — backend aceita qualquer coisa
if (senha.length >= 8) {
    enviarFormulario(form);
}
// backend nao valida o tamanho da senha — falha de seguranca
```

---

## 7. Seguranca

### JS-026 — Nunca armazenar dados sensiveis no cliente [ERRO]

**Regra:** Tokens de autenticacao, senhas, chaves de API nunca ficam em `localStorage`, `sessionStorage` ou cookies acessiveis por JS. Dados sensiveis em memoria (variavel JS) morrem com a pagina — e esse e o comportamento correto.

**Verifica:** Grep por `localStorage.setItem`, `sessionStorage.setItem`, `document.cookie` com token/senha/chave = violacao.

**Por que na BGR:** `localStorage` e `sessionStorage` sao acessiveis por qualquer script na pagina, incluindo scripts de terceiros comprometidos. Na BGR, onde aplicacoes lidam com dados financeiros, vazamento de token e incidente grave.

**Exemplo correto:**
```javascript
// token em memoria — morre com a pagina
var sessionToken = null;

function receberToken(token) {
    sessionToken = token;
    // usa na verificacao, nunca persiste
}
```

**Exemplo incorreto:**
```javascript
// token persistido — acessivel por qualquer script na pagina
localStorage.setItem('token', sessionToken);
// ou
document.cookie = 'token=' + sessionToken;
```

---

### JS-027 — Sem eval(), Function() ou innerHTML com dados do usuario [ERRO]

**Regra:** Nunca executar codigo dinamico com `eval()` ou `new Function()`. Nunca inserir dados do usuario via `innerHTML`. Essas praticas sao vetores de XSS.

**Verifica:** Grep por `eval(`, `new Function(`, `innerHTML\s*=` com dados nao-estaticos = violacao. Tolerancia zero.

**Por que na BGR:** XSS permite que um atacante execute codigo no navegador do usuario, roubando sessoes e dados. Na BGR, com dados financeiros e pessoais, XSS e inaceitavel. A regra e absoluta: sem eval, sem Function, sem innerHTML com dados do usuario.

**Exemplo correto:**
```javascript
// dado do usuario — textContent
var nomeUsuario = resposta.nome;
document.getElementById('proj-nome').textContent = nomeUsuario;

// logica condicional — sem eval
var acoes = {
    salvar: salvarRegistro,
    excluir: excluirRegistro
};
if (acoes[acao]) {
    acoes[acao]();
}
```

**Exemplo incorreto:**
```javascript
// eval — executa codigo arbitrario
eval('var resultado = ' + respostaDoServidor);

// innerHTML com dados do usuario — XSS
document.getElementById('proj-nome').innerHTML = resposta.nome;

// Function — mesmo problema que eval
var fn = new Function('return ' + dadoDoUsuario);
```

---

### JS-028 — Dados do backend sao suspeitos [AVISO]

**Regra:** Mesmo dados vindos do proprio backend devem ser inseridos com `textContent`, nunca com `innerHTML`. O banco pode ter sido comprometido ou conter dados maliciosos inseridos por outro vetor.

**Verifica:** Grep por `innerHTML\s*=.*json` ou `innerHTML\s*=.*resposta` ou `innerHTML\s*=.*data` = violacao. Qualquer dado dinamico via innerHTML = violacao.

**Por que na BGR:** Defesa em profundidade. Na BGR, se o banco for comprometido e dados maliciosos forem inseridos, o frontend nao deve amplificar o ataque renderizando HTML malicioso. `textContent` neutraliza qualquer payload.

**Exemplo correto:**
```javascript
// dados do backend — ainda assim, textContent
var nomeDoBackend = json.data.nome;
document.getElementById('proj-usuario-nome').textContent = nomeDoBackend;
```

**Exemplo incorreto:**
```javascript
// confia cegamente no backend
document.getElementById('proj-usuario-nome').innerHTML = json.data.nome;
// se o banco tiver <script>alert('xss')</script>, executa
```

---

## 8. Compatibilidade e performance

### JS-029 — JavaScript moderno sem transpilacao desnecessaria [AVISO]

**Regra:** Preferir vanilla JS compativel com navegadores modernos. Features ES6+ (`const`, `let`, arrow functions, template literals) sao aceitaveis. Se o projeto nao usa build step, o codigo deve rodar diretamente no navegador. Se usa build step, documentar no CLAUDE.md do projeto.

**Verifica:** Grep por `await`, `?.`, `??` em projeto sem build step = violacao. Verificar CLAUDE.md do projeto pra confirmar se build step existe.

**Por que na BGR:** A BGR prefere simplicidade. Projetos sem build step eliminam uma camada de complexidade (Webpack, Babel, configs). Quando o projeto exige build step, a decisao deve ser explicita e documentada — nunca implícita.

**Exemplo correto:**
```javascript
// ES6+ em projeto sem build step — funciona em navegadores modernos
var mensagem = 'Operacao concluida';
var items = lista.map(function (item) { return item.nome; });
```

**Exemplo incorreto:**
```javascript
// Syntax que exige transpilacao sem build step configurado
const resultado = await fetch(url);
// optional chaining sem verificar suporte
var nome = usuario?.perfil?.nome;
```

**Excecoes:** Projetos com build step documentado (Next.js, Vite, etc.) podem usar qualquer feature suportada pelo transpilador.

---

### JS-030 — Sem bibliotecas externas desnecessarias [ERRO]

**Regra:** Bibliotecas externas so entram quando justificadas por complexidade que nao vale reimplementar. jQuery e proibido. Cada dependencia deve ser aprovada e documentada.

**Verifica:** Grep por `jquery`, `$.(`, `$.ajax` = violacao. Grep por `<script src=` externo nao documentado no CLAUDE.md do projeto = violacao.

**Por que na BGR:** Cada dependencia e uma superficie de ataque, um ponto de manutencao e um risco de supply chain. Na BGR, com times pequenos, menos dependencias significam menos coisas para atualizar, auditar e manter. Vanilla JS resolve 90% dos casos.

**Exemplo correto:**
```javascript
// Vanilla JS — sem dependencia
var elemento = document.getElementById('proj-container');
elemento.classList.add('ativo');
elemento.addEventListener('click', handleClick);
```

**Exemplo incorreto:**
```javascript
// jQuery para algo que vanilla JS resolve
$('#proj-container').addClass('ativo').on('click', handleClick);
```

**Excecoes:** Bibliotecas especializadas (ex.: gerador de QR code, graficos complexos) sao aceitaveis quando a reimplementacao nao faz sentido economico.

---

### JS-031 — Event delegation para listas dinamicas [AVISO]

**Regra:** Para elementos adicionados/removidos dinamicamente, usar delegacao de eventos no container pai. Nunca registrar listeners em cada item individual.

**Verifica:** Grep por `.forEach(` + `addEventListener` dentro do loop em listas dinamicas = violacao. Verificar se o listener esta no container pai.

**Por que na BGR:** Listas dinamicas (tabelas, cards, resultados de busca) mudam constantemente. Registrar listeners em cada item cria memory leaks e elementos orfaos. Delegacao e mais performatica e funciona com elementos adicionados depois da inicializacao.

**Exemplo correto:**
```javascript
// delegacao — um listener no container
document.getElementById('proj-tabela').addEventListener('click', function (e) {
    var btn = e.target.closest('[data-action]');
    if (!btn) return;
    var acao = btn.dataset.action;
    var id = btn.dataset.id;
    // tratar acao
});
```

**Exemplo incorreto:**
```javascript
// listener em cada elemento — quebra com itens adicionados depois
linhas.forEach(function (linha) {
    linha.querySelector('.btn-editar').addEventListener('click', handleEditar);
    linha.querySelector('.btn-excluir').addEventListener('click', handleExcluir);
});
```

---

### JS-032 — Sem polling, preferir eventos [AVISO]

**Regra:** Nunca usar `setInterval` para verificar mudancas de estado. Usar eventos do DOM, callbacks de fetch, MutationObserver ou WebSockets quando necessario.

**Verifica:** Grep por `setInterval` = violacao (exceto timers de UI como countdown). Cada ocorrencia deve ter justificativa documentada.

**Por que na BGR:** Polling desperdiça CPU e bateria, especialmente em dispositivos moveis. Na BGR, onde usuarios acessam por celular, performance do cliente importa. Eventos sao mais eficientes e respondem instantaneamente.

**Exemplo correto:**
```javascript
// evento — reage quando acontece
document.getElementById('proj-input').addEventListener('input', function (e) {
    atualizarPreview(e.target.value);
});

// MutationObserver para mudancas no DOM
var observer = new MutationObserver(function (mutations) {
    // reagir a mudancas
});
observer.observe(container, { childList: true });
```

**Exemplo incorreto:**
```javascript
// polling — verifica a cada segundo se algo mudou
setInterval(function () {
    var valor = document.getElementById('proj-input').value;
    if (valor !== ultimoValor) {
        atualizarPreview(valor);
        ultimoValor = valor;
    }
}, 1000);
```

---

## 9. Formatacao

### JS-033 — Indentacao com 4 espacos [ERRO]

**Regra:** Toda indentacao deve usar 4 espacos. Tabs sao proibidos.

**Verifica:** Grep por `\t` (tab literal) em arquivos JS = violacao. Verificar com editor/linter.

**Por que na BGR:** Consistencia de indentacao e obrigatoria para que diffs sejam limpos e code review (humano ou IA) seja eficiente. 4 espacos e o padrao da BGR em todos os dominios (PHP, JS, CSS) — um unico padrao elimina discussao.

**Exemplo correto:**
```javascript
function calcularTotal(itens) {
    var total = 0;
    itens.forEach(function (item) {
        total += item.valor;
    });
    return total;
}
```

**Exemplo incorreto:**
```javascript
function calcularTotal(itens) {
	var total = 0; // tab em vez de 4 espacos
	itens.forEach(function (item) {
		total += item.valor;
	});
	return total;
}
```

---

### JS-034 — Chaves na mesma linha [AVISO]

**Regra:** Chaves de abertura ficam na mesma linha da declaracao. Nunca na linha seguinte.

**Verifica:** Grep por `^\s*\{` em linha isolada apos `if`, `else`, `function`, `for`, `while` = violacao.

**Por que na BGR:** Estilo K&R e o padrao do ecossistema JavaScript e o que a IA gera por padrao. Manter o mesmo estilo que a IA produz naturalmente reduz friccao em code review e evita reformatacoes desnecessarias.

**Exemplo correto:**
```javascript
if (condicao) {
    // corpo
}

function minhaFuncao() {
    // corpo
}
```

**Exemplo incorreto:**
```javascript
if (condicao)
{
    // corpo
}

function minhaFuncao()
{
    // corpo
}
```

---

### JS-035 — Maximo 120 caracteres por linha [AVISO]

**Regra:** Linhas com mais de 120 caracteres devem ser quebradas com alinhamento logico.

**Verifica:** `grep -P '.{121,}' *.js`. Linha >120 caracteres = violacao.

**Por que na BGR:** Linhas longas dificultam code review em telas divididas e em diffs do GitHub. Na BGR, onde review acontece em telas variadas (incluindo laptops pequenos), 120 caracteres e o limite pratico.

**Exemplo correto:**
```javascript
var mensagem = montarMensagem(
    usuario.nome,
    usuario.email,
    'Sua operacao foi concluida com sucesso.'
);
```

**Exemplo incorreto:**
```javascript
var mensagem = montarMensagem(usuario.nome, usuario.email, 'Sua operacao foi concluida com sucesso.', new Date().toISOString(), true);
```

---

### JS-036 — Ponto e virgula obrigatorio [ERRO]

**Regra:** Toda instrucao termina com `;`. Nunca depender de ASI (Automatic Semicolon Insertion).

**Verifica:** Grep por linhas de instrucao (atribuicao, chamada, return) que nao terminam com `;` = violacao.

**Por que na BGR:** ASI tem regras contra-intuitivas que causam bugs sutis (ex.: return seguido de quebra de linha). Na BGR, onde a IA gera codigo e humanos revisam, explicitar o ponto e virgula elimina uma classe inteira de bugs.

**Exemplo correto:**
```javascript
var nome = 'BGR Software House';
var valor = 1500;
var itens = [1, 2, 3];
```

**Exemplo incorreto:**
```javascript
var nome = 'BGR Software House'
var valor = 1500
var itens = [1, 2, 3]
```

---

### JS-037 — Aspas simples para strings [AVISO]

**Regra:** Preferir aspas simples para strings. Template literals (backticks) apenas quando necessaria interpolacao ou strings multilinhas.

**Verifica:** Grep por strings com aspas duplas (`"..."`) sem necessidade = violacao. Backtick sem `${` = violacao.

**Por que na BGR:** Um unico padrao de aspas elimina inconsistencia visual. Aspas simples sao o padrao mais comum em projetos JavaScript e o que a IA tende a gerar. Manter consistencia reduz ruido em diffs.

**Exemplo correto:**
```javascript
var mensagem = 'Operacao realizada com sucesso.';
var url = '/api/v1/usuarios';

// template literal — justificado por interpolacao
var saudacao = `Ola, ${usuario.nome}!`;
```

**Exemplo incorreto:**
```javascript
// aspas duplas sem necessidade
var mensagem = "Operacao realizada com sucesso.";
var url = "/api/v1/usuarios";

// template literal sem interpolacao — desnecessario
var nome = `BGR Software House`;
```

---

## Definition of Done — Checklist de entrega

> PR que nao cumpre o DoD nao entra em review. E devolvido.

| # | Item | Regras | Verificacao |
|---|------|--------|-------------|
| 1 | Ponto e virgula em todas as instrucoes | JS-036 | Buscar linhas sem `;` no final |
| 2 | Indentacao com 4 espacos, sem tabs | JS-033 | Verificar com editor/linter |
| 3 | Sem `eval()`, `Function()` ou `innerHTML` com dados do usuario | JS-027 | Grep por `eval(`, `new Function(`, `innerHTML =` |
| 4 | Sem dados sensiveis em localStorage/sessionStorage | JS-026 | Grep por `localStorage`, `sessionStorage` |
| 5 | Nonce/token em toda requisicao AJAX | JS-019 | Verificar toda chamada `fetch()` |
| 6 | Tratamento de erro (sucesso + erro + catch) em todo fetch | JS-021 | Verificar `.catch()` em toda cadeia de fetch |
| 7 | Loading state em operacoes assincronas | JS-023 | Verificar `disabled` e spinner em botoes de submit |
| 8 | Feedback visual em toda acao do usuario | JS-024 | Testar manualmente cada fluxo |
| 9 | Guard clause no inicio de cada inicializacao | JS-013 | Verificar `if (!elemento) return;` |
| 10 | Sem bibliotecas externas nao aprovadas | JS-030 | Verificar imports e scripts externos |
| 11 | Variaveis em camelCase, constantes em UPPER_SNAKE_CASE | JS-006, JS-007 | Inspecao visual |
| 12 | Funcoes nomeadas (sem anonimas longas) | JS-009 | Verificar `function () {` com mais de 1 linha |
| 13 | DOMContentLoaded ou encapsulamento equivalente | JS-012 | Verificar inicio do arquivo |
| 14 | Seletores semanticos com prefixo do projeto | JS-014, JS-015 | Verificar `querySelector` e `getElementById` |
| 15 | Linhas com maximo 120 caracteres | JS-035 | Verificar com editor/linter |
