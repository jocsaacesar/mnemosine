---
documento: padroes-rest-api
versao: 2.1.0
criado: 2026-04-13
atualizado: 2026-04-16
total_regras: 14
severidades:
  erro: 10
  aviso: 4
escopo: Padronização de endpoints REST API em todos os projetos da BGR Software House
aplica_a: ["unibgr-campusdigital"]
requer: ["padroes-seguranca", "padroes-php"]
substitui: []
---

# Padrões REST API — BGR Software House

> Documento constitucional. Contrato de entrega entre a BGR e todo
> desenvolvedor que toca endpoints REST nos nossos projetos.
> Código que viola regras ERRO não é discutido — é devolvido.

---

## Como usar este documento

### Para o desenvolvedor

1. Leia este documento inteiro antes de criar ou modificar endpoints REST.
2. Use os IDs das regras (API-001 a API-008) para referenciar em PRs e code reviews.
3. Consulte o DoD no final antes de abrir qualquer Pull Request.

### Para o auditor (humano ou IA)

1. Leia o frontmatter para entender escopo e dependências.
2. Audite o código contra cada regra por ID.
3. Classifique violações pela severidade definida neste documento.
4. Referencie violações pelo ID da regra (ex.: "viola API-003").

### Para o Claude Code

1. Leia o frontmatter para determinar se este documento se aplica ao projeto em questão.
2. Em code review, verifique cada regra ERRO como bloqueante — nenhum merge enquanto houver violação.
3. Regras AVISO devem ser reportadas, mas aceitam justificativa por escrito no PR.
4. Referencie sempre pelo ID (ex.: "viola API-001") para rastreabilidade.

---

## Severidades

| Nível | Significado | Ação |
|-------|-------------|------|
| **ERRO** | Violação inegociável | Bloqueia merge. Corrigir antes de review. |
| **AVISO** | Recomendação forte | Deve ser justificada por escrito se ignorada. |

---

## 1. Namespace e Organização

### API-001 — Namespace = contrato de autenticação [ERRO]

**Regra:** Cada namespace REST representa um **domínio de autenticação** com seu próprio contrato. Endpoints com mecanismos de auth diferentes NUNCA compartilham namespace. Endpoints com o mesmo mecanismo de auth DEVEM estar no mesmo namespace.

**Verifica:** `grep -rn "register_rest_route" inc/` — agrupar por namespace e confirmar que todos os endpoints de um namespace usam o mesmo `permission_callback`.

**Namespaces válidos na BGR:**

| Namespace | Auth | Quem chama | Exemplo |
|-----------|------|-----------|---------|
| `unibgr/v1` | WP nonce/session | Frontend autenticado | `/perfil`, `/dashboard` |
| `auth/v1` | OAuth state token + redirect | Identity providers (Google) | `/google/connect` |
| `loja/v1` | OAuth state token + redirect | Payment providers (MP) | `/mercadopago/oauth/*` |
| `mapa/v1` | Session / HMAC-SHA256 | Browser + webhooks externos | `/pdf/gerar`, `/webhook/mercadopago` |
| `play/v1` | API key (header) | Game clients externos | `/resultado`, `/ranking/{slug}` |

**Por quê na BGR:** namespace é contrato público. Quem consome `play/v1` sabe que precisa de `X-Play-API-Key`. Quem consome `unibgr/v1` sabe que precisa de nonce WP. Misturar auth de API key com nonce WP no mesmo namespace confunde o consumidor e dificulta auditoria — o auditor não sabe qual `permission_callback` esperar.

**Exemplo correto:**
```php
// play/v1 — todo endpoint usa API key
register_rest_route('play/v1', '/resultado', [
    'methods'             => 'POST',
    'callback'            => [$this, 'handle_resultado'],
    'permission_callback' => [$this, 'check_api_key'],
]);
```

**Exemplo incorreto:**
```php
// VIOLAÇÃO: endpoint de API key misturado com endpoints de nonce WP
register_rest_route('unibgr/v1', '/play/resultado', [
    'methods'             => 'POST',
    'callback'            => [$this, 'handle_resultado'],
    'permission_callback' => [$this, 'check_api_key'], // auth diferente do resto do namespace
]);
```

**Criar namespace novo exige:** justificativa de que o mecanismo de auth é incompatível com os namespaces existentes + aprovação no PR.

---

## 2. Rate Limiting

### API-002 — Todo endpoint com mutação DEVE ter rate limit [ERRO]

**Regra:** Endpoints POST, PUT, PATCH e DELETE DEVEM ter rate limiting. Limites recomendados por tipo:

**Verifica:** `grep -rn "rate_limiter\|RateLimiter" inc/` — todo handler de mutação deve chamar `rate_limiter->allow()` antes de processar.

| Tipo | Limite |
|------|--------|
| Login/Auth | 5 req/min por IP |
| Mutação autenticada | 30 req/min por user |
| Webhook externo | 60 req/min por IP |
| Upload | 10 req/min por user |

**Por quê na BGR:** Sem rate limit, um script automatizado pode criar 10.000 pedidos, enviar 50.000 emails ou derrubar o banco com INSERTs em massa. Rate limit é a primeira camada de defesa contra abuso.

**Exemplo correto:**
```php
public function handle_transferir_licenca(\WP_REST_Request $request): \WP_REST_Response
{
    if (!$this->rate_limiter->allow('licenca_transfer', get_current_user_id(), 10, 60)) {
        return new \WP_REST_Response(
            ['erro' => 'Muitas requisições. Aguarde 1 minuto.', 'codigo' => 'RATE_LIMITED'],
            429
        );
    }
    // ...
}
```

### API-004 — Endpoint público DEVE ter rate limit por IP [AVISO]

**Regra:** Endpoints acessíveis sem autenticação DEVEM ter rate limit por IP. Limites recomendados: 30 req/min para leitura, 5 req/min para escrita.

**Verifica:** Endpoints com `permission_callback => '__return_true'` devem ter `rate_limiter->allow()` por IP.

**Por quê na BGR:** Endpoints públicos são acessíveis por qualquer bot, crawler ou atacante. Sem rate limit por IP, um único ator pode consumir 100% dos recursos do servidor.

---

## 3. Isolamento por Tenant

### API-003 — Todo endpoint DEVE filtrar por tenant_id do usuário autenticado [ERRO]

**Regra:** Todo endpoint REST autenticado DEVE filtrar dados pelo `tenant_id` do usuário. Endpoints que retornam listas DEVEM filtrar por tenant. Endpoints que recebem IDs DEVEM validar que o recurso pertence ao tenant do usuário.

**Verifica:** Inspecionar callbacks REST — toda query deve incluir `tenant_id` e todo ID recebido deve ter check de ownership.

**Por quê na BGR:** REST API é fronteira do sistema — é onde ataques IDOR acontecem. Se um endpoint retorna dados sem filtro de tenant, qualquer usuário autenticado vê dados de todos os tenants.

**Exemplo correto:**
```php
public function handle_listar_pedidos(\WP_REST_Request $request): \WP_REST_Response
{
    $tenant_id = unibgr_current_tenant_id();
    $pedidos = $this->pedidoRepo->find_by_tenant($tenant_id);
    // ...
}
```

---

## 4. Formato de Resposta

### API-005 — Resposta de erro DEVE seguir formato padronizado [ERRO]

**Regra:** Toda resposta de erro (4xx, 5xx) DEVE seguir o formato:

**Verifica:** `grep -rn "WP_REST_Response\|wp_send_json_error" inc/` — toda resposta de erro deve ter campos `erro`, `codigo` e `status`.

```json
{
    "erro": "Descrição legível do erro",
    "codigo": "CODIGO_MAQUINA",
    "status": 422
}
```

| Campo | Tipo | Obrigatório | Descrição |
|-------|------|-------------|-----------|
| `erro` | `string` | Sim | Mensagem legível para o frontend |
| `codigo` | `string` | Sim | Código máquina para switch/case no client |
| `status` | `int` | Sim | HTTP status code espelhado no body |

**Por quê na BGR:** Formato consistente permite que o frontend trate erros de forma uniforme. Sem padrão, cada endpoint inventa seu próprio formato e o frontend precisa de N parsers.

**Códigos padronizados:**

| Código | Status | Significado |
|--------|--------|-------------|
| `VALIDATION_ERROR` | 422 | Dados inválidos |
| `NOT_FOUND` | 404 | Recurso não encontrado |
| `UNAUTHORIZED` | 401 | Não autenticado |
| `FORBIDDEN` | 403 | Sem permissão |
| `RATE_LIMITED` | 429 | Muitas requisições |
| `CONFLICT` | 409 | Estado conflitante |
| `INTERNAL_ERROR` | 500 | Erro interno |

### API-006 — Endpoints deprecated DEVEM retornar 410 Gone [AVISO]

**Regra:** Endpoints que serão removidos DEVEM passar por ciclo de deprecação:
1. Header `Deprecation: true` + `Sunset: <data>` por 90 dias
2. Após a data de sunset: retornar `410 Gone` com body indicando o endpoint substituto

**Verifica:** `grep -rn "Deprecation\|Sunset\|410" inc/` — endpoints marcados pra remoção devem ter headers de deprecação ou status 410.

**Por quê na BGR:** Remoção abrupta de endpoint quebra integrações. 410 é explícito — o client sabe que o endpoint morreu e onde ir.

---

## 5. Segurança

### API-007 — Webhook DEVE validar assinatura antes de processar [ERRO]

**Regra:** Todo endpoint de webhook que recebe payloads de serviços externos (Mercado Pago, Brevo, etc.) DEVE validar assinatura/autenticidade antes de processar. Mínimo: verificação via API do serviço (anti-spoofing). Ideal: HMAC signature validation.

**Verifica:** `grep -rn "webhook\|handle_webhook" inc/` — todo handler de webhook deve validar assinatura ou consultar API de origem antes de processar payload.

**Por quê na BGR:** Webhook sem validação aceita qualquer payload. Atacante pode forjar notificação de pagamento aprovado e conceder acesso indevido. O webhook do Mercado Pago já faz anti-spoofing via consulta à API — manter esse padrão.

**Exemplo correto (anti-spoofing):**
```php
public function handle_webhook(\WP_REST_Request $request): \WP_REST_Response
{
    $payment_id = $request->get_param('data')['id'] ?? null;
    if (!$payment_id) {
        return new \WP_REST_Response(['erro' => 'Payload inválido'], 400);
    }

    // Anti-spoofing: consulta a API do MP antes de processar
    $payment = $this->mp_client->get_payment($payment_id);
    if (!$payment) {
        return new \WP_REST_Response(['erro' => 'Pagamento não encontrado na API'], 404);
    }
    // ... processar com dados da API, não do webhook
}
```

### API-008 — Input validation com sanitização e limites [ERRO]

**Regra:** Todo campo recebido via REST DEVE ser sanitizado por tipo e ter limite de comprimento definido. Campos sem limite são vetor de DoS por payload gigante. Sem exceção — endpoint que aceita string sem sanitização não mergea.

**Verifica:** Inspecionar todo `$request->get_param()` — deve ter `sanitize_text_field()`/`absint()`/`sanitize_email()` e `strlen()` check imediatamente após.

**Por quê na BGR:** `POST /api/endpoint` com body de 10MB sem validação de tamanho pode travar o PHP-FPM worker. Sanitização previne XSS e injection. Limites previnem abuso de storage e memória.

**Sanitização por tipo (obrigatória):**

| Tipo de campo | Sanitizador | Limite |
|---------------|------------|--------|
| Nome / título | `sanitize_text_field()` | 255 chars |
| Slug | `sanitize_text_field()` | 100 chars |
| Descrição curta | `sanitize_text_field()` | 500 chars |
| Texto longo / HTML | `wp_kses_post()` | 5000 chars |
| Email | `sanitize_email()` + `is_email()` | 320 chars |
| URL | `esc_url()` | 2048 chars |
| Inteiro | `(int)` cast + `min()`/`max()` bounds | Faixa explícita |
| JSON payload | `json_decode()` + validação de estrutura | 64 KB |

**Exemplo correto:**
```php
$score     = min(max((int) ($params['score'] ?? 0), 0), $score_max);  // clamped
$nome      = sanitize_text_field($params['nome'] ?? '');
$email     = sanitize_email($params['email'] ?? '');
if (empty($nome) || strlen($nome) < 3) { /* rejeita */ }
if (!is_email($email)) { /* rejeita */ }
```

---

## 6. Proteção de Endpoint

### API-009 — Todo endpoint DEVE ter permission_callback explícito [ERRO]

**Regra:** Todo `register_rest_route()` DEVE declarar `permission_callback`. Usar `'__return_true'` apenas para endpoints genuinamente públicos. NUNCA omitir o campo — WordPress aceita omissão mas loga aviso e expõe o endpoint sem proteção.

**Verifica:** `grep -A5 "register_rest_route" inc/` — todo registro deve conter `permission_callback`. Ausência é violação.

**Por quê na BGR:** omitir `permission_callback` cria endpoint aberto que não aparece em auditoria automatizada. Forçar `'__return_true'` torna a decisão explícita e auditável.

**Exemplo correto:**
```php
register_rest_route('play/v1', '/ranking/(?P<slug>[a-z0-9-]+)', [
    'methods'             => 'GET',
    'callback'            => [$this, 'handle_ranking'],
    'permission_callback' => [$this, 'check_api_key'],  // explícito
]);
```

**Exemplo incorreto:**
```php
// VIOLAÇÃO: permission_callback omitido — endpoint aberto silenciosamente
register_rest_route('mapa/v1', '/dados', [
    'methods'  => 'GET',
    'callback' => [$this, 'handle_dados'],
]);
```

### API-010 — Valores numéricos DEVEM ter clamping com faixa explícita [ERRO]

**Regra:** Todo inteiro ou float recebido do client DEVE ser clampado com `min()`/`max()` para uma faixa válida definida pela regra de negócio. Cast sem clamp não é validação — transforma lixo em número, mas não garante sanidade.

**Verifica:** `grep -rn "(int)" inc/` em handlers REST — todo cast inteiro deve ter `min(max(...))` na mesma linha ou próxima.

**Por quê na BGR:** `score = (int) $params['score']` aceita `-2147483648` ou `999999999` sem reclamar. Sem clamp, o banco armazena valor absurdo e cálculos derivados (ranking, média, prêmio) quebram silenciosamente.

**Exemplo correto:**
```php
$score     = (int) ($params['score'] ?? 0);
$score_max = (int) ($params['score_max'] ?? 0);
if ($score_max <= 0) { /* rejeita */ }
$score = min(max($score, 0), $score_max);  // 0 ≤ score ≤ score_max
```

**Exemplo incorreto:**
```php
// VIOLAÇÃO: cast sem clamp — aceita qualquer inteiro
$score = (int) $params['score'];
$limit = (int) $request->get_param('limit');  // pode ser 999999
```

### API-011 — Validação DEVE acontecer antes de qualquer side effect [ERRO]

**Regra:** Todo endpoint DEVE validar todos os campos de input ANTES de tocar banco, filesystem, API externa ou qualquer recurso com side effect. Padrão: bloco de validação → acumula erros → retorna 400/422 com todos os erros de uma vez. NUNCA validar campo a campo com retorno antecipado que oculta os próximos erros.

**Verifica:** Inspecionar handlers — bloco de validação deve vir antes de qualquer `$this->wpdb->` ou `$repo->`. Nenhum INSERT/UPDATE antes da validação completa.

**Por quê na BGR:** se a validação do campo 3 faz INSERT antes de verificar campo 5, um input parcialmente válido deixa lixo no banco. Além disso, retornar erro por campo obriga o client a fazer N requests até acertar — retornar tudo de uma vez é respeito com quem consome.

**Exemplo correto:**
```php
$errors = [];
if (empty($jogo_slug)) { $errors[] = 'jogo_slug é obrigatório.'; }
if (empty($nome) || strlen($nome) < 3) { $errors[] = 'nome mínimo 3 caracteres.'; }
if (!is_email($email)) { $errors[] = 'email inválido.'; }
if ($score_max <= 0) { $errors[] = 'score_max deve ser > 0.'; }

if (!empty($errors)) {
    return new \WP_REST_Response([
        'erro'   => implode(' ', $errors),
        'codigo' => 'VALIDATION_ERROR',
        'status' => 422
    ], 422);
}
// Agora sim: toca banco
```

### API-012 — JSON opcional DEVE ser validado em estrutura antes de persistir [ERRO]

**Regra:** Campos que aceitam JSON do client (arrays, objetos, metadata) DEVEM: (1) verificar se é `array` após decode, (2) sanitizar cada valor interno, (3) re-encodar com `wp_json_encode()`. NUNCA persistir JSON cru do client sem inspeção.

**Verifica:** `grep -rn "json_encode\|wp_json_encode" inc/` — todo JSON persistido deve vir de `wp_json_encode()` com dados previamente validados com `is_array()` e sanitizados.

**Por quê na BGR:** JSON é payload livre — o client pode mandar estrutura arbitrária, incluindo HTML, scripts ou gigabytes de nesting. Sem validação de estrutura, o banco vira depósito de lixo e o frontend que renderiza o JSON herda XSS.

**Exemplo correto:**
```php
$dados_json = '{}';
if (isset($params['dados']) && is_array($params['dados'])) {
    $dados_json = wp_json_encode($params['dados']);
}

$device_json = '{}';
if (isset($params['device']) && is_array($params['device'])) {
    $device_json = wp_json_encode(array_map('sanitize_text_field', $params['device']));
}
```

**Exemplo incorreto:**
```php
// VIOLAÇÃO: JSON direto do client pro banco sem inspeção
$this->wpdb->insert($table, [
    'dados_json' => json_encode($params['dados']),
]);
```

### API-013 — Resposta de sucesso DEVE seguir formato padronizado [AVISO]

**Regra:** Respostas de sucesso (2xx) DEVEM incluir campo `sucesso: true` na raiz do payload. Dados retornados vivem em campos nomeados (não em raiz genérica `data`). IDs de recursos criados DEVEM ser retornados.

**Verifica:** `grep -rn "WP_REST_Response" inc/` — respostas 2xx devem conter `'sucesso' => true` e campos nomeados.

**Por quê na BGR:** frontend que consome N endpoints diferentes precisa de um contrato previsível. `sucesso: true` + campos nomeados permite tratamento uniforme sem inspecionar status HTTP.

**Exemplo correto:**
```php
return new \WP_REST_Response([
    'sucesso'   => true,
    'sessao_id' => $session_id,
    'premio'    => [
        'tipo'      => 'moedas',
        'descricao' => '10 moedas de prata!',
        'mensagem'  => 'Parabéns! Seu prêmio foi creditado.',
    ],
], 200);
```

### API-014 — Endpoint externo DEVE documentar contrato de integração [AVISO]

**Regra:** Todo endpoint consumido por client externo (game, app mobile, integração third-party) DEVE ter contrato documentado em `docs/modulos/rest-api.md` incluindo: URL, método, headers obrigatórios, body schema (campos, tipos, obrigatoriedade, limites), response schema (sucesso + erro), e exemplo de request/response.

**Verifica:** Listar endpoints com `permission_callback` de API key ou público — cada um deve ter entrada correspondente em `docs/modulos/rest-api.md`.

**Por quê na BGR:** endpoint interno pode ser descoberto lendo o código. Endpoint externo é consumido por quem NÃO tem acesso ao código — sem documentação, a integração vira tentativa e erro.

---

## DoD — Definition of Done (REST API)

Antes de abrir PR que cria ou modifica endpoints REST:

- [ ] Namespace correto pro domínio de auth (API-001)
- [ ] Endpoint com mutação tem rate limit (API-002)
- [ ] Endpoint filtra por tenant_id (API-003)
- [ ] Endpoint público tem rate limit por IP (API-004)
- [ ] Respostas de erro seguem formato padronizado (API-005)
- [ ] Endpoints deprecated retornam 410 (API-006)
- [ ] Webhooks validam assinatura (API-007)
- [ ] Inputs sanitizados por tipo com limites de comprimento (API-008)
- [ ] `permission_callback` explícito em todo `register_rest_route` (API-009)
- [ ] Valores numéricos com clamp min/max (API-010)
- [ ] Validação completa antes de qualquer side effect (API-011)
- [ ] JSON do client validado em estrutura e sanitizado antes de persistir (API-012)
- [ ] Resposta de sucesso com `sucesso: true` + campos nomeados (API-013)
- [ ] Endpoint externo com contrato documentado (API-014)

---

## Versionamento

| Versão | Data | Responsável | Alteração |
|--------|------|-------------|-----------|
| 1.0.0 | 2026-04-13 | Joc + Reliable | Criação — 8 regras (5 ERRO, 3 AVISO) |
| 2.0.0 | 2026-04-13 | Joc + Reliable | API-001 reescrita (namespace = contrato de auth, não cosmética). API-008 promovida de AVISO→ERRO. 6 regras novas: API-009 permission_callback explícito, API-010 clamp numérico, API-011 validação antes de side effect, API-012 JSON sanitizado, API-013 resposta de sucesso padronizada, API-014 contrato de integração documentado. Total: 14 regras (10 ERRO, 4 AVISO) |
| 2.1.0 | 2026-04-16 | Reliable | Adição de campo **Verifica** em todas as 14 regras |

---

*BGR Software House. API é contrato público — trate como tal.*
