---
name: auditar-seguranca
description: Audita segurança do código PHP do PR aberto contra as regras definidas em docs/padroes-seguranca.md. Cobre SQL injection, XSS, CSRF, IDOR, criptografia e validação. Trigger manual apenas.
---

# /auditar-seguranca — Auditora de segurança

Lê as regras de `docs/padroes-seguranca.md`, identifica os arquivos PHP alterados no PR aberto (não mergeado) e compara cada arquivo contra cada regra de segurança aplicável. Foco em: SQL injection, XSS, CSRF, IDOR, criptografia de dados financeiros, validação na fronteira, uploads e webhooks.

Complementa `/auditar-php` (sintaxe), `/auditar-poo` (arquitetura) e `/auditar-testes` (testes).

## Quando usar

- **APENAS** quando o usuário digitar `/auditar-seguranca` explicitamente.
- Rodar antes de mergear um PR — funciona como gate de segurança.
- **Nunca** disparar automaticamente, nem como parte de outra skill.

## Padrões mínimos exigidos

> Esta seção contém os padrões completos usados pela auditoria. Edite para personalizar ao seu projeto.

# Padrão de segurança

## Descrição

Documento de referência para auditoria de segurança no projeto Acertando os Pontos. Define regras obrigatórias para proteger dados financeiros, prevenir ataques e garantir a integridade do sistema. A skill `/auditar-seguranca` lê este documento e compara contra o código-alvo.

Complementa `docs/padroes-php.md` (sintaxe), `docs/padroes-poo.md` (arquitetura) e `docs/padroes-testes.md` (testes).

## Escopo

- Todo código PHP dentro de `acertandoospontos/inc/` e `acertandoospontos/paginas/`
- Handlers AJAX/REST, repositórios, templates de página
- Configurações de infraestrutura (Nginx, Docker) quando aplicável
- Contexto: dados financeiros pessoais e de pequenas empresas

## Referências

- `docs/padroes-php.md` — Regras complementares de segurança PHP (PHP-037 a PHP-042)
- `referencias/entrada/CLAUDE-UniBGR.md` — Seção Segurança da plataforma-mãe
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [WordPress Security Best Practices](https://developer.wordpress.org/plugins/security/)

## Severidade

- **ERRO** — Violação bloqueia aprovação. Deve ser corrigida antes de merge.
- **AVISO** — Recomendação forte. Deve ser justificada se ignorada.

---

## 1. SQL Injection

### SEG-001 — Queries parametrizadas obrigatórias [ERRO]

Toda query que recebe dados variáveis usa `$wpdb->prepare()` com placeholders tipados. Sem exceção.

```php
// correto
$wpdb->get_results($wpdb->prepare(
    "SELECT * FROM {$this->tableName()} WHERE user_id = %d AND status = %s",
    $userId,
    $status
));

$wpdb->insert($this->tableName(), [
    'user_id' => $userId,
    'valor_cents' => $valorCriptografado,
], ['%d', '%s']);

// incorreto — injeção direta
$wpdb->get_results("SELECT * FROM {$tabela} WHERE user_id = {$userId}");
$wpdb->query("DELETE FROM {$tabela} WHERE id = " . $_POST['id']);
```

### SEG-002 — Sem concatenação de variáveis em SQL [ERRO]

Mesmo que a variável pareça segura (vem de outra query, é um int), sempre usar `prepare()`. A regra é mecânica, não contextual.

```php
// correto — mesmo para IDs internos
$wpdb->get_row($wpdb->prepare(
    "SELECT * FROM {$this->tableName()} WHERE id = %d",
    $id
));

// incorreto — "confia" que o ID é seguro
$wpdb->get_row("SELECT * FROM {$this->tableName()} WHERE id = {$id}");
```

---

## 2. Cross-Site Scripting (XSS)

### SEG-003 — Sanitizar toda entrada do usuário [ERRO]

Todo dado vindo de `$_POST`, `$_GET`, `$_REQUEST` ou corpo de requisição é sanitizado antes de qualquer uso.

```php
// correto — sanitização na fronteira
$descricao = sanitize_text_field($_POST['descricao'] ?? '');
$valor = absint($_POST['valor'] ?? 0);
$url = esc_url_raw($_POST['url'] ?? '');
$conteudo = wp_kses_post($_POST['conteudo'] ?? '');

// incorreto — uso direto
$descricao = $_POST['descricao'];
$valor = $_POST['valor'];
```

### SEG-004 — Escapar toda saída para o navegador [ERRO]

Todo dado exibido em HTML, atributos ou JavaScript é escapado com a função apropriada.

```php
// correto — escapamento por contexto
echo esc_html($lancamento->descricao());           // dentro de tags HTML
echo esc_attr($conta->nome());                      // dentro de atributos
echo esc_url($link);                                // em href/src
echo wp_json_encode($dados);                        // em contexto JavaScript

// incorreto — saída sem escapamento
echo $lancamento->descricao();
echo "<a href='{$link}'>";
```

### SEG-005 — Whitelist, nunca blocklist [AVISO]

Validar contra o que é permitido, não contra o que é proibido. Lista branca é finita e previsível; lista negra é infinita e sempre incompleta.

```php
// correto — whitelist
$tiposPermitidos = ['receita', 'despesa', 'transferencia'];
if (!in_array($tipo, $tiposPermitidos, true)) {
    wp_send_json_error(['mensagem' => 'Tipo inválido.']);
}

// incorreto — blocklist
$tiposProibidos = ['hack', 'admin', 'drop'];
if (in_array($tipo, $tiposProibidos, true)) {
    wp_send_json_error(['mensagem' => 'Tipo proibido.']);
}
```

---

## 3. Cross-Site Request Forgery (CSRF)

### SEG-006 — Nonce obrigatório em todo handler AJAX/REST [ERRO]

Todo endpoint que recebe requisição do frontend valida nonce antes de qualquer processamento.

```php
// correto — nonce verificado primeiro
public function handleCriarLancamento(): void
{
    check_ajax_referer('acp_nonce', 'nonce');
    // ... processamento
}

// incorreto — sem verificação de nonce
public function handleCriarLancamento(): void
{
    $descricao = sanitize_text_field($_POST['descricao']);
    // ... processa direto, sem verificar se a requisição é legítima
}
```

### SEG-007 — Nonce é a primeira verificação do handler [ERRO]

A verificação de nonce vem antes de qualquer outra operação. Antes de sanitizar, antes de buscar no banco, antes de tudo.

```php
// correto — ordem de verificações
public function handleAtualizarConta(): void
{
    // 1. Nonce
    check_ajax_referer('acp_nonce', 'nonce');

    // 2. Permissão (role)
    $this->checkPermission();

    // 3. Sanitização de input
    $contaId = absint($_POST['conta_id'] ?? 0);

    // 4. Lógica
    $this->manager->atualizarConta($contaId);
}
```

---

## 4. IDOR e controle de acesso

### SEG-008 — Verificar propriedade do recurso [ERRO]

Antes de ler, alterar ou deletar qualquer recurso, verificar se o usuário logado é dono daquele recurso. Nunca confiar no ID vindo do frontend.

```php
// correto — verifica ownership
public function handleDeletarLancamento(): void
{
    check_ajax_referer('acp_nonce', 'nonce');
    $this->checkPermission();

    $lancamentoId = absint($_POST['lancamento_id'] ?? 0);
    $lancamento = $this->repository->findById($lancamentoId);

    if (!$lancamento || $lancamento->userId() !== get_current_user_id()) {
        wp_send_json_error(['mensagem' => 'Sem permissão.'], 403);
    }

    $this->manager->deletarLancamento($lancamentoId);
    wp_send_json_success();
}

// incorreto — deleta sem verificar quem é o dono
public function handleDeletarLancamento(): void
{
    $lancamentoId = absint($_POST['lancamento_id'] ?? 0);
    $this->manager->deletarLancamento($lancamentoId); // qualquer um deleta qualquer lançamento
}
```

### SEG-009 — Roles verificadas em todo handler [ERRO]

Todo handler define `ALLOWED_ROLES` e verifica antes de processar. Sem role check, o endpoint está aberto para qualquer usuário logado.

```php
// correto
class FinanceiroAjaxHandler
{
    private const ALLOWED_ROLES = ['acp_admin', 'acp_user'];

    private function checkPermission(): void
    {
        $user = wp_get_current_user();
        $hasRole = array_intersect(self::ALLOWED_ROLES, $user->roles);

        if (empty($hasRole)) {
            wp_send_json_error(['mensagem' => 'Sem permissão.'], 403);
        }
    }
}
```

### SEG-010 — Sem escalonamento de privilégios [ERRO]

Ações administrativas (criar roles, alterar permissões, acessar dados de outros usuários) são restritas a roles específicas. Nunca um `acp_user` executa ação de `acp_admin`.

---

## 5. Criptografia de dados financeiros

### SEG-011 — Dados sensíveis criptografados em repouso [ERRO]

Todo dado financeiro sensível (valores monetários, descrições de transações, nomes de contas, dados bancários) é criptografado antes de persistir no banco e descriptografado após leitura.

```php
// correto — criptografia no repositório
public function create(Lancamento $lancamento): int
{
    $this->wpdb->insert($this->tableName(), [
        'valor_cents' => $this->cripto->criptografar((string) $lancamento->valorCents()),
        'descricao' => $this->cripto->criptografar($lancamento->descricao()),
    ]);

    return (int) $this->wpdb->insert_id;
}

private function hydrate(object $row): Lancamento
{
    $row->valor_cents = (int) $this->cripto->descriptografar($row->valor_cents);
    $row->descricao = $this->cripto->descriptografar($row->descricao);
    return Lancamento::fromRow($row);
}
```

### SEG-012 — Algoritmo AES-256-CBC [AVISO]

A classe `Criptografia` usa AES-256-CBC com IV aleatório por operação. Compatível com o padrão da UniBGR.

### SEG-013 — Chave de criptografia no .env [ERRO]

A chave de criptografia vive exclusivamente no `.env`. Nunca hardcoded, nunca em constante PHP, nunca em arquivo de configuração versionado.

```php
// correto
$chave = getenv('APP_ENCRYPTION_KEY');

// incorreto
private const ENCRYPTION_KEY = 'minha-chave-secreta';
define('APP_ENCRYPTION_KEY', 'chave-no-codigo');
```

### SEG-014 — Sem segredos no código-fonte [ERRO]

Nenhuma chave de API, senha, token ou segredo aparece em código PHP, JavaScript, CSS ou arquivo versionado. Tudo vive no `.env`.

Verificação: `grep -r "password\|secret\|api_key\|token" acertandoospontos/inc/` não deve retornar resultados que não sejam nomes de variáveis de ambiente.

---

## 6. Validação na fronteira

### SEG-015 — Handler é a única fronteira [ERRO]

Toda validação e sanitização de input acontece no handler. Gerenciadores, repositórios e entidades confiam que os dados chegam limpos. A responsabilidade de validar é do handler, nunca da entidade.

```
Request → Handler (valida, sanitiza) → Gerenciador → Repositório → Banco
                                                                    ↓
Response ← Handler (escapar output) ← Gerenciador ← Repositório ← Banco
```

### SEG-016 — Validar tipo, formato e domínio [ERRO]

Toda entrada é validada em três níveis:
1. **Tipo** — é int, string, array?
2. **Formato** — está no formato esperado (data, email, moeda)?
3. **Domínio** — está dentro dos valores permitidos?

```php
// correto — três níveis
$tipo = sanitize_text_field($_POST['tipo'] ?? '');

// Tipo: é string (sanitize_text_field garante)
// Formato: não vazio
if (empty($tipo)) {
    wp_send_json_error(['mensagem' => 'Tipo é obrigatório.']);
}

// Domínio: está nos valores permitidos
$tiposPermitidos = ['receita', 'despesa', 'transferencia'];
if (!in_array($tipo, $tiposPermitidos, true)) {
    wp_send_json_error(['mensagem' => 'Tipo inválido.']);
}
```

### SEG-017 — Nunca confiar em dados do frontend [ERRO]

IDs, valores, status — tudo que vem do frontend é potencialmente manipulado. Revalidar no backend.

```php
// correto — revalida no backend
$valorCents = absint($_POST['valor_cents'] ?? 0);
if ($valorCents <= 0 || $valorCents > 99999999) {
    wp_send_json_error(['mensagem' => 'Valor inválido.']);
}

// incorreto — confia no frontend
$valorCents = $_POST['valor_cents']; // pode ser negativo, string, SQL injection
```

---

## 7. Upload de arquivos

### SEG-018 — Whitelist de MIME types [ERRO]

Uploads aceitam apenas tipos MIME explicitamente permitidos. Verificação real do conteúdo, não apenas da extensão.

```php
// correto — MIME real verificado
$tiposPermitidos = ['image/jpeg', 'image/png', 'image/webp'];
$fileInfo = wp_check_filetype_and_ext($arquivo['tmp_name'], $arquivo['name']);

if (!in_array($fileInfo['type'], $tiposPermitidos, true)) {
    wp_send_json_error(['mensagem' => 'Tipo de arquivo não permitido.']);
}
```

### SEG-019 — Limite de tamanho por upload [ERRO]

Todo upload tem limite de tamanho definido. Padrão: 2MB para imagens, 5MB para documentos.

```php
// correto
$maxBytes = 2 * 1024 * 1024; // 2MB
if ($arquivo['size'] > $maxBytes) {
    wp_send_json_error(['mensagem' => 'Arquivo excede o limite de 2MB.']);
}
```

---

## 8. Proteção de infraestrutura

### SEG-020 — Rate limiting em endpoints sensíveis [AVISO]

Endpoints de autenticação, criação de recursos e operações financeiras têm limite de requisições por IP/usuário. Implementar via Nginx (`limit_req_zone`) ou via transients do WordPress.

### SEG-021 — Headers de segurança [AVISO]

O servidor deve enviar os seguintes headers:
- `Strict-Transport-Security` (HSTS)
- `X-Content-Type-Options: nosniff`
- `X-Frame-Options: DENY` (previne clickjacking)
- `Referrer-Policy: strict-origin-when-cross-origin`
- `Permissions-Policy` (restritiva)

### SEG-022 — HTTPS obrigatório [ERRO]

Todo tráfego em produção usa HTTPS com TLS 1.2+. HTTP redireciona 301 para HTTPS.

### SEG-023 — Arquivos sensíveis bloqueados no servidor [AVISO]

O servidor (Nginx) bloqueia acesso direto a: `.env`, `.git`, `.htaccess`, `.sql`, `.bak`, `composer.json`, `composer.lock`.

---

## 9. Webhooks e APIs externas

### SEG-024 — Validação anti-spoofing em webhooks [ERRO]

Webhooks de serviços externos (gateways de pagamento, APIs) validam a autenticidade da requisição antes de processar. Consultar o serviço de origem para confirmar os dados.

```php
// correto — valida com a API de origem antes de processar
public function handleWebhook(): void
{
    $paymentId = sanitize_text_field($_POST['payment_id'] ?? '');

    // Consulta a API de origem para confirmar
    $pagamento = $this->gateway->consultarPagamento($paymentId);

    if (!$pagamento) {
        wp_send_json_error(['mensagem' => 'Pagamento não encontrado na origem.']);
    }

    // Processa com dados da API, não do webhook
    $this->manager->processarPagamento($pagamento);
}
```

### SEG-025 — Proteção contra replay attack [AVISO]

Webhooks verificam timestamp da requisição. Requisições com mais de 5 minutos de atraso são rejeitadas.

```php
// correto
$timestamp = absint($_POST['timestamp'] ?? 0);
$agora = time();

if (abs($agora - $timestamp) > 300) { // 5 minutos
    wp_send_json_error(['mensagem' => 'Requisição expirada.']);
}
```

---

## 10. Regras derivadas de incidentes

> Regras adicionadas a partir de erros reais documentados em `aprendizado/erros/`. Cada uma referencia o incidente que a originou.

### SEG-026 — Select/dropdown com FK envia ID real, não rótulo textual [ERRO]

Formulários com `<select>` ou dropdown que alimentam uma foreign key no banco DEVEM ter `value` com o ID real (UUID, int), nunca o rótulo textual. Backend que recebe nome textual onde espera UUID resulta em FK violation silenciosa.

```html
<!-- correto — value é o UUID -->
<option value="550e8400-e29b-41d4-a716-446655440000">Salário</option>

<!-- incorreto — value é o nome -->
<option value="Salário">Salário</option>
```

**Origem:** incidente 0011 — modal de lançamento mandava nome da categoria como `categoriaId`. Insert falhava com FK violation.

### SEG-027 — OAuth multisite com domínios separados usa token one-time [ERRO]

Em WordPress Multisite com domínios próprios por tenant, o callback OAuth roda no domínio principal. Cookie setado no domínio principal não chega ao tenant (cross-domain). Usar token one-time via `site_transient` com TTL curto (2 min) para transferir autenticação.

```php
// correto — token one-time para cross-domain
$token = wp_generate_password(32, false);
set_site_transient('auto_login_' . $token, $user_id, 120);
wp_redirect($tenant_url . '/login/?auto_login=' . $token);

// incorreto — cookie direto (não funciona cross-domain)
wp_set_auth_cookie($user_id);
wp_redirect($tenant_url . '/inicio/');
```

**Origem:** incidente 0020 — login Google no CDI não completava porque cookie do domínio principal não chegava ao tenant.

### SEG-028 — Demo/staging com auto-login usa allowlist, não blocklist [ERRO]

Ambiente demo com auto-login (visitante = tenant_admin) deve bloquear TODAS as actions de escrita por padrão (allowlist de leitura), não listar algumas para bloquear (blocklist). REST API deve exigir auth real. wp-admin deve ser inacessível.

```php
// correto — allowlist (só permite leitura)
$actionsPermitidas = ['listar_catalogo', 'ver_dashboard', 'ver_mapa'];
if (!in_array($action, $actionsPermitidas, true)) {
    wp_send_json_error(['mensagem' => 'Ação bloqueada no demo.']);
}

// incorreto — blocklist (esquece 248 actions de escrita)
$actionsBloqueadas = ['deletar_usuario', 'enviar_email', /* mais 20... */];
// 248+ actions de escrita ficam abertas
```

**Origem:** incidente 0027 — demo com blocklist de 22 actions deixou 248+ actions de escrita abertas.

### SEG-029 — Variáveis de ambiente com caracteres especiais e Docker [AVISO]

Variáveis de ambiente com caracteres especiais (`$`, `!`, `@`, backticks, pipes, chaves) não sobrevivem à cadeia Docker Compose → env_file → PHP getenv(). Security keys do WordPress com esses caracteres devem ficar no wp-config.php, não em .env via getenv().

**Origem:** incidente 0031 — 8 security keys do WP com caracteres especiais retornaram string vazia via getenv(). Todos os usuários deslogados, login em loop infinito.

### SEG-030 — CSP script-src inclui TODOS os CDNs usados [ERRO]

Ao adicionar ou modificar Content-Security-Policy, listar TODOS os scripts externos carregados pelo projeto e garantir que estejam no `script-src`. CDN esquecido = ícones/scripts bloqueados silenciosamente.

```bash
# verificação obrigatória ao configurar CSP
grep -rn "src=.*https://" --include="*.php" --include="*.js" .
```

**Origem:** incidente 0032 — CSP com `script-src` não incluiu `unpkg.com` (Lucide Icons). Todos os ícones da plataforma ficaram vazios.

### SEG-031 — Projeto com Docker DEVE ter .dockerignore [ERRO]

Todo projeto que usa Docker DEVE ter `.dockerignore` excluindo: `.env`, `.git`, `node_modules`, `.next`, e qualquer arquivo com credenciais. O `.gitignore` protege do Git mas é irrelevante pro Docker — sem `.dockerignore`, secrets vão pro build context.

```
# .dockerignore obrigatório
.env
.env.*
!.env.example
.git
node_modules
.next
*.sql
*.bak
```

**Origem:** incidente 0034 — ACP sem `.dockerignore` enviava `.env` com credenciais reais no build context. 1.4 GB de lixo por build.

### SEG-032 — Bloquear arquivos de manifesto no servidor [AVISO]

Nginx deve bloquear acesso direto a `composer.json`, `package.json`, `package-lock.json`, `composer.lock`, `yarn.lock` além dos já bloqueados (`.env`, `.git`, `.sql`, `.bak`). Esses arquivos expõem dependências, versões exatas e estrutura do projeto.

```nginx
# adicionar ao bloco server
location ~* (composer\.(json|lock)|package(-lock)?\.json|yarn\.lock)$ {
    deny all;
    return 404;
}
```

**Origem:** incidente 0035 — `composer.json` e `package.json` retornavam HTTP 200 em produção.

### SEG-033 — Em Multisite, roles via for_site(), não ->roles direto [ERRO]

`wp_get_current_user()->roles` retorna roles do **primary blog** do user, não do blog atual. Em Multisite com múltiplos tenants, isso causa contaminação cross-tenant. Sempre usar `for_site($blog_id)`.

```php
// correto — roles do blog atual
$user = get_userdata(get_current_user_id());
$user->for_site(get_current_blog_id());
$roles = $user->roles;

// incorreto — roles do primary blog (contaminação cross-tenant)
$roles = wp_get_current_user()->roles;
```

**Origem:** incidente 0044 — user com `tenant_gestor` no CDI e `tenant_admin` na Artvac era tratado como admin no CDI. Isolamento de tenant quebrado.

### SEG-034 — Auth guard obrigatório em toda página protegida [ERRO]

Toda página de tenant com conteúdo protegido DEVE ter auth guard (`unibgr_require_login()` ou equivalente) no início do template. Página sem guard retorna 200 via URL direta sem autenticação.

```php
// correto — auth guard no início do template
<?php
unibgr_require_login();
get_header();
// ... conteúdo protegido

// incorreto — sem guard, qualquer visitante acessa
<?php
get_header();
// ... conteúdo protegido acessível sem login
```

**Verificação:** `grep -rL "require_login\|is_user_logged_in" pages/page-*.php` — todo resultado é página sem guard.

**Origem:** incidente 0045 — 12 páginas do tenant-starter acessíveis sem login em produção.

---

## Checklist de auditoria

A skill `/auditar-seguranca` deve verificar, para cada arquivo:

**SQL Injection:**
- [ ] `$wpdb->prepare()` em toda query com dados variáveis
- [ ] Sem concatenação de variáveis em SQL

**XSS:**
- [ ] Toda entrada sanitizada (sanitize_text_field, absint, esc_url_raw, wp_kses_post)
- [ ] Toda saída escapada (esc_html, esc_attr, esc_url, wp_json_encode)

**CSRF:**
- [ ] Nonce verificado em todo handler AJAX/REST
- [ ] Nonce é a primeira verificação do handler

**IDOR e acesso:**
- [ ] Propriedade do recurso verificada antes de ler/alterar/deletar
- [ ] ALLOWED_ROLES definido e verificado em todo handler
- [ ] Sem escalonamento de privilégios

**Criptografia:**
- [ ] Dados financeiros criptografados em repouso
- [ ] Chave de criptografia no .env, nunca no código
- [ ] Sem segredos hardcoded em nenhum arquivo versionado

**Validação:**
- [ ] Handler é a única fronteira de validação
- [ ] Tipo, formato e domínio validados
- [ ] Nenhum dado do frontend usado sem revalidação

**Upload:**
- [ ] Whitelist de MIME types com verificação real
- [ ] Limite de tamanho definido

**Infraestrutura:**
- [ ] HTTPS obrigatório
- [ ] Headers de segurança configurados

**Webhooks:**
- [ ] Validação anti-spoofing (consulta API de origem)
- [ ] Proteção contra replay attack

**Incidentes:**
- [ ] Select/dropdown envia ID real, não rótulo (SEG-026)
- [ ] OAuth cross-domain usa token one-time (SEG-027)
- [ ] Demo/staging usa allowlist, não blocklist (SEG-028)
- [ ] CSP inclui todos os CDNs usados (SEG-030)
- [ ] .dockerignore presente com .env excluído (SEG-031)
- [ ] Manifests (composer.json, package.json) bloqueados no servidor (SEG-032)
- [ ] Multisite: roles via for_site(), não ->roles direto (SEG-033)
- [ ] Auth guard em toda página protegida (SEG-034)

## Processo

### Fase 1 — Carregar a régua

1. Ler a seção **Padrões mínimos exigidos** deste documento.
2. Internalizar todas as regras com seus IDs, descrições, exemplos e severidades (ERRO/AVISO).
3. Não resumir nem recitar o documento de volta.

### Fase 2 — Identificar o PR aberto

1. Executar `gh pr list --state open --base develop --json number,title,headBranch --limit 1` para encontrar o PR aberto mais recente contra `develop`.
2. Se houver mais de um PR aberto, listar todos e perguntar ao usuário qual auditar.
3. Se não houver PR aberto, informar o usuário e encerrar.
4. Executar `gh pr diff <numero>` para obter o diff completo do PR.
5. Filtrar apenas arquivos `.php` dentro de `acertandoospontos/`.

### Fase 3 — Auditar arquivo por arquivo

Para cada arquivo PHP alterado no PR:

1. Ler o arquivo completo (não apenas o diff — contexto importa).
2. Comparar contra **cada regra** de `docs/padroes-seguranca.md`, uma por uma, na ordem do documento.
3. Para cada violação encontrada, registrar:
   - **Arquivo** e **linha(s)** onde ocorre
   - **ID da regra** violada (ex.: SEG-008)
   - **Severidade** (ERRO ou AVISO)
   - **Tipo de vulnerabilidade** (SQL injection, XSS, CSRF, IDOR, criptografia, validação)
   - **O que está errado** — descrição concisa
   - **Como corrigir** — correção específica para aquele trecho
4. Se o arquivo não viola nenhuma regra, registrar como aprovado.

### Fase 4 — Relatório

Apresentar o relatório ao usuário no seguinte formato:

```
## Relatório de auditoria de segurança

**PR:** #<numero> — <titulo>
**Branch:** <branch>
**Arquivos auditados:** <quantidade>
**Régua:** docs/padroes-seguranca.md

### Resumo

- Erros: <quantidade>
- Avisos: <quantidade>
- Arquivos aprovados: <quantidade>

### Violações

#### <arquivo.php>

| Linha | Regra | Severidade | Tipo | Descrição | Correção |
|-------|-------|------------|------|-----------|----------|
| 22 | SEG-001 | ERRO | SQL Injection | Query sem prepare() | Usar $wpdb->prepare() |
| 45 | SEG-008 | ERRO | IDOR | Sem verificação de ownership | Checar userId antes de deletar |

#### <outro-arquivo.php>
✅ Aprovado — nenhuma violação encontrada.
```

### Fase 5 — Plano de correções

Se houver violações do tipo ERRO:

1. Listar as correções necessárias agrupadas por tipo de vulnerabilidade.
2. Ordenar por risco (SQL injection e IDOR primeiro, headers por último).
3. Para cada correção, indicar exatamente o que mudar e onde.
4. Perguntar ao usuário: "Quer que eu execute as correções agora?"

Se houver apenas AVISOs ou nenhuma violação:

> "Nenhuma vulnerabilidade bloquante. Os avisos são recomendações — quer que eu corrija algum?"

## Regras

- **Nunca alterar código durante a auditoria.** A skill é read-only até o usuário pedir correção explicitamente.
- **Nunca auditar arquivos fora do PR.** Apenas arquivos PHP alterados no PR aberto.
- **Sempre referenciar o ID da regra violada.** O relatório deve ser rastreável ao documento de padrões.
- **Nunca inventar regras.** A régua é exclusivamente o `docs/padroes-seguranca.md` — sem opinião, sem sugestões extras.
- **Ser metódica e processual.** Cada arquivo é comparado contra cada regra, na ordem do documento, sem pular.
- **Fidelidade ao documento.** Se o código viola uma regra do documento, reportar. Se o documento não cobre o caso, não reportar.
- **Priorizar por risco.** No relatório, SQL injection e IDOR vêm antes de headers e rate limiting.
- **Mostrar o relatório completo antes de qualquer ação.** Nunca executar correções sem aprovação explícita.
