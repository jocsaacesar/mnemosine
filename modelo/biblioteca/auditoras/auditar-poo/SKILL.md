---
name: auditar-poo
description: Audita arquitetura e design OOP do PR aberto contra as regras definidas em docs/padroes-poo.md. Entrega relatorio de violacoes e plano de correcoes. Trigger manual apenas.
---

# /auditar-poo — Auditora de padroes orientados a objetos

Le as regras de `docs/padroes-poo.md`, identifica os arquivos PHP alterados no PR aberto (nao mergeado) e compara cada arquivo contra cada regra aplicavel. Foco em arquitetura e design: modelagem de dominio, encapsulamento, padroes do projeto (entidade, repositorio, gerenciador, handler), SOLID e Value Objects.

Complementa a `/auditar-php`, que cobre sintaxe e regras de linguagem.

## Quando usar

- **APENAS** quando o usuario digitar `/auditar-poo` explicitamente.
- Rodar antes de mergear um PR — funciona como gate de qualidade arquitetural.
- **Nunca** disparar automaticamente, nem como parte de outra skill.

## Padroes minimos exigidos

> Esta secao contem os padroes completos usados pela auditoria. Edite para personalizar ao seu projeto.

# Padrao de programacao orientada a objetos

## Descricao

Documento de referencia para auditoria de arquitetura e design orientado a objetos no projeto. Define como classes devem ser modeladas, como objetos se relacionam e como os padroes arquiteturais do projeto devem ser aplicados. A skill `/auditar-poo` le este documento e compara contra o codigo-alvo.

Complementa o `docs/padroes-php.md`, que cobre sintaxe, formatacao e regras de linguagem. Este documento cobre **design e arquitetura**.

## Escopo

- Todo codigo PHP dentro dos diretorios do projeto
- Foco em: entidades, repositorios, gerenciadores, handlers

## Referencias

- `docs/padroes-php.md` — Regras de linguagem PHP (complementar)
- [PHP-FIG PSR-4](https://www.php-fig.org/psr/psr-4/) — Autoloading
- SOLID Principles (Robert C. Martin)
- Domain-Driven Design — Eric Evans (conceitos aplicaveis)

## Severidade

- **ERRO** — Violacao bloqueia aprovacao. Deve ser corrigida antes de merge.
- **AVISO** — Recomendacao forte. Deve ser justificada se ignorada.

---

## 1. Modelagem de dominio

### POO-001 — Classes representam substantivos do dominio [ERRO]

Cada classe de entidade representa um conceito real do negocio. O nome da classe dita seu papel — sem classes "curinga" que tentam ser duas coisas.

```php
// correto — conceitos claros do dominio
class Pedido {}
class Cliente {}
class Produto {}
class ItemPedido {}

// incorreto — generico, ambiguo
class Item {}
class Registro {}
class Dados {}
```

### POO-002 — Metodos expressam intencao com verbos de acao [ERRO]

Metodos de negocio usam verbos que descrevem o que o objeto **faz**, nao o que ele **expoe**.

```php
// correto — intencao clara
$pedido->confirmar();
$conta->transferirPara($outraConta, $valor);
$meta->registrarProgresso($valor);

// incorreto — sem intencao, operacao mecanica
$pedido->setStatus('confirmado');
$conta->atualizarSaldo($novoSaldo);
```

### POO-003 — Sem classes anemicas [ERRO]

Entidades contem logica de dominio: predicados de estado, transicoes, validacoes e calculos de negocio. Nunca sacos de getters e setters.

```php
// correto — entidade rica com comportamento
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

// incorreto — anemica, logica vive fora
class Pedido
{
    public function getStatus(): string { return $this->status; }
    public function setStatus(string $s): void { $this->status = $s; }
    public function getValorCents(): int { return $this->valorCents; }
}
```

---

## 2. Encapsulamento

### POO-004 — Atributos sempre privados [ERRO]

Toda propriedade e `private` (ou `readonly` via constructor promotion). `protected` apenas em hierarquias de heranca reais. Nunca `public`.

```php
// correto
class Cliente
{
    private int $saldoCents;
    private string $nome;
    private bool $ativo;
}

// incorreto
class Cliente
{
    public int $saldoCents;
    public string $nome;
}
```

### POO-005 — Tell, Don't Ask [ERRO]

Nao extraia dados do objeto para tomar decisoes fora dele. Diga ao objeto o que fazer — ele decide internamente.

```php
// correto — o objeto decide
$pedido->confirmar();
// internamente: verifica se pode transicionar, muda status, lanca exception se nao pode

// incorreto — decisao externa
if ($pedido->status() === 'pendente') {
    $pedido->setStatus('confirmado');
}
```

### POO-006 — Setters privados, mutacao via metodos de negocio [ERRO]

Propriedades mutaveis sao alteradas por metodos que expressam intencao de negocio, nunca por setters publicos.

```php
// correto
class Meta
{
    private string $status;

    public function atingir(): void
    {
        if ($this->valorAtualCents < $this->valorAlvoCents) {
            throw new MetaNaoAtingidaException();
        }
        $this->status = self::STATUS_ATINGIDA;
    }
}

// incorreto
class Meta
{
    public function setStatus(string $status): void
    {
        $this->status = $status;
    }
}
```

### POO-007 — Objetos imutaveis quando possivel [AVISO]

Para dados que nao mudam apos criacao (configuracoes, Value Objects, DTOs de leitura), usar `readonly` no construtor. Sem setters, sem mutacao.

```php
// correto — imutavel
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

---

## 3. Heranca e polimorfismo

### POO-008 — Heranca apenas para subtipos reais [ERRO]

Heranca so quando a afirmativa "X **e um** Y" e verdadeira comportamentalmente. Para reutilizar codigo, usar composicao (injecao de dependencia).

```php
// correto — subtipo real
abstract class ExcecaoDominio extends \DomainException {}
class SaldoInsuficienteException extends ExcecaoDominio {}
class PedidoNaoEncontradoException extends ExcecaoDominio {}

// incorreto — heranca para reaproveitar codigo
class FinanceiroManager extends BaseManager {} // "tem funcionalidades de", nao "e um"
```

### POO-009 — Classes concretas sao finais [AVISO]

Classes concretas que nao foram projetadas para extensao devem usar `final`. Impede heranca acidental.

### POO-010 — Polimorfismo substitui switch/if em tipo [AVISO]

Quando multiplos `if/else` ou `switch` decidem comportamento baseado no "tipo" de algo, extrair para hierarquia polimorfica.

```php
// correto — polimorfismo
interface CalculadoraDeJuros
{
    public function calcular(int $valorCents, int $dias): int;
}

class JurosSimples implements CalculadoraDeJuros
{
    public function calcular(int $valorCents, int $dias): int
    {
        return (int) ($valorCents * 0.01 * $dias);
    }
}

// incorreto — switch no tipo
function calcularJuros(string $tipo, int $valor, int $dias): int
{
    switch ($tipo) {
        case 'simples': return (int) ($valor * 0.01 * $dias);
        case 'compostos': return (int) ($valor * ((1.01 ** $dias) - 1));
    }
}
```

---

## 4. Interfaces e abstracoes

### POO-011 — Interfaces magras e especificas [AVISO]

Interfaces definem contratos pequenos e coesos. Nunca "interfaces gordas" que forcam implementacao de metodos irrelevantes.

### POO-012 — Depender de abstracoes, nao de implementacoes concretas [AVISO]

Gerenciadores e handlers recebem interfaces quando a dependencia pode variar. Dependencias estaveis podem ser concretas.

### POO-013 — Classes abstratas como molde de hierarquia [AVISO]

Classes abstratas compartilham estado e comportamento entre subtipos reais. Nunca usar como "repositorio de metodos utilitarios".

---

## 5. Value Objects

### POO-014 — Tipos primitivos com significado de dominio viram Value Objects [AVISO]

Quando um primitivo carrega regras de validacao ou formatacao, encapsular em Value Object.

```php
// correto — Value Object com validacao
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

    public function formatado(): string
    {
        return 'R$ ' . number_format($this->centavos / 100, 2, ',', '.');
    }
}
```

### POO-015 — Value Objects sao imutaveis [ERRO]

Value Objects nunca mudam apos criacao. Operacoes retornam novas instancias.

### POO-016 — Comparacao por valor, nao por referencia [AVISO]

Value Objects implementam metodo de igualdade baseado nos atributos, nao na referencia de memoria.

---

## 6. Padroes arquiteturais do projeto

### POO-017 — Entidade: Rich Domain Model com FSM [ERRO]

Toda entidade com estado segue o padrao Rich Domain Model com maquina de estados finita.

Estrutura obrigatoria:
1. Constantes de status
2. `STATUS_TRANSITIONS` definindo transicoes validas
3. Construtor parametrizado (estado valido desde a criacao)
4. Getters sem prefixo `get_`
5. Lifecycle methods (`confirmar()`, `cancelar()`) com Tell, Don't Ask
6. Predicados de estado (`estaConfirmado()`, `estaPendente()`)
7. `podeTransicionarPara()` publico
8. `fromRow()` tolerante (nunca lanca exception)
9. `toArray()` para serializacao

### POO-018 — Repositorio: interface uniforme [ERRO]

Todo repositorio segue a mesma estrutura de metodos.

Metodos obrigatorios:
1. `findById(int $id): ?Entidade`
2. `findAll(): array`
3. `create(Entidade $e): int`
4. `update(Entidade $e): bool`
5. `delete(int $id): bool`
6. `tableName(): string` (privado)
7. `hydrate(object $row): Entidade` (privado)

### POO-019 — Gerenciador: orquestracao sem logica de dominio [ERRO]

Gerenciadores coordenam operacoes entre entidades e repositorios. A logica de dominio vive na entidade, nao no gerenciador.

```php
// correto — gerenciador orquestra
class PedidoManager
{
    public function confirmarPedido(int $pedidoId): void
    {
        $pedido = $this->pedidos->findById($pedidoId);

        if (!$pedido) {
            throw new PedidoNaoEncontradoException($pedidoId);
        }

        $pedido->confirmar(); // logica na entidade
        $this->pedidos->update($pedido);
    }
}

// incorreto — gerenciador com logica de dominio
class PedidoManager
{
    public function confirmarPedido(int $id): void
    {
        $pedido = $this->pedidos->findById($id);

        if ($pedido->status() !== 'pendente') { // logica deveria estar na entidade
            throw new \Exception('Nao pode confirmar');
        }
    }
}
```

### POO-020 — Handler: fronteira do sistema [ERRO]

Handlers sao a fronteira entre o mundo externo (request HTTP) e o dominio. Responsabilidades:
1. Verificar autenticacao e autorizacao
2. Sanitizar e validar input
3. Delegar para o gerenciador
4. Retornar resposta

Handlers nunca contem logica de dominio nem acessam o banco de dados diretamente.

---

## 7. SOLID aplicado ao projeto

### POO-021 — SRP: uma razao para mudar por classe [ERRO]

### POO-022 — OCP: extensao sem modificacao [AVISO]

### POO-023 — LSP: subtipos substituiveis [AVISO]

### POO-024 — ISP: interfaces segregadas [AVISO]

### POO-025 — DIP: inversao de dependencia [AVISO]

---

## 8. Enums e tipos seguros

### POO-026 — Enums para dominios fechados [AVISO]

Status, tipos e categorias com conjunto fixo de valores devem usar PHP Enums (8.1+), nao strings soltas.

```php
// correto
enum TipoPedido: string
{
    case Venda = 'venda';
    case Troca = 'troca';
    case Devolucao = 'devolucao';
}

// incorreto — string solta
$tipo = 'venda'; // pode ser qualquer coisa, sem validacao
```

### POO-027 — Usar DateTimeImmutable, nunca strings de data [ERRO]

Datas sao objetos, nao strings. Usar `DateTimeImmutable` para todas as propriedades temporais.

```php
// correto
private readonly DateTimeImmutable $criadoEm;
private ?DateTimeImmutable $prazo;

// incorreto
private string $criadoEm; // '2026-04-07'
private ?string $prazo;
```

---

## Checklist de auditoria

A skill `/auditar-poo` deve verificar, para cada arquivo:

**Modelagem e encapsulamento:**
- [ ] Classes representam conceitos do dominio (nomes claros)
- [ ] Metodos expressam intencao com verbos de acao
- [ ] Entidade nao e anemica (contem logica de dominio)
- [ ] Atributos sao privados (nunca public)
- [ ] Tell, Don't Ask respeitado (decisoes dentro do objeto)
- [ ] Sem setters publicos (mutacao via metodos de negocio)

**Heranca e polimorfismo:**
- [ ] Heranca apenas para subtipos reais
- [ ] Composicao sobre heranca para reutilizacao de codigo
- [ ] Switch/if em tipo substituido por polimorfismo quando aplicavel

**Interfaces:**
- [ ] Interfaces magras e especificas
- [ ] Dependencias que podem variar recebem interface

**Value Objects:**
- [ ] Primitivos com significado de dominio encapsulados em VO
- [ ] Value Objects sao imutaveis
- [ ] Datas usam DateTimeImmutable

**Padroes do projeto:**
- [ ] Entidade segue Rich Domain Model (FSM, lifecycle, predicados, fromRow, toArray)
- [ ] Repositorio segue interface uniforme (findById, findAll, create, update, delete, hydrate)
- [ ] Gerenciador orquestra sem logica de dominio
- [ ] Handler valida e delega (nunca acessa banco, nunca contem logica de dominio)

**SOLID:**
- [ ] Uma responsabilidade por classe (SRP)
- [ ] Extensao sem modificacao quando aplicavel (OCP)
- [ ] Subtipos substituiveis (LSP)
- [ ] Interfaces segregadas (ISP)
- [ ] Inversao de dependencia quando a dependencia varia (DIP)

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
2. Comparar contra **cada regra** de `docs/padroes-poo.md`, uma por uma, na ordem do documento.
3. Para cada violacao encontrada, registrar:
   - **Arquivo** e **linha(s)** onde ocorre
   - **ID da regra** violada (ex.: padroes-poo.md, POO-017)
   - **Severidade** (ERRO ou AVISO)
   - **O que esta errado** — descricao concisa
   - **Como corrigir** — correcao especifica para aquele trecho
4. Se o arquivo nao viola nenhuma regra, registrar como aprovado.

### Fase 4 — Relatorio

Apresentar o relatorio ao usuario no seguinte formato:

```
## Relatorio de auditoria POO

**PR:** #<numero> — <titulo>
**Branch:** <branch>
**Arquivos auditados:** <quantidade>
**Regua:** docs/padroes-poo.md

### Resumo

- Erros: <quantidade>
- Avisos: <quantidade>
- Arquivos aprovados: <quantidade>

### Violacoes

#### <arquivo.php>

| Linha | Regra | Severidade | Descricao | Correcao |
|-------|-------|------------|-----------|----------|
| 10 | POO-003 | ERRO | Entidade anemica, so getters/setters | Adicionar logica de dominio |
| 25 | POO-005 | ERRO | Decisao de status fora da entidade | Mover para lifecycle method |

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
- **Nunca inventar regras.** A regua e exclusivamente o `docs/padroes-poo.md` — sem opiniao, sem sugestoes extras.
- **Ser metodica e processual.** Cada arquivo e comparado contra cada regra, na ordem do documento, sem pular.
- **Fidelidade ao documento.** Se o codigo viola uma regra do documento, reportar. Se o documento nao cobre o caso, nao reportar.
- **Mostrar o relatorio completo antes de qualquer acao.** Nunca executar correcoes sem aprovacao explicita.
