---
name: auditar-seguranca
description: Audita seguranca do codigo PHP do PR aberto contra as regras definidas em docs/padroes-seguranca.md. Cobre SQL injection, XSS, CSRF, IDOR, criptografia e validacao. Trigger manual apenas.
---

# /auditar-seguranca — Auditora de seguranca

Le as regras de `docs/padroes-seguranca.md`, identifica os arquivos PHP alterados no PR aberto (nao mergeado) e compara cada arquivo contra cada regra de seguranca aplicavel. Foco em: SQL injection, XSS, CSRF, IDOR, criptografia de dados sensiveis, validacao na fronteira, uploads e webhooks.

Complementa `/auditar-php` (sintaxe), `/auditar-poo` (arquitetura) e `/auditar-testes` (testes).

## Quando usar

- **APENAS** quando o usuario digitar `/auditar-seguranca` explicitamente.
- Rodar antes de mergear um PR — funciona como gate de seguranca.
- **Nunca** disparar automaticamente, nem como parte de outra skill.

## Padroes minimos exigidos

> Esta secao contem os padroes completos usados pela auditoria. Edite para personalizar ao seu projeto.

# Padrao de seguranca

## Descricao

Documento de referencia para auditoria de seguranca no projeto. Define regras obrigatorias para proteger dados sensiveis, prevenir ataques e garantir a integridade do sistema. A skill `/auditar-seguranca` le este documento e compara contra o codigo-alvo.

## Escopo

- Todo codigo PHP do projeto
- Handlers HTTP/AJAX/REST, repositorios, templates de pagina
- Configuracoes de infraestrutura quando aplicavel

## Referencias

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- `docs/padroes-php.md` — Regras complementares de seguranca PHP

## Severidade

- **ERRO** — Violacao bloqueia aprovacao. Deve ser corrigida antes de merge.
- **AVISO** — Recomendacao forte. Deve ser justificada se ignorada.

---

## 1. SQL Injection

### SEG-001 — Queries parametrizadas obrigatorias [ERRO]

Toda query que recebe dados variaveis usa queries preparadas com placeholders tipados. Sem excecao.

```php
// correto
$db->prepare("SELECT * FROM {$tabela} WHERE user_id = ? AND status = ?", [$userId, $status]);

// incorreto — injecao direta
$db->query("SELECT * FROM {$tabela} WHERE user_id = {$userId}");
```

### SEG-002 — Sem concatenacao de variaveis em SQL [ERRO]

Mesmo que a variavel pareca segura, sempre usar queries preparadas. A regra e mecanica, nao contextual.

---

## 2. Cross-Site Scripting (XSS)

### SEG-003 — Sanitizar toda entrada do usuario [ERRO]

Todo dado vindo de `$_POST`, `$_GET`, `$_REQUEST` ou corpo de requisicao e sanitizado antes de qualquer uso.

```php
// correto — sanitizacao na fronteira
$descricao = filter_var($_POST['descricao'] ?? '', FILTER_SANITIZE_SPECIAL_CHARS);
$valor = filter_var($_POST['valor'] ?? 0, FILTER_VALIDATE_INT);
```

### SEG-004 — Escapar toda saida para o navegador [ERRO]

Todo dado exibido em HTML, atributos ou JavaScript e escapado com a funcao apropriada.

```php
// correto — escapamento por contexto
echo htmlspecialchars($pedido->descricao(), ENT_QUOTES, 'UTF-8');   // dentro de tags HTML
echo htmlspecialchars($conta->nome(), ENT_QUOTES, 'UTF-8');          // dentro de atributos
echo json_encode($dados, JSON_HEX_TAG | JSON_HEX_AMP);              // em contexto JavaScript
```

### SEG-005 — Whitelist, nunca blocklist [AVISO]

Validar contra o que e permitido, nao contra o que e proibido.

```php
// correto — whitelist
$tiposPermitidos = ['venda', 'troca', 'devolucao'];
if (!in_array($tipo, $tiposPermitidos, true)) {
    throw new TipoInvalidoException();
}
```

---

## 3. Cross-Site Request Forgery (CSRF)

### SEG-006 — Token CSRF obrigatorio em todo handler [ERRO]

Todo endpoint que recebe requisicao do frontend valida um token CSRF antes de qualquer processamento.

### SEG-007 — Token CSRF e a primeira verificacao do handler [ERRO]

A verificacao do token vem antes de qualquer outra operacao. Antes de sanitizar, antes de buscar no banco, antes de tudo.

```php
// correto — ordem de verificacoes
public function handleAtualizarConta(): void
{
    // 1. CSRF token
    $this->verificarToken($_POST['csrf_token'] ?? '');

    // 2. Permissao
    $this->verificarPermissao();

    // 3. Sanitizacao de input
    $contaId = (int) ($_POST['conta_id'] ?? 0);

    // 4. Logica
    $this->manager->atualizarConta($contaId);
}
```

---

## 4. IDOR e controle de acesso

### SEG-008 — Verificar propriedade do recurso [ERRO]

Antes de ler, alterar ou deletar qualquer recurso, verificar se o usuario logado e dono daquele recurso. Nunca confiar no ID vindo do frontend.

```php
// correto — verifica ownership
$pedido = $this->repository->findById($pedidoId);

if (!$pedido || $pedido->userId() !== $this->usuarioAtual()->id()) {
    throw new SemPermissaoException();
}
```

### SEG-009 — Roles verificadas em todo handler [ERRO]

Todo handler define roles permitidas e verifica antes de processar.

### SEG-010 — Sem escalonamento de privilegios [ERRO]

Acoes administrativas sao restritas a roles especificas. Nunca um usuario comum executa acao de administrador.

---

## 5. Criptografia de dados sensiveis

### SEG-011 — Dados sensiveis criptografados em repouso [ERRO]

Todo dado sensivel e criptografado antes de persistir no banco e descriptografado apos leitura.

### SEG-012 — Algoritmo moderno de criptografia [AVISO]

A classe de criptografia usa algoritmos modernos e auditados (ex.: AES-256-GCM, XChaCha20-Poly1305).

### SEG-013 — Chave de criptografia no .env [ERRO]

A chave de criptografia vive exclusivamente no `.env`. Nunca hardcoded, nunca em constante PHP, nunca em arquivo de configuracao versionado.

### SEG-014 — Sem segredos no codigo-fonte [ERRO]

Nenhuma chave de API, senha, token ou segredo aparece em codigo PHP, JavaScript, CSS ou arquivo versionado. Tudo vive no `.env`.

---

## 6. Validacao na fronteira

### SEG-015 — Handler e a unica fronteira [ERRO]

Toda validacao e sanitizacao de input acontece no handler. Gerenciadores, repositorios e entidades confiam que os dados chegam limpos.

### SEG-016 — Validar tipo, formato e dominio [ERRO]

Toda entrada e validada em tres niveis:
1. **Tipo** — e int, string, array?
2. **Formato** — esta no formato esperado?
3. **Dominio** — esta dentro dos valores permitidos?

### SEG-017 — Nunca confiar em dados do frontend [ERRO]

IDs, valores, status — tudo que vem do frontend e potencialmente manipulado. Revalidar no backend.

---

## 7. Upload de arquivos

### SEG-018 — Whitelist de MIME types [ERRO]

Uploads aceitam apenas tipos MIME explicitamente permitidos. Verificacao real do conteudo, nao apenas da extensao.

### SEG-019 — Limite de tamanho por upload [ERRO]

Todo upload tem limite de tamanho definido.

---

## 8. Protecao de infraestrutura

### SEG-020 — Rate limiting em endpoints sensiveis [AVISO]

Endpoints de autenticacao, criacao de recursos e operacoes criticas tem limite de requisicoes por IP/usuario.

### SEG-021 — Headers de seguranca [AVISO]

O servidor deve enviar os seguintes headers:
- `Strict-Transport-Security` (HSTS)
- `X-Content-Type-Options: nosniff`
- `X-Frame-Options: DENY`
- `Referrer-Policy: strict-origin-when-cross-origin`

### SEG-022 — HTTPS obrigatorio [ERRO]

Todo trafego em producao usa HTTPS com TLS 1.2+.

### SEG-023 — Arquivos sensiveis bloqueados no servidor [AVISO]

O servidor bloqueia acesso direto a: `.env`, `.git`, `.sql`, `.bak`, `composer.json`, `composer.lock`.

---

## 9. Webhooks e APIs externas

### SEG-024 — Validacao anti-spoofing em webhooks [ERRO]

Webhooks de servicos externos validam a autenticidade da requisicao antes de processar.

### SEG-025 — Protecao contra replay attack [AVISO]

Webhooks verificam timestamp da requisicao. Requisicoes com mais de 5 minutos de atraso sao rejeitadas.

---

## Checklist de auditoria

A skill `/auditar-seguranca` deve verificar, para cada arquivo:

**SQL Injection:**
- [ ] Queries parametrizadas em toda query com dados variaveis
- [ ] Sem concatenacao de variaveis em SQL

**XSS:**
- [ ] Toda entrada sanitizada
- [ ] Toda saida escapada

**CSRF:**
- [ ] Token CSRF verificado em todo handler
- [ ] Token CSRF e a primeira verificacao do handler

**IDOR e acesso:**
- [ ] Propriedade do recurso verificada antes de ler/alterar/deletar
- [ ] Roles definidas e verificadas em todo handler
- [ ] Sem escalonamento de privilegios

**Criptografia:**
- [ ] Dados sensiveis criptografados em repouso
- [ ] Chave de criptografia no .env, nunca no codigo
- [ ] Sem segredos hardcoded em nenhum arquivo versionado

**Validacao:**
- [ ] Handler e a unica fronteira de validacao
- [ ] Tipo, formato e dominio validados
- [ ] Nenhum dado do frontend usado sem revalidacao

**Upload:**
- [ ] Whitelist de MIME types com verificacao real
- [ ] Limite de tamanho definido

**Infraestrutura:**
- [ ] HTTPS obrigatorio
- [ ] Headers de seguranca configurados

**Webhooks:**
- [ ] Validacao anti-spoofing
- [ ] Protecao contra replay attack

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
5. Filtrar apenas arquivos `.php` do projeto.

### Fase 3 — Auditar arquivo por arquivo

Para cada arquivo PHP alterado no PR:

1. Ler o arquivo completo (nao apenas o diff — contexto importa).
2. Comparar contra **cada regra** de `docs/padroes-seguranca.md`, uma por uma, na ordem do documento.
3. Para cada violacao encontrada, registrar:
   - **Arquivo** e **linha(s)** onde ocorre
   - **ID da regra** violada (ex.: padroes-seguranca.md, SEG-008)
   - **Severidade** (ERRO ou AVISO)
   - **Tipo de vulnerabilidade** (SQL injection, XSS, CSRF, IDOR, criptografia, validacao)
   - **O que esta errado** — descricao concisa
   - **Como corrigir** — correcao especifica para aquele trecho
4. Se o arquivo nao viola nenhuma regra, registrar como aprovado.

### Fase 4 — Relatorio

Apresentar o relatorio ao usuario no formato padrao com tabela de violacoes (Linha, Regra, Severidade, Tipo, Descricao, Correcao).

### Fase 5 — Plano de correcoes

Se houver violacoes do tipo ERRO:

1. Listar as correcoes necessarias agrupadas por tipo de vulnerabilidade.
2. Ordenar por risco (SQL injection e IDOR primeiro, headers por ultimo).
3. Perguntar ao usuario: "Quer que eu execute as correcoes agora?"

## Regras

- **Nunca alterar codigo durante a auditoria.** A skill e read-only ate o usuario pedir correcao explicitamente.
- **Nunca auditar arquivos fora do PR.** Apenas arquivos PHP alterados no PR aberto.
- **Sempre referenciar o ID da regra violada.** O relatorio deve ser rastreavel ao documento de padroes.
- **Nunca inventar regras.** A regua e exclusivamente o `docs/padroes-seguranca.md`.
- **Ser metodica e processual.** Cada arquivo e comparado contra cada regra, na ordem do documento, sem pular.
- **Fidelidade ao documento.** Se o codigo viola uma regra do documento, reportar. Se o documento nao cobre o caso, nao reportar.
- **Priorizar por risco.** No relatorio, SQL injection e IDOR vem antes de headers e rate limiting.
- **Mostrar o relatorio completo antes de qualquer acao.** Nunca executar correcoes sem aprovacao explicita.
