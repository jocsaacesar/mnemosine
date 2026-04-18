---
documento: padroes-poo
versao: 2.1.0
criado: 2026-04-07
atualizado: 2026-04-16
total_regras: 27
severidades:
  erro: 14
  aviso: 13
escopo: Design e arquitetura orientada a objetos em todos os projetos PHP
aplica_a: ["todos"]
requer: ["padroes-php"]
substitui: ["padroes-poo v1 (versão anterior)"]
---

# Padroes de POO — sua organização

> Documento constitucional. Contrato de entrega para todo
> desenvolvedor que toca programacao orientada a objetos nos nossos projetos.
> Codigo que viola regras ERRO nao e discutido — e devolvido.
> 27 regras | IDs: POO-001 a POO-027 (POO-028 removida — escopo generico, nao OOP)

---

## Como usar este documento

### Para o desenvolvedor

1. Leia as regras que afetam as classes que voce esta criando ou alterando.
2. Antes de abrir PR, passe pelo DoD no final do documento.
3. Use os IDs das regras (ex.: POO-003) para referenciar decisoes em code review.

### Para o auditor (humano ou IA)

1. Leia o frontmatter para entender escopo e dependencias.
2. Audite o codigo contra cada regra por ID e severidade.
3. Classifique violacoes: ERRO bloqueia merge, AVISO exige justificativa escrita.
4. Referencie violacoes pelo ID da regra (ex.: "viola POO-017").

### Para o Claude Code

1. Leia o frontmatter para saber quais projetos e dependencias se aplicam.
2. Em code review, verifique cada regra por ID — comece pelas regras ERRO.
3. Ao reportar violacoes, sempre cite o ID (ex.: "viola POO-005 — Tell, Don't Ask").
4. Consulte `padroes-php` para regras de linguagem que complementam este documento.

---

## Severidades

| Nivel | Significado | Acao |
|-------|-------------|------|
| **ERRO** | Violacao inegociavel | Bloqueia merge. Corrigir antes de review. |
| **AVISO** | Recomendacao forte | Deve ser justificada por escrito se ignorada. |

---

## 1. Modelagem de dominio

### POO-001 — Classes representam substantivos do dominio [ERRO]

**Regra:** Cada classe de entidade representa um conceito real do negocio. O nome da classe dita seu papel — sem classes genericas que tentam ser duas coisas.

**Verifica:** Grep por `^class ` — nome deve ser substantivo do dominio. Falha se encontrar nomes genericos como `Item`, `Dados`, `Helper`, `Registro`, `Manager` sem prefixo de dominio.

**Por quê:** Times pequenos precisam entender o codigo em 5 minutos. Uma classe chamada `Item` ou `Dados` obriga o desenvolvedor a ler o corpo inteiro para entender o que faz. Nomes de dominio eliminam essa perda de tempo.

**Exemplo correto:**
```php
// cada classe mapeia um conceito real do negocio
class Pedido {}
class Cliente {}
class Produto {}
class NotaFiscal {}
```

**Exemplo incorreto:**
```php
// generico, ambiguo — ninguem sabe o que faz sem ler o corpo
class Item {}
class Registro {}
class Dados {}
class Helper {}
```

### POO-002 — Metodos expressam intencao com verbos de acao [ERRO]

**Regra:** Metodos de negocio usam verbos que descrevem o que o objeto **faz**, nunca o que ele **expoe**. O nome do metodo deve comunicar a intencao de negocio.

**Verifica:** Grep por `public function set[A-Z]` em entidades. Metodos de mutacao devem usar verbos de dominio (`confirmar`, `cancelar`), nao setters genericos.

**Por quê:** Desenvolvimento assistido por IA depende de codigo autoexplicativo. Um metodo `confirmar()` comunica intencao instantaneamente. Um metodo `setStatus('confirmado')` esconde a regra de negocio e exige que o leitor (humano ou IA) adivinhe o contexto.

**Exemplo correto:**
```php
$pedido->confirmar();
$conta->transferirPara($outraConta, $valor);
$tarefa->concluir();
```

**Exemplo incorreto:**
```php
$pedido->setStatus('confirmado');
$conta->atualizarSaldo($novoSaldo);
$tarefa->setCompleta(true);
```

### POO-003 — Sem classes anemicas [ERRO]

**Regra:** Entidades contem logica de dominio: predicados de estado, transicoes, validacoes e calculos de negocio. Nunca sacos de getters e setters.

**Verifica:** Inspecionar entidades — cada uma deve ter pelo menos 1 lifecycle method ou predicado de estado alem de getters. Falha se classe so tem `get`/`set`/`__construct`.

**Por quê:** Classes anemicas espalham logica de negocio por gerenciadores, handlers e scripts. Quando um novo dev entra no time, ele nao sabe onde a regra vive. Entidades ricas concentram a logica onde ela pertence — no objeto que conhece seus proprios dados.

**Exemplo correto:**
```php
class Pedido
{
    public function confirmar(): void
    {
        if (!$this->podeTransicionarPara(self::STATUS_CONFIRMADO)) {
            throw new TransicaoInvalidaException($this->status, self::STATUS_CONFIRMADO);
        }
        $this->status = self::STATUS_CONFIRMADO;
    }

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
class Pedido
{
    public function getStatus(): string { return $this->status; }
    public function setStatus(string $s): void { $this->status = $s; }
    public function getValorCents(): int { return $this->valorCents; }
}
// logica de negocio espalhada em gerenciadores e scripts
```

---

## 2. Encapsulamento

### POO-004 — Atributos sempre privados [ERRO]

**Regra:** Toda propriedade e `private` (ou `readonly` via constructor promotion). `protected` apenas em hierarquias de heranca reais. Nunca `public`.

**Verifica:** Grep por `public (?:string|int|float|bool|array|\?)\s+\$` em classes. Qualquer propriedade `public` sem `readonly` e violacao.

**Por quê:** Propriedades publicas permitem que qualquer parte do sistema mude o estado do objeto sem validacao. No projeto, onde projetos sao mantidos por times pequenos e rotativos, uma propriedade publica vira uma bomba-relogio — alguem vai mutar sem saber das regras de negocio.

**Exemplo correto:**
```php
class Cliente
{
    private string $nome;
    private string $email;
    private bool $ativo;
}
```

**Exemplo incorreto:**
```php
class Cliente
{
    public string $nome;
    public string $email;
}
```

### POO-005 — Tell, Don't Ask [ERRO]

**Regra:** Nunca extraia dados do objeto para tomar decisoes fora dele. Diga ao objeto o que fazer — ele decide internamente.

**Verifica:** Grep por `if.*\$\w+->(?:status|get[A-Z])\(\).*===` fora da propria classe. Decisao baseada em getter externo e violacao.

**Por quê:** Decisoes externas duplicam logica e criam inconsistencia. Quando a regra muda, precisa cacar todos os lugares que fazem `if ($obj->status() === '...')` em vez de alterar um unico metodo na entidade. No projeto, com poucos devs, essa caca vira bug em producao.

**Exemplo correto:**
```php
$pedido->confirmar();
// internamente: verifica se pode transicionar, muda status, lanca exception se nao pode
```

**Exemplo incorreto:**
```php
if ($pedido->status() === 'pendente') {
    $pedido->setStatus('confirmado');
}
```

### POO-006 — Setters privados, mutacao via metodos de negocio [ERRO]

**Regra:** Propriedades mutaveis sao alteradas por metodos que expressam intencao de negocio, nunca por setters publicos.

**Verifica:** Grep por `public function set[A-Z]` — qualquer setter publico em entidade e violacao. Mutacao deve ser via metodo de dominio.

**Por quê:** Setters publicos eliminam qualquer protecao do encapsulamento. No projeto, qualquer dev deve poder chamar metodos de entidade sem conhecer as regras internas — o metodo de negocio garante que a transicao e valida. Um setter nao garante nada.

**Exemplo correto:**
```php
class Tarefa
{
    private string $status;

    public function concluir(): void
    {
        if (!$this->podeConcluir()) {
            throw new OperacaoInvalidaException('Tarefa nao pode ser concluida neste estado.');
        }
        $this->status = self::STATUS_CONCLUIDA;
    }
}
```

**Exemplo incorreto:**
```php
class Tarefa
{
    public function setStatus(string $status): void
    {
        $this->status = $status;
    }
}
```

### POO-007 — Objetos imutaveis quando possivel [AVISO]

**Regra:** Para dados que nao mudam apos criacao (configuracoes, Value Objects, DTOs de leitura), usar `readonly` no construtor. Sem setters, sem mutacao.

**Verifica:** Inspecionar VOs e DTOs — propriedades devem ter `readonly`. Grep por `function set` nesses arquivos deve retornar zero.

**Por quê:** Objetos imutaveis eliminam uma categoria inteira de bugs — ninguem pode mutar acidentalmente um valor que deveria ser constante. Em times pequenos sem code review exaustivo, imutabilidade e uma rede de seguranca automatica.

**Exemplo correto:**
```php
class PeriodoRelatorio
{
    public function __construct(
        private readonly DateTimeImmutable $inicio,
        private readonly DateTimeImmutable $fim,
    ) {
        if ($fim <= $inicio) {
            throw new PeriodoInvalidoException();
        }
    }
}
```

**Exemplo incorreto:**
```php
class PeriodoRelatorio
{
    private DateTimeImmutable $inicio;
    private DateTimeImmutable $fim;

    public function setInicio(DateTimeImmutable $inicio): void
    {
        $this->inicio = $inicio;
    }
}
```

---

## 3. Heranca e polimorfismo

### POO-008 — Heranca apenas para subtipos reais [ERRO]

**Regra:** Heranca so quando a afirmativa "X **e um** Y" e verdadeira comportamentalmente. Para reutilizar codigo, usar composicao (injecao de dependencia).

**Verifica:** Grep por `extends` — cada heranca deve passar no teste "X e um Y". Falha se classe herda apenas para reaproveitar metodo utilitario.

**Por quê:** Heranca mal usada cria acoplamento rigido que impede evolucao. No projeto, projetos mudam rapido — um gerenciador que herda de `BaseManager` para reutilizar um metodo carrega todo o peso da classe pai. Composicao permite trocar pecas sem efeito cascata.

**Exemplo correto:**
```php
// subtipo real — excecao de dominio "e uma" excecao
abstract class ExcecaoDominio extends \DomainException {}
class EntidadeNaoEncontradaException extends ExcecaoDominio {}
class TransicaoInvalidaException extends ExcecaoDominio {}
```

**Exemplo incorreto:**
```php
// heranca para reaproveitar codigo — "tem funcionalidades de", nao "e um"
class PedidoManager extends BaseManager {}
class ClienteManager extends BaseManager {}
```

### POO-009 — Classes concretas sao finais [AVISO]

**Regra:** Classes concretas que nao foram projetadas para extensao devem usar `final`. Impede heranca acidental.

**Verifica:** Grep por `^class ` (sem `abstract`) — classes concretas sem `final` que nao sao base de hierarquia sao violacao.

**Por quê:** Sem `final`, qualquer dev pode herdar de uma classe que nao foi projetada para isso e criar comportamento imprevisivel. No projeto, onde o onboarding e rapido e assistido por IA, `final` comunica explicitamente: "esta classe nao foi feita para extensao".

**Exemplo correto:**
```php
final class PedidoRepository
{
    // ...
}
```

**Exemplo incorreto:**
```php
// sem final, outro dev pode herdar sem saber que nao deveria
class PedidoRepository
{
    // ...
}
```

### POO-010 — Polimorfismo substitui switch/if em tipo [AVISO]

**Regra:** Quando multiplos `if/else` ou `switch` decidem comportamento baseado no "tipo" de algo, extrair para hierarquia polimorfica.

**Verifica:** Grep por `switch.*\$tipo` ou `if.*===.*'tipo'` — decisoes por tipo em 3+ branches indicam violacao. Deve ser polimorfismo.

**Por quê:** Cada novo tipo adicionado via `switch` exige alterar codigo existente e testar tudo de novo. Com polimorfismo, novos tipos sao classes novas — nenhum codigo existente e tocado. Menos risco, menos regressao.

**Exemplo correto:**
```php
interface CalculadoraDesconto
{
    public function calcular(int $valorCents): int;
}

class DescontoPercentual implements CalculadoraDesconto
{
    public function __construct(private readonly float $percentual) {}

    public function calcular(int $valorCents): int
    {
        return (int) ($valorCents * $this->percentual);
    }
}

class DescontoFixo implements CalculadoraDesconto
{
    public function __construct(private readonly int $descontoCents) {}

    public function calcular(int $valorCents): int
    {
        return min($this->descontoCents, $valorCents);
    }
}
```

**Exemplo incorreto:**
```php
function calcularDesconto(string $tipo, int $valor): int
{
    switch ($tipo) {
        case 'percentual': return (int) ($valor * 0.10);
        case 'fixo': return 500;
    }
}
```

---

## 4. Interfaces e abstracoes

### POO-011 — Interfaces magras e especificas [AVISO]

**Regra:** Interfaces definem contratos pequenos e coesos. Nunca "interfaces gordas" que forcam implementacao de metodos irrelevantes.

**Verifica:** Contar metodos por interface — mais de 5 metodos indica interface gorda. Verificar se implementacoes tem metodos vazios ou `throw new \RuntimeException`.

**Por quê:** Interfaces gordas obrigam classes a implementar metodos que nao fazem sentido para elas. No projeto, isso gera metodos vazios ou que lancam `RuntimeException` — codigo morto que confunde quem le e quem audita.

**Exemplo correto:**
```php
interface Criptografavel
{
    public function criptografar(string $dado): string;
    public function descriptografar(string $dado): string;
}
```

**Exemplo incorreto:**
```php
interface ServicoCentral
{
    public function criptografar(string $dado): string;
    public function calcularTotal(int $id): int;
    public function enviarEmail(string $para, string $assunto): void;
}
```

### POO-012 — Depender de abstracoes, nao de implementacoes concretas [AVISO]

**Regra:** Gerenciadores e handlers recebem interfaces quando a dependencia pode variar. Dependencias estaveis (como `$wpdb`) podem ser concretas.

**Verifica:** Inspecionar construtores de managers/handlers — dependencias variaveis (cripto, cache, notificacao) devem receber interface, nao classe concreta.

**Por quê:** Trocar uma implementacao concreta exige alterar todas as classes que dependem dela. Com interface, a troca e transparente. No projeto, onde criptografia, cache e integracao externa podem mudar entre projetos, abstrair e obrigatorio.

**Exemplo correto:**
```php
class PedidoManager
{
    public function __construct(
        private readonly CriptografiaInterface $cripto,
        private readonly \wpdb $wpdb, // estavel, concreto aceitavel
    ) {}
}
```

**Exemplo incorreto:**
```php
class PedidoManager
{
    public function __construct(
        private readonly AES256Criptografia $cripto, // e se trocar o algoritmo?
    ) {}
}
```

### POO-013 — Classes abstratas como molde de hierarquia [AVISO]

**Regra:** Classes abstratas compartilham estado e comportamento entre subtipos reais. Nunca usar como "repositorio de metodos utilitarios".

**Verifica:** Grep por `abstract class` — verificar se tem pelo menos 1 subtipo real via `extends`. Classe abstrata sem filho ou usada como bag of utilities e violacao.

**Por quê:** Classes abstratas usadas como "bag of utilities" criam heranca forcada. No projeto, cada classe deve justificar sua existencia como conceito de dominio — utilitarios viram funcoes ou classes finais injetadas.

**Exemplo correto:**
```php
abstract class ExcecaoDominio extends \DomainException
{
    public function __construct(
        string $mensagem,
        private readonly string $codigoNegocio,
    ) {
        parent::__construct($mensagem);
    }

    public function codigoNegocio(): string
    {
        return $this->codigoNegocio;
    }
}
```

**Exemplo incorreto:**
```php
abstract class BaseHelper
{
    protected function formatarData(string $data): string { /* ... */ }
    protected function sanitizarString(string $s): string { /* ... */ }
    protected function logarErro(string $msg): void { /* ... */ }
}

class PedidoService extends BaseHelper {} // herda para usar formatarData()
```

---

## 5. Value Objects

### POO-014 — Tipos primitivos com significado de dominio viram Value Objects [AVISO]

**Regra:** Quando um primitivo carrega regras de validacao ou formatacao, encapsular em Value Object. Exemplos: dinheiro em centavos, CPF, email, periodo de datas.

**Verifica:** Grep por `int $valorCents`, `string $cpf`, `string $email` em entidades — primitivos com regras de dominio repetidos em 2+ classes devem ser VOs.

**Por quê:** Primitivos soltos espalham validacao por todo o sistema. No projeto, um `int $valorCents` aparece em entidades, repositorios e handlers — se a validacao so existe em um lugar, os outros ficam desprotegidos. Value Objects validam na criacao e garantem consistencia em qualquer contexto.

**Exemplo correto:**
```php
final class Dinheiro
{
    public function __construct(
        private readonly int $centavos,
    ) {
        if ($centavos < 0) {
            throw new ValorNegativoException($centavos);
        }
    }

    public function centavos(): int
    {
        return $this->centavos;
    }

    public function somar(self $outro): self
    {
        return new self($this->centavos + $outro->centavos);
    }

    public function maiorQue(self $outro): bool
    {
        return $this->centavos > $outro->centavos;
    }

    public function formatado(): string
    {
        return 'R$ ' . number_format($this->centavos / 100, 2, ',', '.');
    }
}
```

**Exemplo incorreto:**
```php
// primitivo solto sem validacao — qualquer valor passa
$total = $valorCents + $freteCents;
if ($total < 0) { /* validacao dispersa */ }
```

### POO-015 — Value Objects sao imutaveis [ERRO]

**Regra:** Value Objects nunca mudam apos criacao. Operacoes retornam novas instancias.

**Verifica:** Inspecionar VOs — todas propriedades devem ser `readonly`. Metodos de operacao devem retornar `new self(...)`, nunca mutar `$this`.

**Por quê:** Um Value Object mutavel e um bug esperando acontecer. Se dois objetos compartilham referencia a um VO e um deles muda o valor, o outro e afetado sem saber. No projeto, onde entidades passam VOs entre camadas, imutabilidade e a unica garantia de integridade.

**Exemplo correto:**
```php
$total = $preco->somar($frete); // novo Dinheiro, $preco nao muda
```

**Exemplo incorreto:**
```php
$preco->adicionar($frete); // muda o objeto original — efeito colateral
```

### POO-016 — Comparacao por valor, nao por referencia [AVISO]

**Regra:** Value Objects implementam metodo de igualdade baseado nos atributos, nunca na referencia de memoria.

**Verifica:** Inspecionar VOs — deve existir metodo `igualA(self)` ou `equals(self)`. Grep por `===` comparando dois VOs por referencia e violacao.

**Por quê:** Dois objetos `Dinheiro(100)` criados separadamente devem ser considerados iguais. Sem metodo de comparacao, o PHP compara por referencia e diz que sao diferentes — gerando bugs sutis em validacoes e testes.

**Exemplo correto:**
```php
final class Dinheiro
{
    public function igualA(self $outro): bool
    {
        return $this->centavos === $outro->centavos;
    }
}
```

**Exemplo incorreto:**
```php
// comparacao por referencia — dois VOs com mesmo valor sao "diferentes"
if ($dinheiroA === $dinheiroB) { /* falso mesmo com valores iguais */ }
```

---

## 6. Padroes arquiteturais

### POO-017 — Entidade: Rich Domain Model com FSM [ERRO]

**Regra:** Toda entidade com estado segue o padrao Rich Domain Model com maquina de estados finita. Estrutura obrigatoria:

1. Constantes de status
2. `STATUS_TRANSITIONS` definindo transicoes validas
3. Construtor parametrizado (estado valido desde a criacao)
4. Getters sem prefixo `get_`
5. Lifecycle methods (`confirmar()`, `cancelar()`) com Tell, Don't Ask
6. Predicados de estado (`estaConfirmado()`, `estaPendente()`)
7. `podeTransicionarPara()` publico
8. `fromRow()` tolerante (nunca lanca exception)
9. `toArray()` para serializacao

**Verifica:** Checklist por entidade: (1) `STATUS_TRANSITIONS` presente, (2) `fromRow` e `toArray` existem, (3) grep por `get_` retorna zero, (4) pelo menos 1 lifecycle method e 1 predicado.

**Por quê:** Este padrao e o contrato arquitetural do projeto. Qualquer dev ou IA que abrir uma entidade sabe exatamente onde encontrar cada coisa. Sem padrao, cada entidade e um universo proprio — impossivel de auditar ou manter com time pequeno.

**Exemplo correto:**
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

    public function __construct(
        private readonly int $id,
        private readonly int $userId,
        private int $valorCents,
        private string $status = self::STATUS_PENDENTE,
        private readonly DateTimeImmutable $criadoEm = new DateTimeImmutable(),
    ) {}

    // Getters sem get_
    public function id(): int { return $this->id; }
    public function status(): string { return $this->status; }
    public function valorCents(): int { return $this->valorCents; }

    // Lifecycle methods
    public function confirmar(): void
    {
        if (!$this->podeTransicionarPara(self::STATUS_CONFIRMADO)) {
            throw new TransicaoInvalidaException($this->status, self::STATUS_CONFIRMADO);
        }
        $this->status = self::STATUS_CONFIRMADO;
    }

    public function cancelar(): void
    {
        if (!$this->podeTransicionarPara(self::STATUS_CANCELADO)) {
            throw new TransicaoInvalidaException($this->status, self::STATUS_CANCELADO);
        }
        $this->status = self::STATUS_CANCELADO;
    }

    // Predicados
    public function estaConfirmado(): bool { return $this->status === self::STATUS_CONFIRMADO; }
    public function estaPendente(): bool { return $this->status === self::STATUS_PENDENTE; }

    // FSM
    public function podeTransicionarPara(string $novoStatus): bool
    {
        return in_array($novoStatus, self::STATUS_TRANSITIONS[$this->status] ?? [], true);
    }

    // Hidratacao tolerante
    public static function fromRow(object $row): self
    {
        $entity = (new \ReflectionClass(self::class))
            ->newInstanceWithoutConstructor();

        $entity->id = (int) $row->id;
        $entity->userId = (int) $row->user_id;
        $entity->valorCents = (int) $row->valor_cents;
        $entity->status = (string) $row->status;

        return $entity;
    }

    // Serializacao
    public function toArray(): array
    {
        return [
            'id' => $this->id,
            'user_id' => $this->userId,
            'valor_cents' => $this->valorCents,
            'status' => $this->status,
        ];
    }
}
```

**Exemplo incorreto:**
```php
class Pedido
{
    // sem constantes de status
    // sem STATUS_TRANSITIONS
    // sem lifecycle methods
    private string $status;

    public function getStatus(): string { return $this->status; }
    public function setStatus(string $s): void { $this->status = $s; } // mutacao direta
}
```

### POO-018 — Repositorio: interface uniforme [ERRO]

**Regra:** Todo repositorio segue a mesma estrutura de metodos:

1. `findById(int $id): ?Entidade`
2. `findAll(): array`
3. `create(Entidade $e): int`
4. `update(Entidade $e): bool`
5. `delete(int $id): bool`
6. `tableName(): string` (privado)
7. `hydrate(object $row): Entidade` (privado)

**Verifica:** Grep por `class.*Repository` — cada repo deve ter `findById`, `create`, `update`, `tableName`, `hydrate`. Metodos com nomes fora do padrao (`buscar`, `salvar`) sao violacao.

**Por quê:** Interface uniforme permite que qualquer dev (ou IA) navegue qualquer repositorio sem surpresas. No projeto, repositorios sao o ponto unico de acesso ao banco — uniformidade elimina duvidas sobre onde e como os dados sao persistidos.

**Exemplo correto:**
```php
class PedidoRepository
{
    public function __construct(
        private readonly \wpdb $wpdb,
    ) {}

    public function findById(int $id): ?Pedido
    {
        $row = $this->wpdb->get_row($this->wpdb->prepare(
            "SELECT * FROM {$this->tableName()} WHERE id = %d",
            $id
        ));

        return $row ? $this->hydrate($row) : null;
    }

    public function create(Pedido $pedido): int
    {
        $this->wpdb->insert($this->tableName(), [
            'user_id' => $pedido->userId(),
            'valor_cents' => $pedido->valorCents(),
            'status' => $pedido->status(),
        ]);

        return (int) $this->wpdb->insert_id;
    }

    private function tableName(): string
    {
        return $this->wpdb->prefix . 'pedidos';
    }

    private function hydrate(object $row): Pedido
    {
        return Pedido::fromRow($row);
    }
}
```

**Exemplo incorreto:**
```php
class PedidoRepository
{
    // metodos com nomes inconsistentes
    public function buscar(int $id): ?Pedido { /* ... */ }
    public function salvar(Pedido $p): void { /* ... */ }
    public function remover(int $id): void { /* ... */ }
    // sem hydrate, sem tableName — acesso direto espalhado
}
```

### POO-019 — Gerenciador: orquestracao sem logica de dominio [ERRO]

**Regra:** Gerenciadores coordenam operacoes entre entidades e repositorios. A logica de dominio vive na entidade, nunca no gerenciador.

**Verifica:** Grep por `if.*->status\(\)` ou `if.*->get` dentro de classes `*Manager` — condicao de negocio no manager e violacao. Deve estar na entidade.

**Por quê:** Gerenciadores com logica de dominio se tornam classes gigantes e intocaveis — ninguem sabe onde a regra de negocio realmente vive. No projeto, a entidade e a fonte da verdade. O gerenciador apenas orquestra: busca, delega, persiste.

**Exemplo correto:**
```php
class PedidoManager
{
    public function __construct(
        private readonly PedidoRepository $pedidos,
    ) {}

    public function confirmarPedido(int $pedidoId): void
    {
        $pedido = $this->pedidos->findById($pedidoId);

        if (!$pedido) {
            throw new EntidadeNaoEncontradaException('Pedido', $pedidoId);
        }

        $pedido->confirmar(); // logica na entidade
        $this->pedidos->update($pedido);
    }
}
```

**Exemplo incorreto:**
```php
class PedidoManager
{
    public function confirmarPedido(int $id): void
    {
        $pedido = $this->pedidos->findById($id);

        if ($pedido->status() !== 'pendente') { // logica deveria estar na entidade
            throw new \Exception('Nao pode confirmar');
        }

        // muda status diretamente — viola Tell, Don't Ask
    }
}
```

### POO-020 — Handler: fronteira do sistema [ERRO]

**Regra:** Handlers sao a fronteira entre o mundo externo (request HTTP/AJAX) e o dominio. Responsabilidades:

1. Verificar autenticacao e autorizacao
2. Sanitizar e validar input
3. Delegar para o gerenciador
4. Retornar resposta

Handlers nunca contem logica de dominio nem acessam `$wpdb` diretamente.

**Verifica:** Grep por `\$wpdb` e `global \$wpdb` em classes `*Handler` — qualquer ocorrencia e violacao. Grep por `if.*status.*===` no handler indica logica de dominio vazada.

**Por quê:** Handlers que acessam banco ou contem logica de negocio misturam fronteira com dominio. No projeto, handlers sao descartaveis — se a interface muda (de AJAX para REST, de WordPress para framework X), apenas o handler muda. A logica de negocio permanece intacta nas entidades e gerenciadores.

**Exemplo correto:**
```php
class PedidoAjaxHandler
{
    public function __construct(
        private readonly PedidoManager $manager,
    ) {}

    public function handleConfirmar(): void
    {
        $this->verificarPermissao();

        $pedidoId = absint($_POST['pedido_id'] ?? 0);

        if (!$pedidoId) {
            wp_send_json_error(['mensagem' => 'ID do pedido e obrigatorio.']);
        }

        try {
            $this->manager->confirmarPedido($pedidoId);
            wp_send_json_success(['mensagem' => 'Pedido confirmado.']);
        } catch (EntidadeNaoEncontradaException $e) {
            wp_send_json_error(['mensagem' => 'Pedido nao encontrado.']);
        } catch (TransicaoInvalidaException $e) {
            wp_send_json_error(['mensagem' => 'Transicao de status invalida.']);
        }
    }

    private function verificarPermissao(): void
    {
        check_ajax_referer('app_nonce', 'nonce');

        if (!current_user_can('manage_options')) {
            wp_send_json_error(['mensagem' => 'Sem permissao.'], 403);
        }
    }
}
```

**Exemplo incorreto:**
```php
class PedidoAjaxHandler
{
    public function handleConfirmar(): void
    {
        global $wpdb; // acesso direto ao banco no handler
        $row = $wpdb->get_row("SELECT * FROM pedidos WHERE id = ...");

        if ($row->status !== 'pendente') { // logica de dominio no handler
            wp_send_json_error(['mensagem' => 'Nao pode confirmar.']);
        }

        $wpdb->update('pedidos', ['status' => 'confirmado'], ['id' => $row->id]);
    }
}
```

---

## 7. SOLID

### POO-021 — SRP: uma razao para mudar por classe [ERRO]

**Regra:** Cada classe tem uma unica responsabilidade. Se uma classe faz validacao, calculo e persistencia, dividir em entidade (calculo/validacao), repositorio (persistencia) e handler (validacao de input).

**Verifica:** Inspecionar classes >200 loc — se contem `$wpdb` + logica de negocio + envio de email na mesma classe, viola SRP. Cada responsabilidade deve estar em classe separada.

**Por quê:** Classes com multiplas responsabilidades crescem descontroladamente. No projeto, com times pequenos e rotatividade, uma classe que faz tudo e uma classe que ninguem quer tocar. SRP garante que cada mudanca afeta um unico arquivo — menos conflito, menos risco.

**Exemplo correto:**
```php
// cada classe tem UMA responsabilidade
class Pedido
{
    // responsabilidade: regras de negocio do pedido
    public function confirmar(): void { /* ... */ }
    public function valorTotal(): int { /* ... */ }
}

class PedidoRepository
{
    // responsabilidade: persistencia
    public function findById(int $id): ?Pedido { /* ... */ }
    public function create(Pedido $p): int { /* ... */ }
}

class PedidoManager
{
    // responsabilidade: orquestracao
    public function confirmarPedido(int $id): void { /* ... */ }
}
```

**Exemplo incorreto:**
```php
class PedidoService
{
    // faz tudo: validacao, calculo, persistencia, envio de email
    public function confirmar(int $id): void
    {
        $row = $this->wpdb->get_row("SELECT ...");      // persistencia
        if ($row->status !== 'pendente') { /* ... */ }    // logica de dominio
        $this->wpdb->update('pedidos', ['status' => 'confirmado'], ['id' => $id]); // persistencia
        wp_mail($email, 'Pedido confirmado', '...');     // notificacao
    }
}
```

### POO-022 — OCP: extensao sem modificacao [AVISO]

**Regra:** Quando novo comportamento e necessario (novo tipo, nova regra de calculo), preferir polimorfismo ou estrategia em vez de `if/else` no codigo existente.

**Verifica:** Grep por `switch` e cadeias `elseif` com 3+ branches sobre tipo/categoria — deveria ser polimorfismo ou strategy pattern.

**Por quê:** Modificar codigo existente para adicionar comportamento novo exige retestar tudo que ja funcionava. No projeto, onde testes automatizados ainda estao em construcao, cada alteracao em codigo estavel e um risco. Extensao por polimorfismo isola o novo sem tocar no existente.

**Exemplo correto:**
```php
// novo tipo de notificacao: criar nova classe, nao alterar as existentes
interface Notificador
{
    public function enviar(string $destinatario, string $mensagem): void;
}

class NotificadorEmail implements Notificador
{
    public function enviar(string $destinatario, string $mensagem): void
    {
        wp_mail($destinatario, 'Notificacao', $mensagem);
    }
}

class NotificadorSlack implements Notificador
{
    public function enviar(string $destinatario, string $mensagem): void
    {
        // envia para webhook do Slack
    }
}
```

**Exemplo incorreto:**
```php
class Notificador
{
    public function enviar(string $tipo, string $destinatario, string $mensagem): void
    {
        if ($tipo === 'email') {
            wp_mail($destinatario, 'Notificacao', $mensagem);
        } elseif ($tipo === 'slack') {
            // envia para Slack
        }
        // cada novo tipo exige alterar este metodo
    }
}
```

### POO-023 — LSP: subtipos substituiveis [AVISO]

**Regra:** Toda classe filha deve poder substituir a classe mae sem quebrar o comportamento. Se a subclasse precisa desabilitar um metodo da mae, o design esta errado — extrair para classes irmas.

**Verifica:** Inspecionar classes filhas — grep por `throw new \RuntimeException` ou metodo vazio que sobrescreve metodo da mae. Subtipo que desabilita comportamento herdado e violacao.

**Por quê:** Subtipos que quebram o contrato da classe mae criam bugs silenciosos. No projeto, onde o Claude Code audita herancas automaticamente, uma violacao de LSP gera comportamento imprevisivel que so aparece em producao.

**Exemplo correto:**
```php
abstract class Forma
{
    abstract public function area(): float;
}

class Retangulo extends Forma
{
    public function __construct(
        private readonly float $largura,
        private readonly float $altura,
    ) {}

    public function area(): float
    {
        return $this->largura * $this->altura;
    }
}

class Circulo extends Forma
{
    public function __construct(
        private readonly float $raio,
    ) {}

    public function area(): float
    {
        return M_PI * $this->raio ** 2;
    }
}
```

**Exemplo incorreto:**
```php
class Retangulo
{
    public function setLargura(float $l): void { $this->largura = $l; }
    public function setAltura(float $a): void { $this->altura = $a; }
}

class Quadrado extends Retangulo
{
    // quebra LSP: setLargura muda altura tambem
    public function setLargura(float $l): void
    {
        $this->largura = $l;
        $this->altura = $l; // comportamento inesperado para quem espera Retangulo
    }
}
```

### POO-024 — ISP: interfaces segregadas [AVISO]

**Regra:** Interfaces pequenas e coesas. Se uma classe precisa implementar metodos que nao usa, a interface e gorda — dividir.

**Verifica:** Grep por `implements` — verificar se a classe implementa todos os metodos com corpo real. Metodo vazio ou `throw new \RuntimeException` em implementacao indica interface gorda.

**Por quê:** No projeto, interfaces sao contratos entre camadas. Uma interface gorda forca implementacoes a carregar metodos mortos — codigo que ninguem chama mas que aparece em toda auditoria como potencial ponto de falha.

**Exemplo correto:**
```php
interface Leitura
{
    public function findById(int $id): ?object;
    public function findAll(): array;
}

interface Escrita
{
    public function create(object $entidade): int;
    public function update(object $entidade): bool;
    public function delete(int $id): bool;
}

// classe que so precisa ler implementa apenas Leitura
class RelatorioService
{
    public function __construct(
        private readonly Leitura $repositorio,
    ) {}
}
```

**Exemplo incorreto:**
```php
interface RepositorioCompleto
{
    public function findById(int $id): ?object;
    public function findAll(): array;
    public function create(object $e): int;
    public function update(object $e): bool;
    public function delete(int $id): bool;
    public function exportarCSV(): string;
    public function importarCSV(string $csv): void;
}

// RelatorioService e forcado a depender de create, delete, importar...
```

### POO-025 — DIP: inversao de dependencia [AVISO]

**Regra:** Modulos de alto nivel (gerenciadores) dependem de abstracoes (interfaces), nunca de implementacoes concretas, quando a dependencia pode variar.

**Verifica:** Inspecionar type hints em construtores de managers — dependencias variaveis (cripto, cache, notificacao) devem tipar interface, nao classe concreta.

**Por quê:** No projeto, dependencias como criptografia, cache e servicos externos variam entre projetos. Se um gerenciador depende de `AES256Criptografia` diretamente, trocar o algoritmo exige alterar o gerenciador. Com interface, a troca e transparente e o gerenciador nem percebe.

**Exemplo correto:**
```php
interface CriptografiaInterface
{
    public function criptografar(string $dado): string;
    public function descriptografar(string $cifrado): string;
}

class PedidoManager
{
    public function __construct(
        private readonly CriptografiaInterface $cripto, // abstracacao
        private readonly PedidoRepository $pedidos,
    ) {}
}

// implementacao concreta injetada na composicao
$manager = new PedidoManager(new AES256Criptografia($chave), $repo);
```

**Exemplo incorreto:**
```php
class PedidoManager
{
    public function __construct(
        private readonly AES256Criptografia $cripto, // concreto — e se trocar?
    ) {}
}
```

---

## 8. Enums e tipos seguros

### POO-026 — Enums para dominios fechados [AVISO]

**Regra:** Status, tipos e categorias com conjunto fixo de valores devem usar PHP Enums (8.1+), nunca strings soltas.

**Verifica:** Grep por `=== '` em comparacoes de status/tipo/categoria — se o conjunto de valores e fechado e conhecido, deve ser Enum. Strings soltas repetidas em 2+ arquivos sao violacao.

**Por quê:** Strings soltas aceitam qualquer valor — um typo como `'pendnete'` passa pelo compilador e so estoura em producao. Enums validam em tempo de compilacao e dao autocompletar na IDE. No projeto, onde erros de digitacao em status ja causaram dados inconsistentes, Enums sao obrigatorios para dominios fechados.

**Exemplo correto:**
```php
enum StatusPedido: string
{
    case Pendente = 'pendente';
    case Confirmado = 'confirmado';
    case Cancelado = 'cancelado';
}

enum TipoProduto: string
{
    case Fisico = 'fisico';
    case Digital = 'digital';
    case Servico = 'servico';
}
```

**Exemplo incorreto:**
```php
$status = 'pendnete'; // typo — nenhum erro em compilacao, bug silencioso
```

**Excecoes:** Projetos rodando em PHP < 8.1 devem usar constantes de classe como paliativo, mas o upgrade para Enums e prioritario.

### POO-027 — Usar DateTimeImmutable, nunca strings de data [ERRO]

**Regra:** Datas sao objetos, nunca strings. Usar `DateTimeImmutable` para todas as propriedades temporais.

**Verifica:** Grep por `private.*string.*\$(criado|atualizado|data|prazo|vencimento|inicio|fim)` — propriedade temporal tipada como string e violacao. Deve ser `DateTimeImmutable`.

**Por quê:** Strings de data nao tem fuso horario, nao validam formato e nao oferecem operacoes de comparacao seguras. No projeto, onde projetos lidam com datas de vencimento, prazos e agendamentos, uma data invalida ou em fuso errado causa impacto direto no negocio.

**Exemplo correto:**
```php
private readonly DateTimeImmutable $criadoEm;
private ?DateTimeImmutable $prazo;
```

**Exemplo incorreto:**
```php
private string $criadoEm; // '2026-04-08'
private ?string $prazo;   // sem validacao, sem fuso, sem operacoes
```

---

## Definition of Done — Checklist de entrega

> PR que nao cumpre o DoD nao entra em review. E devolvido.

| # | Item | Regras | Verificacao |
|---|------|--------|-------------|
| 1 | Classes nomeadas com substantivos do dominio | POO-001 | Inspecao visual dos nomes de classe |
| 2 | Metodos expressam intencao com verbos | POO-002 | Inspecao visual dos nomes de metodo |
| 3 | Entidades contem logica de dominio (nao anemicas) | POO-003 | Verificar se entidade tem lifecycle methods, predicados e calculos |
| 4 | Atributos privados, sem setters publicos | POO-004, POO-006 | Buscar `public` em propriedades e `setX()` publicos |
| 5 | Tell, Don't Ask respeitado | POO-005 | Buscar decisoes externas baseadas em getters |
| 6 | Heranca apenas para subtipos reais | POO-008 | Verificar se toda heranca passa no teste "e um" |
| 7 | Value Objects imutaveis | POO-015 | Verificar `readonly` e ausencia de setters em VOs |
| 8 | Entidade segue Rich Domain Model com FSM | POO-017 | Checar constantes de status, STATUS_TRANSITIONS, lifecycle, predicados, fromRow, toArray |
| 9 | Repositorio segue interface uniforme | POO-018 | Checar findById, findAll, create, update, delete, hydrate, tableName |
| 10 | Gerenciador orquestra sem logica de dominio | POO-019 | Verificar que condicoes de negocio estao na entidade |
| 11 | Handler valida e delega (sem $wpdb, sem logica) | POO-020 | Buscar `$wpdb` e condicoes de negocio no handler |
| 12 | SOLID respeitado | POO-021 a POO-025 | Auditoria por regra |
| 13 | Datas usam DateTimeImmutable | POO-027 | Buscar `string` em propriedades temporais |
| 14 | Enums para dominios fechados | POO-026 | Buscar strings soltas para status/tipo/categoria |
