---
name: auditar-js
description: Audita codigo JavaScript do PR aberto contra as regras definidas em docs/padroes-js.md. Cobre principios, nomenclatura, DOM, AJAX, seguranca, UX e formatacao. Trigger manual apenas.
---

# /auditar-js — Auditora de padroes JavaScript

Le as regras de `docs/padroes-js.md`, identifica os arquivos JavaScript alterados no PR aberto (nao mergeado) e compara cada arquivo contra cada regra aplicavel. Foco em: principios de engenharia, nomenclatura, estrutura de arquivos, manipulacao de DOM, comunicacao AJAX, feedback visual, seguranca client-side e formatacao.

Complementa `/auditar-frontend` (que cobre UX/UI e identidade visual).

## Quando usar

- **APENAS** quando o usuario digitar `/auditar-js` explicitamente.
- Rodar antes de mergear um PR — funciona como gate de qualidade do JavaScript.
- **Nunca** disparar automaticamente, nem como parte de outra skill.

## Padroes minimos exigidos

> Esta secao contem os padroes completos usados pela auditoria. Edite para personalizar ao seu projeto.

# Padrao de programacao em JavaScript

## Descricao

Documento de referencia para auditoria de codigo JavaScript no projeto. Define regras obrigatorias e recomendacoes que todo arquivo, funcao e modulo JS deve seguir. A skill `/auditar-js` le este documento e compara contra o codigo-alvo.

## Escopo

- Todo JavaScript dentro de `assets/js/`
- Vanilla JS ou framework declarado no projeto
- Comunicacao AJAX via `fetch()`

## Referencias

- [MDN Web Docs — JavaScript](https://developer.mozilla.org/pt-BR/docs/Web/JavaScript)
- [WCAG 2.1](https://www.w3.org/TR/WCAG21/)
- `docs/padroes-ux-ui.md` — Padroes de UX/UI (complementar)

## Severidade

- **ERRO** — Violacao bloqueia aprovacao. Deve ser corrigida antes de merge.
- **AVISO** — Recomendacao forte. Deve ser justificada se ignorada.

---

## 1. Principios fundamentais

### JS-001 — KISS: simplicidade primeiro [AVISO]

O codigo deve ser o mais simples possivel.

### JS-002 — DRY: uma regra, um lugar [ERRO]

Uma logica e implementada em um unico ponto. Se o mesmo calculo ou validacao aparece em dois arquivos, extrair para um modulo compartilhado.

### JS-003 — YAGNI: nao construa o que nao precisa agora [AVISO]

### JS-004 — Separacao de responsabilidades [ERRO]

Cada arquivo JS tem um escopo claro. Um arquivo nao mistura logica de formulario, manipulacao de DOM e comunicacao AJAX sem estrutura.

### JS-005 — Lei de Demeter: fale so com seus vizinhos [AVISO]

---

## 2. Estilo e nomenclatura

### JS-006 — Variaveis e funcoes em camelCase [ERRO]

```javascript
// correto
var valorTotal = 0;
function calcularSaldo() {}

// incorreto
var valor_total = 0;
function calcular_saldo() {}
```

### JS-007 — Constantes em UPPER_SNAKE_CASE [AVISO]

### JS-008 — Nomes descritivos, sem abreviacoes obscuras [AVISO]

### JS-009 — Funcoes nomeadas, nunca anonimas soltas [AVISO]

Funcoes devem ter nomes descritivos para facilitar debugging e stack traces.

---

## 3. Estrutura de arquivos

### JS-010 — Um arquivo por pagina/funcionalidade [ERRO]

Cada arquivo JS corresponde a uma pagina ou funcionalidade isolada.

### JS-011 — Carregamento condicional por pagina [ERRO]

Cada arquivo JS e carregado apenas na pagina que o utiliza. Nunca carregar todos os scripts em todas as paginas.

### JS-012 — Padrao de inicializacao via DOMContentLoaded [ERRO]

Todo arquivo JS inicia com `document.addEventListener('DOMContentLoaded', ...)` e encapsula toda a logica dentro desse escopo.

### JS-013 — Guard clause no inicio [ERRO]

Se o elemento principal da pagina nao existe, retornar imediatamente.

```javascript
document.addEventListener('DOMContentLoaded', function () {
    var form = document.getElementById('meu-form');
    if (!form) return; // guard clause

    // resto da logica
});
```

---

## 4. Manipulacao de DOM

### JS-014 — Selecao por ID ou classe semantica, nunca por tag [ERRO]

Usar `getElementById` ou `querySelector` com seletores semanticos. Nunca selecionar por tag generica.

### JS-015 — IDs e classes com prefixo do projeto [AVISO]

Elementos manipulados por JS usam prefixo do projeto para evitar colisao.

### JS-016 — addEventListener, nunca onclick inline [ERRO]

### JS-017 — Criar elementos via DOM API, nunca innerHTML para dados dinamicos [ERRO]

Para inserir dados dinamicos do usuario, usar `textContent` ou DOM API. `innerHTML` so e aceitavel para templates estaticos sem dados do usuario (previne XSS).

---

## 5. Comunicacao AJAX

### JS-018 — fetch() para toda comunicacao, nunca XMLHttpRequest [ERRO]

### JS-019 — Token de seguranca em toda requisicao AJAX [ERRO]

Toda requisicao inclui o token de seguranca (CSRF, nonce, etc.) adequado ao framework do projeto.

### JS-020 — Action/endpoint com prefixo do projeto [ERRO]

### JS-021 — Tratamento de erros em toda requisicao [ERRO]

Toda chamada `fetch()` tem tratamento de sucesso, erro de negocio e erro de rede (`.catch()`).

```javascript
// correto — tres caminhos tratados
fetch(url, { method: 'POST', body: formData })
    .then(function (resp) { return resp.json(); })
    .then(function (json) {
        if (json.success) {
            // sucesso
        } else {
            mostrarAlerta(json.data.mensagem, 'danger');
        }
    })
    .catch(function () {
        mostrarAlerta('Erro de conexao. Tente novamente.', 'danger');
    });
```

### JS-022 — FormData para envio quando aplicavel [AVISO]

---

## 6. Feedback visual e UX

### JS-023 — Loading state em toda operacao assincrona [ERRO]

Enquanto uma operacao AJAX esta em andamento, o botao que disparou fica desabilitado com spinner.

### JS-024 — Feedback em toda acao do usuario [ERRO]

Toda acao produz feedback visual. O usuario nunca fica sem saber o resultado.

### JS-025 — Validacao no cliente como UX, nao como seguranca [AVISO]

Validacao no JS e para feedback rapido ao usuario. A validacao real acontece no backend.

---

## 7. Seguranca

### JS-026 — Nunca armazenar dados sensiveis no cliente [ERRO]

Tokens de autenticacao, senhas, chaves de API nunca ficam em `localStorage`, `sessionStorage` ou cookies acessiveis por JS.

### JS-027 — Sem eval(), Function() ou innerHTML com dados do usuario [ERRO]

Nunca executar codigo dinamico. Nunca inserir dados do usuario via `innerHTML`. Previne XSS.

### JS-028 — Dados do backend sao suspeitos [AVISO]

Mesmo dados vindos do proprio backend devem ser inseridos com `textContent`, nao `innerHTML`.

---

## 8. Compatibilidade e performance

### JS-029 — Compatibilidade com navegadores alvo [AVISO]

O JavaScript deve ser compativel com os navegadores alvo do projeto.

### JS-030 — Sem bibliotecas externas desnecessarias [ERRO]

Bibliotecas so entram quando justificadas. A convencao do projeto define quais sao autorizadas.

### JS-031 — Event delegation para listas dinamicas [AVISO]

Para elementos que sao adicionados/removidos dinamicamente, usar delegacao de eventos no container pai.

### JS-032 — Sem polling, preferir eventos [AVISO]

Nao usar `setInterval` para verificar mudancas de estado. Usar eventos do DOM, callbacks de fetch ou MutationObserver.

---

## 9. Formatacao

### JS-033 — Indentacao com 4 espacos [ERRO]

### JS-034 — Chaves na mesma linha [AVISO]

### JS-035 — Maximo 120 caracteres por linha [AVISO]

### JS-036 — Ponto e virgula obrigatorio [ERRO]

Toda instrucao termina com `;`.

### JS-037 — Aspas simples para strings [AVISO]

Preferir aspas simples. Template literals apenas quando necessario interpolacao.

---

## Checklist de auditoria

A skill `/auditar-js` deve verificar, para cada arquivo:

**Principios:**
- [ ] KISS, DRY, YAGNI, SoC, Demeter respeitados
- [ ] Separacao de responsabilidades (um arquivo = uma funcionalidade)

**Nomenclatura:**
- [ ] Variaveis e funcoes em camelCase
- [ ] Constantes em UPPER_SNAKE_CASE
- [ ] Nomes descritivos
- [ ] Funcoes nomeadas

**Estrutura:**
- [ ] Um arquivo por pagina/funcionalidade
- [ ] Carregamento condicional
- [ ] Inicializacao via DOMContentLoaded
- [ ] Guard clause no inicio

**DOM:**
- [ ] Selecao por ID/classe semantica
- [ ] Prefixo do projeto em IDs/classes manipulados por JS
- [ ] addEventListener (sem onclick inline)
- [ ] textContent para dados dinamicos

**AJAX:**
- [ ] fetch() em toda comunicacao
- [ ] Token de seguranca em toda requisicao
- [ ] Tratamento de sucesso, erro e catch

**UX:**
- [ ] Loading state em operacoes assincronas
- [ ] Feedback visual em toda acao

**Seguranca:**
- [ ] Sem dados sensiveis no cliente
- [ ] Sem eval(), Function() ou innerHTML com dados do usuario

**Compatibilidade:**
- [ ] Sem bibliotecas desnecessarias
- [ ] Event delegation para listas dinamicas

**Formatacao:**
- [ ] Indentacao com 4 espacos
- [ ] Ponto e virgula obrigatorio
- [ ] Maximo 120 caracteres por linha

## Processo

### Fase 1 — Carregar a regua

1. Ler a secao **Padroes minimos exigidos** deste documento.
2. Internalizar todas as regras com seus IDs, descricoes, exemplos e severidades (ERRO/AVISO).
3. Nao resumir nem recitar o documento de volta.

### Fase 2 — Identificar o PR aberto

1. Executar `gh pr list --state open --base develop --json number,title,headRefName --limit 1`.
2. Se houver mais de um PR aberto, listar todos e perguntar ao usuario qual auditar.
3. Se nao houver PR aberto, informar o usuario e encerrar.
4. Executar `gh pr diff <numero>` para obter o diff completo do PR.
5. Filtrar apenas arquivos `.js` do projeto.

### Fase 3 — Auditar arquivo por arquivo

Para cada arquivo JavaScript alterado no PR:

1. Ler o arquivo completo (nao apenas o diff — contexto importa).
2. Comparar contra **cada regra** de `docs/padroes-js.md`, uma por uma, na ordem do documento.
3. Para cada violacao encontrada, registrar:
   - **Arquivo** e **linha(s)** onde ocorre
   - **ID da regra** violada (ex.: padroes-js.md, JS-018)
   - **Severidade** (ERRO ou AVISO)
   - **O que esta errado** — descricao concisa
   - **Como corrigir** — correcao especifica para aquele trecho
4. Se o arquivo nao viola nenhuma regra, registrar como aprovado.

### Fase 4 — Relatorio

Apresentar o relatorio ao usuario no formato padrao de auditoria.

### Fase 5 — Plano de correcoes

Se houver violacoes do tipo ERRO:

1. Listar as correcoes necessarias agrupadas por arquivo.
2. Perguntar ao usuario: "Quer que eu execute as correcoes agora?"

## Regras

- **Nunca alterar codigo durante a auditoria.** A skill e read-only ate o usuario pedir correcao explicitamente.
- **Nunca auditar arquivos fora do PR.** Apenas arquivos JavaScript alterados no PR aberto.
- **Sempre referenciar o ID da regra violada.** O relatorio deve ser rastreavel ao documento de padroes.
- **Nunca inventar regras.** A regua e exclusivamente o `docs/padroes-js.md`.
- **Ser metodica e processual.** Cada arquivo e comparado contra cada regra, na ordem do documento, sem pular.
- **Fidelidade ao documento.** Se o codigo viola uma regra do documento, reportar. Se o documento nao cobre o caso, nao reportar.
- **Mostrar o relatorio completo antes de qualquer acao.** Nunca executar correcoes sem aprovacao explicita.
