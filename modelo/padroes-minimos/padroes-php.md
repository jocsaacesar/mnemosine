---
documento: padroes-php
versao: 4.0.0
criado: 2026-04-08
atualizado: 2026-04-16
total_regras: 44
severidades:
  erro: 27
  aviso: 16
escopo: Todo codigo PHP de todos os projetos BGR Software House
stack: php
aplica_a: [todos]
requer: [padroes-seguranca, padroes-poo]
substitui: [padroes-php v3.0.0]
---

# Padroes de PHP -- BGR Software House

> Documento constitucional. Contrato de entrega entre a BGR e todo
> desenvolvedor que toca PHP nos nossos projetos.
> Codigo que viola regras ERRO nao e discutido -- e devolvido.
>
> 43 regras | IDs: PHP-002 a PHP-051 (com gaps de regras movidas para outros anexos)
> Princípios universais (KISS, YAGNI, SoC, Demeter, SOLID) → padroes-poo.md / skill-executora
> Workflow (commits, SemVer, CHANGELOG) → futuro anexo de processo

---

## Como usar este documento

### Para o desenvolvedor

1. Leia este documento inteiro antes de escrever a primeira linha de codigo em qualquer projeto BGR.
2. Antes de abrir um PR, passe pelo checklist do DoD no final deste documento.
3. Quando receber um apontamento em code review referenciando um ID (ex.: "viola PHP-025"), consulte a regra aqui e corrija.
4. Se discordar de uma regra AVISO, escreva a justificativa no PR. Se discordar de uma regra ERRO, converse com o Joc antes de escrever o codigo.

### Para o auditor (humano ou IA)

1. Leia o frontmatter para entender escopo e dependencias com outros documentos.
2. Audite cada arquivo PHP contra as regras por ID e severidade.
3. Classifique violacoes: ERRO bloqueia merge, AVISO precisa de justificativa escrita.
4. Referencie violacoes pelo ID da regra (ex.: "viola PHP-034 -- excecao generica").
5. Em caso de duvida entre dois documentos, consulte a hierarquia de precedencia no `padroes-modelo.md`.

### Para o Claude Code

1. Ao fazer code review, leia este documento e aplique cada regra relevante ao diff.
2. Referencie violacoes pelo ID exato (ex.: "PHP-025: fromRow() usando new self() viola a regra").
3. Respeite a severidade: ERRO e bloqueante, AVISO e recomendacao forte.
4. Use as cross-references para apontar violacoes em outros documentos quando aplicavel (ex.: "ver tambem SEG-011").
5. Nunca invente regras que nao estao neste documento. Se identificar uma lacuna, reporte ao usuario.

---

## Severidades

| Nivel | Significado | Acao |
|-------|-------------|------|
| **ERRO** | Violacao inegociavel | Bloqueia merge. Corrigir antes de review. |
| **AVISO** | Recomendacao forte | Deve ser justificada por escrito se ignorada. |

---

## 1. Seguranca

> Seguranca vem primeiro porque a BGR lida com dados sensiveis em todos os
> projetos -- financeiros, de saude, educacionais. Um vazamento nao e "bug"
> -- e incidente de compliance.
>
> Regras de seguranca detalhadas vivem em `padroes-seguranca.md`. Esta secao
> cobre apenas o que e especifico de PHP puro.

### PHP-037 -- Dados sensiveis sempre criptografados em repouso [ERRO]

**Regra:** Todo dado sensivel (valores financeiros, dados pessoais, descricoes confidenciais) deve ser criptografado antes de gravar no banco e descriptografado apos leitura. Usar a classe de criptografia do projeto.

**Verifica:** `grep -rn "->inserir\|->insert\|->update\|INSERT INTO\|UPDATE.*SET" inc/repositorios/` — repositorios de entidades sensiveis devem chamar `criptografar()` antes de persistir campos como valor, descricao, dados pessoais.

**Por que na BGR:** A BGR opera sistemas que armazenam dados financeiros e pessoais reais. Um dump de banco exposto sem criptografia entrega o historico completo de cada usuario. A criptografia em repouso e a ultima barreira: mesmo com acesso ao banco, os dados sao inuteis sem a chave.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// Repositorio criptografa ANTES de gravar no banco.
// Mesmo que alguem acesse a tabela diretamente, ve apenas texto cifrado.
$valorCriptografado = $this->cripto->criptografar(
    (string) $lancamento->valorCents()
);
$descricaoCriptografada = $this->cripto->criptografar(
    $lancamento->descricao()
);

$this->repositorio->inserir([
    'user_id'     => $lancamento->userId(),
    'valor_cents' => $valorCriptografado,    // cifrado
    'descricao'   => $descricaoCriptografada, // cifrado
    'status'      => $lancamento->status(),   // status nao e sensivel
]);
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// PERIGO: dados sensiveis gravados em texto puro.
// Qualquer acesso indevido ao banco expoe tudo.
$this->repositorio->inserir([
    'user_id'     => $lancamento->userId(),
    'valor_cents' => $lancamento->valorCents(),  // texto puro!
    'descricao'   => $lancamento->descricao(),    // texto puro!
    'status'      => $lancamento->status(),
]);
```

**Referencias:** SEG-011, SEG-012, SEG-013

---

### PHP-038 -- Queries parametrizadas obrigatorias [ERRO]

**Regra:** Toda query SQL que recebe dados variaveis deve usar prepared statements com placeholders tipados. Sem excecao, mesmo que a variavel venha de outra query interna. A forma especifica de parametrizacao depende do framework (ver WP-001 para WordPress).

**Verifica:** `grep -rn "->query(.*\$\|\".*{\$" inc/` deve retornar vazio. Qualquer interpolacao direta de variavel em SQL e violacao.

**Por que na BGR:** SQL injection e o vetor de ataque numero 1 do OWASP Top 10. Em sistemas que lidam com dados sensiveis, uma injecao pode expor ou corromper registros inteiros. A regra e mecanica, nao contextual: sempre parametrizar, sem julgamento de "parece seguro".

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// Prepared statement com placeholders tipados.
// O driver escapa automaticamente os valores.
$stmt = $pdo->prepare(
    "SELECT * FROM lancamentos WHERE user_id = :userId AND status = :status"
);
$stmt->execute([
    ':userId' => $userId,
    ':status' => $status,
]);
$resultados = $stmt->fetchAll();
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// VULNERAVEL: interpolacao direta permite SQL injection.
// Um $userId malicioso como "1 OR 1=1" retorna todos os registros.
$resultados = $pdo->query(
    "SELECT * FROM lancamentos WHERE user_id = {$userId}"
);
```

**Referencias:** SEG-001, SEG-002

---

### PHP-039 -- Sanitizar entrada, escapar saida [ERRO]

**Regra:** Todo dado que entra no sistema via request deve ser sanitizado antes de qualquer uso. Todo dado que sai para o navegador deve ser escapado com funcoes apropriadas ao contexto (HTML, atributo, URL, JS). As funcoes especificas dependem do framework (ver WP-005, WP-006 para WordPress).

**Verifica:** `grep -rn "echo.*\$_\|echo.*->.*().*;" inc/` — saida sem `htmlspecialchars`/`esc_html` e violacao. `grep -rn "\$_POST\[.*\]\|\$_GET\[.*\]" inc/` fora de handlers indica sanitizacao ausente.

**Por que na BGR:** Handlers sao a fronteira do sistema nos projetos BGR. Dados nao sanitizados que chegam a um gerenciador ou repositorio podem corromper registros ou abrir vetores de XSS. A sanitizacao na entrada e o escape na saida sao duas barreiras complementares -- nenhuma substitui a outra.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// ENTRADA: sanitizar no handler, antes de qualquer uso.
$descricao = trim(strip_tags($_POST['descricao'] ?? ''));
$categoriaId = (int) ($_POST['categoria_id'] ?? 0);

// SAIDA: escapar antes de imprimir no HTML.
echo '<p>' . htmlspecialchars($lancamento->descricao(), ENT_QUOTES, 'UTF-8') . '</p>';
echo '<input value="' . htmlspecialchars($lancamento->nome(), ENT_QUOTES, 'UTF-8') . '">';
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// PERIGO: uso direto de $_POST sem sanitizacao.
$descricao = $_POST['descricao'];

// PERIGO: saida sem escape permite XSS.
echo '<p>' . $lancamento->descricao() . '</p>';
```

**Referencias:** SEG-003, SEG-004

---

### PHP-040 -- Validacao na fronteira do sistema [ERRO]

**Regra:** Handlers validam e sanitizam todos os dados recebidos antes de passar para gerenciadores ou repositorios. Entidades e repositorios confiam que os dados ja chegam limpos. A validacao inclui tipo, formato e dominio (ex.: status so aceita valores da whitelist).

**Verifica:** `grep -rn "\$_POST\|\$_GET\|\$_REQUEST" inc/gerenciadores/ inc/repositorios/ inc/entidades/` deve retornar vazio. Superglobais so aparecem em handlers.

**Por que na BGR:** A arquitetura BGR segue camadas claras (handler > gerenciador > repositorio > entidade). Se a validacao vaza para dentro das camadas internas, cria duplicacao e acoplamento com o request. O handler e a unica porta de entrada -- se ele deixar passar dado sujo, todo o resto esta comprometido.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// O handler e a UNICA camada que toca $_POST.
// Ele sanitiza, valida e so entao delega para o gerenciador.
class CriarLancamentoHandler
{
    public function handle(): void
    {
        // 1. Sanitizacao
        $descricao = trim(strip_tags($_POST['descricao'] ?? ''));
        $valorCents = (int) ($_POST['valor_cents'] ?? 0);
        $status = trim(strip_tags($_POST['status'] ?? ''));

        // 2. Validacao de dominio (whitelist de status validos)
        $statusPermitidos = ['pendente', 'confirmado'];
        if (!in_array($status, $statusPermitidos, true)) {
            $this->responderErro('Status invalido.');
            return;
        }

        // 3. Validacao de obrigatoriedade
        if ($valorCents === 0 || $descricao === '') {
            $this->responderErro('Campos obrigatorios.');
            return;
        }

        // 4. Delega -- o gerenciador recebe dados ja limpos
        $this->gerenciador->criarLancamento($descricao, $valorCents, $status);
    }
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// ERRADO: handler passa dados crus para o gerenciador.
// A validacao deveria ter acontecido AQUI, nao dentro do gerenciador.
class CriarLancamentoHandler
{
    public function handle(): void
    {
        $this->gerenciador->criarLancamento(
            $_POST['descricao'],  // sem sanitizacao!
            $_POST['valor_cents'], // sem conversao de tipo!
            $_POST['status']       // sem whitelist!
        );
    }
}
```

**Referencias:** SEG-015, SEG-016, SEG-017, POO-020

---

### PHP-041 -- Chaves e segredos vivem no .env, nunca no codigo [ERRO]

**Regra:** Chaves de criptografia, tokens de API, credenciais de banco e qualquer segredo devem ser carregados de variaveis de ambiente ou arquivos `.env`. Nunca hardcoded no codigo-fonte.

**Verifica:** `grep -rn "password\|secret\|token\|api_key" inc/ --include="*.php" | grep -v "getenv\|env(\|_ENV"` — qualquer match com string literal hardcoded e violacao.

**Por que na BGR:** O repositorio e compartilhado entre desenvolvedores e o Claude Code. Um segredo commitado no codigo fica acessivel a todos com acesso ao repo -- e ao historico do Git para sempre, mesmo se removido depois. Na BGR, a chave de criptografia protege dados reais; se vazar, todos os dados criptografados ficam expostos.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// A chave vem do ambiente. Nunca aparece no codigo-fonte.
// Em producao, e definida no servidor. Em dev, no .env local.
$chave = getenv('APP_ENCRYPTION_KEY');

if ($chave === false || $chave === '') {
    // Falha explicita e melhor que funcionar sem criptografia.
    throw new ConfiguracaoAusenteException('APP_ENCRYPTION_KEY nao definida.');
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// PERIGO: chave hardcoded no codigo-fonte.
// Qualquer pessoa com acesso ao repo ve esta chave.
// E ela fica no historico do Git PARA SEMPRE.
$chave = 'minha-chave-secreta-hardcoded-12345';
```

**Referencias:** SEG-013, SEG-014

---

## 2. Duplicacao

> Codigo duplicado e a fonte #1 de divergencia silenciosa.


### PHP-002 -- DRY: uma regra, um lugar [ERRO]

**Regra:** Uma regra de negocio e implementada em um unico ponto do sistema. Se o mesmo calculo ou validacao aparece em dois lugares, extrair para um metodo ou classe.

**Verifica:** Inspecao visual em code review: buscar calculos ou validacoes identicas em mais de um arquivo. `grep -rn "<expressao-suspeita>" inc/` com a logica duplicada candidata.

**Por que na BGR:** Na BGR, ja houve caso onde o calculo de valor liquido aparecia tanto no handler de criacao quanto no gerenciador de relatorios. Quando a regra de desconto mudou, so um foi atualizado -- gerando divergencia nos relatorios por semanas. Uma regra, um lugar, zero divergencia.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// O calculo vive na entidade -- unica fonte de verdade.
// Handler, gerenciador e relatorio usam este metodo.
class Lancamento
{
    public function valorLiquido(): int
    {
        // Regra de negocio centralizada: valor - desconto.
        return $this->valorCents - $this->descontoCents;
    }
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// DUPLICACAO: o mesmo calculo em dois lugares.
// Se a regra muda, alguem vai esquecer de atualizar um deles.

// No handler:
$liquido = $valor - $desconto;

// No gerenciador de relatorios (copia da mesma logica):
$liquido = $valor - $desconto;
```

**Referencias:** POO-003, POO-005

---




## 3. Tipagem e strict mode

> PHP sem tipagem e uma arma carregada. Com dados sensiveis,
> um tipo errado nao e "warning" -- e dado corrompido.

### PHP-012 -- Todo arquivo PHP abre com strict_types [ERRO]

**Regra:** Todo arquivo PHP que contem codigo (classes, funcoes, scripts) deve comecar com `declare(strict_types=1)` imediatamente apos a tag de abertura `<?php`.

**Verifica:** `grep -rL "strict_types" inc/` deve retornar vazio. Qualquer arquivo PHP sem essa declaracao e violacao.

**Por que na BGR:** Sem strict_types, o PHP faz coercao silenciosa de tipos: `"123abc"` vira `123` em contexto numerico, sem erro. Em um sistema financeiro, uma coercao silenciosa de `"1500.50"` para `1500` (truncamento) pode significar centavos perdidos em cada transacao. strict_types forca o TypeError imediato, revelando o bug antes que ele corrompa dados.

**Exemplo correto:**
```php
<?php
// strict_types DEVE ser a primeira instrucao, antes de qualquer codigo.
// Isso forca o PHP a rejeitar tipos incompativeis com TypeError.
declare(strict_types=1);

class Lancamento
{
    // Com strict_types, passar "123" (string) para $id (int) gera TypeError.
    public function __construct(
        private readonly int $id,
        private readonly string $nome,
    ) {}
}
```

**Exemplo incorreto:**
```php
<?php
// SEM strict_types, o PHP aceita "123abc" como inteiro sem erro.
// Isso pode corromper dados silenciosamente.
class Lancamento
{
    public function __construct(
        private readonly int $id,
        private readonly string $nome,
    ) {}
}
```

---

### PHP-014 -- Type hints obrigatorios em parametros [ERRO]

**Regra:** Todo parametro de metodo ou funcao deve ter type hint explicito. Sem excecao.

**Verifica:** PHPStan nivel 6+ ou `grep -rn "function.*(\$" inc/` — parametro sem tipo antes do `$` e violacao.

**Por que na BGR:** Type hints sao a documentacao executavel do contrato de um metodo. Na BGR, onde o Claude Code faz code review automatizado, type hints permitem deteccao de incompatibilidades sem executar o codigo. Passar uma string onde se espera um int pode significar operacao aritmetica com tipo errado -- e dados corrompidos.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// Type hints explicitam o contrato: int entra, array sai.
// Qualquer chamada com tipo errado gera TypeError imediato.
public function buscarPorUsuario(int $userId): array
{
    // ...
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// Sem type hint, $userId pode ser qualquer coisa: string, null, array.
// O erro so aparece la dentro da query, se aparecer.
public function buscarPorUsuario($userId)
{
    // ...
}
```

**Referencias:** POO-004

---

### PHP-015 -- Tipo de retorno obrigatorio [ERRO]

**Regra:** Todo metodo deve declarar seu tipo de retorno. Usar `void` para metodos sem retorno. Usar `?Tipo` ou `Tipo|null` para retornos que podem ser nulos.

**Verifica:** `grep -rn "function .*)[^:]" inc/ --include="*.php"` — metodo sem `:` apos os parenteses indica tipo de retorno ausente. PHPStan nivel 6+ detecta automaticamente.

**Por que na BGR:** O tipo de retorno e o contrato de saida do metodo. Na BGR, gerenciadores dependem do retorno de repositorios para tomar decisoes. Um repositorio que retorna `null` quando o gerenciador espera um objeto causa fatal em producao. O tipo de retorno explicito forca a IDE e o PHP a detectarem isso antes do deploy.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// Retorno tipado: quem chama sabe EXATAMENTE o que esperar.
public function calcularSaldo(): int
{
    return $this->valorCents - $this->descontoCents;
}

// Retorno nullable: o chamador sabe que precisa verificar null.
public function buscarOuNulo(int $id): ?Lancamento
{
    // ...
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// Sem tipo de retorno: retorna int? string? null? Ninguem sabe.
public function calcularSaldo()
{
    return $this->valorCents - $this->descontoCents;
}
```

---

### PHP-016 -- Usar tipos union quando necessario, nunca mixed [AVISO]

**Regra:** Quando um metodo pode retornar ou receber mais de um tipo, usar union types (`int|string`). Nunca usar `mixed`, que e o equivalente a "qualquer coisa".

**Verifica:** `grep -rn ": mixed\|mixed \$" inc/` deve retornar vazio. Qualquer uso de `mixed` como tipo e violacao.

**Por que na BGR:** `mixed` elimina toda informacao de tipo -- e o oposto de tipagem forte. Na BGR, code review automatizado (Claude Code) nao consegue validar fluxo de dados quando um metodo retorna `mixed`. Union types documentam exatamente quais tipos sao possiveis, permitindo verificacao estatica.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// Union type: ou retorna a entidade, ou retorna null.
// O chamador sabe que precisa lidar com esses dois casos.
public function encontrar(int $id): Lancamento|null
{
    // ...
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// mixed: pode ser qualquer coisa. String? Int? Array? Null? Objeto?
// Impossivel saber sem ler a implementacao inteira.
public function encontrar(int $id): mixed
{
    // ...
}
```

---

### PHP-017 -- Propriedades tipadas [ERRO]

**Regra:** Toda propriedade de classe deve ter tipo explicito. Propriedades que podem ser nulas usam `?Tipo`.

**Verifica:** `grep -rn "private \$\|protected \$\|public \$" inc/` — propriedade sem tipo entre visibilidade e `$` e violacao.

**Por que na BGR:** Propriedades sem tipo permitem atribuicao de qualquer valor. Em entidades que representam dados sensiveis, uma propriedade `$valorCents` sem tipo pode receber uma string acidentalmente, gerando calculos errados que so aparecem no relatorio final. O tipo na propriedade e a ultima barreira antes do dado corrompido.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

class Lancamento
{
    // Tipos explicitos: o PHP rejeita atribuicao de tipo errado.
    private int $valorCents;
    private string $descricao;
    private ?DateTimeImmutable $prazo; // pode ser null
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

class Lancamento
{
    // Sem tipo: $valorCents pode virar string, null, array...
    // E o PHP nao reclama ate a hora de fazer aritmetica.
    private $valorCents;
    private $descricao;
}
```

---

## 4. Nomenclatura

> Nomes claros eliminam a necessidade de comentarios. Na BGR, onde times enxutos
> leem codigo uns dos outros constantemente, um nome ruim custa tempo de todos.

### PHP-006 -- Classes em PascalCase [ERRO]

**Regra:** Toda classe PHP usa PascalCase (cada palavra inicia com maiuscula, sem separadores).

**Verifica:** `grep -rn "^class [a-z]\|^class .*_" inc/` deve retornar vazio. Classe com inicial minuscula ou underscore e violacao.

**Por que na BGR:** Consistencia de nomenclatura e o que permite que qualquer dev BGR navegue entre projetos sem reaprender convencoes. PascalCase para classes e o padrao PSR-1, e todos os projetos BGR seguem a mesma convencao.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// PascalCase: cada palavra com inicial maiuscula.
class LancamentoRepository {}
class FinanceiroManager {}
class ContaBancaria {}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// snake_case e camelCase nao sao aceitos para classes.
class lancamento_repository {}
class financeiroManager {}
```

---

### PHP-007 -- Metodos e propriedades em camelCase [ERRO]

**Regra:** Todos os metodos e propriedades de classe usam camelCase (primeira palavra minuscula, demais iniciam com maiuscula).

**Verifica:** Inspecao visual: metodos e propriedades devem usar camelCase (PHP generico) ou snake_case (projetos WP). Misturar convencoes no mesmo projeto e violacao.

**Excecao WordPress (Emenda 2026-04-09):** Projetos construidos sobre WordPress seguem a convenção de nomenclatura do WordPress Coding Standards — `snake_case` para metodos, funcoes, propriedades e variaveis. Justificativa: Art. 3° do Engrama (Excelencia Contextual) — consistencia com o ecossistema host e mais valiosa que uniformidade com PSR em projetos WP. O WordPress core inteiro usa snake_case (`get_users()`, `wp_send_json_success()`, `add_action()`); misturar convencoes no mesmo arquivo cria ruido cognitivo. Classes permanecem `PascalCase` (PHP-006, nao conflita). Constantes permanecem `UPPER_SNAKE_CASE` (PHP-008, nao conflita). Aprovado pelo Joc em 2026-04-09.

**Por que na BGR:** camelCase para metodos e propriedades distingue visualmente "o que a classe e" (PascalCase) de "o que a classe faz" (camelCase). Em projetos com dezenas de entidades e repositorios, essa consistencia acelera a leitura do codigo. Em projetos WordPress, snake_case cumpre o mesmo papel por ser a convencao nativa do ecossistema.

**Exemplo correto (PHP generico):**
```php
<?php
declare(strict_types=1);

// camelCase: primeira palavra minuscula, demais com maiuscula.
public function calcularSaldo(): int {}
private int $valorCents;
protected string $nomeCompleto;
```

**Exemplo correto (projetos WordPress):**
```php
<?php
declare(strict_types=1);

// snake_case: convencao WordPress, consistente com o core.
public function calcular_saldo(): int {}
private int $valor_cents;
protected string $nome_completo;
```

**Exemplo incorreto (misturar convencoes no mesmo projeto):**
```php
<?php
declare(strict_types=1);

// ERRADO: camelCase e snake_case misturados no mesmo codebase.
public function calcularSaldo(): int {}
public function get_total_cents(): int {}
```

---

### PHP-008 -- Constantes em UPPER_SNAKE_CASE [ERRO]

**Regra:** Toda constante de classe usa UPPER_SNAKE_CASE (todas maiusculas, palavras separadas por underscore).

**Verifica:** `grep -rn "const [a-z]" inc/` deve retornar vazio. Constante com letra minuscula e violacao.

**Por que na BGR:** Constantes representam valores imutaveis do dominio (status, limites, configuracoes). UPPER_SNAKE_CASE as distingue visualmente de propriedades e metodos. Na BGR, constantes de status (`STATUS_PENDENTE`, `STATUS_CONFIRMADO`) sao usadas na FSM das entidades -- identificacao visual instantanea e critica.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// UPPER_SNAKE_CASE: visualmente distinto de propriedades e metodos.
public const STATUS_ATIVO = 'ativo';
private const MAX_TENTATIVAS = 3;
public const MOEDA_PADRAO = 'BRL';
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// camelCase e PascalCase nao sao aceitos para constantes.
public const statusAtivo = 'ativo';
private const maxTentativas = 3;
```

---

### PHP-009 -- Variaveis locais em camelCase [AVISO]

**Regra:** Variaveis locais (dentro de metodos) usam camelCase. Excecao: variaveis que representam chaves de array vindas do banco (que usam snake_case) podem manter o formato original.

**Verifica:** Inspecao visual em code review: variaveis locais com PascalCase (`$CategoriaId`) ou snake_case fora de contexto WP/banco sao violacao.

**Excecao WordPress (Emenda 2026-04-09):** Mesma excecao de PHP-007 — projetos WordPress usam snake_case para variaveis locais, consistente com o ecossistema.

**Por que na BGR:** Consistencia de nomenclatura em variaveis locais facilita a leitura de metodos longos e reduz ambiguidade. Na BGR, a unica excecao aceita e o mapeamento direto de colunas do banco (`$row->user_id`), onde forcar camelCase criaria confusao. Em projetos WordPress, snake_case e o padrao nativo.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// camelCase para variaveis locais.
$valorTotal = $lancamento->valorCents();
$categoriaId = (int) ($request['categoria_id'] ?? 0);
$estaAtivo = $conta->estaAtiva();
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// snake_case e PascalCase nao sao aceitos para variaveis locais.
$valor_total = $lancamento->valorCents();
$CategoriaId = (int) ($request['categoria_id'] ?? 0);
```

---

### PHP-010 -- Nomes descritivos, sem abreviacoes obscuras [AVISO]

**Regra:** Nomes de variaveis, metodos e classes devem ser descritivos o suficiente para serem entendidos sem contexto adicional. Abreviacoes so sao aceitas quando universais no dominio (ex.: `$id`, `$url`, `$db`).

**Verifica:** Inspecao visual: variaveis de 1-2 letras (`$lr`, `$ca`, `$s`) que nao sejam `$i`/`$id`/`$db`/`$e` sao violacao.

**Por que na BGR:** Na BGR, o Claude Code audita codigo sem acesso ao contexto mental do dev. Nomes como `$lr` ou `$ca` forcam o auditor (humano ou IA) a rastrear a definicao para entender o que a variavel contem. Nomes descritivos tornam o codigo auto-documentado.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// Descritivo: qualquer dev entende sem olhar a definicao.
$lancamentoRepository = new LancamentoRepository($db);
$categoriaAtiva = $categoria->estaAtiva();
$saldoAtualCents = $conta->saldoAtual();
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// Abreviacoes obscuras: o que e "lr"? "ca"? "s"?
$lr = new LancamentoRepository($db);
$ca = $categoria->estaAtiva();
$s = $conta->saldoAtual();
```

---

### PHP-013 -- Sem tag de fechamento PHP [ERRO]

**Regra:** Arquivos que contem apenas PHP nao usam `?>` no final.

**Verifica:** `grep -rl "?>" inc/ --include="*.php"` deve retornar vazio (exceto templates com HTML misto).

**Por que na BGR:** A tag de fechamento `?>` permite whitespace acidental apos ela, que o PHP envia como output. Em handlers que retornam JSON, esse whitespace invisivel corrompe a resposta e causa erros de parsing no frontend. Todos os projetos BGR usam handlers JSON extensivamente -- a tag de fechamento e proibida.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

class Lancamento
{
    // ... codigo da classe
}
// Arquivo termina aqui. Sem ?>
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

class Lancamento
{
    // ... codigo da classe
}
?> 
```

---

## 5. Classes e objetos

> Esta e a maior secao porque define como a BGR modela dominio.
> Entidades ricas, FSM e fromRow() tolerante sao a espinha dorsal
> de todos os projetos BGR.

### PHP-018 -- Visibilidade explicita em tudo [ERRO]

**Regra:** Toda propriedade, metodo e constante deve declarar visibilidade (`public`, `protected`, `private`). Sem excecao.

**Verifica:** `grep -rn "^\s*function \|^\s*const \|^\s*\$" inc/ --include="*.php" | grep -v "public\|private\|protected"` — match indica visibilidade ausente.

**Por que na BGR:** PHP permite omitir visibilidade (default e `public`). Na BGR, visibilidade implicita e proibida porque oculta a intencao do desenvolvedor. Um metodo sem `private` parece publico por acidente, nao por decisao. Em code review, visibilidade explicita permite validar se a API publica da classe esta correta.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

class Lancamento
{
    // Visibilidade explicita em TUDO: propriedade, metodo, constante.
    private int $id;
    private string $status;
    public const STATUS_PENDENTE = 'pendente';

    public function id(): int
    {
        return $this->id;
    }

    private function validarTransicao(string $novo): bool
    {
        return in_array($novo, self::STATUS_TRANSITIONS[$this->status] ?? [], true);
    }
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

class Lancamento
{
    // SEM visibilidade: e public por default, mas foi intencional?
    int $id;
    const STATUS_PENDENTE = 'pendente';

    function id(): int
    {
        return $this->id;
    }
}
```

**Referencias:** POO-004

---

### PHP-019 -- Propriedades readonly quando nao mutaveis [AVISO]

**Regra:** Propriedades que nao mudam apos a construcao do objeto devem ser declaradas como `readonly`.

**Verifica:** Inspecao em construtores: propriedades como `$id`, `$userId`, `$criadoEm` sem `readonly` sao candidatas a violacao. Verificar se ha reatribuicao fora do construtor.

**Por que na BGR:** `readonly` e uma garantia do PHP de que o valor nao sera alterado. Em entidades, o `$id` e o `$userId` nunca mudam depois que o objeto e criado. Sem `readonly`, um bug pode reatribuir o ID de um registro sem que ninguem perceba. A imutabilidade explicita previne classes inteiras de bugs.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// readonly: o PHP garante que esses valores nunca sao reatribuidos.
public function __construct(
    private readonly int $id,
    private readonly string $nome,
    private readonly int $userId,
) {}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// Sem readonly: nada impede que $id seja reatribuido por engano.
public function __construct(
    private int $id,
    private string $nome,
    private int $userId,
) {}
```

**Excecoes:** Propriedades que mudam por lifecycle methods (ex.: `$status` muda via `confirmar()`, `cancelar()`).

**Referencias:** POO-007

---

### PHP-020 -- Construtores via promocao de propriedades [AVISO]

**Regra:** Preferir constructor promotion (PHP 8.0+) para injetar dependencias e definir propriedades.

**Verifica:** Inspecao visual: construtor que declara propriedade + atribui manualmente (`$this->x = $x`) em vez de usar promotion (`private readonly X $x`) e candidato a violacao.

**Por que na BGR:** Constructor promotion reduz boilerplate significativamente. Em repositorios e gerenciadores BGR que recebem 2-4 dependencias, a versao sem promotion tem o dobro de linhas sem nenhum ganho de clareza. Menos codigo = menos lugar para bug.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// Constructor promotion: declaracao + atribuicao em uma unica linha.
// Menos boilerplate, mesma clareza.
class FinanceiroManager
{
    public function __construct(
        private readonly LancamentoRepository $lancamentos,
        private readonly CriptografiaInterface $cripto,
    ) {}
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// Verboso: 2 propriedades + 2 atribuicoes = 4 linhas extras.
// Nenhuma informacao nova em relacao ao promotion.
class FinanceiroManager
{
    private LancamentoRepository $lancamentos;
    private CriptografiaInterface $cripto;

    public function __construct(
        LancamentoRepository $lancamentos,
        CriptografiaInterface $cripto
    ) {
        $this->lancamentos = $lancamentos;
        $this->cripto = $cripto;
    }
}
```

---


### PHP-022 -- Entidades ricas, nao anemicas [ERRO]

**Regra:** Entidades contem logica de dominio: predicados de estado, transicoes, validacoes de regra de negocio. Nunca devem ser apenas sacos de getters e setters.

**Verifica:** `grep -rn "function set[A-Z]" inc/entidades/` deve retornar vazio. Setters publicos indicam entidade anemica. Entidades devem ter predicados (`esta*`, `pode*`) ou lifecycle methods.

**Por que na BGR:** Na BGR, a logica de "um lancamento pendente pode ser confirmado, mas um cancelado nao pode" PERTENCE a entidade Lancamento. Se essa logica fica no gerenciador, qualquer novo gerenciador pode ignorar a restricao e confirmar um lancamento cancelado. Entidades ricas protegem invariantes de negocio na fonte.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// Entidade RICA: contem logica de dominio, predicados, transicoes.
// Nenhum codigo externo consegue violar as regras de transicao.
class Lancamento
{
    // Predicado: responde sobre o estado sem expor a propriedade.
    public function estaConfirmado(): bool
    {
        return $this->status === self::STATUS_CONFIRMADO;
    }

    // Lifecycle method: transicao com validacao embutida.
    public function confirmar(): void
    {
        if ($this->status !== self::STATUS_PENDENTE) {
            throw new TransicaoInvalidaException(
                $this->status,
                self::STATUS_CONFIRMADO
            );
        }
        $this->status = self::STATUS_CONFIRMADO;
    }

    // Calculo de negocio: centralizado na entidade.
    public function valorLiquido(): int
    {
        return $this->valorCents - $this->descontoCents;
    }
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// Entidade ANEMICA: apenas getters e setters.
// Qualquer codigo externo pode setar status para qualquer valor.
// Nenhuma regra de negocio e protegida.
class Lancamento
{
    public function getStatus(): string
    {
        return $this->status;
    }

    // PERIGO: permite setar "confirmado" mesmo que o atual seja "cancelado".
    public function setStatus(string $status): void
    {
        $this->status = $status;
    }
}
```

**Referencias:** POO-003, POO-017

---

### PHP-023 -- Getters sem prefixo get_ [ERRO]

**Regra:** Metodos de acesso usam o nome da propriedade diretamente, sem prefixo `get`. Predicados booleanos usam `esta`, `foi`, `pode`, `tem`.

**Verifica:** `grep -rn "function get[A-Z]" inc/entidades/` deve retornar vazio. `grep -rn "function is[A-Z]" inc/entidades/` — usar `esta`/`foi`/`pode`/`tem` em vez de `is`.

**Por que na BGR:** Padrao BGR deliberado: `$lancamento->valorCents()` e mais limpo que `$lancamento->getValorCents()`. Em cadeias de leitura que aparecem em templates e relatorios, o prefixo `get` e ruido visual que nao agrega informacao. Predicados com verbos em portugues (`estaAtiva()`, `foiCancelado()`) leem como linguagem natural.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// Acessores: nome da propriedade, sem prefixo.
public function id(): int { return $this->id; }
public function nome(): string { return $this->nome; }
public function valorCents(): int { return $this->valorCents; }

// Predicados: verbos descritivos em portugues.
public function estaConfirmado(): bool { return $this->status === self::STATUS_CONFIRMADO; }
public function temConta(): bool { return $this->contaId !== null; }
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// Prefixo get_ e proibido nos projetos BGR.
public function getId(): int { return $this->id; }
public function getNome(): string { return $this->nome; }
public function getValorCents(): int { return $this->valorCents; }
public function isConfirmado(): bool { return $this->status === self::STATUS_CONFIRMADO; }
```

**Referencias:** POO-002

---

### PHP-024 -- FSM na entidade via STATUS_TRANSITIONS [ERRO]

**Regra:** Entidades com estado definem suas transicoes validas como constante `STATUS_TRANSITIONS` e expoem lifecycle methods para cada transicao. O metodo `podeTransicionarPara()` e obrigatorio.

**Verifica:** `grep -rn "STATUS_TRANSITIONS" inc/entidades/` — toda entidade com `$status` deve ter essa constante. `grep -rn "podeTransicionarPara" inc/entidades/` confirma metodo obrigatorio.

**Por que na BGR:** Sem FSM explicita, transicoes de estado sao controladas por logica espalhada em gerenciadores e handlers. Na BGR, ja houve caso onde a ausencia de FSM permitiu que um registro cancelado fosse "reconfirmado" por um handler que nao verificava o estado anterior. Com FSM na entidade, a transicao invalida e impossivel -- a entidade se protege.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

class Lancamento
{
    public const STATUS_PENDENTE = 'pendente';
    public const STATUS_CONFIRMADO = 'confirmado';
    public const STATUS_CANCELADO = 'cancelado';

    // Mapa de transicoes: de cada status, quais destinos sao validos.
    public const STATUS_TRANSITIONS = [
        self::STATUS_PENDENTE   => [self::STATUS_CONFIRMADO, self::STATUS_CANCELADO],
        self::STATUS_CONFIRMADO => [self::STATUS_CANCELADO],
        self::STATUS_CANCELADO  => [], // estado terminal, sem saida
    ];

    // Lifecycle method: transicao validada pela FSM.
    public function confirmar(): void
    {
        if (!$this->podeTransicionarPara(self::STATUS_CONFIRMADO)) {
            throw new TransicaoInvalidaException(
                $this->status,
                self::STATUS_CONFIRMADO
            );
        }
        $this->status = self::STATUS_CONFIRMADO;
    }

    public function cancelar(): void
    {
        if (!$this->podeTransicionarPara(self::STATUS_CANCELADO)) {
            throw new TransicaoInvalidaException(
                $this->status,
                self::STATUS_CANCELADO
            );
        }
        $this->status = self::STATUS_CANCELADO;
    }

    // Metodo de consulta: pode ser usado por UIs para habilitar/desabilitar botoes.
    public function podeTransicionarPara(string $novoStatus): bool
    {
        return in_array(
            $novoStatus,
            self::STATUS_TRANSITIONS[$this->status] ?? [],
            true
        );
    }
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// SEM FSM: qualquer status pode virar qualquer outro.
// Nao existe constante de transicoes, nao existe validacao.
class Lancamento
{
    public function setStatus(string $status): void
    {
        // Aceita QUALQUER valor. "cancelado" -> "confirmado"? Ok.
        // "pendente" -> "xpto_inventado"? Ok tambem.
        $this->status = $status;
    }
}
```

**Referencias:** POO-017

---

### PHP-025 -- fromRow() tolerante, nunca lanca exception [ERRO]

**Regra:** O metodo `fromRow()` converte uma linha do banco de dados em uma instancia da entidade. Ele NUNCA lanca exception. Usa `ReflectionClass::newInstanceWithoutConstructor()` para bypassar validacoes do construtor. Dados do banco sao fato consumado -- nao cabe ao hidratador rejeitar o que ja esta persistido.

**Verifica:** `grep -rn "new self\|new static" inc/entidades/` dentro de `fromRow()` e violacao. `grep -rn "newInstanceWithoutConstructor" inc/entidades/` deve ter match em toda entidade com `fromRow()`.

**Por que na BGR:** Na BGR, houve fatal em producao causado por `fromRow()` usando `new self()`. O construtor validava campos obrigatorios e lancava exception quando um campo legacy estava vazio no banco. Resultado: pagina inteira fora do ar porque a hidratacao explodia em dados historicos que nao tinham o campo. A regra nasceu desse incidente: fromRow() nao julga, fromRow() hidrata.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// fromRow() TOLERANTE: usa Reflection para pular o construtor.
// Nunca lanca exception. Dados do banco sao fato consumado.
public static function fromRow(object $row): self
{
    // newInstanceWithoutConstructor() pula toda validacao do __construct.
    // Isso e intencional: dados do banco ja existem, nao precisam ser validados.
    $entity = (new \ReflectionClass(self::class))
        ->newInstanceWithoutConstructor();

    // Cast explicito para cada propriedade.
    // Se o campo nao existe no $row, usar valor default seguro.
    $entity->id = (int) ($row->id ?? 0);
    $entity->nome = (string) ($row->nome ?? '');
    $entity->status = (string) ($row->status ?? self::STATUS_PENDENTE);
    $entity->valorCents = (int) ($row->valor_cents ?? 0);

    return $entity;
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// PERIGO: new self() passa pelo construtor, que pode validar e lancar exception.
// Se o banco tem dados legacy com campo vazio, FATAL em producao.
public static function fromRow(object $row): self
{
    return new self(
        id: (int) $row->id,
        nome: (string) $row->nome,    // construtor valida campo obrigatorio
        status: (string) $row->status, // construtor pode lancar exception aqui
    );
}
```

---

### PHP-026 -- Entidades nao dependem de infraestrutura [ERRO]

**Regra:** Classes de entidade (`inc/entidades/`) nunca importam acesso a banco, classes de repositorio, servicos externos ou qualquer dependencia de infraestrutura. Entidades contem logica de dominio pura.

**Verifica:** `grep -rn "use.*Repository\|use.*PDO\|use.*wpdb\|global \$wpdb" inc/entidades/` deve retornar vazio.

**Por que na BGR:** Entidades BGR sao a camada mais interna do sistema. Se uma entidade depende de acesso a banco, ela nao pode ser testada sem infraestrutura. Na BGR, testes unitarios de entidades devem rodar em milissegundos, sem setup. Alem disso, entidades sao compartilhadas entre projetos -- acoplar a infraestrutura impede a reutilizacao.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// Entidade PURA: nenhuma dependencia de infraestrutura.
// Pode ser testada com new Lancamento() sem banco, sem framework.
class Lancamento
{
    public function estaConfirmado(): bool
    {
        return $this->status === self::STATUS_CONFIRMADO;
    }

    public function valorLiquido(): int
    {
        return $this->valorCents - $this->descontoCents;
    }
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// ERRADO: entidade acoplada a infraestrutura (acesso direto ao banco).
// Impossivel testar sem banco. Impossivel reutilizar fora do framework.
class Lancamento
{
    public function salvar(\PDO $pdo): void
    {
        $stmt = $pdo->prepare("INSERT INTO lancamentos (valor_cents) VALUES (:val)");
        $stmt->execute([':val' => $this->valorCents]);
    }
}
```

**Referencias:** POO-017, PHP-004

---




## 6. Metodos

> Metodos sao a unidade atomica de trabalho. Se um metodo esta complexo,
> a classe provavelmente esta fazendo demais.

### PHP-030 -- Maximo 20 linhas por metodo [AVISO]

**Regra:** Se um metodo ultrapassa 20 linhas de codigo (excluindo linhas em branco e comentarios), provavelmente faz mais de uma coisa. Extrair submetodos com nomes descritivos.

**Verifica:** Contagem visual de linhas de codigo por metodo (excluindo brancos e comentarios). Metodo com >20 loc e candidato a violacao.

**Por que na BGR:** Na BGR, code review e feito por dev + Claude Code. Metodos longos dificultam ambos: o dev perde o contexto, o Claude Code tem mais chances de falhar na analise. Metodos curtos com nomes descritivos sao auto-documentados e mais faceis de testar unitariamente.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// Metodo principal: 5 linhas, delegando para submetodos nomeados.
// Cada submetodo tem responsabilidade unica e nome descritivo.
public function processarLancamento(Lancamento $lancamento): void
{
    $this->validarLancamento($lancamento);
    $this->aplicarRegrasDeNegocio($lancamento);
    $this->persistir($lancamento);
    $this->notificarObservadores($lancamento);
}

private function validarLancamento(Lancamento $lancamento): void
{
    if (!$lancamento->temConta()) {
        throw new LancamentoSemContaException();
    }
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// Metodo com 40+ linhas fazendo validacao, calculo, persistencia e notificacao.
// Impossivel saber o que cada bloco faz sem ler linha por linha.
public function processarLancamento(Lancamento $lancamento): void
{
    if (!$lancamento->temConta()) { throw new LancamentoSemContaException(); }
    if ($lancamento->estaCancelado()) { return; }
    $valor = $lancamento->valorCents();
    $desconto = $lancamento->descontoCents();
    $liquido = $valor - $desconto;
    // ... mais 30 linhas de logica misturada
}
```

---

### PHP-031 -- Retorno antecipado (early return) [AVISO]

**Regra:** Reduzir aninhamento usando guard clauses. Casos invalidos ou triviais saem cedo, a logica principal fica no final sem indentacao extra.

**Verifica:** Inspecao visual: metodo com >2 niveis de indentacao de `if` aninhado e candidato a refatoracao com early return.

**Por que na BGR:** Na BGR, handlers validam multiplas condicoes antes de delegar. Sem early return, o handler vira uma piramide de `if` aninhados. Early return mantem o codigo linear: cada guarda elimina um caso, e a logica principal fica no nivel base de indentacao.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// Guard clauses eliminam casos invalidos no inicio.
// A logica principal fica no final, sem aninhamento.
public function processar(Lancamento $lancamento): void
{
    // Guarda 1: caso trivial, sai cedo.
    if ($lancamento->estaCancelado()) {
        return;
    }

    // Guarda 2: caso invalido, lanca exception.
    if (!$lancamento->temConta()) {
        throw new LancamentoSemContaException();
    }

    // Logica principal: sem aninhamento, facil de ler.
    $lancamento->confirmar();
    $this->repositorio->salvar($lancamento);
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// Piramide de ifs aninhados: dificil de ler, facil de errar.
public function processar(Lancamento $lancamento): void
{
    if (!$lancamento->estaCancelado()) {
        if ($lancamento->temConta()) {
            // Logica principal enterrada em 2 niveis de indentacao.
            $lancamento->confirmar();
            $this->repositorio->salvar($lancamento);
        } else {
            throw new LancamentoSemContaException();
        }
    }
}
```

---

### PHP-032 -- Maximo 4 parametros por metodo [AVISO]

**Regra:** Se um metodo precisa de mais de 4 parametros, considerar um Value Object ou DTO para agrupar os dados relacionados.

**Verifica:** `grep -rn "function.*\$.*\$.*\$.*\$.*\$" inc/` — match com 5+ `$` na assinatura indica >4 parametros.

**Por que na BGR:** Metodos com muitos parametros sao dificeis de chamar corretamente (qual parametro e qual?), dificeis de testar (muitas combinacoes) e indicam que o metodo faz coisas demais. Na BGR, quando um handler precisa passar muitos dados para o gerenciador, o padrao e criar um DTO.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// DTO agrupa dados relacionados em um unico objeto tipado.
// O metodo recebe UM parametro com significado claro.
class CriarLancamentoDTO
{
    public function __construct(
        public readonly int $userId,
        public readonly string $descricao,
        public readonly int $valorCents,
        public readonly int $categoriaId,
        public readonly string $status,
    ) {}
}

public function criarLancamento(CriarLancamentoDTO $dados): Lancamento
{
    // $dados->userId, $dados->descricao, etc.
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// 5 parametros: qual e qual na hora de chamar? Facil de inverter.
public function criarLancamento(
    int $userId,
    string $descricao,
    int $valorCents,
    int $categoriaId,
    string $status
): Lancamento {
    // ...
}
```

**Referencias:** POO-014

---

### PHP-033 -- Metodos publicos de entidade como predicados descritivos [AVISO]

**Regra:** Metodos de entidade que respondem perguntas sobre o estado do objeto devem ter nomes que leem como perguntas naturais em portugues: `esta*()`, `foi*()`, `pode*()`, `tem*()`.

**Verifica:** `grep -rn "->get.*() ==\|->get.*() ===\|->get.*() !=" inc/` — comparacao com getter fora da entidade indica predicado faltante na entidade.

**Por que na BGR:** Na BGR, predicados descritivos tornam o codigo de gerenciadores e handlers legivel como prosa: `if ($lancamento->estaConfirmado())` le como portugues natural. Isso reduz a distancia entre o requisito de negocio e o codigo que o implementa, facilitando code review por todos -- inclusive pelo Joc revisando logica de negocio.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// Predicados que leem como perguntas naturais.
$lancamento->estaConfirmado();  // "o lancamento esta confirmado?"
$conta->estaAtiva();            // "a conta esta ativa?"
$meta->foiAtingida();           // "a meta foi atingida?"
$lancamento->podeCancelar();    // "o lancamento pode cancelar?"
$conta->temSaldo();             // "a conta tem saldo?"
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// Expor propriedade interna e comparar fora da entidade.
// Viola encapsulamento e nao le como linguagem natural.
$lancamento->getStatus() === 'confirmado';
$conta->getAtiva() === true;
$meta->getValorAtual() >= $meta->getValorAlvo();
```

**Referencias:** POO-002, POO-005

---

## 7. Tratamento de erros

> Erros silenciados sao a pior categoria de bug: o sistema parece funcionar,
> mas os dados estao errados. Na BGR, onde lidamos com dados sensiveis,
> um erro silenciado pode significar dado errado no relatorio.

### PHP-034 -- Excecoes tipadas, nunca genericas [ERRO]

**Regra:** Toda excecao lancada deve ser de uma classe especifica do dominio. Nunca usar `\Exception`, `\RuntimeException` ou `\LogicException` diretamente.

**Verifica:** `grep -rn "new \\\\Exception\|new \\\\RuntimeException\|new \\\\LogicException" inc/` deve retornar vazio.

**Por que na BGR:** Excecoes tipadas permitem tratamento granular: o handler pode capturar `SaldoInsuficienteException` e retornar uma mensagem amigavel, enquanto `RegistroNaoEncontradoException` retorna um 404. Com `\Exception` generica, o handler nao sabe o que aconteceu e nao pode tomar decisoes. Na BGR, cada tipo de erro tem uma resposta diferente para o usuario.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// Excecao tipada: o handler sabe EXATAMENTE o que aconteceu.
// Pode retornar uma mensagem especifica para o usuario.
throw new SaldoInsuficienteException(
    $conta->id(),
    $valorSolicitado,
    $conta->saldoAtual()
);

throw new RegistroNaoEncontradoException($id);
throw new TransicaoInvalidaException($statusAtual, $statusDesejado);
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// Excecao generica: o handler nao sabe se e saldo, se e permissao,
// se e dado nao encontrado. So consegue mostrar a mensagem crua.
throw new \Exception('Saldo insuficiente');
throw new \RuntimeException('Nao encontrado');
```

**Referencias:** POO-002

---

### PHP-035 -- Nunca silenciar erros com @ [ERRO]

**Regra:** O operador `@` de supressao de erros e proibido. Erros devem ser tratados explicitamente com verificacao de retorno ou try/catch.

**Verifica:** `grep -rn "@\$\|@file\|@json\|@array\|@unlink\|@fopen\|@mail" inc/` deve retornar vazio.

**Por que na BGR:** O `@` esconde erros que podem indicar problemas reais: falha de parse em JSON, arquivo de configuracao corrompido, funcao depreciada. Na BGR, um `@json_decode()` em dados sensiveis pode retornar `null` silenciosamente, e o sistema segue processando como se o dado fosse vazio. O erro real so aparece dias depois, quando o relatorio sai errado.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// Tratamento explicito: se o JSON e invalido, sabemos imediatamente.
$resultado = json_decode($json, true);
if (json_last_error() !== JSON_ERROR_NONE) {
    throw new JsonInvalidoException(json_last_error_msg());
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// @ esconde o erro. Se o JSON for invalido, $resultado e null
// e o sistema continua processando null como se fosse um array valido.
$resultado = @json_decode($json, true);
```

---

### PHP-036 -- Catch especifico, nunca \Throwable generico [AVISO]

**Regra:** Blocos catch devem capturar excecoes especificas. Nunca capturar `\Throwable` ou `\Exception` genericos, a menos que seja no handler de ultimo recurso que deve sempre retornar uma resposta valida.

**Verifica:** `grep -rn "catch.*\\\\Throwable\|catch.*\\\\Exception[^a-zA-Z]" inc/` — match fora de handlers de ultimo recurso e violacao.

**Por que na BGR:** `catch (\Throwable)` engole TUDO: TypeError, OutOfMemoryError, erros de logica. Na BGR, ja houve caso onde catch generico num repositorio escondia TypeError causado por dado corrompido -- o registro era silenciosamente ignorado e nao aparecia nos relatorios. Catch especifico garante que so tratamos o que sabemos tratar.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// Catch especifico: sabemos exatamente o que estamos tratando.
try {
    $this->repositorio->salvar($lancamento);
} catch (DuplicataException $e) {
    // Tratar especificamente: registro duplicado.
    $this->responderErro('Registro ja existe.');
}
// TypeError, OutOfMemory, etc. propagam naturalmente -- como devem.
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// Catch generico: engole TypeError, OutOfMemory, qualquer coisa.
// Se der problema de memoria, o sistema "trata" como duplicata.
try {
    $this->repositorio->salvar($lancamento);
} catch (\Throwable $e) {
    // "Tratar tudo" == nao tratar nada direito.
    error_log($e->getMessage());
}
```

**Excecoes:** Handlers de request que precisam SEMPRE retornar resposta valida podem ter um catch generico como ultimo recurso, desde que faca log e retorne erro generico.

---

## 8. Performance

> Otimizacao prematura e raiz de todo mal, mas problemas de performance
> conhecidos sao proibidos. Esta secao cobre os padroes que ja causaram
> problemas reais na BGR.

### PHP-042 -- Nao otimizar prematuramente [AVISO]

**Regra:** Otimizacoes de performance (cache, desnormalizacao, queries complexas com JOINs multiplos) so entram quando ha medicao comprovando o gargalo. Codigo claro e correto primeiro, otimizado depois com dados.

**Verifica:** Inspecao em code review: query com >2 JOINs, cache manual ou desnormalizacao deve ter comentario com medicao que justifique. Sem medicao = violacao.

**Por que na BGR:** Projetos BGR sao sistemas internos com dezenas a centenas de usuarios simultaneos, nao milhoes. A maioria dos gargalos percebidos sao falsos positivos. Na BGR, codigo "otimizado" prematuramente ja gerou queries ilegiveis que ninguem conseguia debugar. Clareza e correcao vencem performance percebida.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// Codigo claro e direto. Se performance virar problema,
// medimos com profiling e otimizamos com dados concretos.
public function buscarLancamentosDoMes(int $userId, string $mesAno): array
{
    $lancamentos = $this->repositorio->buscarPorUsuarioEMes($userId, $mesAno);

    // Filtro em PHP -- claro, testavel, debugavel.
    return array_filter(
        $lancamentos,
        fn(Lancamento $l) => $l->estaConfirmado()
    );
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// "Otimizacao" prematura: query complexa com subquery e CASE
// para evitar o filtro em PHP. Ninguem vai entender daqui 3 meses.
// E nao tem medicao provando que o filtro em PHP era um problema.
$sql = "SELECT *, (CASE WHEN status = 'confirmado' THEN 1 ELSE 0 END) as is_conf
        FROM lancamentos
        WHERE user_id = :userId
        AND DATE_FORMAT(created_at, '%Y-%m') = :mesAno
        HAVING is_conf = 1";
```

---

### PHP-050 -- Queries dentro de loops sao proibidas [ERRO]

**Regra:** Nunca executar queries SQL dentro de loops (`for`, `foreach`, `while`, `array_map`). Toda operacao que precisa de dados para uma colecao deve usar uma unica query com `WHERE IN` ou equivalente, e processar os resultados em memoria.

**Verifica:** Inspecao visual: qualquer chamada a repositorio/`$wpdb`/`$pdo` dentro de `foreach`/`for`/`while`/`array_map` e violacao. `grep -A5 "foreach\|for (" inc/ | grep "->buscar\|->find\|->query"` ajuda a detectar.

**Por que na BGR:** Na BGR, dashboards exibem dezenas de registros, cada um com relacoes. Uma query por iteracao transforma uma listagem de 50 itens em 50+ queries ao banco. Em producao, isso ja causou timeouts em relatorios. A regra e absoluta: se tem loop, nao tem query dentro.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// UMA query busca TODOS os registros de uma vez.
// O loop processa apenas dados ja carregados em memoria.
$lancamentos = $this->repositorio->buscarPorIds($ids);

// Indexar por ID para acesso rapido O(1) por registro.
$lancamentosPorId = [];
foreach ($lancamentos as $lancamento) {
    $lancamentosPorId[$lancamento->id()] = $lancamento;
}

// Agora usar o mapa -- sem query adicional.
foreach ($ids as $id) {
    $lancamento = $lancamentosPorId[$id] ?? null;
    if ($lancamento !== null) {
        $resultados[] = $lancamento->toArray();
    }
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// N+1 PROBLEM: uma query por iteracao.
// 50 registros = 50 queries ao banco. Timeout garantido.
foreach ($ids as $id) {
    // ERRADO: query dentro de loop!
    $lancamento = $this->repositorio->buscarPorId($id);
    $resultados[] = $lancamento->toArray();
}
```

**Excecoes:** Operacoes que exigem atomicidade individual (ex.: transacoes onde cada uma precisa de lock proprio). Nesse caso, documentar o motivo no codigo.

---

### PHP-051 -- Erros criticos devem ir para o monitoramento [ERRO]

**Regra:** Toda excecao nao tratada e todo erro critico (falha de criptografia, falha de conexao com banco, transicao de estado invalida em operacao sensivel) deve ser registrado no sistema de monitoramento via `error_log()` com contexto suficiente para diagnostico. Nunca engolir erros silenciosamente.

**Verifica:** `grep -B2 -A5 "catch" inc/ | grep -L "error_log\|throw"` — bloco catch sem `error_log()` nem re-throw e violacao (erro engolido).

**Por que na BGR:** Na BGR, erros silenciosos ja causaram situacoes onde dados ficavam inconsistentes por dias sem que ninguem percebesse. Em um caso, uma migration sem lock duplicou dados varias vezes e so foi detectada porque um usuario reportou -- nao pelo sistema. Monitoramento proativo e obrigatorio: se algo quebrou, a equipe precisa saber antes do usuario.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// Registrar erro com contexto suficiente para diagnostico.
// Quem? O que? Quando? Qual dado? Qual operacao?
try {
    $this->repositorio->salvar($lancamento);
} catch (DuplicataException $e) {
    // Log com contexto: usuario, entidade, operacao, erro.
    error_log(sprintf(
        '[BGR][ERRO] Duplicata ao salvar lancamento. user_id=%d, lancamento_id=%d, erro=%s',
        $lancamento->userId(),
        $lancamento->id(),
        $e->getMessage()
    ));

    // Re-lancar ou tratar -- mas NUNCA engolir silenciosamente.
    throw $e;
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// ERRADO: catch vazio engole o erro. Ninguem fica sabendo.
// O registro nao foi salvo, mas o sistema segue como se nada tivesse acontecido.
try {
    $this->repositorio->salvar($lancamento);
} catch (\Throwable $e) {
    // silencio... o usuario nunca vai saber que o dado se perdeu
}
```

**Referencias:** PHP-034, PHP-035, PHP-036

---

## 9. Estrutura de arquivos e formatacao

> Estrutura previsivel permite que qualquer dev encontre qualquer arquivo
> em menos de 5 segundos. Formatacao consistente elimina discussoes de
> estilo em code review. Na BGR, essas regras sao mecanicas -- nao exigem
> julgamento.

### PHP-011 -- Um arquivo por classe [ERRO]

**Regra:** Cada classe PHP vive em seu proprio arquivo. O nome do arquivo e o nome da classe seguido de `.php`.

**Verifica:** `grep -rn "^class " inc/ --include="*.php" -l | sort | uniq -d` — arquivo com >1 classe e violacao. Nome do arquivo deve coincidir com o nome da classe.

**Por que na BGR:** Um arquivo por classe e pre-requisito para autoloading (PSR-4) e para navegacao rapida no projeto. Na BGR, a convencao de pastas (`entidades/`, `repositorios/`, `gerenciadores/`, `handlers/`) depende de um arquivo por classe para funcionar. Duas classes no mesmo arquivo significam que uma delas esta na pasta errada.

**Exemplo correto:**
```
inc/entidades/Lancamento.php              <-- classe Lancamento
inc/entidades/ContaBancaria.php           <-- classe ContaBancaria
inc/repositorios/LancamentoRepository.php <-- classe LancamentoRepository
inc/gerenciadores/FinanceiroManager.php   <-- classe FinanceiroManager
inc/handlers/CriarLancamentoHandler.php   <-- classe CriarLancamentoHandler
```

**Exemplo incorreto:**
```
inc/entidades/Financeiro.php  <-- contem Lancamento E ContaBancaria no mesmo arquivo
inc/utils/helpers.php         <-- contem 5 classes soltas
```

**Referencias:** POO-001

---

### PHP-043 -- Indentacao com 4 espacos [ERRO]

**Regra:** Toda indentacao usa 4 espacos. Nunca tabs. Sem excecao.

**Verifica:** `grep -rPn "\t" inc/ --include="*.php"` deve retornar vazio. Qualquer tab e violacao.

**Por que na BGR:** Tabs renderizam diferente em cada editor e em cada ferramenta de diff. Na BGR, onde code review acontece no GitHub e no Claude Code, a renderizacao inconsistente de tabs causa confusao visual. 4 espacos e deterministico: parece igual em todos os lugares.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

class Lancamento
{
    // 4 espacos de indentacao em cada nivel.
    public function valorCents(): int
    {
        return $this->valorCents;
    }
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

class Lancamento
{
	// Tab: renderiza como 2, 4 ou 8 espacos dependendo do editor.
	public function valorCents(): int
	{
		return $this->valorCents;
	}
}
```

---

### PHP-044 -- Chaves na mesma linha para estruturas de controle [AVISO]

**Regra:** Em estruturas de controle (`if`, `else`, `for`, `foreach`, `while`, `switch`), a chave de abertura fica na mesma linha da instrucao.

**Verifica:** `grep -rPn "^\s*(if|else|for|foreach|while|switch).*\n\s*\{" inc/` — chave de abertura na linha seguinte de estrutura de controle e violacao.

**Por que na BGR:** Seguimos PSR-12 para estruturas de controle. Chaves na mesma linha economizam linhas verticais, mantendo mais codigo visivel na tela. Em metodos de 20 linhas (PHP-030), cada linha conta.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// Chave na mesma linha da instrucao de controle.
if ($lancamento->estaConfirmado()) {
    return $lancamento->valorCents();
}

foreach ($lancamentos as $lancamento) {
    $total += $lancamento->valorCents();
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// Chave na linha seguinte para controle: desperdica espaco vertical.
if ($lancamento->estaConfirmado())
{
    return $lancamento->valorCents();
}
```

---

### PHP-045 -- Chaves na linha seguinte para classes e metodos [AVISO]

**Regra:** Em declaracoes de classes e metodos, a chave de abertura fica na linha seguinte (estilo Allman).

**Verifica:** `grep -rn "class.*{$\|function.*){.*{$" inc/` — chave `{` na mesma linha de declaracao de classe ou metodo e violacao.

**Por que na BGR:** PSR-12 diferencia classes/metodos (chave na proxima linha) de controles (chave na mesma linha). Na BGR, essa distincao visual ajuda a identificar rapidamente onde comeca uma classe ou metodo versus um bloco de controle.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// Classe: chave na proxima linha.
class Lancamento
{
    // Metodo: chave na proxima linha.
    public function valorCents(): int
    {
        return $this->valorCents;
    }
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// Classe com chave na mesma linha: nao segue PSR-12.
class Lancamento {
    public function valorCents(): int {
        return $this->valorCents;
    }
}
```

---

### PHP-046 -- Linha em branco entre metodos [AVISO]

**Regra:** Todo metodo e separado do proximo por exatamente uma linha em branco.

**Verifica:** Inspecao visual: dois metodos consecutivos sem linha em branco entre `}` e a proxima declaracao `public`/`private`/`protected` e violacao.

**Por que na BGR:** Linhas em branco entre metodos criam separacao visual que facilita a leitura rapida. Na BGR, entidades ricas podem ter 10+ metodos (acessores, predicados, lifecycle methods). Sem separacao, o codigo vira um bloco monolitico ilegivel.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

public function id(): int
{
    return $this->id;
}

public function nome(): string
{
    return $this->nome;
}

public function estaConfirmado(): bool
{
    return $this->status === self::STATUS_CONFIRMADO;
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

public function id(): int
{
    return $this->id;
}
public function nome(): string
{
    return $this->nome;
}
public function estaConfirmado(): bool
{
    return $this->status === self::STATUS_CONFIRMADO;
}
```

---

### PHP-047 -- Maximo 120 caracteres por linha [AVISO]

**Regra:** Nenhuma linha de codigo deve ultrapassar 120 caracteres. Quebrar linhas longas com alinhamento coerente.

**Verifica:** `awk 'length > 120' inc/**/*.php` — qualquer linha retornada e violacao.

**Por que na BGR:** Code review no GitHub e no Claude Code usa janelas de largura fixa. Linhas longas forcam scroll horizontal, que oculta parte do codigo durante review. 120 caracteres acomoda a maioria das chamadas de metodo e queries sem quebra forcada.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// Linha longa quebrada com alinhamento coerente.
$stmt = $pdo->prepare(
    "SELECT * FROM lancamentos WHERE user_id = :userId AND status = :status ORDER BY created_at DESC"
);
$stmt->execute([
    ':userId' => $userId,
    ':status' => $status,
]);
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// Linha unica com 150+ caracteres: scroll horizontal no review.
$stmt = $pdo->prepare("SELECT * FROM lancamentos WHERE user_id = :userId AND status = :status ORDER BY created_at DESC LIMIT 100");
$stmt->execute([':userId' => $userId, ':status' => $status]);
```

---

### PHP-048 -- Uma instrucao por linha [ERRO]

**Regra:** Cada instrucao PHP ocupa sua propria linha. Nunca duas instrucoes separadas por `;` na mesma linha.

**Verifica:** `grep -rn ";.*;" inc/ --include="*.php" | grep -v "for ("` — match (exceto cabecalho de `for`) indica multiplas instrucoes na mesma linha.

**Por que na BGR:** Instrucoes empilhadas na mesma linha sao invisiveis em diffs. Se duas instrucoes estao na mesma linha e uma muda, o diff mostra a linha inteira como alterada, dificultando identificar qual instrucao mudou. Na BGR, onde code review e obrigatorio, cada mudanca precisa ser visivel.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// Uma instrucao por linha: cada uma visivel individualmente no diff.
$valor = 100;
$desconto = 10;
$liquido = $valor - $desconto;
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// Duas instrucoes na mesma linha: dificil de auditar em diff.
$valor = 100; $desconto = 10;
$liquido = $valor - $desconto; $resultado = $liquido * 2;
```

---

## 10. Documentacao

> Codigo autoexplicativo. Comentarios so quando o "por que" nao e obvio.


### PHP-053 -- PHPDoc obrigatorio em metodos com logica nao-obvia [AVISO]

**Regra:** PHPDoc e obrigatorio quando o metodo contem logica que nao e evidente pelo nome e pela assinatura. O PHPDoc explica "por que" o metodo existe ou "por que" a implementacao e assim, nunca "o que" o metodo faz (isso o nome ja diz). Codigo autoexplicativo nao precisa de comentario.

**Verifica:** Inspecao visual: metodo com Reflection, regex complexa ou regra de negocio nao-obvia sem PHPDoc e violacao. PHPDoc que repete o nome do metodo ("Retorna o id") tambem e violacao (ruido).

**Por que na BGR:** Na BGR, entidades ricas tem metodos cujo nome ja e descritivo (`estaConfirmado()`, `valorLiquido()`). Esses nao precisam de PHPDoc. Mas metodos como `fromRow()` (que usa Reflection) ou metodos com regras de negocio nao-obvias precisam de explicacao do "por que". Comentarios que repetem o nome do metodo sao ruido.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// SEM PHPDoc: o nome e a assinatura ja dizem tudo.
// Comentario aqui seria ruido.
public function estaConfirmado(): bool
{
    return $this->status === self::STATUS_CONFIRMADO;
}

/**
 * Hidrata entidade a partir de linha do banco SEM passar pelo construtor.
 *
 * Usa Reflection porque dados legacy podem ter campos vazios que o
 * construtor rejeitaria. fromRow() nunca lanca exception -- dados do
 * banco sao fato consumado.
 */
public static function fromRow(object $row): self
{
    $entity = (new \ReflectionClass(self::class))
        ->newInstanceWithoutConstructor();
    // ...
    return $entity;
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

/**
 * Verifica se o lancamento esta confirmado.
 *
 * @return bool Retorna true se confirmado, false caso contrario.
 */
// RUIDO: o nome ja diz isso. O PHPDoc nao agrega nenhuma informacao.
public function estaConfirmado(): bool
{
    return $this->status === self::STATUS_CONFIRMADO;
}
```

---



### PHP-054 -- Operacoes financeiras devem ser atomicas [ERRO]

**Regra:** Toda operacao que modifica saldo (creditos, Brio, licencas, estoque) ou envolve transferencia de valor entre entidades deve rodar dentro de uma unica transacao (`START TRANSACTION` / `COMMIT` / `ROLLBACK`). O SELECT que le o saldo antes de modificar deve usar `FOR UPDATE` pra evitar race condition. Side effects externos (email, webhook) ficam FORA da transacao.

**Verifica:** `grep -rn "creditar\|debitar\|transferir\|converter\|compra" inc/` — todo metodo que muda saldo deve conter `START TRANSACTION` na mesma funcao (nao delegado pra outro metodo que abre transacao propria). `grep -rn "FOR UPDATE" inc/` — todo SELECT antes de UPDATE de saldo deve ter `FOR UPDATE`.

**Por que na BGR:** Incidente de sessao 71: 6 operacoes financeiras sem atomicidade adequada — `creditar()` sem FOR UPDATE (race condition), `converter_em_creditos()` com duas transacoes independentes (estorno best-effort), `creditar_periodo()` com idempotencia sem lock (creditacao dupla), `criar_convite()` sem transacao (convite sem cobranca). Transacoes aninhadas em MySQL/MariaDB causam commit implicito da primeira — `START TRANSACTION` dentro de outra transacao commita silenciosamente.

**Armadilha:** Nunca chamar um metodo que abre `START TRANSACTION` de dentro de outra transacao. O segundo `START TRANSACTION` commita a primeira implicitamente. Se precisar de operacao cross-modulo atomica, fazer os INSERTs/UPDATEs inline na transacao pai — nao delegar pra metodos que abrem transacao propria.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// Transacao global: debitar de A + creditar pra B atomicamente
$wpdb->query('START TRANSACTION');
try {
    $saldo = (int) $wpdb->get_var($wpdb->prepare(
        "SELECT saldo FROM {$p}saldo WHERE user_id = %d FOR UPDATE", $de
    ));
    if ($saldo < $qtd) {
        $wpdb->query('ROLLBACK');
        return 'Saldo insuficiente.';
    }
    $wpdb->query($wpdb->prepare("UPDATE {$p}saldo SET saldo = saldo - %d WHERE user_id = %d", $qtd, $de));
    $wpdb->query($wpdb->prepare("UPDATE {$p}saldo SET saldo = saldo + %d WHERE user_id = %d", $qtd, $para));
    // Ledger (append-only)
    $wpdb->insert("{$p}ledger", ['tipo' => 'debito', 'user_id' => $de, ...]);
    $wpdb->insert("{$p}ledger", ['tipo' => 'credito', 'user_id' => $para, ...]);
    $wpdb->query('COMMIT');
} catch (\Throwable $e) {
    $wpdb->query('ROLLBACK');
}
// Email FORA da transacao (side effect irreversivel)
wp_mail($destinatario, 'Transferencia recebida', ...);
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// ERRADO: duas transacoes separadas — se a segunda falha, a primeira ja commitou
$this->debitar($de, $qtd);    // abre START TRANSACTION + COMMIT
$this->creditar($para, $qtd); // abre START TRANSACTION + COMMIT (pode falhar!)
```

---



## Definition of Done -- Checklist de entrega

> PR que nao cumpre o DoD nao entra em review. E devolvido.

| # | Item | Regras | Verificacao |
|---|------|--------|-------------|
| 1 | `declare(strict_types=1)` em todo arquivo PHP | PHP-012 | `grep -rL "strict_types" inc/` deve retornar vazio |
| 2 | Sem tag de fechamento `?>` | PHP-013 | `grep -rl "?>" inc/ --include="*.php"` deve retornar vazio |
| 3 | Type hints em todos os parametros e retornos | PHP-014, PHP-015 | Code review + analise estatica (PHPStan nivel 6+) |
| 4 | Propriedades tipadas com visibilidade explicita | PHP-017, PHP-018 | Code review: nenhuma propriedade sem tipo ou sem visibilidade |
| 5 | Entidades ricas com FSM e predicados | PHP-022, PHP-024, PHP-033 | Entidades tem STATUS_TRANSITIONS, lifecycle methods e predicados descritivos |
| 6 | `fromRow()` usa Reflection, nunca `new self()` | PHP-025 | `grep -rn "new self\|new static" inc/entidades/` deve retornar zero em fromRow() |
| 7 | Dados sensiveis criptografados em repouso | PHP-037 | Repositorios de entidades sensiveis usam criptografia antes de INSERT/UPDATE |
| 8 | Queries parametrizadas | PHP-038 | Nenhuma query com interpolacao direta de variaveis |
| 9 | Sem queries dentro de loops | PHP-050 | Nenhum foreach/for/while contem chamadas a repositorio ou banco |
| 10 | Excecoes tipadas, sem `@` supressor | PHP-034, PHP-035 | `grep -rn "@\$\|@file\|@json\|@array" inc/` e `grep -rn "new \\\\Exception" inc/` retornam vazio |
| 11 | Erros criticos logados com contexto | PHP-051 | Catch blocks fazem error_log() com prefixo `[BGR]` e dados de contexto |
| 12 | Entrada sanitizada no handler | PHP-039, PHP-040 | Handlers sanitizam todo dado de $_POST/$_GET antes de delegar |
| 13 | Formatacao PSR-12 | PHP-043 a PHP-048 | Indentacao 4 espacos, chaves corretas, linhas < 120 chars |
| 14 | Operacoes financeiras atomicas | PHP-054 | Todo creditar/debitar/transferir usa START TRANSACTION + FOR UPDATE + ROLLBACK. Sem transacoes aninhadas. |
