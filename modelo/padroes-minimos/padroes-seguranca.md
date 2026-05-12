---
documento: padroes-seguranca
versao: 2.1.0
criado: 2025-06-01
atualizado: 2026-04-16
total_regras: 25
severidades:
  erro: 19
  aviso: 6
stack: php
escopo: Segurança de aplicação e infraestrutura em todos os projetos da BGR Software House
aplica_a: ["todos"]
requer: []
substitui: ["padroes-seguranca v1 (versão específica Acertando os Pontos)"]
---

# Padrões de Segurança — BGR Software House

> Documento constitucional. Contrato de entrega entre a BGR e todo
> desenvolvedor que toca segurança nos nossos projetos.
> Código que viola regras ERRO não é discutido — é devolvido.

---

## Como usar este documento

### Para o desenvolvedor

1. Leia este documento inteiro antes de abrir seu primeiro PR que envolva entrada de dados, autenticação, criptografia ou infraestrutura.
2. Use os IDs das regras (SEG-001 a SEG-025) para referenciar em PRs e code reviews.
3. Consulte o DoD no final antes de abrir qualquer Pull Request.

### Para o auditor (humano ou IA)

1. Leia o frontmatter para entender escopo e dependências.
2. Audite o código contra cada regra por ID.
3. Classifique violações pela severidade definida neste documento.
4. Referencie violações pelo ID da regra (ex.: "viola SEG-011").

### Para o Claude Code

1. Leia o frontmatter para determinar se este documento se aplica ao projeto em questão.
2. Em code review, verifique cada regra ERRO como bloqueante — nenhum merge enquanto houver violação.
3. Regras AVISO devem ser reportadas, mas aceitam justificativa por escrito no PR.
4. Referencie sempre pelo ID (ex.: "viola SEG-003") para rastreabilidade.

---

## Severidades

| Nível | Significado | Ação |
|-------|-------------|------|
| **ERRO** | Violação inegociável | Bloqueia merge. Corrigir antes de review. |
| **AVISO** | Recomendação forte | Deve ser justificada por escrito se ignorada. |

---

## 1. SQL Injection

### SEG-001 — Queries parametrizadas obrigatórias [ERRO]

**Regra:** Toda query que recebe dados variáveis deve usar prepared statements com placeholders tipados. Sem exceção, independente da linguagem ou framework.

**Verifica:** `grep -rn` por interpolação direta em strings SQL (`"SELECT.*\$`, `"INSERT.*\$`, `"UPDATE.*\$`, `"DELETE.*\$`). Zero ocorrências = passa.

**Por quê na BGR:** A BGR trabalha com dados sensíveis em múltiplos projetos — financeiros, pessoais, de saúde. Uma única query sem parametrização é vetor de vazamento catastrófico. Time pequeno significa que não há equipe de resposta a incidentes separada; quem causou o problema é quem vai corrigir às 3h da manhã.

**Exemplo correto:**
```php
// WordPress/PHP — usando $wpdb->prepare()
$wpdb->get_results($wpdb->prepare(
    "SELECT * FROM {$this->tableName()} WHERE user_id = %d AND status = %s",
    $userId,
    $status
));
```

```python
# Python — usando parametrização nativa
cursor.execute(
    "SELECT * FROM usuarios WHERE id = %s AND status = %s",
    (user_id, status)
)
```

**Exemplo incorreto:**
```php
// Injeção direta — PROIBIDO em qualquer linguagem
$wpdb->get_results("SELECT * FROM {$tabela} WHERE user_id = {$userId}");
```

```python
# Interpolação direta — PROIBIDO
cursor.execute(f"SELECT * FROM usuarios WHERE id = {user_id}")
```

**Referências:** SEG-002

---

### SEG-002 — Sem concatenação de variáveis em SQL [ERRO]

**Regra:** Mesmo que a variável pareça segura (vem de outra query, é um inteiro, foi validada antes), sempre usar prepared statements. A regra é mecânica, não contextual.

**Verifica:** `grep -rn` por concatenação de variável em SQL (`$wpdb->query(".*{$`, `$wpdb->get_`). Toda ocorrência sem `prepare()` = ERRO.

**Por quê na BGR:** Desenvolvimento autônomo com IA significa que código é gerado e revisado em alta velocidade. Regras mecânicas ("sempre prepare, sem pensar") eliminam a classe inteira de erro. Confiar no contexto exige julgamento humano que nem sempre está presente na review.

**Exemplo correto:**
```php
// Mesmo para IDs internos — sempre prepare
$wpdb->get_row($wpdb->prepare(
    "SELECT * FROM {$this->tableName()} WHERE id = %d",
    $id
));
```

```javascript
// Node.js — sempre parametrizado
const result = await db.query(
    "SELECT * FROM usuarios WHERE id = $1",
    [id]
);
```

**Exemplo incorreto:**
```php
// "Confia" que o ID é seguro — PROIBIDO
$wpdb->get_row("SELECT * FROM {$this->tableName()} WHERE id = {$id}");
```

**Referências:** SEG-001

---

## 2. Cross-Site Scripting (XSS)

### SEG-003 — Sanitizar toda entrada do usuário [ERRO]

**Regra:** Todo dado vindo de input externo (formulários, query strings, corpo de requisição, headers) deve ser sanitizado antes de qualquer uso. Nunca usar dados brutos do request.

**Verifica:** `grep -rn '\$_POST\|\$_GET\|\$_REQUEST\|\$_SERVER'` em handlers. Toda ocorrência sem `sanitize_*`/`absint`/`esc_*` wrapper = ERRO.

**Por quê na BGR:** Na BGR, Claude Code gera código em volume. Se a sanitização não for regra absoluta na fronteira, basta um handler esquecido para abrir XSS persistente. Dados sensíveis dos clientes da BGR não podem vazar por negligência em um único endpoint.

**Exemplo correto:**
```php
// WordPress — funções de sanitização na fronteira
$descricao = sanitize_text_field($_POST['descricao'] ?? '');
$valor = absint($_POST['valor'] ?? 0);
$url = esc_url_raw($_POST['url'] ?? '');
```

```python
# Python/Django — sanitização na fronteira
descricao = bleach.clean(request.POST.get('descricao', ''))
valor = int(request.POST.get('valor', 0))
```

**Exemplo incorreto:**
```php
// Uso direto sem sanitização — PROIBIDO
$descricao = $_POST['descricao'];
$valor = $_POST['valor'];
```

---

### SEG-004 — Escapar toda saída para o navegador [ERRO]

**Regra:** Todo dado exibido em HTML, atributos ou JavaScript deve ser escapado com a função apropriada ao contexto de renderização. Nunca emitir dados brutos para o navegador.

**Verifica:** `grep -rn 'echo \$'` em templates/views. Toda saída sem `esc_html`/`esc_attr`/`esc_url`/`wp_json_encode` = ERRO.

**Por quê na BGR:** Projetos da BGR lidam com dados financeiros e pessoais exibidos em dashboards. XSS refletido ou persistente em tela de saldo ou transação é devastador para a confiança do cliente. Escapar por contexto é obrigação mecânica.

**Exemplo correto:**
```php
// WordPress — escapamento por contexto
echo esc_html($entidade->descricao());       // dentro de tags HTML
echo esc_attr($entidade->nome());            // dentro de atributos
echo esc_url($link);                         // em href/src
echo wp_json_encode($dados);                 // em contexto JavaScript
```

```javascript
// JavaScript — usar textContent, nunca innerHTML com dados variáveis
element.textContent = userData.name;
```

**Exemplo incorreto:**
```php
// Saída sem escapamento — PROIBIDO
echo $entidade->descricao();
echo "<a href='{$link}'>";
```

---

### SEG-005 — Whitelist, nunca blocklist [AVISO]

**Regra:** Validar contra o que é permitido, nunca contra o que é proibido. Lista branca é finita e previsível; lista negra é infinita e sempre incompleta.

**Verifica:** Inspecionar validações de input. Presença de array de valores proibidos sem array de permitidos = AVISO.

**Por quê na BGR:** Time pequeno não tem capacidade de manter blocklists atualizadas contra novos vetores de ataque. Whitelist é "defina uma vez, proteja para sempre". Blocklist é "esqueça um caso, perca tudo".

**Exemplo correto:**
```php
// Whitelist — lista finita de valores aceitos
$tiposPermitidos = ['receita', 'despesa', 'transferencia'];
if (!in_array($tipo, $tiposPermitidos, true)) {
    throw new InvalidArgumentException('Tipo inválido.');
}
```

**Exemplo incorreto:**
```php
// Blocklist — lista infinita de valores proibidos
$tiposProibidos = ['hack', 'admin', 'drop'];
if (in_array($tipo, $tiposProibidos, true)) {
    throw new InvalidArgumentException('Tipo proibido.');
}
```

**Exceções:** Filtros de spam ou conteúdo ofensivo, onde a natureza do problema exige blocklist. Mesmo assim, combinar com whitelist quando possível.

---

## 3. Cross-Site Request Forgery (CSRF)

### SEG-006 — Token CSRF obrigatório em todo handler de mutação [ERRO]

**Regra:** Todo endpoint que recebe requisição de mutação (POST, PUT, DELETE) do frontend deve validar um token CSRF antes de qualquer processamento.

**Verifica:** `grep -rn 'function handle'` em handlers de mutação. Cada um deve conter `check_ajax_referer`/`wp_verify_nonce` ou equivalente. Ausência = ERRO.

**Por quê na BGR:** Projetos da BGR operam com dados financeiros e pessoais. Um ataque CSRF pode transferir dinheiro, alterar cadastros ou deletar registros sem o usuário saber. Token CSRF é a barreira mínima contra ações forjadas.

**Exemplo correto:**
```php
// WordPress — verificação de nonce (implementação de CSRF do WP)
public function handleCriarRegistro(): void
{
    check_ajax_referer('app_nonce', 'nonce');
    // ... processamento
}
```

```python
# Django — @csrf_protect ou middleware global
@csrf_protect
def criar_registro(request):
    # ... processamento
```

**Exemplo incorreto:**
```php
// Sem verificação de CSRF — PROIBIDO
public function handleCriarRegistro(): void
{
    $descricao = sanitize_text_field($_POST['descricao']);
    // processa direto, sem verificar se a requisição é legítima
}
```

---

### SEG-007 — Token CSRF é a primeira verificação do handler [ERRO]

**Regra:** A verificação de CSRF vem antes de qualquer outra operação. Antes de sanitizar, antes de buscar no banco, antes de tudo.

**Verifica:** Em cada handler de mutação, `check_ajax_referer` deve ser a primeira chamada do método. Qualquer operação antes dela = ERRO.

**Por quê na BGR:** Se a requisição é forjada, nenhum processamento deve acontecer. Sanitizar input de uma requisição ilegítima é desperdício e aumenta a superfície de ataque. Na BGR, a ordem de verificações é lei: autenticidade primeiro, permissão segundo, dados terceiro.

**Exemplo correto:**
```php
public function handleAtualizar(): void
{
    // 1. CSRF
    check_ajax_referer('app_nonce', 'nonce');

    // 2. Permissão (role/autorização)
    $this->checkPermission();

    // 3. Sanitização de input
    $id = absint($_POST['id'] ?? 0);

    // 4. Lógica de negócio
    $this->manager->atualizar($id);
}
```

**Exemplo incorreto:**
```php
public function handleAtualizar(): void
{
    // Sanitiza ANTES de verificar CSRF — ordem errada
    $id = absint($_POST['id'] ?? 0);
    $this->manager->atualizar($id);
    check_ajax_referer('app_nonce', 'nonce'); // tarde demais
}
```

---

## 4. IDOR e controle de acesso

### SEG-008 — Verificar propriedade do recurso [ERRO]

**Regra:** Antes de ler, alterar ou deletar qualquer recurso, verificar se o usuário autenticado é dono ou tem permissão explícita sobre aquele recurso. Nunca confiar no ID vindo do frontend.

**Verifica:** Em handlers que recebem ID do frontend, buscar comparação `userId()` / `user_id` com usuário autenticado antes da operação. Ausência = ERRO.

**Por quê na BGR:** Projetos da BGR armazenam dados sensíveis de múltiplos usuários na mesma base. Um IDOR permite que o usuário A acesse dados do usuário B trocando um ID na requisição. Em projetos financeiros, isso significa ver saldos, transações e dados bancários alheios.

**Exemplo correto:**
```php
public function handleDeletar(): void
{
    check_ajax_referer('app_nonce', 'nonce');
    $this->checkPermission();

    $registroId = absint($_POST['id'] ?? 0);
    $registro = $this->repository->findById($registroId);

    if (!$registro || $registro->userId() !== $this->getCurrentUserId()) {
        throw new ForbiddenException('Sem permissão.');
    }

    $this->manager->deletar($registroId);
}
```

**Exemplo incorreto:**
```php
public function handleDeletar(): void
{
    $registroId = absint($_POST['id'] ?? 0);
    $this->manager->deletar($registroId); // qualquer um deleta qualquer registro
}
```

---

### SEG-009 — Roles verificadas em todo handler [ERRO]

**Regra:** Todo handler que processa requisições deve definir quais roles têm acesso e verificar antes de processar. Sem verificação de role, o endpoint está aberto para qualquer usuário autenticado.

**Verifica:** `grep -rn 'ALLOWED_ROLES\|checkPermission\|current_user_can\|permission_required'` em handlers. Handler sem nenhuma verificação de role = ERRO.

**Por quê na BGR:** A BGR constrói sistemas multi-role (admin, usuário comum, auditor). Endpoint sem role check é porta aberta para escalonamento horizontal de privilégios. Time pequeno não consegue auditar manualmente cada endpoint — a regra mecânica de "toda handler verifica role" elimina a classe de erro.

**Exemplo correto:**
```php
class RegistroHandler
{
    private const ALLOWED_ROLES = ['admin', 'user'];

    private function checkPermission(): void
    {
        $user = $this->getCurrentUser();
        $hasRole = array_intersect(self::ALLOWED_ROLES, $user->roles);

        if (empty($hasRole)) {
            throw new ForbiddenException('Sem permissão.');
        }
    }
}
```

```python
# Django — decorator de permissão
@permission_required('app.pode_criar_registro')
def criar_registro(request):
    # ...
```

**Exemplo incorreto:**
```php
// Handler sem nenhuma verificação de role
class RegistroHandler
{
    public function handle(): void
    {
        // qualquer usuário autenticado executa
    }
}
```

---

### SEG-010 — Sem escalonamento de privilégios [ERRO]

**Regra:** Ações administrativas (criar roles, alterar permissões, acessar dados de outros usuários) devem ser restritas a roles específicas. Nunca um usuário comum executa ação de administrador.

**Verifica:** Endpoints que alteram roles/permissões devem exigir role `admin` ou equivalente. `grep -rn 'setRole\|add_role\|promote'` — cada ocorrência deve ter guard de admin antes.

**Por quê na BGR:** Na BGR, cada projeto define roles com responsabilidades claras. Escalonamento de privilégios significa que um usuário comum pode se tornar admin, alterar dados alheios ou manipular configurações do sistema. Em projetos com dados sensíveis, isso é catastrófico.

**Exemplo correto:**
```php
public function handleAlterarRole(): void
{
    check_ajax_referer('app_nonce', 'nonce');

    if (!$this->isAdmin()) {
        throw new ForbiddenException('Apenas administradores alteram roles.');
    }

    // ... altera role
}
```

**Exemplo incorreto:**
```php
public function handleAlterarRole(): void
{
    // Qualquer usuário logado pode alterar roles
    $novaRole = sanitize_text_field($_POST['role']);
    $this->userManager->setRole($userId, $novaRole);
}
```

---

## 5. Criptografia de dados sensíveis

### SEG-011 — Dados sensíveis criptografados em repouso [ERRO]

**Regra:** Todo dado sensível (valores monetários, descrições de transações, dados pessoais, dados bancários, dados de saúde) deve ser criptografado antes de persistir no banco e descriptografado após leitura.

**Verifica:** Em repositórios que persistem campos sensíveis, verificar chamada a `criptografar()` no `insert`/`update` e `descriptografar()` no `hydrate`/`from_row`. Ausência = ERRO.

**Por quê na BGR:** A BGR constrói sistemas que armazenam dados financeiros, pessoais e de saúde. Vazamento do banco de dados (SQL dump, backup exposto) sem criptografia em repouso expõe todos os dados em texto claro. Criptografia em repouso é a última linha de defesa.

**Exemplo correto:**
```php
// Criptografia no repositório — padrão BGR
public function create(Entidade $entidade): int
{
    $this->db->insert($this->tableName(), [
        'valor_cents' => $this->cripto->criptografar((string) $entidade->valorCents()),
        'descricao' => $this->cripto->criptografar($entidade->descricao()),
    ]);

    return (int) $this->db->lastInsertId();
}

private function hydrate(object $row): Entidade
{
    $row->valor_cents = (int) $this->cripto->descriptografar($row->valor_cents);
    $row->descricao = $this->cripto->descriptografar($row->descricao);
    return Entidade::fromRow($row);
}
```

**Exemplo incorreto:**
```php
// Dados sensíveis em texto claro no banco — PROIBIDO
$this->db->insert($this->tableName(), [
    'valor_cents' => $entidade->valorCents(),
    'descricao' => $entidade->descricao(),
]);
```

---

### SEG-012 — Algoritmo de criptografia robusto e padronizado [AVISO]

**Regra:** A implementação de criptografia deve usar algoritmo AES-256-CBC (ou superior) com IV aleatório por operação. Nunca implementar criptografia própria.

**Verifica:** `grep -rn 'openssl_encrypt\|Cipher\|aes'` — confirmar uso de `aes-256-cbc` ou superior. `grep -rn 'base64_encode\|rot13\|md5\|sha1'` em contexto de "criptografia" = AVISO.

**Por quê na BGR:** A BGR precisa de um padrão de criptografia consistente entre projetos para facilitar auditoria e manutenção. AES-256-CBC é amplamente suportado, auditado e atende aos requisitos de compliance. Criptografia caseira é a forma mais rápida de ter segurança ilusória.

**Exemplo correto:**
```php
// PHP — openssl com IV aleatório por operação
$iv = openssl_random_pseudo_bytes(openssl_cipher_iv_length('aes-256-cbc'));
$criptografado = openssl_encrypt($dados, 'aes-256-cbc', $chave, 0, $iv);
$resultado = base64_encode($iv . $criptografado);
```

```python
# Python — usando cryptography (Fernet usa AES-128-CBC, para AES-256 usar primitivas)
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
import os
iv = os.urandom(16)
cipher = Cipher(algorithms.AES(chave), modes.CBC(iv))
```

**Exemplo incorreto:**
```php
// ROT13, Base64 ou "criptografia" caseira — PROIBIDO
$criptografado = base64_encode($dados); // isso é encoding, não criptografia
$criptografado = str_rot13($dados);     // isso é piada, não criptografia
```

---

### SEG-013 — Chave de criptografia em variável de ambiente [ERRO]

**Regra:** A chave de criptografia deve existir exclusivamente em variável de ambiente (.env ou equivalente). Nunca hardcoded, nunca em constante no código, nunca em arquivo de configuração versionado.

**Verifica:** `grep -rn 'ENCRYPTION_KEY\|encryption_key'` no código-fonte. Ocorrência que não seja `getenv`/`os.environ`/`process.env` = ERRO.

**Por quê na BGR:** Repositórios da BGR são acessados por desenvolvedores e por agentes de IA. Chave hardcoded no código significa que qualquer pessoa com acesso ao repositório tem acesso a todos os dados criptografados. Variável de ambiente isola o segredo do código.

**Exemplo correto:**
```php
$chave = getenv('APP_ENCRYPTION_KEY');
```

```python
import os
chave = os.environ['APP_ENCRYPTION_KEY']
```

**Exemplo incorreto:**
```php
// Chave no código-fonte — PROIBIDO
private const ENCRYPTION_KEY = 'minha-chave-secreta';
define('APP_ENCRYPTION_KEY', 'chave-no-codigo');
```

---

### SEG-014 — Sem segredos no código-fonte [ERRO]

**Regra:** Nenhuma chave de API, senha, token ou segredo deve aparecer em código-fonte ou arquivo versionado. Tudo deve estar em variáveis de ambiente (.env ou equivalente).

**Verifica:** `grep -rn 'sk_live\|sk_test\|password.*=.*["\x27]\|api_key.*=.*["\x27]\|secret.*=.*["\x27]'` em arquivos versionados. Qualquer match com valor literal = ERRO.

**Por quê na BGR:** A BGR usa Git como fonte de verdade. Segredo commitado é segredo exposto para sempre (mesmo após remoção, fica no histórico). Com desenvolvimento assistido por IA, o risco aumenta — modelos podem reproduzir segredos vistos no código em outros contextos.

**Exemplo correto:**
```php
$apiKey = getenv('PAYMENT_GATEWAY_KEY');
$dbPassword = getenv('DB_PASSWORD');
```

```javascript
const apiKey = process.env.PAYMENT_GATEWAY_KEY;
```

**Exemplo incorreto:**
```php
$apiKey = 'sk_live_abc123def456';
define('DB_PASSWORD', 'senha-super-secreta');
```

```javascript
const apiKey = 'sk_live_abc123def456';
```

---

## 6. Validação na fronteira

### SEG-015 — Handler é a única fronteira de validação [ERRO]

**Regra:** Toda validação e sanitização de input deve acontecer no handler (controller, endpoint, action). Camadas internas (serviços, repositórios, entidades) confiam que os dados chegam limpos. A responsabilidade de validar é exclusiva da fronteira.

**Verifica:** `grep -rn 'sanitize_\|absint\|esc_'` em services/repositories. Presença de sanitização fora do handler = ERRO (responsabilidade vazou da fronteira).

**Por quê na BGR:** Na arquitetura da BGR, a separação de responsabilidades é lei. Se validação está espalhada em múltiplas camadas, ninguém sabe onde o dado é validado, e alterações em uma camada quebram premissas de outra. Fronteira única = auditoria simples.

**Exemplo correto:**
```
Request → Handler (valida, sanitiza) → Serviço → Repositório → Banco
                                                                  ↓
Response ← Handler (escapa output) ← Serviço ← Repositório ← Banco
```

**Exemplo incorreto:**
```
Request → Handler (não valida) → Serviço (valida parcial) → Repositório (valida de novo) → Banco
// Ninguém sabe onde a validação realmente acontece
```

---

### SEG-016 — Validar tipo, formato e domínio [ERRO]

**Regra:** Toda entrada deve ser validada em três níveis: tipo (int, string, array), formato (data, email, moeda) e domínio (dentro dos valores permitidos).

**Verifica:** Inspecionar cada input no handler. Deve ter: (1) cast/sanitize de tipo, (2) validação de formato, (3) checagem contra valores permitidos. Faltou nível = ERRO.

**Por quê na BGR:** Validação incompleta é validação inútil. Verificar só o tipo deixa passar formatos inválidos. Verificar só o formato deixa passar valores fora do domínio. Na BGR, dados corrompidos no banco são mais caros de corrigir do que prevenir — time pequeno não tem luxo de "corrigir depois".

**Exemplo correto:**
```php
$tipo = sanitize_text_field($_POST['tipo'] ?? '');

// Tipo: é string (sanitize_text_field garante)
// Formato: não vazio
if (empty($tipo)) {
    throw new ValidationException('Tipo é obrigatório.');
}

// Domínio: está nos valores permitidos
$tiposPermitidos = ['receita', 'despesa', 'transferencia'];
if (!in_array($tipo, $tiposPermitidos, true)) {
    throw new ValidationException('Tipo inválido.');
}
```

**Exemplo incorreto:**
```php
// Valida só o tipo, ignora formato e domínio
$tipo = sanitize_text_field($_POST['tipo'] ?? '');
// usa $tipo direto sem verificar se é um valor válido
```

---

### SEG-017 — Nunca confiar em dados do frontend [ERRO]

**Regra:** IDs, valores, status — tudo que vem do frontend é potencialmente manipulado. Sempre revalidar no backend.

**Verifica:** Dados do request usados em lógica de negócio devem passar por validação no backend. Input usado sem cast/validação = ERRO.

**Por quê na BGR:** DevTools do navegador permitem alterar qualquer valor antes de enviar. O frontend é conveniência para o usuário, nunca garantia para o sistema. Na BGR, dados financeiros e pessoais exigem que o backend seja a autoridade absoluta sobre validação.

**Exemplo correto:**
```php
$valorCents = absint($_POST['valor_cents'] ?? 0);
if ($valorCents <= 0 || $valorCents > 99999999) {
    throw new ValidationException('Valor inválido.');
}
```

```python
valor_cents = int(request.POST.get('valor_cents', 0))
if valor_cents <= 0 or valor_cents > 99999999:
    raise ValidationError('Valor inválido.')
```

**Exemplo incorreto:**
```php
// Confia no frontend — PROIBIDO
$valorCents = $_POST['valor_cents']; // pode ser negativo, string, SQL injection
```

---

## 7. Upload de arquivos

### SEG-018 — Whitelist de MIME types em uploads [ERRO]

**Regra:** Uploads devem aceitar apenas tipos MIME explicitamente permitidos. A verificação deve ser feita no conteúdo real do arquivo, nunca apenas na extensão.

**Verifica:** Em handlers de upload, buscar verificação de MIME real (`wp_check_filetype_and_ext`, `finfo_file`, `python-magic`). Verificação só por extensão ou ausente = ERRO.

**Por quê na BGR:** Upload com verificação só de extensão permite que um arquivo PHP seja renomeado para .jpg e executado no servidor. Na BGR, onde projetos rodam em servidores compartilhados, um shell upload compromete todos os projetos do servidor.

**Exemplo correto:**
```php
// WordPress — verificação de MIME real
$tiposPermitidos = ['image/jpeg', 'image/png', 'image/webp'];
$fileInfo = wp_check_filetype_and_ext($arquivo['tmp_name'], $arquivo['name']);

if (!in_array($fileInfo['type'], $tiposPermitidos, true)) {
    throw new ValidationException('Tipo de arquivo não permitido.');
}
```

```python
# Python — verificação de MIME real com python-magic
import magic
mime = magic.from_file(arquivo.temporary_file_path(), mime=True)
tipos_permitidos = ['image/jpeg', 'image/png', 'image/webp']
if mime not in tipos_permitidos:
    raise ValidationError('Tipo de arquivo não permitido.')
```

**Exemplo incorreto:**
```php
// Verifica só a extensão — PROIBIDO
$ext = pathinfo($arquivo['name'], PATHINFO_EXTENSION);
if ($ext === 'jpg') { /* aceita */ }
// Um arquivo malicioso.php renomeado para malicioso.jpg passa
```

---

### SEG-019 — Limite de tamanho por upload [ERRO]

**Regra:** Todo upload deve ter limite de tamanho definido e verificado no backend. Cada projeto define seus limites conforme necessidade.

**Verifica:** Em handlers de upload, buscar comparação de `$arquivo['size']` / `file.size` contra constante de limite. Ausência de verificação de tamanho no backend = ERRO.

**Por quê na BGR:** Servidores da BGR têm recursos limitados. Upload sem limite permite DoS por esgotamento de disco ou memória. Limite definido e verificado no backend é obrigatório — limite só no frontend é ignorável via curl.

**Exemplo correto:**
```php
$maxBytes = 2 * 1024 * 1024; // 2MB
if ($arquivo['size'] > $maxBytes) {
    throw new ValidationException('Arquivo excede o limite de 2MB.');
}
```

```python
if arquivo.size > 2 * 1024 * 1024:
    raise ValidationError('Arquivo excede o limite de 2MB.')
```

**Exemplo incorreto:**
```php
// Sem limite — aceita upload de qualquer tamanho
move_uploaded_file($arquivo['tmp_name'], $destino);
```

---

## 8. Proteção de infraestrutura

### SEG-020 — Rate limiting em endpoints sensíveis [AVISO]

**Regra:** Endpoints de autenticação, criação de recursos e operações sensíveis devem ter limite de requisições por IP e/ou por usuário.

**Verifica:** `grep -rn 'limit_req\|RateLimiter\|throttle'` na config do servidor e handlers sensíveis. Endpoint de login/criação sem rate limit = AVISO.

**Por quê na BGR:** Time pequeno não monitora logs 24/7. Rate limiting é defesa automatizada contra brute force e abuso. Sem rate limiting, um bot pode tentar milhares de senhas por minuto ou criar milhares de registros falsos sem que ninguém perceba a tempo.

**Exemplo correto:**
```nginx
# Nginx — rate limiting por zona
limit_req_zone $binary_remote_addr zone=login:10m rate=5r/m;

location /api/login {
    limit_req zone=login burst=3 nodelay;
    # ...
}
```

**Exemplo incorreto:**
```nginx
# Endpoint de login sem nenhum rate limiting
location /api/login {
    proxy_pass http://backend;
    # qualquer IP pode fazer 1000 tentativas por segundo
}
```

---

### SEG-021 — Headers de segurança configurados [AVISO]

**Regra:** O servidor deve enviar os seguintes headers de segurança em toda resposta:
- `Strict-Transport-Security` (HSTS)
- `X-Content-Type-Options: nosniff`
- `X-Frame-Options: DENY`
- `Referrer-Policy: strict-origin-when-cross-origin`
- `Permissions-Policy` (restritiva)

**Verifica:** `curl -sI https://dominio | grep -iE 'strict-transport|x-content-type|x-frame|referrer-policy|permissions-policy'`. Cada header listado acima ausente = AVISO.

**Por quê na BGR:** Headers de segurança são defesa de baixo custo e alto impacto. Configurar uma vez no servidor protege todas as respostas. Na BGR, onde projetos compartilham infraestrutura, headers padronizados garantem baseline de segurança consistente entre projetos.

**Exemplo correto:**
```nginx
# Nginx — headers de segurança
add_header Strict-Transport-Security "max-age=63072000; includeSubDomains" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-Frame-Options "DENY" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
add_header Permissions-Policy "camera=(), microphone=(), geolocation=()" always;
```

**Exemplo incorreto:**
```nginx
# Servidor sem nenhum header de segurança
server {
    listen 443 ssl;
    # ... nenhum add_header de segurança
}
```

---

### SEG-022 — HTTPS obrigatório [ERRO]

**Regra:** Todo tráfego em produção deve usar HTTPS com TLS 1.2 ou superior. HTTP deve redirecionar 301 para HTTPS.

**Verifica:** `curl -sI http://dominio` deve retornar `301` com `Location: https://`. `curl -sI https://dominio` deve conectar com TLS 1.2+. Falha em qualquer = ERRO.

**Por quê na BGR:** Dados financeiros e pessoais trafegam entre navegador e servidor. HTTP em texto claro permite interceptação trivial (man-in-the-middle). Na BGR, HTTPS não é diferencial — é requisito mínimo de operação.

**Exemplo correto:**
```nginx
server {
    listen 80;
    server_name exemplo.bgr.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl;
    ssl_protocols TLSv1.2 TLSv1.3;
    # ...
}
```

**Exemplo incorreto:**
```nginx
# Serve conteúdo em HTTP sem redirecionamento
server {
    listen 80;
    server_name exemplo.bgr.com;
    root /var/www/html;
    # dados sensíveis trafegam em texto claro
}
```

---

### SEG-023 — Arquivos sensíveis bloqueados no servidor [AVISO]

**Regra:** O servidor deve bloquear acesso direto a arquivos sensíveis: `.env`, `.git`, `.htaccess`, `.sql`, `.bak`, `composer.json`, `composer.lock`, `package.json`, `package-lock.json`.

**Verifica:** `curl -sI https://dominio/.env` e `curl -sI https://dominio/.git/config` devem retornar 403 ou 404. Qualquer 200 = AVISO.

**Por quê na BGR:** Um `.env` acessível via browser expõe todas as chaves do projeto. Um `.git` exposto permite download de todo o histórico do repositório. Na BGR, onde múltiplos projetos coexistem no mesmo servidor, um projeto exposto compromete a credibilidade de todos.

**Exemplo correto:**
```nginx
# Nginx — bloquear arquivos sensíveis
location ~ /\.(env|git|htaccess) {
    deny all;
    return 404;
}

location ~ \.(sql|bak)$ {
    deny all;
    return 404;
}
```

**Exemplo incorreto:**
```nginx
# Nenhuma regra de bloqueio — .env acessível via browser
server {
    root /var/www/projeto;
    # https://projeto.com/.env retorna o conteúdo do arquivo
}
```

---

## 9. Webhooks e APIs externas

### SEG-024 — Validação anti-spoofing em webhooks [ERRO]

**Regra:** Webhooks de serviços externos (gateways de pagamento, APIs de terceiros) devem validar a autenticidade da requisição antes de processar. Sempre consultar o serviço de origem para confirmar os dados recebidos.

**Verifica:** Em handlers de webhook, buscar chamada à API de origem (ex.: `consultarPagamento`, `verify_signature`) antes de processar dados. Processamento direto do payload sem verificação = ERRO.

**Por quê na BGR:** Webhook é uma porta aberta para o mundo. Qualquer pessoa que conheça a URL pode enviar dados forjados. Na BGR, onde projetos processam pagamentos e dados financeiros, um webhook falso pode registrar pagamentos inexistentes ou alterar saldos.

**Exemplo correto:**
```php
// Valida com a API de origem antes de processar
public function handleWebhook(): void
{
    $paymentId = sanitize_text_field($_POST['payment_id'] ?? '');

    // Consulta a API de origem para confirmar
    $pagamento = $this->gateway->consultarPagamento($paymentId);

    if (!$pagamento) {
        throw new SecurityException('Pagamento não encontrado na origem.');
    }

    // Processa com dados da API, não do webhook
    $this->manager->processarPagamento($pagamento);
}
```

**Exemplo incorreto:**
```php
// Confia nos dados do webhook sem validar — PROIBIDO
public function handleWebhook(): void
{
    $dados = json_decode(file_get_contents('php://input'), true);
    $this->manager->processarPagamento($dados); // dados podem ser forjados
}
```

---

### SEG-025 — Proteção contra replay attack [AVISO]

**Regra:** Webhooks devem verificar o timestamp da requisição. Requisições com mais de 5 minutos de atraso devem ser rejeitadas.

**Verifica:** Em handlers de webhook, buscar comparação de timestamp (`abs(time() - $timestamp) > 300` ou equivalente). Ausência de verificação temporal = AVISO.

**Por quê na BGR:** Replay attack reutiliza uma requisição legítima capturada. Em projetos financeiros da BGR, isso pode significar processar o mesmo pagamento duas vezes. Verificação de timestamp é defesa simples e eficaz contra replay.

**Exemplo correto:**
```php
$timestamp = (int) ($_POST['timestamp'] ?? 0);
$agora = time();

if (abs($agora - $timestamp) > 300) { // 5 minutos
    throw new SecurityException('Requisição expirada.');
}
```

```python
import time
timestamp = int(request.POST.get('timestamp', 0))
if abs(time.time() - timestamp) > 300:
    raise SecurityError('Requisição expirada.')
```

**Exemplo incorreto:**
```php
// Sem verificação de timestamp — aceita requisições de qualquer momento
public function handleWebhook(): void
{
    // processa sem verificar quando a requisição foi gerada
    $this->processar($_POST);
}
```

**Exceções:** Webhooks de serviços que não enviam timestamp. Nesse caso, usar idempotency key para evitar processamento duplicado.

---

## Definition of Done — Checklist de entrega

> PR que não cumpre o DoD não entra em review. É devolvido.

| # | Item | Regras | Verificação |
|---|------|--------|-------------|
| 1 | Queries parametrizadas em toda operação de banco | SEG-001, SEG-002 | Busca por concatenação de variáveis em SQL no diff |
| 2 | Toda entrada sanitizada na fronteira | SEG-003, SEG-015 | Verificar que handlers sanitizam todo input do request |
| 3 | Toda saída escapada por contexto | SEG-004 | Verificar que dados exibidos em HTML/atributos/JS usam escape |
| 4 | Token CSRF validado como primeira operação em handlers de mutação | SEG-006, SEG-007 | Verificar presença e posição da validação CSRF |
| 5 | Ownership verificado antes de ler/alterar/deletar recurso | SEG-008 | Verificar que handlers comparam userId do recurso com usuário autenticado |
| 6 | Roles definidas e verificadas em todo handler | SEG-009, SEG-010 | Verificar presença de ALLOWED_ROLES e checkPermission |
| 7 | Dados sensíveis criptografados antes de persistir | SEG-011, SEG-012 | Verificar que repositórios criptografam campos sensíveis |
| 8 | Sem segredos hardcoded no código | SEG-013, SEG-014 | `grep -rn "password\|secret\|api_key\|token" src/` sem resultados suspeitos |
| 9 | Validação em três níveis (tipo, formato, domínio) | SEG-016, SEG-017 | Verificar que handlers validam tipo + formato + domínio de cada input |
| 10 | Uploads com whitelist de MIME e limite de tamanho | SEG-018, SEG-019 | Verificar verificação de MIME real e limite de bytes |
| 11 | HTTPS obrigatório com TLS 1.2+ | SEG-022 | Verificar configuração do servidor e redirecionamento HTTP→HTTPS |
| 12 | Headers de segurança configurados | SEG-021 | `curl -I https://dominio` e verificar headers obrigatórios |
| 13 | Arquivos sensíveis bloqueados | SEG-023 | `curl https://dominio/.env` retorna 404 |
| 14 | Webhooks com validação anti-spoofing | SEG-024 | Verificar que handler consulta API de origem antes de processar |
| 15 | Whitelist preferida sobre blocklist em validações | SEG-005, SEG-025 | Verificar que validações usam lista de valores permitidos |
| 16 | Operações financeiras atômicas | PHP-054 | Creditar/debitar/transferir usa transação + FOR UPDATE + ROLLBACK. Sem transações aninhadas. |
