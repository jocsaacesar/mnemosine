---
name: auditar-php
description: Audita codigo PHP do PR aberto contra as regras definidas em docs/padroes-php.md. Entrega relatorio de violacoes e plano de correcoes. Trigger manual apenas.
---

# /auditar-php — Auditora de padroes PHP

Le as regras de `docs/padroes-php.md`, identifica os arquivos PHP alterados no PR aberto (nao mergeado) e compara cada arquivo contra cada regra aplicavel. Entrega um relatorio de violacoes com referencia ao ID da regra e um plano de correcoes quando necessario.

## Quando usar

- **APENAS** quando o usuario digitar `/auditar-php` explicitamente.
- Rodar antes de mergear um PR — funciona como gate de qualidade.
- **Nunca** disparar automaticamente, nem como parte de outra skill.

## Padroes minimos exigidos

> Esta secao contem os padroes completos usados pela auditoria. Edite para personalizar ao seu projeto.

# Padrao de programacao em PHP

## Descricao

Documento de referencia para auditoria de codigo PHP no projeto. Define regras obrigatorias e recomendacoes que toda classe, metodo e arquivo PHP deve seguir. A skill `/auditar-php` le este documento e compara contra o codigo-alvo.

## Escopo

- Todo codigo PHP dentro dos diretorios do projeto
- PHP 8.1+ com `declare(strict_types=1)`

## Referencias

- [PSR-1: Basic Coding Standard](https://www.php-fig.org/psr/psr-1/)
- [PSR-4: Autoloading Standard](https://www.php-fig.org/psr/psr-4/)
- [PSR-12: Extended Coding Style Guide](https://www.php-fig.org/psr/psr-12/)
- [SemVer 2.0.0](https://semver.org/lang/pt-BR/)

## Severidade

- **ERRO** — Violacao bloqueia aprovacao. Deve ser corrigida antes de merge.
- **AVISO** — Recomendacao forte. Deve ser justificada se ignorada.

---

## 1. Principios fundamentais

Estes principios regem toda decisao de codigo. A skill os usa como criterio de julgamento quando uma regra especifica nao cobre o caso.

### PHP-001 — KISS: simplicidade primeiro [AVISO]

O codigo deve ser o mais simples possivel. Se existe uma forma direta de resolver, usar essa. Abstracoes, patterns e indirecoes so entram quando o problema exige.

```php
// correto — direto
public function estaAtiva(): bool
{
    return $this->status === self::STATUS_ATIVA;
}

// incorreto — indirecao sem necessidade
public function estaAtiva(): bool
{
    return (new StatusChecker($this))->verificar(self::STATUS_ATIVA);
}
```

### PHP-002 — DRY: uma regra, um lugar [ERRO]

Uma regra de negocio e implementada em um unico ponto do sistema. Se o mesmo calculo ou validacao aparece em dois lugares, extrair para um metodo ou classe.

```php
// correto — calculo centralizado na entidade
class Pedido
{
    public function valorLiquido(): int
    {
        return $this->valorCents - $this->descontoCents;
    }
}

// incorreto — calculo duplicado no handler e no manager
// handler: $liquido = $valor - $desconto;
// manager: $liquido = $valor - $desconto;
```

### PHP-003 — YAGNI: nao construa o que nao precisa agora [AVISO]

Nao implementar classes, metodos ou parametros pensando em "possibilidades futuras". Implementar estritamente o que o requisito atual exige. Codigo que nunca sera usado e divida tecnica desde o nascimento.

### PHP-004 — Separacao de responsabilidades (SoC) [ERRO]

Cada camada tem um trabalho:

| Camada | Responsabilidade | Pasta |
|--------|-----------------|-------|
| Entidade | Logica de dominio, estado, predicados | `inc/entidades/` |
| Repositorio | Acesso a dados, queries, hidratacao | `inc/repositorios/` |
| Gerenciador | Orquestracao, regras entre entidades | `inc/gerenciadores/` |
| Handler | Receber request, validar, delegar, responder | `inc/handlers/` |

Handler nunca faz query. Repositorio nunca valida request. Entidade nunca acessa banco.

### PHP-005 — Lei de Demeter: fale so com seus vizinhos [AVISO]

Um objeto interage apenas com suas dependencias diretas. Nunca encadear chamadas que atravessam camadas.

```php
// correto
$saldo = $conta->saldoAtual();

// incorreto — o handler conhece a estrutura interna da conta
$saldo = $pedido->conta()->repositorio()->calcularSaldo();
```

---

## 2. Nomenclatura

### PHP-006 — Classes em PascalCase [ERRO]

```php
// correto
class PedidoRepository {}
class FinanceiroManager {}

// incorreto
class pedido_repository {}
class financeiroManager {}
```

### PHP-007 — Metodos e propriedades em camelCase [ERRO]

```php
// correto
public function calcularSaldo(): int {}
private int $valorCents;

// incorreto
public function calcular_saldo(): int {}
private int $valor_cents;
```

### PHP-008 — Constantes em UPPER_SNAKE_CASE [ERRO]

```php
// correto
public const STATUS_ATIVO = 'ativo';
private const MAX_TENTATIVAS = 3;

// incorreto
public const statusAtivo = 'ativo';
private const maxTentativas = 3;
```

### PHP-009 — Variaveis locais em camelCase [AVISO]

```php
// correto
$valorTotal = $pedido->valorCents();
$categoriaId = $request['categoria_id'];

// incorreto
$valor_total = $pedido->valorCents();
$CategoriaId = $request['categoria_id'];
```

### PHP-010 — Nomes descritivos, sem abreviacoes obscuras [AVISO]

```php
// correto
$pedidoRepository = new PedidoRepository($db);
$categoriaAtiva = $categoria->estaAtiva();

// incorreto
$pr = new PedidoRepository($db);
$ca = $categoria->estaAtiva();
```

---

## 3. Estrutura de arquivos

### PHP-011 — Um arquivo por classe [ERRO]

Cada classe PHP vive em seu proprio arquivo. O nome do arquivo e o nome da classe seguido de `.php`.

```
inc/entidades/Pedido.php              <- classe Pedido
inc/repositorios/PedidoRepository.php <- classe PedidoRepository
```

### PHP-012 — Todo arquivo PHP abre com strict_types [ERRO]

```php
// correto
<?php
declare(strict_types=1);

class Pedido {}

// incorreto
<?php
class Pedido {}
```

### PHP-013 — Sem tag de fechamento PHP [ERRO]

Arquivos que contem apenas PHP nao usam `?>` no final.

---

## 4. Tipagem

### PHP-014 — Type hints obrigatorios em parametros [ERRO]

```php
// correto
public function buscarPorUsuario(int $userId): array {}

// incorreto
public function buscarPorUsuario($userId) {}
```

### PHP-015 — Tipo de retorno obrigatorio [ERRO]

```php
// correto
public function calcularSaldo(): int {}
public function buscarOuNulo(int $id): ?Pedido {}

// incorreto
public function calcularSaldo() {}
```

### PHP-016 — Usar tipos union quando necessario, nunca mixed [AVISO]

```php
// correto
public function encontrar(int $id): Pedido|null {}

// incorreto
public function encontrar(int $id): mixed {}
```

### PHP-017 — Propriedades tipadas [ERRO]

```php
// correto
private int $valorCents;
private string $descricao;
private ?DateTimeImmutable $prazo;

// incorreto
private $valorCents;
private $descricao;
```

---

## 5. Classes e objetos

### PHP-018 — Visibilidade explicita em tudo [ERRO]

Toda propriedade, metodo e constante deve declarar visibilidade (`public`, `protected`, `private`).

```php
// correto
private int $id;
public function id(): int { return $this->id; }

// incorreto
int $id;
function id(): int { return $this->id; }
```

### PHP-019 — Propriedades readonly quando nao mutaveis [AVISO]

```php
// correto
public function __construct(
    private readonly int $id,
    private readonly string $nome,
) {}

// incorreto (se o valor nunca muda apos construcao)
public function __construct(
    private int $id,
    private string $nome,
) {}
```

### PHP-020 — Construtores via promocao de propriedades [AVISO]

Preferir constructor promotion quando aplicavel.

```php
// correto
public function __construct(
    private readonly Database $db,
    private readonly Logger $logger,
) {}

// aceitavel mas verboso
public function __construct(Database $db, Logger $logger)
{
    $this->db = $db;
    $this->logger = $logger;
}
```

### PHP-021 — Composicao sobre heranca [AVISO]

Heranca cria acoplamento forte. Usar apenas para hierarquias reais (ex.: excecoes tipadas). Para reutilizar comportamento, injetar dependencias.

```php
// correto — composicao
class FinanceiroManager
{
    public function __construct(
        private readonly PedidoRepository $pedidos,
        private readonly Logger $logger,
    ) {}
}

// incorreto — heranca para reaproveitar codigo
class FinanceiroManager extends BaseManager {}
```

### PHP-022 — Entidades ricas, nao anemicas [ERRO]

Entidades contem logica de dominio: predicados, transicoes de estado, validacoes de regra de negocio. Nunca devem ser apenas sacos de getters e setters.

```php
// correto — entidade com comportamento
class Pedido
{
    public function confirmar(): void
    {
        if ($this->status !== self::STATUS_PENDENTE) {
            throw new TransicaoInvalidaException($this->status, self::STATUS_CONFIRMADO);
        }
        $this->status = self::STATUS_CONFIRMADO;
    }

    public function estaConfirmado(): bool
    {
        return $this->status === self::STATUS_CONFIRMADO;
    }
}

// incorreto — entidade anemica
class Pedido
{
    public function getStatus(): string { return $this->status; }
    public function setStatus(string $status): void { $this->status = $status; }
}
```

### PHP-023 — Getters sem prefixo get_ [ERRO]

Metodos de acesso usam o nome da propriedade diretamente.

```php
// correto
public function id(): int { return $this->id; }
public function nome(): string { return $this->nome; }
public function valorCents(): int { return $this->valorCents; }

// incorreto
public function getId(): int { return $this->id; }
public function getNome(): string { return $this->nome; }
```

### PHP-024 — FSM na entidade via STATUS_TRANSITIONS [ERRO]

Entidades com estado definem suas transicoes validas como constante e expoem lifecycle methods.

```php
class Pedido
{
    public const STATUS_PENDENTE = 'pendente';
    public const STATUS_CONFIRMADO = 'confirmado';
    public const STATUS_CANCELADO = 'cancelado';

    public const STATUS_TRANSITIONS = [
        self::STATUS_PENDENTE   => [self::STATUS_CONFIRMADO, self::STATUS_CANCELADO],
        self::STATUS_CONFIRMADO => [self::STATUS_CANCELADO],
        self::STATUS_CANCELADO  => [],
    ];

    public function confirmar(): void
    {
        if (!$this->podeTransicionarPara(self::STATUS_CONFIRMADO)) {
            throw new TransicaoInvalidaException($this->status, self::STATUS_CONFIRMADO);
        }
        $this->status = self::STATUS_CONFIRMADO;
    }

    public function podeTransicionarPara(string $novoStatus): bool
    {
        return in_array($novoStatus, self::STATUS_TRANSITIONS[$this->status] ?? [], true);
    }
}
```

### PHP-025 — from_row() tolerante, nunca lanca exception [ERRO]

Dados do banco sao fato consumado. O metodo `from_row()` nunca lanca exception — usa `ReflectionClass::newInstanceWithoutConstructor()` para bypassar validacoes do construtor.

```php
// correto
public static function fromRow(object $row): self
{
    $entity = (new \ReflectionClass(self::class))
        ->newInstanceWithoutConstructor();

    $entity->id = (int) $row->id;
    $entity->nome = (string) $row->nome;
    $entity->status = (string) $row->status;

    return $entity;
}

// incorreto — explode com dado sujo do banco
public static function fromRow(object $row): self
{
    return new self(
        id: (int) $row->id,
        nome: (string) $row->nome, // construtor pode validar e lancar exception
    );
}
```

### PHP-026 — Entidades nao dependem de infraestrutura [ERRO]

Classes de entidade nunca importam classes de banco de dados, classes de repositorio ou servicos externos. Entidades contem logica de dominio pura.

```php
// correto — entidade pura
class Pedido
{
    public function estaConfirmado(): bool
    {
        return $this->status === self::STATUS_CONFIRMADO;
    }
}

// incorreto — entidade acoplada a infraestrutura
class Pedido
{
    public function salvar(Database $db): void
    {
        $db->insert(...);
    }
}
```

### PHP-027 — SOLID: responsabilidade unica por classe [ERRO]

Uma classe tem um unico motivo para mudar. Se uma classe faz validacao, calculo e persistencia, ela tem tres motivos — dividir.

### PHP-028 — SOLID: aberto para extensao, fechado para modificacao [AVISO]

Quando um novo comportamento e necessario (ex.: novo tipo de pedido), preferir polimorfismo ou estrategia em vez de adicionar `if/else` ao codigo existente.

### PHP-029 — SOLID: inversao de dependencia [AVISO]

Gerenciadores e handlers dependem de abstracoes (interfaces), nao de classes concretas, quando a dependencia pode variar.

```php
// correto
public function __construct(
    private readonly CriptografiaInterface $cripto,
) {}

// aceitavel para dependencias estaveis
public function __construct(
    private readonly Database $db,
) {}
```

---

## 6. Metodos

### PHP-030 — Maximo 20 linhas por metodo [AVISO]

Se um metodo ultrapassa 20 linhas, provavelmente faz mais de uma coisa. Extrair submetodos.

### PHP-031 — Retorno antecipado (early return) [AVISO]

Reduzir aninhamento usando guard clauses.

```php
// correto
public function processar(Pedido $pedido): void
{
    if ($pedido->estaCancelado()) {
        return;
    }

    if (!$pedido->temConta()) {
        throw new PedidoSemContaException();
    }

    // logica principal aqui
}

// incorreto
public function processar(Pedido $pedido): void
{
    if (!$pedido->estaCancelado()) {
        if ($pedido->temConta()) {
            // logica principal aqui
        } else {
            throw new PedidoSemContaException();
        }
    }
}
```

### PHP-032 — Maximo 4 parametros por metodo [AVISO]

Se um metodo precisa de mais de 4 parametros, considerar um objeto de valor (Value Object) ou DTO.

### PHP-033 — Metodos publicos de entidade como predicados descritivos [AVISO]

```php
// correto
$pedido->estaConfirmado();
$conta->estaAtiva();
$meta->foiAtingida();

// incorreto
$pedido->getStatus() === 'confirmado';
$conta->getAtiva() === true;
```

---

## 7. Tratamento de erros

### PHP-034 — Excecoes tipadas, nunca genericas [ERRO]

```php
// correto
throw new SaldoInsuficienteException($conta->id(), $valorSolicitado);
throw new PedidoNaoEncontradoException($id);

// incorreto
throw new \Exception('Saldo insuficiente');
throw new \RuntimeException('Nao encontrado');
```

### PHP-035 — Nunca silenciar erros com @ [ERRO]

```php
// correto
$resultado = json_decode($json, true);
if (json_last_error() !== JSON_ERROR_NONE) {
    throw new JsonInvalidoException(json_last_error_msg());
}

// incorreto
$resultado = @json_decode($json, true);
```

### PHP-036 — Catch especifico, nunca \Throwable generico [AVISO]

```php
// correto
try {
    $this->repositorio->salvar($pedido);
} catch (DuplicataException $e) {
    // tratar caso especifico
}

// incorreto
try {
    $this->repositorio->salvar($pedido);
} catch (\Throwable $e) {
    // engolir tudo
}
```

---

## 8. Seguranca

### PHP-037 — Dados sensiveis criptografados em repouso [ERRO]

Todo valor sensivel deve ser criptografado antes de gravar no banco e descriptografado apos leitura.

```php
// correto
$valorCriptografado = $this->cripto->criptografar((string) $pedido->valorCents());
$db->insert($tabela, ['valor_cents' => $valorCriptografado]);

// incorreto
$db->insert($tabela, ['valor_cents' => $pedido->valorCents()]);
```

### PHP-038 — Sempre usar queries parametrizadas [ERRO]

```php
// correto
$db->prepare("SELECT * FROM {$tabela} WHERE user_id = ?", [$userId]);

// incorreto
$db->query("SELECT * FROM {$tabela} WHERE user_id = {$userId}");
```

### PHP-039 — Sanitizar entrada, escapar saida [ERRO]

Toda entrada do usuario e sanitizada antes de uso. Toda saida para o navegador e escapada.

### PHP-040 — Validacao na fronteira do sistema [ERRO]

Handlers validam e sanitizam todos os dados recebidos antes de passar para gerenciadores ou repositorios. Entidades e repositorios confiam que os dados ja chegam limpos.

### PHP-041 — Chaves e segredos vivem no .env, nunca no codigo [ERRO]

```php
// correto
$chave = getenv('APP_ENCRYPTION_KEY');

// incorreto
$chave = 'minha-chave-secreta-hardcoded';
```

### PHP-042 — Nao otimizar prematuramente [AVISO]

Otimizacoes de performance (cache, desnormalizacao, queries complexas) so entram quando ha medicao comprovando o gargalo. Codigo claro e correto primeiro, otimizado depois.

---

## 9. Formatacao

### PHP-043 — Indentacao com 4 espacos [ERRO]

Nunca tabs. Sempre 4 espacos.

### PHP-044 — Chaves na mesma linha para estruturas de controle [AVISO]

```php
// correto
if ($condicao) {
    // corpo
}

// incorreto
if ($condicao)
{
    // corpo
}
```

### PHP-045 — Chaves na linha seguinte para classes e metodos [AVISO]

```php
// correto (PSR-12)
class Pedido
{
    public function valorCents(): int
    {
        return $this->valorCents;
    }
}
```

### PHP-046 — Linha em branco entre metodos [AVISO]

### PHP-047 — Maximo 120 caracteres por linha [AVISO]

Quebrar linhas longas com alinhamento.

### PHP-048 — Uma instrucao por linha [ERRO]

```php
// correto
$a = 1;
$b = 2;

// incorreto
$a = 1; $b = 2;
```

---

## 10. Versionamento

### PHP-049 — SemVer 2.0.0 [AVISO]

O projeto adota versionamento semantico:

- **MAJOR** (X.y.z) — Alteracoes incompativeis na API.
- **MINOR** (x.Y.z) — Funcionalidades novas mantendo compatibilidade.
- **PATCH** (x.y.Z) — Correcoes de bugs mantendo compatibilidade.

---

## Checklist de auditoria

A skill `/auditar-php` deve verificar, para cada arquivo:

- [ ] Principios: KISS, DRY, YAGNI, SoC, Demeter respeitados
- [ ] `declare(strict_types=1)` presente
- [ ] Sem tag de fechamento `?>`
- [ ] Uma classe por arquivo
- [ ] Classe em PascalCase, metodos em camelCase, constantes em UPPER_SNAKE_CASE
- [ ] Visibilidade explicita em tudo
- [ ] Type hints em todos os parametros e retornos
- [ ] Propriedades tipadas
- [ ] Entidades ricas (com comportamento), nao anemicas
- [ ] Getters sem prefixo get_ (ex.: nome(), nao getNome())
- [ ] FSM na entidade via STATUS_TRANSITIONS + lifecycle methods
- [ ] from_row() tolerante (nunca lanca exception)
- [ ] Entidades sem dependencia de infraestrutura
- [ ] Responsabilidade unica por classe
- [ ] Composicao sobre heranca
- [ ] Excecoes tipadas (nunca genericas)
- [ ] Sem `@` supressor de erro
- [ ] Dados sensiveis criptografados
- [ ] Queries parametrizadas em toda query
- [ ] Entrada sanitizada, saida escapada
- [ ] Sem segredos hardcoded
- [ ] Indentacao com 4 espacos
- [ ] Maximo 120 caracteres por linha

## Processo

### Fase 1 — Carregar a regua

1. Ler a secao **Padroes minimos exigidos** deste documento.
2. Internalizar todas as regras com seus IDs, descricoes, exemplos e severidades (ERRO/AVISO).
3. Nao resumir nem recitar o documento de volta.

### Fase 2 — Identificar o PR aberto

1. Executar `gh pr list --state open --base develop --json number,title,headBranch --limit 1` para encontrar o PR aberto mais recente contra `develop`.
2. Se houver mais de um PR aberto, listar todos e perguntar ao usuario qual auditar.
3. Se nao houver PR aberto, informar o usuario e encerrar.
4. Executar `gh pr diff <numero>` para obter o diff completo do PR.
5. Filtrar apenas arquivos `.php` do projeto.

### Fase 3 — Auditar arquivo por arquivo

Para cada arquivo PHP alterado no PR:

1. Ler o arquivo completo (nao apenas o diff — contexto importa).
2. Comparar contra **cada regra** de `docs/padroes-php.md`, uma por uma, na ordem do documento.
3. Para cada violacao encontrada, registrar:
   - **Arquivo** e **linha(s)** onde ocorre
   - **ID da regra** violada (ex.: padroes-php.md, PHP-024)
   - **Severidade** (ERRO ou AVISO)
   - **O que esta errado** — descricao concisa
   - **Como corrigir** — correcao especifica para aquele trecho
4. Se o arquivo nao viola nenhuma regra, registrar como aprovado.

### Fase 4 — Relatorio

Apresentar o relatorio ao usuario no seguinte formato:

```
## Relatorio de auditoria PHP

**PR:** #<numero> — <titulo>
**Branch:** <branch>
**Arquivos auditados:** <quantidade>
**Regua:** docs/padroes-php.md

### Resumo

- Erros: <quantidade>
- Avisos: <quantidade>
- Arquivos aprovados: <quantidade>

### Violacoes

#### <arquivo.php>

| Linha | Regra | Severidade | Descricao | Correcao |
|-------|-------|------------|-----------|----------|
| 15 | PHP-024 | ERRO | FSM nao definida | Adicionar STATUS_TRANSITIONS |
| 32 | PHP-030 | AVISO | Metodo com 25 linhas | Extrair submetodo |

#### <outro-arquivo.php>
Aprovado — nenhuma violacao encontrada.
```

### Fase 5 — Plano de correcoes

Se houver violacoes do tipo ERRO:

1. Listar as correcoes necessarias agrupadas por arquivo.
2. Ordenar por severidade (ERROs primeiro, AVISOs depois).
3. Para cada correcao, indicar exatamente o que mudar e onde.
4. Perguntar ao usuario: "Quer que eu execute as correcoes agora?"

Se houver apenas AVISOs ou nenhuma violacao:

> "Nenhum erro bloquante. Os avisos sao recomendacoes — quer que eu corrija algum?"

## Regras

- **Nunca alterar codigo durante a auditoria.** A skill e read-only ate o usuario pedir correcao explicitamente.
- **Nunca auditar arquivos fora do PR.** Apenas arquivos PHP alterados no PR aberto.
- **Sempre referenciar o ID da regra violada.** O relatorio deve ser rastreavel ao documento de padroes.
- **Nunca inventar regras.** A regua e exclusivamente o `docs/padroes-php.md` — sem opiniao, sem sugestoes extras.
- **Ser metodica e processual.** Cada arquivo e comparado contra cada regra, na ordem do documento, sem pular.
- **Fidelidade ao documento.** Se o codigo viola uma regra do documento, reportar. Se o documento nao cobre o caso, nao reportar.
- **Mostrar o relatorio completo antes de qualquer acao.** Nunca executar correcoes sem aprovacao explicita.
