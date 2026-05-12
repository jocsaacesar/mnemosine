---
name: auditar-poo
description: Audita arquitetura e design OOP do PR aberto contra as regras definidas neste documento. Entrega relatório de violações e plano de correções. Trigger manual apenas.
---

# /auditar-poo — Auditora de padrões orientados a objetos

Lê as regras deste documento, identifica os arquivos PHP alterados no PR aberto (não mergeado) e compara cada arquivo contra cada regra aplicável. Foco em arquitetura e design: modelagem de domínio, encapsulamento, padrões do projeto (entidade, repositório, gerenciador, handler), SOLID e Value Objects.

Complementa a `/auditar-php`, que cobre sintaxe e regras de linguagem.

## Quando usar

- **APENAS** quando o usuário digitar `/auditar-poo` explicitamente.
- Rodar antes de mergear um PR — funciona como gate de qualidade arquitetural.
- **Nunca** disparar automaticamente, nem como parte de outra skill.

## Padrões mínimos exigidos

> Esta seção contém os padrões completos usados pela auditoria. 71 regras no total:
> POO-001 a POO-062 (princípios universais), POO-063 a POO-068 (padrões arquiteturais BGR),
> POO-069 a POO-071 (regras derivadas de incidentes).

---
documento: padroes-poo
versao: 1.1.0
criado: 2026-05-08
atualizado: 2026-05-08
total_regras: 71
severidades:
  erro: 44
  aviso: 27
versao_anterior: 1.0.0 (2026-05-08) — documento inicial, 52 regras. Autoria corrigida na 1.1.0.
escopo: Todo codigo orientado a objetos de todos os projetos da BGR / Taito
stack: linguagem-agnostica (exemplos em PHP)
aplica_a: [todos]
requer: []
referenciado_por: [padroes-php, padroes-seguranca, skill-executora]
fonte_principal: |
  Thiago Leite e Carvalho. "Orientacao a Objetos: aprenda seus conceitos e
  suas aplicabilidades de forma efetiva". Casa do Codigo, 2024. ISBN
  978-85-5519-213-5. Em particular: Capitulo 3 (Por que usar OO -- reuso,
  coesao, acoplamento, gap semantico), Capitulo 4 (Os 3 fundamentos:
  abstracao, reuso, encapsulamento), Capitulo 5 (Conceitos estruturais),
  Capitulo 6 (Conceitos relacionais), Capitulo 7 (Conceitos organizacionais),
  Capitulo 9 (Boas praticas BP01-BP15) e Apendice IV (SOLID).
fontes_complementares: |
  - Robert C. Martin, "Design Principles and Design Patterns" (origem do SOLID)
  - Lei de Demeter (Northeastern University, 1987)
  - Tell-Don't-Ask (Pragmatic Programmer, Hunt & Thomas)
  - Domain-Driven Design / linguagem ubiqua (Eric Evans)
  - Pratica acumulada da BGR/Taito (vertical RH/competencias, PHP estrito).
---

# Padroes de POO -- BGR / Taito

> Documento constitucional para Programacao Orientada a Objetos.
> Vale para todo codigo OO da casa, independente de linguagem ou framework.
> Aqui ficam os princípios universais; o `padroes-php.md` aplica
> esses princípios à realidade da linguagem PHP, e o `padroes-seguranca.md`
> aplica à fronteira do sistema.
>
> Codigo que viola regras ERRO nao e discutido -- e devolvido.
>
> **71 regras | IDs: POO-001 a POO-071**
> POO-001 a POO-062: princípios universais de OO.
> POO-063 a POO-068: padrões arquiteturais BGR (entidade, repo, manager, handler).
> POO-069 a POO-071: regras derivadas de incidentes reais.
> Regras de linguagem PHP vivem em padroes-php.md.
> Regras de fronteira (sanitizar, escapar, criptografar) vivem em padroes-seguranca.md.

> **Como este documento se relaciona com o livro do Thiago Leite e Carvalho.**
> O livro (Casa do Codigo, 2024) e a fonte principal das regras. Cada
> capitulo do livro mapeia para uma secao deste documento:
>
> - Capitulo 3 (Por que usar OO) -> Secoes 0 e 8 (gap semantico, coesao, acoplamento, reuso).
> - Capitulo 4 (Fundamentos) -> Secao 0 (3 pilares: abstracao, reuso, encapsulamento).
> - Capitulo 5 (Conceitos estruturais) -> Secoes 1, 2, 3 (classe, atributo, metodo, objeto, mensagem).
> - Capitulo 6 (Conceitos relacionais) -> Secoes 4, 5, 6 (heranca, associacao, interface).
> - Capitulo 7 (Conceitos organizacionais) -> Secoes 2, 8 (visibilidades, pacotes/camadas).
> - Capitulo 9 (Boas praticas BP01-BP15) -> Secoes 8 e 11 (regras POO-040, POO-041, POO-053 a POO-062).
> - Apendice IV (SOLID) -> Secao 7 (POO-035 a POO-039).
>
> **Os 3 pilares do livro.** Diferente da tradicao oral que cita 4 pilares
> (encapsulamento, heranca, polimorfismo, abstracao), o livro do Thiago Leite
> e explicito: a OO tem **3 fundamentos -- abstracao, reuso e encapsulamento**.
> Heranca, polimorfismo e associacao sao *mecanismos* que viabilizam esses
> pilares; nao sao pilares por si. Esta sutileza nao e estilistica: ela
> orienta o que priorizar quando regras conflitarem.
> Precedência entre docs: padroes-seguranca > padroes-poo > padroes-php > framework.

---

## 0. Os 3 pilares e o gap semantico

> Esta secao nao tem regras numeradas -- ela e o quadro de fundo. Tudo
> que vier depois se justifica em algum dos tres pilares ou na luta
> contra o gap semantico. Quando uma regra parecer arbitraria, volte
> aqui: provavelmente ela esta servindo a um destes quatro objetivos.

### Os 3 pilares (Capitulo 4 do livro)

O livro do Thiago Leite e Carvalho lista exatamente tres pilares da OO,
nesta ordem:

1. **Abstracao.** Isolar o essencial e ignorar o acidental. Uma classe
   nao representa "tudo que se sabe sobre uma cadeira" -- representa
   "o que importa para o sistema saber sobre cadeira". A boa abstracao
   tem nome de dominio, expoe pouca superficie, e esconde como faz.
   Abstracao e o que permite generalizar (uma classe `Forma` que serve
   para varios tipos) e especializar (subclasses concretas com detalhes
   proprios). A maior parte da Secao 3 deste documento serve a este
   pilar.

2. **Reuso.** Evitar repeticao. O livro e claro: "nao existe pior
   pratica em programacao do que a repeticao de codigo". Reuso em OO se
   da por dois caminhos -- heranca (reuso por subtipo) e associacao
   (reuso por composicao). O livro insiste, e nos seguimos: associacao
   e quase sempre o caminho certo (BP07 / POO-020). Reuso ruim --
   heranca para reusar codigo que nao tem relacao "e-um" -- e pior do
   que repeticao, porque acopla tudo. A Secao 4 deste documento serve
   este pilar.

3. **Encapsulamento.** Esconder a implementacao, expor apenas o
   resultado. A analogia do livro e direta: o paciente nao recebe
   "400mg de acido acetilsalicilico + 1mg de maleato de
   dexclorfeniramina + ..."; recebe "1 comprimido de Resfriol".
   Encapsulamento tem duas faces: ocultacao da informacao (estado
   privado) e ocultacao do como (metodos publicos como API). Ferir
   uma das duas e o erro mais comum em codigo OO de iniciantes (e ate
   de senior estressado). A Secao 2 deste documento serve este pilar.

**Sobre heranca e polimorfismo serem ou nao pilares.** Muito do mercado
brasileiro repete a frase "OO tem 4 pilares: abstracao, encapsulamento,
heranca e polimorfismo". O livro do Thiago Leite e explicito ao discordar
e nos adotamos a posicao do livro. Heranca e polimorfismo sao mecanismos
poderosos que **viabilizam** abstracao, reuso e encapsulamento -- mas nao
sao pilares por si. Tratar polimorfismo como pilar leva ao culto da
heranca; tratar heranca como pilar leva ao "extends para reusar codigo".
Ambos sao anti-padroes (POO-019, POO-020, POO-024).

### O gap semantico (Capitulo 3.4 do livro)

**Definicao.** Gap semantico e a distancia entre como o especialista de
dominio descreve o problema (em portugues, no quadro branco, no Notion)
e como o codigo o representa. OO existe **especificamente** para reduzir
esse gap. Se voce le o codigo e nao reconhece o vocabulario do produto,
o gap esta grande -- e voce vai pagar caro em manutencao.

**Exemplo concreto (Taito).** Quando o produto diz "o colaborador
atinge a competencia X ao ser aprovado em N avaliacoes", o codigo
deveria ler:

```php
if ($colaborador->atingiu($competencia)) {
    $colaborador->emitirCertificado($competencia);
}
```

E **nunca**:

```php
if ($u->ev[5] >= 7 && $u->ev[5] <= 10 && count($u->p) > $u->m) {
    self::doStuff($u, $u->ev[5]);
}
```

A primeira versao tem gap pequeno -- voce le o codigo e ouve o
especialista. A segunda tem gap gigante -- voce so entende o codigo
abrindo arquivo por arquivo, decifrando indices.

**Como o gap se manifesta na pratica.** Em ordem decrescente de gravidade:

1. Nomes em ingles em codigo de dominio em portugues (`User` para `Colaborador`, `evaluate` para `avaliar`).
2. Estruturas tecnicas modeladas como conceitos (`UserDataMap` em vez de `Colaborador`).
3. Logica de dominio em servicos (POO-017): a regra "atingir competencia" mora em algum `EvaluationService::process()`, longe da entidade.
4. Tipos primitivos em vez de Value Objects (POO-014, POO-015): `string $cpf` em vez de `Cpf`.
5. Cadeias de `if` por tipo em vez de polimorfismo (POO-025).

**Como combater o gap.** Cada regra deste documento ataca uma faceta:
linguagem ubiqua (POO-002, POO-016), entidades ricas (POO-017),
predicados descritivos (POO-005, POO-033), Value Objects (POO-014).
A soma vencer o gap; uma regra isolada nao basta.

---

## 1. Fundamentos da Orientacao a Objetos

> A OO nao e sobre classes -- e sobre como modelar o dominio em conceitos
> com identidade, estado e comportamento. Errar aqui contamina toda a
> arquitetura: os bugs aparecem na entidade, mas a raiz esta em ter modelado
> "uma tabela do banco" em vez de "um conceito do negocio".

### POO-001 -- Uma classe modela um conceito do dominio, nao uma estrutura tecnica [ERRO]

**Regra:** Toda classe deve representar um conceito identificavel do dominio do negocio (Lancamento, ContaBancaria, Avaliacao, Competencia, Colaborador) ou um conceito tecnico bem delimitado (Repositorio, Handler, Manager). Nunca uma classe que e apenas "um saco de funcoes uteis", "Helpers", "Utils", "Common".

**Verifica:** Buscar classes com nomes genericos: `grep -rn "class.*Helper\|class.*Utils\|class.*Common\|class.*Manager$\|class.*Service$" inc/`. Toda classe assim e candidata a violacao -- precisa ser quebrada em conceitos com nome de dominio.

**Por quê:** Classes "Helper" sao gavetas que crescem indefinidamente. Quando alguem precisa de uma nova funcao, joga ali. Em seis meses, voce tem `FinanceiroHelper` com 40 metodos sem coesao alguma. No projeto, isso ja causou retrabalho de toda uma camada porque ninguem mais sabia o que era responsabilidade do Helper e o que era do gerenciador. Conceitos do dominio tem fronteira clara -- "Lancamento" sabe o que pode e o que nao pode fazer.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// Conceito de dominio identificavel: um lancamento financeiro
// e algo que existe no mundo real, com regras proprias.
class Lancamento
{
    public function valorLiquido(): int
    {
        return $this->valorCents - $this->descontoCents;
    }

    public function podeCancelar(): bool
    {
        return $this->status === self::STATUS_PENDENTE;
    }
}

// Conceito tecnico bem delimitado: persiste lancamentos.
class LancamentoRepository
{
    public function buscarPorId(int $id): ?Lancamento { /* ... */ }
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// "Helpers" vira gaveta. Hoje 3 metodos, em 6 meses 40 metodos
// sem coesao alguma -- formatar moeda, validar cpf, calcular juros,
// enviar e-mail, gerar pdf, escapar string. Tudo no mesmo lugar.
class FinanceiroHelper
{
    public static function formatarMoeda(int $cents): string { /* ... */ }
    public static function calcularJuros(int $valor, float $taxa): int { /* ... */ }
    public static function validarCpf(string $cpf): bool { /* ... */ }
    public static function enviarEmailConfirmacao(string $email): void { /* ... */ }
    public static function gerarPdfRecibo(Lancamento $l): string { /* ... */ }
}
```

**Referencias:** POO-035, POO-040, PHP-011

---

### POO-002 -- Nomeacao no idioma do dominio, nunca no idioma da implementacao [ERRO]

**Regra:** Classes, metodos e atributos devem usar a linguagem que o usuario do sistema usa para descrever o conceito. "Avaliacao", "Competencia", "Colaborador", "Confirmar", "Atingir meta" -- nunca "Item1", "Process", "Manager2", "DoStuff", "ProcessData".

**Verifica:** Inspecao em code review: nomes genericos como "Process", "Handle", "Manage", "Item", "Data", "Object", "Helper" como sufixo principal sao violacao. Discutir o nome no domain-driven naming, nao apenas em revisao de codigo.

**Por quê:** Quando o codigo usa o vocabulario do negocio, a distancia entre "o requisito que veio do PO" e "o codigo que implementa" diminui. No Taito, quando o cliente diz "esse colaborador atingiu a competencia X", queremos ler exatamente isso no codigo: `$colaborador->atingiu($competencia)`. Nao `$user->processItem($obj)`. Code review fica mais rapido, novos devs entendem o sistema mais rapido, e o proprio time de produto consegue ler trechos do codigo.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// Vocabulario do dominio: "colaborador", "competencia", "atingiu",
// "avaliar". Quem leu a especificacao ja entende o codigo.
class Colaborador
{
    public function atingiu(Competencia $competencia): bool
    {
        return $this->avaliacoes->paraCompetencia($competencia)->foiAprovada();
    }

    public function competenciasAdquiridas(): CompetenciaCollection
    {
        return $this->avaliacoes->aprovadas()->competencias();
    }
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// Generico, sem dominio: "user", "item", "process", "data".
// Nao da pra inferir nada do negocio so olhando o nome.
class User
{
    public function process(Item $item): bool
    {
        return $this->data->checkStuff($item);
    }

    public function getList(): array
    {
        return $this->data->all();
    }
}
```

**Referencias:** POO-005, POO-016, PHP-010

---

### POO-003 -- Atributos representam estado; metodos representam comportamento [ERRO]

**Regra:** Atributos sao SUBSTANTIVOS que descrevem o que o objeto E ou TEM (`$saldoCents`, `$nome`, `$dataNascimento`). Metodos sao VERBOS que descrevem o que o objeto FAZ ou RESPONDE (`confirmar()`, `temSaldo()`, `valorLiquido()`). Nunca o contrario.

**Verifica:** Inspecao visual: propriedade com nome verbal (`$processar`, `$validar`) e violacao -- ou ela deveria ser metodo, ou o nome esta errado. Metodo com nome de estado (`saldoCents()` retornando o atributo cru sem semantica) e candidato a virar acessor com proposito.

**Por quê:** A confusao entre estado e comportamento e a fonte numero 1 de classes anemicas. Quando voce tem `$validar` como propriedade, o que isso significa? Um booleano? Um closure? Um objeto? E quando voce tem `getValor()` como metodo que so retorna `$this->valor`, isso poderia ser uma propriedade publica -- a OO nao agregou nada. No Taito, queremos `$avaliacao->foiAprovada()` (verbo, comportamento) e nao `$avaliacao->aprovada` (estado boolean exposto).

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

class ContaBancaria
{
    // ATRIBUTOS: substantivos. Estado da conta.
    private int $saldoCents;
    private string $titular;
    private DateTimeImmutable $abertaEm;
    private string $status;

    // METODOS: verbos. Comportamento da conta.
    public function depositar(int $valorCents): void { /* ... */ }
    public function sacar(int $valorCents): void { /* ... */ }
    public function temSaldo(int $valorCents): bool { /* ... */ }
    public function estaAtiva(): bool { /* ... */ }
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

class ContaBancaria
{
    // ERRADO: nome de propriedade com cara de verbo.
    private bool $depositar;
    private bool $validar;

    // ERRADO: metodo que so devolve atributo cru, sem semantica.
    // Poderia ser propriedade publica que daria no mesmo.
    public function getSaldoCents(): int
    {
        return $this->saldoCents;
    }
}
```

**Referencias:** POO-005, POO-017, PHP-022

---

### POO-004 -- Identidade nao e o mesmo que igualdade [AVISO]

**Regra:** Entidades tem **identidade** (`$id`, `$uuid`) -- duas entidades sao "a mesma" se tem o mesmo identificador, mesmo que outros campos tenham mudado. Value Objects nao tem identidade -- dois Value Objects sao iguais se todos os campos sao iguais. A classe deve declarar explicitamente em qual categoria ela se encaixa.

**Verifica:** Em code review, perguntar para cada classe: "duas instancias com mesmos campos sao a mesma coisa? ou apenas iguais?" Se a resposta nao esta clara olhando o codigo, e violacao. Comparar entidades por igualdade de campos (`==`) em vez de identidade (`->id() === $outro->id()`) e violacao.

**Por quê:** Confundir identidade com igualdade leva a bugs sutis: dois `Lancamento` com mesmo valor mas IDs diferentes nao sao "o mesmo lancamento" -- sao dois lancamentos parecidos. Tratar como o mesmo apaga registros. Por outro lado, dois `Cep` com o mesmo valor sao iguais, ponto. Forcar ID em Value Object polui o modelo. Saber qual e qual evita classe inteira de bugs.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// ENTIDADE: tem identidade. O ID a torna unica no sistema.
// Dois lancamentos com mesmo valor sao DUAS coisas diferentes.
class Lancamento
{
    public function __construct(
        private readonly int $id,
        private int $valorCents,
        private string $descricao,
    ) {}

    // Comparacao por identidade.
    public function ehMesmo(Lancamento $outro): bool
    {
        return $this->id === $outro->id;
    }
}

// VALUE OBJECT: nao tem identidade. Sao "iguais" se valores sao iguais.
// Dois CEPs "01234-567" sao A MESMA coisa em qualquer lugar do sistema.
final class Cep
{
    public function __construct(public readonly string $valor) {}

    // Comparacao por igualdade de campos.
    public function igualA(Cep $outro): bool
    {
        return $this->valor === $outro->valor;
    }
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// ERRADO: comparar entidade por igualdade de campos.
// Dois lancamentos com mesmo valor cents nao sao A MESMA entidade.
if ($lancamento1->valorCents() === $lancamento2->valorCents()) {
    // Considera "o mesmo lancamento". Bug se sao IDs diferentes.
}

// ERRADO: forcar ID em Value Object polui o modelo.
class Cep
{
    public function __construct(
        private readonly int $id,        // CEP nao precisa de ID
        public readonly string $valor,
    ) {}
}
```

**Referencias:** POO-014, POO-017

---

### POO-005 -- Codigo le como prosa do dominio (auto-documentado) [AVISO]

**Regra:** A leitura sequencial dos metodos publicos de uma classe deve formar uma frase em portugues que descreve o que aquele conceito sabe fazer. Se a sequencia parece codigo cifrado, os nomes precisam mudar.

**Verifica:** Em code review, ler em voz alta uma cadeia de chamadas: `$colaborador->avaliar($competencia)->foiAprovada()`. Soa como prosa? Se nao, refatorar. Predicados booleanos com prefixo `is`/`has` em codigo portugues sao violacao -- usar `esta`/`foi`/`pode`/`tem`.

**Por quê:** Codigo e lido muitas mais vezes do que escrito. No projeto, code review tem dev humano e Claude Code. Ambos sao mais eficientes em prosa do que em criptografia. Quando voce le `if ($lancamento->estaConfirmado() && $lancamento->podeCancelar())`, nao precisa abrir a classe para entender. Quando voce le `if ($l->st === 1 && $l->c === 0)`, voce abre, pesquisa o significado dos numeros, e perde tempo.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// Le como prosa em portugues.
// "Se o colaborador atingiu a competencia, registra a aprovacao."
if ($colaborador->atingiu($competencia)) {
    $colaborador->registrarAprovacao($competencia);
}

// "Se o lancamento esta confirmado e pode cancelar, cancela."
if ($lancamento->estaConfirmado() && $lancamento->podeCancelar()) {
    $lancamento->cancelar();
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// Cifrado. Para entender, e preciso abrir Lancamento e Colaborador
// e mapear cada constante numerica.
if ($l->st === 1 && $l->ct === 0) {
    $l->prc();
}

// Ingles + portugues misturados, e prefixo "is" em codigo portugues.
if ($lancamento->isConfirmed() && $lancamento->canCancel()) {
    $lancamento->cancelar();
}
```

**Referencias:** POO-002, PHP-023, PHP-033

---

## 2. Encapsulamento

> Encapsulamento nao e "atributo privado". E "ninguem fora da classe sabe
> como ela guarda o estado". Quando voce expoe getters/setters de tudo,
> voce so escondeu o atributo atras de dois metodos -- a logica continua
> espalhada em quem chama.

### POO-006 -- Atributos sempre privados [ERRO]

**Regra:** Atributos de classe (campos) sao sempre `private` por padrao. `protected` so e aceito em hierarquias controladas (POO-021). `public` e proibido em atributos de instancia, com a unica excecao de Value Objects imutaveis (`readonly`).

**Verifica:** `grep -rn "public \$\|protected \$" inc/` -- atributo publico ou protegido em entidade ou servico e violacao. Em Value Objects, `public readonly` e aceito (nao quebra encapsulamento porque nunca muda).

**Por quê:** Atributo publico vira API. Quando voce faz `$lancamento->valor` ser publico, qualquer codigo do sistema pode ler ou (pior) escrever em `valor`. Voce perdeu o controle do estado. No projeto, ja vimos um campo publico `$status` ser sobrescrito por um handler que nao deveria nem saber que existia status -- porque podia. A unica defesa e nunca expor o atributo cru.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// Atributos privados. O acesso passa por metodos da classe,
// que podem (e devem) impor regras.
class Lancamento
{
    private int $valorCents;
    private string $status;
    private DateTimeImmutable $criadoEm;

    public function valorCents(): int { return $this->valorCents; }
    public function estaConfirmado(): bool
    {
        return $this->status === self::STATUS_CONFIRMADO;
    }
}

// EXCECAO ACEITA: Value Object com public readonly.
// Como nunca muda, nao quebra encapsulamento.
final class Cep
{
    public function __construct(public readonly string $valor) {}
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// ERRADO: atributos publicos. Qualquer codigo pode reescrever.
class Lancamento
{
    public int $valorCents;
    public string $status;
}

// PERIGO: alguem la longe pode setar status para o que quiser.
$lancamento->status = 'qualquer-coisa-que-eu-quiser';
```

**Referencias:** POO-008, PHP-018

---

### POO-007 -- Imutabilidade quando nao ha motivo para mutar [AVISO]

**Regra:** Toda propriedade que nao muda apos a construcao deve ser declarada `readonly`. Quando uma classe inteira nunca muda apos a construcao (Value Objects, eventos de dominio, DTOs), declarar a classe como totalmente imutavel.

**Verifica:** Inspecao em construtores: propriedades como `$id`, `$userId`, `$criadoEm`, `$cpf`, `$cep` sem `readonly` sao candidatas a violacao. Verificar se ha reatribuicao fora do construtor; se nao, devem ser readonly.

**Por quê:** Imutabilidade elimina classes inteiras de bugs: ninguem pode mudar o que nao da pra mudar. No projeto, ja houve bug de "ID do lancamento mudou no meio do processamento" -- impossivel se `$id` for `readonly`. Alem disso, objetos imutaveis sao seguros para compartilhar, paralelizar e cachear. O custo e baixo (uma palavra-chave no atributo) e o ganho e enorme.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// Identidade e dados estruturais nunca mudam.
// Status pode mudar via lifecycle methods (POO-017, POO-046).
class Lancamento
{
    public function __construct(
        private readonly int $id,
        private readonly int $userId,
        private readonly DateTimeImmutable $criadoEm,
        private string $status,            // muda via confirmar() / cancelar()
        private int $valorCents,            // muda via aplicarDesconto()
    ) {}
}

// VALUE OBJECT TOTALMENTE IMUTAVEL.
// Toda propriedade e readonly. A classe e final (POO-022).
final class Cep
{
    public function __construct(public readonly string $valor) {}
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// ERRADO: $id mutavel. Um bug pode trocar o ID de um registro.
class Lancamento
{
    public function __construct(
        private int $id,            // sem readonly
        private int $userId,        // sem readonly
        private string $status,
    ) {}

    // E ainda expor um metodo que muda o ID por engano:
    public function setId(int $id): void { $this->id = $id; }
}
```

**Referencias:** POO-014, POO-046, PHP-019

---

### POO-008 -- Sem setters publicos genericos [ERRO]

**Regra:** Setters do tipo `setStatus($valor)` que aceitam qualquer valor e mudam o atributo diretamente sao proibidos. Mudancas de estado passam por metodos com nomes de dominio que validam invariantes (`confirmar()`, `cancelar()`, `aplicarDesconto($valorCents)`).

**Verifica:** `grep -rn "function set[A-Z]" inc/entidades/` deve retornar vazio. Em servicos/gerenciadores, setters sao aceitos com mais cuidado, mas ainda preferir metodos de dominio.

**Por quê:** Setter generico e o oposto de OO -- e voltar para "saco de campos". Quando voce expoe `setStatus()`, qualquer codigo pode mudar status para qualquer valor: pula validacoes, pula transicoes, pula efeitos colaterais. No projeto, esse foi exatamente o caminho que permitiu um lancamento "cancelado" voltar para "confirmado" -- nao tinha como impedir, porque a porta estava aberta. Metodos de dominio fecham a porta.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

class Lancamento
{
    private string $status;
    private int $descontoCents = 0;

    // Mudanca de estado com nome de dominio. Valida transicao.
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

    // Mudanca de estado com nome de dominio. Valida regra de negocio.
    public function aplicarDesconto(int $descontoCents): void
    {
        if ($descontoCents < 0) {
            throw new DescontoInvalidoException();
        }
        if ($descontoCents > $this->valorCents) {
            throw new DescontoMaiorQueValorException();
        }
        $this->descontoCents = $descontoCents;
    }
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

class Lancamento
{
    // Generico: aceita qualquer valor, sem validacao, sem transicao.
    // E inutil ter logica de FSM em outro lugar -- esse setter
    // permite escapar dela.
    public function setStatus(string $status): void
    {
        $this->status = $status;
    }

    // Generico: aceita desconto negativo, desconto maior que valor,
    // desconto em lancamento cancelado. Nada e validado.
    public function setDescontoCents(int $valor): void
    {
        $this->descontoCents = $valor;
    }
}
```

**Referencias:** POO-046, POO-047, PHP-022, PHP-024

---

### POO-009 -- Getter so existe quando ha consumidor real [AVISO]

**Regra:** Nao crie getter "porque um dia alguem pode precisar". Getter so existe quando ha codigo concreto que consome o valor. Quando o valor e usado apenas dentro da propria classe, ele continua privado e sem acesso externo.

**Verifica:** Em code review, perguntar para cada getter: "qual codigo fora desta classe usa isso?" Se a resposta for "nenhum" ou "talvez no futuro", remover o getter.

**Por quê:** Cada getter e um vazamento controlado de estado. Quanto menos vazar, mais facil refatorar a classe internamente sem quebrar consumidores. Adicionar getter "preventivamente" cria acoplamento que nao existia. Quando voce decidir trocar `$valorCents` por `Money`, todos os getters viram problema. Adicionar getter sob demanda mantem a superficie minima.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

class Lancamento
{
    private int $valorCents;
    private int $descontoCents;
    private string $status;
    private DateTimeImmutable $criadoEm;
    private array $tags;

    // Existe getter porque a UI mostra o valor liquido.
    public function valorLiquido(): int
    {
        return $this->valorCents - $this->descontoCents;
    }

    // Existe predicado porque handlers verificam isso.
    public function estaConfirmado(): bool
    {
        return $this->status === self::STATUS_CONFIRMADO;
    }

    // NAO existe getter para $tags ou $criadoEm porque
    // ninguem fora da classe usa. Sao detalhe interno hoje.
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

class Lancamento
{
    private int $valorCents;
    private int $descontoCents;
    private string $status;
    private DateTimeImmutable $criadoEm;
    private array $tags;

    // Getters preventivos para TODOS os campos.
    // Acoplamento futuro garantido com codigo que nem existe ainda.
    public function getValorCents(): int { return $this->valorCents; }
    public function getDescontoCents(): int { return $this->descontoCents; }
    public function getStatus(): string { return $this->status; }
    public function getCriadoEm(): DateTimeImmutable { return $this->criadoEm; }
    public function getTags(): array { return $this->tags; }
    // E um setter pra cada um, claro.
}
```

**Referencias:** POO-006, POO-013, PHP-023

---

### POO-010 -- Tell, Don't Ask [ERRO]

**Regra:** Em vez de perguntar o estado de um objeto e tomar decisao fora dele, mande o objeto fazer a coisa. A logica fica DENTRO do objeto que tem os dados, nao fora.

**Verifica:** Padrao a procurar: `if ($obj->getX() === Y) { $obj->setZ(W); }` -- buscar uma propriedade, comparar, e mudar outra com base nisso. Isso e "ask" -- deveria ser um metodo de dominio que faz tudo isso ("tell"). `grep -rn "->get.*().*==.*->set" inc/` ajuda.

**Por quê:** Ask espalha logica de dominio fora da classe. Cada lugar que pergunta o estado e decide e uma copia da regra de negocio. Quando a regra muda, voce tem que achar todas as copias. No projeto, isso ja causou divergencia em 4 lugares diferentes -- quatro versoes da regra "lancamento pendente pode ser cancelado". Tell consolida tudo na classe que conhece o conceito. A regra muda? Muda em um lugar so.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// TELL: mando o lancamento cancelar. Ele cuida das regras.
// Se nao puder cancelar, ele que avise (excecao tipada).
$lancamento->cancelar();

// TELL: mando a conta sacar. A conta cuida do saldo, dos limites,
// das regras de horario e do que mais for relevante.
$conta->sacar($valorCents);

// O metodo cancelar() na classe consolida toda a regra:
public function cancelar(): void
{
    if ($this->status === self::STATUS_CANCELADO) {
        return; // ja cancelado, idempotente
    }
    if ($this->status === self::STATUS_PROCESSANDO) {
        throw new CancelamentoBloqueadoException();
    }
    $this->status = self::STATUS_CANCELADO;
    $this->canceladoEm = new DateTimeImmutable();
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// ASK: pergunta status, decide aqui fora, escreve aqui fora.
// Cada handler do sistema vai ter uma copia desta logica.
if ($lancamento->getStatus() !== 'cancelado'
    && $lancamento->getStatus() !== 'processando') {
    $lancamento->setStatus('cancelado');
    $lancamento->setCanceladoEm(new DateTimeImmutable());
}

// ASK: pergunta saldo, decide aqui fora.
// A regra "tem saldo o suficiente" nao mora em ContaBancaria,
// mora aqui no chamador -- e em outros 5 chamadores.
if ($conta->getSaldoCents() >= $valorCents) {
    $conta->setSaldoCents($conta->getSaldoCents() - $valorCents);
}
```

**Referencias:** POO-008, POO-017, POO-035

---

### POO-011 -- Lei de Demeter: nao fale com estranhos [ERRO]

**Regra:** Um metodo de uma classe pode chamar metodos:
1. da propria classe (`$this->foo()`)
2. dos seus proprios atributos (`$this->dependencia->foo()`)
3. dos parametros que recebe (`$param->foo()`)
4. de objetos criados localmente (`(new Foo)->bar()`)

Nao pode atravessar mais de um nivel: `$this->a->b->c->fazer()` e violacao.

**Verifica:** `grep -rn "->.*->.*->.*->" inc/` -- 4+ niveis de cadeia de metodos e violacao mecanica. 3 niveis e candidato a revisao. Cadeia em getters (`->getFoo()->getBar()->getBaz()`) e o sintoma classico.

**Por quê:** Cada `->` extra na cadeia e um acoplamento extra -- voce sabe demais sobre a estrutura interna de objetos que nao sao seus. Quando `$this->a` ganha um novo nivel, `$this->a->b` quebra, e voce tem que caçar todos os lugares que faziam `$this->a->b->c`. No projeto, isso ja causou refatoracao em 12 arquivos por uma mudanca trivial. Demeter limita o raio de explosao.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

class FinanceiroManager
{
    public function __construct(
        private readonly LancamentoRepository $lancamentos,
    ) {}

    public function totalDoUsuario(int $userId): int
    {
        // Fala com proprio atributo. Um nivel. OK.
        $lancamentos = $this->lancamentos->buscarPorUsuario($userId);

        // Fala com parametro do loop. Um nivel. OK.
        $total = 0;
        foreach ($lancamentos as $lancamento) {
            $total += $lancamento->valorLiquido();
        }
        return $total;
    }
}

// Quando precisa de algo "interno" de algum atributo,
// CRIE UM METODO no atributo que entrega o resultado direto.
class Lancamento
{
    public function valorLiquido(): int  // <-- evita atravessar
    {
        return $this->valorCents - $this->descontoCents;
    }
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// Atravessa varios niveis de objetos alheios.
// Acoplado a estrutura interna de Lancamento, Conta e Banco.
$valor = $usuario->getConta()->getBanco()->getTaxas()->doDia();

// Cadeia de getters tipica do anti-padrao "ask".
// Acoplado a estrutura interna de Pedido, Cliente, Endereco.
$cep = $pedido->getCliente()->getEndereco()->getCep()->getValor();
```

**Referencias:** POO-010, POO-040, POO-041

---

### POO-012 -- Construtor garante objeto valido ou lanca excecao [ERRO]

**Regra:** Apos a execucao do construtor, o objeto DEVE estar em estado valido. Se algum parametro impede um estado valido, o construtor lanca excecao tipada e o objeto nunca existe. Nao existe "objeto meio construido" no codigo.

**Verifica:** Inspecao em construtores: validacoes de invariantes (CPF tem 11 digitos, valor e positivo, status pertence ao enum) devem estar no construtor ou em named constructor (`Cpf::de('123')`). `grep -rn "function __construct" inc/entidades/` para localizar e revisar.

**Por quê:** Quando o construtor permite objeto invalido, o problema migra para "todo lugar que usa esse objeto". Cada metodo precisa re-validar `if ($this->cpf !== null && strlen($this->cpf) === 11)`. Multiplique por 50 metodos. Construtor que valida concentra a regra em um lugar e da uma garantia: "se voce tem o objeto, voce tem um valido". O resto do codigo confia.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

final class Cpf
{
    public function __construct(public readonly string $valor)
    {
        // Invariante: CPF tem 11 digitos numericos.
        if (!preg_match('/^\d{11}$/', $valor)) {
            throw new CpfInvalidoException($valor);
        }
        // Invariante: digito verificador correto (omitido por brevidade).
        if (!self::digitoVerificadorOk($valor)) {
            throw new CpfInvalidoException($valor);
        }
    }

    private static function digitoVerificadorOk(string $cpf): bool
    {
        // ... calculo padrao do CPF
        return true;
    }
}

// Apos isso, qualquer codigo que receber um Cpf TEM CERTEZA
// que e valido. Nao precisa revalidar.
$cpf = new Cpf('12345678909'); // ou explode aqui
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

class Cpf
{
    private string $valor = '';

    // Construtor sem argumentos: cria CPF "vazio".
    public function __construct() {}

    // Setter para definir depois -- pode ser invalido.
    public function setValor(string $cpf): void
    {
        // Aceita qualquer string. Sem validacao.
        $this->valor = $cpf;
    }

    // Agora todo metodo precisa proteger:
    public function valor(): string
    {
        if ($this->valor === '') {
            throw new CpfNaoDefinidoException();
        }
        return $this->valor;
    }
}
```

**Referencias:** POO-046, POO-047, PHP-022

---

## 3. Abstracao

> Abstrair e esconder o que nao importa para mostrar o que importa.
> Boa abstracao tem nome de dominio, esconde implementacao, e expoe apenas
> o que outros conceitos precisam saber.

### POO-013 -- Cada classe expoe a menor superficie publica possivel [ERRO]

**Regra:** Metodos publicos sao a API da classe. Tudo que nao e parte essencial dessa API e privado. Helper interno: privado. Detalhe de implementacao: privado. Calculo intermediario: privado. Apenas operacoes de dominio sao publicas.

**Verifica:** Em code review, contar metodos publicos da classe. Mais de 7-10 metodos publicos numa entidade ja e sinal de alerta. Em servicos/gerenciadores, mais de 5 e candidato a quebra (POO-035).

**Por quê:** Quanto menor a superficie publica, mais voce pode mudar a classe sem quebrar consumidores. Metodo publico e contrato; deletar contrato e breaking change. No projeto, ja tivemos classe com 25 metodos publicos -- era impossivel refatorar nada sem quebrar testes em outro modulo. Quando uma classe expoe apenas o que outras classes precisam, ela respira -- pode mudar internamente sem afetar ninguem.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

class Lancamento
{
    // PUBLICOS: 4 metodos. Operacoes de dominio.
    public function valorLiquido(): int { /* ... */ }
    public function estaConfirmado(): bool { /* ... */ }
    public function confirmar(): void { /* ... */ }
    public function cancelar(): void { /* ... */ }

    // PRIVADOS: tudo que e detalhe.
    private function podeTransicionarPara(string $novo): bool { /* ... */ }
    private function aplicarTransicao(string $novo): void { /* ... */ }
    private function validarValor(int $valor): void { /* ... */ }
    private function calcularDesconto(): int { /* ... */ }
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

class Lancamento
{
    // 12 metodos publicos. Tudo virou API.
    // Cada um e um contrato que limita a refatoracao futura.
    public function valorLiquido(): int { /* ... */ }
    public function estaConfirmado(): bool { /* ... */ }
    public function confirmar(): void { /* ... */ }
    public function cancelar(): void { /* ... */ }
    public function podeTransicionarPara(string $novo): bool { /* ... */ }
    public function aplicarTransicao(string $novo): void { /* ... */ }
    public function validarValor(int $valor): void { /* ... */ }
    public function calcularDesconto(): int { /* ... */ }
    public function recalcularValorBruto(): int { /* ... */ }
    public function logarMudanca(): void { /* ... */ }
    public function notificar(): void { /* ... */ }
    public function persistir(): void { /* ... */ }
}
```

**Referencias:** POO-009, POO-035, POO-040

---

### POO-014 -- Conceitos sem identidade viram Value Objects [ERRO]

**Regra:** Quando um conceito do dominio so faz sentido pelo conjunto de seus valores (CEP, CPF, Email, Money, DateRange, Cor), ele deve ser modelado como Value Object: imutavel, com igualdade por valor, sem ID. Nao deve ser modelado como string solta ou int solto carregado de funcoes auxiliares.

**Verifica:** `grep -rn "string \$cpf\|string \$email\|string \$cep\|int \$valor.*Cents" inc/` -- candidatos a virar Value Object. Em entidades de dominio, primitivos com semantica especifica (CPF e string mas tem regras) sao violacao.

**Por quê:** "Primitive obsession" e um anti-padrao classico: voce passa string $cpf por todo o sistema, e em cada lugar precisa lembrar de validar, formatar, e tratar erros. Um VO concentra essas regras em uma classe pequena. No Taito, a Competencia tem uma "pontuacao" que tem regras (0-100, sem decimais, com niveis "iniciante/intermediario/avancado"). Um VO Pontuacao concentra tudo isso; um `int $pontuacao` espalha as regras por toda parte.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// Value Object: imutavel, sem identidade, igual por valor.
final class Money
{
    public function __construct(
        public readonly int $cents,
        public readonly string $moeda = 'BRL',
    ) {
        if ($cents < 0) {
            throw new MoneyInvalidoException();
        }
    }

    public function somar(Money $outro): Money
    {
        if ($this->moeda !== $outro->moeda) {
            throw new MoedaIncompativelException($this->moeda, $outro->moeda);
        }
        return new Money($this->cents + $outro->cents, $this->moeda);
    }

    public function igualA(Money $outro): bool
    {
        return $this->cents === $outro->cents
            && $this->moeda === $outro->moeda;
    }
}

// Uso: tipo expressivo, regras encapsuladas.
class Lancamento
{
    public function __construct(
        private readonly int $id,
        private Money $valor,
    ) {}
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// Primitive obsession: int + string solto.
// Cada lugar tem que lembrar de tratar moeda separadamente,
// e a validacao "cents nao negativo" mora em todos os lugares.
class Lancamento
{
    public function __construct(
        private readonly int $id,
        private int $valorCents,
        private string $moeda,
    ) {
        if ($valorCents < 0) {
            throw new InvalidArgumentException();
        }
    }

    public function somar(int $outroCents, string $outraMoeda): int
    {
        if ($this->moeda !== $outraMoeda) {
            throw new InvalidArgumentException();
        }
        return $this->valorCents + $outroCents;
    }
}
```

**Referencias:** POO-004, POO-007, POO-015, PHP-032

---

### POO-015 -- Combata "primitive obsession" (BP02 do livro) [AVISO]

**Regra:** Tipos primitivos (`string`, `int`, `float`, `bool`) sao apropriados para dados sem semantica de dominio (`$contador`, `$indice`, `$pagina`). Quando o primitivo carrega regras de dominio (CPF e string com validacao, valor e int em centavos), encapsular em Value Object (POO-014).

**Verifica:** Em code review, perguntar para cada parametro/atributo primitivo: "ha regras de dominio sobre esse valor?". Se sim, candidato a VO. Sequencia de strings/ints na assinatura de um metodo (`func($cpf, $cep, $email)`) e sintoma classico.

**Por quê:** Primitivo nao se autovalida. Cada vez que voce usa `string $cpf`, voce tem que lembrar: "essa string ja foi validada? formatada? esta crua?". Erro silencioso e quase certo. Um `Cpf` no tipo do parametro elimina a duvida -- se voce conseguiu chamar a funcao, voce passou um CPF valido. O compilador e o IDE viram aliados.

**Caso classico do livro (BP02 -- "use strings com parcimonia").** Thiago Leite usa o caso do `Cliente` com `String dataAniversario`, `String sexo` e `String endereco`. Em todos os tres a string e a opcao errada:

- `dataAniversario` -- usar `DateTimeImmutable`. Calcular idade a partir de string e tortura.
- `sexo` -- usar `enum` (em PHP 8.1+). String aceita "M", "Masculino", "masc", "Homem", "1" -- todos errados, todos passam silenciosamente.
- `endereco` -- usar uma classe `Endereco` (logradouro, numero, bairro, cidade, cep). Buscar "todos os clientes que moram em Eusebio" via `LIKE` numa string e o caminho da treva.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// Tipos expressivos contam a historia. Voce sabe que recebe
// CPF valido, dinheiro com moeda explicita, e datas com fuso.
public function transferir(
    Cpf $origem,
    Cpf $destino,
    Money $valor,
    DateTimeImmutable $quandoOcorreu,
): TransferenciaId {
    // ...
}

// Uso:
$id = $servico->transferir(
    new Cpf($cpfOrigemBruto),
    new Cpf($cpfDestinoBruto),
    new Money(15000, 'BRL'),
    new DateTimeImmutable(),
);
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// Cinco strings/ints. Qual e qual? Quem ja foi validado?
// O proprio metodo nao consegue garantir nada.
public function transferir(
    string $cpfOrigem,
    string $cpfDestino,
    int $valorCents,
    string $moeda,
    string $quando,
): int {
    // E aqui dentro, validar tudo de novo, e em todo lugar
    // que chama, validar antes tambem, e cada um a seu jeito.
}
```

**Referencias:** POO-014, POO-016, PHP-014

---

### POO-016 -- Use o vocabulario do especialista de dominio [AVISO]

**Regra:** Quando o time de produto e o cliente usam um termo, o codigo usa o mesmo termo. "Avaliacao" no Taito nao e "Review", nem "Assessment", nem "Eval" -- e Avaliacao. "Trilha" nao e "Track" nem "Path". "Brio" nao vira "Token" no codigo (Brio e o token do Taito, mas tem nome proprio).

**Verifica:** Em code review com o líder técnico ou com o líder de produto: cada classe nova passa pelo "voce usa esse termo na conversa diaria?". Termos novos no codigo que nao existem no Notion/Slack do produto sao violacao.

**Por quê:** Domain-Driven Design comecou daqui: ubiquitous language. Quando codigo e produto falam o mesmo idioma, conversas em reuniao, tickets no backlog e PRs ficam alinhados. No Taito, "Brio" e o token interno; chamar isso de "Token", "Coin" ou "Credit" no codigo cria duas linguagens paralelas. Tres meses depois, ninguem mais sabe qual termo e qual.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// Termos que o cliente usa: Colaborador, Avaliacao, Competencia, Brio.
class Colaborador
{
    public function ganharBrio(int $quantidade, string $motivo): void { /* ... */ }
    public function avaliacaoEm(Competencia $competencia): ?Avaliacao { /* ... */ }
}

class Avaliacao
{
    public function foiAprovada(): bool { /* ... */ }
}

class Brio
{
    // Token interno do Taito (POO-002). Tem nome proprio.
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// Termos genericos que ninguem do produto usa.
class User                        // ninguem chama de User
{
    public function addToken(int $amount): void { /* ... */ }   // Brio nao e Token
    public function evaluation($x): ?Review { /* ... */ }       // Avaliacao nao e Review
}

class Review                     // Avaliacao virou Review
{
    public function isApproved(): bool { /* ... */ }
}

class Token                      // Brio virou Token
{
    // ...
}
```

**Referencias:** POO-002, POO-005

---

### POO-017 -- Entidades ricas: comportamento mora junto dos dados [ERRO]

**Regra:** Entidades de dominio contem **a logica que opera sobre seus proprios dados**. Calculos, predicados, transicoes, validacoes de regra de negocio. Servicos/gerenciadores orquestram entidades; nao reimplementam a logica que pertence a elas.

**Verifica:** Buscar logica em servicos que toca atributos de entidade: `grep -rn "->getValor.*-.*->getDesconto" inc/gerenciadores/` indica calculo que deveria estar na entidade. Setters publicos em entidade (POO-008) sao violacao correlata.

**Por quê:** Entidade anemica + servico inflado = "modelo de transacao por script". Toda regra de negocio mora em servicos espalhados, e a entidade e so um carregador de dados. Quando a regra muda, voce caça em N servicos. Entidade rica concentra: a regra de "lancamento pendente pode ser confirmado" mora em `Lancamento::confirmar()`. Acabou.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// ENTIDADE RICA. Sabe operar sobre seus proprios dados.
class Lancamento
{
    public function valorLiquido(): int
    {
        return $this->valorCents - $this->descontoCents;
    }

    public function aplicarDesconto(int $descontoCents): void
    {
        if ($descontoCents < 0 || $descontoCents > $this->valorCents) {
            throw new DescontoInvalidoException();
        }
        $this->descontoCents = $descontoCents;
    }

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
}

// SERVICO ENXUTO: orquestra. A logica esta na entidade.
class FinanceiroManager
{
    public function confirmarLancamento(int $id): void
    {
        $lancamento = $this->repositorio->buscarPorId($id);
        $lancamento->confirmar();           // <-- a regra mora la
        $this->repositorio->salvar($lancamento);
    }
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// ENTIDADE ANEMICA. So getter / setter.
class Lancamento
{
    public function getValor(): int { return $this->valorCents; }
    public function getDesconto(): int { return $this->descontoCents; }
    public function setStatus(string $s): void { $this->status = $s; }
}

// SERVICO INFLADO. A regra de negocio mora aqui, longe dos dados.
class FinanceiroManager
{
    public function confirmarLancamento(int $id): void
    {
        $l = $this->repositorio->buscarPorId($id);
        if ($l->getStatus() !== 'pendente') {
            throw new \Exception('nao da pra confirmar');
        }
        $l->setStatus('confirmado');
        $this->repositorio->salvar($l);
    }

    public function valorLiquidoDe(int $id): int
    {
        $l = $this->repositorio->buscarPorId($id);
        return $l->getValor() - $l->getDesconto();   // logica fora da entidade
    }
}
```

**Referencias:** POO-003, POO-010, POO-035, PHP-022

---

### POO-018 -- Abstracoes estaveis na direcao certa [AVISO]

**Regra:** Abstracoes (interfaces, classes abstratas, classes de dominio) ficam mais estaveis a medida que voce desce as camadas: dominio (mais estavel) > aplicacao > infraestrutura (menos estavel). Nunca uma camada estavel depende de uma camada instavel.

**Verifica:** Em code review, verificar a direcao de `use`/`namespace`. Entidade que importa `mysqli`, `wpdb`, `Guzzle`, `cURL` ou qualquer detalhe de infra e violacao. Servico de aplicacao que importa um namespace `Infra\` direto (sem passar por interface) e candidato.

**Por quê:** Codigo de infra muda muito (versoes de banco, libs HTTP, frameworks). Codigo de dominio muda pouco (a regra "lancamento pendente vira confirmado" e quase eterna). Se infra muda e quebra dominio, voce esta refazendo a cabeca toda vez. Inverter a dependencia (dominio define interface, infra implementa) protege o nucleo. No projeto, a entidade `Lancamento` ja sobreviveu a duas trocas de driver de banco -- porque nao depende de banco.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// CAMADA DOMINIO: estavel. Define interface, ignora detalhe de infra.
namespace Dominio\Financeiro;

interface LancamentoRepository
{
    public function buscarPorId(int $id): ?Lancamento;
    public function salvar(Lancamento $lancamento): void;
}

class Lancamento { /* ... */ }

// CAMADA INFRA: instavel. Implementa a interface do dominio.
namespace Infra\Financeiro;

class LancamentoRepositoryMysql implements \Dominio\Financeiro\LancamentoRepository
{
    public function __construct(private readonly \PDO $pdo) {}
    public function buscarPorId(int $id): ?\Dominio\Financeiro\Lancamento { /* ... */ }
    public function salvar(\Dominio\Financeiro\Lancamento $l): void { /* ... */ }
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// ERRADO: camada de dominio depende de PDO (infra).
// Se a infra muda (de PDO para wpdb, por exemplo),
// voce muda a entidade -- que nao tem nada a ver com isso.
namespace Dominio\Financeiro;

use PDO;

class Lancamento
{
    public function persistir(PDO $pdo): void
    {
        $stmt = $pdo->prepare("INSERT INTO lancamentos ...");
        $stmt->execute([/* ... */]);
    }
}
```

**Referencias:** POO-039, POO-042, POO-044, PHP-026

---

## 4. Heranca

> Heranca e a feature mais abusada da OO. Vista em volume errado, vira
> hierarquia gigante de classes que ninguem entende e ninguem consegue
> trocar. A regra de ouro: heranca e e-um (taxonomia), composicao e
> tem-um (capacidade). Em duvida, prefira composicao.

### POO-019 -- Heranca apenas para "e-um" verdadeiro [ERRO]

**Regra:** `B extends A` so e aceitavel quando "todo B e um A no sentido pleno do dominio". `Quadrado` extends `Forma` -- ok. `ContaPoupanca` extends `ContaBancaria` -- ok se voce realmente trata ContaPoupanca como ContaBancaria em todos os lugares. Heranca para reusar codigo, sem relacao "e-um", e violacao.

**Verifica:** Em code review, formular o "Liskov test" para cada `extends`: "se eu trocar a subclasse pela superclasse em qualquer ponto do codigo, ainda funciona conceitualmente?" Se a resposta tem "depende", rever a heranca.

**Por quê:** Heranca cria acoplamento permanente. A subclasse herda TUDO da superclasse -- atributos, metodos, contratos, comportamentos. Quando voce usa heranca apenas para reusar 3 metodos, voce esta colando a subclasse a 30 metodos que ela nao queria. No projeto, ja vimos `LogService extends User` "porque ambos precisavam de createdAt" -- absurdo. Composicao resolve sem violar a hierarquia.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// E-um valido: ContaCorrente E-UMA ContaBancaria. Em qualquer lugar
// que recebe ContaBancaria, ContaCorrente funciona.
abstract class ContaBancaria
{
    abstract public function tarifaMensal(): int;
    public function depositar(int $valorCents): void { /* ... */ }
    public function sacar(int $valorCents): void { /* ... */ }
}

class ContaCorrente extends ContaBancaria
{
    public function tarifaMensal(): int { return 2500; }
}

class ContaPoupanca extends ContaBancaria
{
    public function tarifaMensal(): int { return 0; }
    public function calcularRendimento(): int { /* ... */ }
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// Heranca apenas para reuso. NotificacaoService nao E-UM Logger.
// Acopla todo o sistema de notificacao a logger -- e quando logger
// mudar a interface, notificacao quebra junto.
class Logger
{
    public function info(string $msg): void { /* ... */ }
    public function error(string $msg): void { /* ... */ }
    public function debug(string $msg): void { /* ... */ }
    protected function format(string $msg): string { /* ... */ }
}

class NotificacaoService extends Logger    // ERRADO: nao e Logger
{
    public function enviarEmail(string $to, string $body): void
    {
        $this->info("Enviando email para $to");   // usa heranca pra reusar log
        // ...
    }
}
```

**Referencias:** POO-020, POO-023

---

### POO-020 -- Composicao em vez de heranca [ERRO]

**Regra:** Para reusar comportamento, COMPOR (ter um atributo do tipo desejado) e melhor que HERDAR. Heranca e usada apenas para modelar "e-um" (POO-019). Para "tem-um" ou "usa-um", composicao e a regra.

**Verifica:** Em code review, perguntar para cada `extends`: "esta classe USA a outra ou E a outra?". Se "USA", refatorar para composicao. `grep -rn "class.*extends" inc/` e ponto de partida.

**Por quê:** Composicao e mais flexivel: voce pode trocar a parte composta em runtime, pode compor varias coisas, pode mockar para teste. Heranca te prende: depois que voce extends, nao tem volta. No projeto, refatoramos uma hierarquia de 4 niveis de heranca (que nasceu querendo reusar codigo) para 1 classe + 3 colaboradores compostos. O codigo ficou metade do tamanho e os testes ficaram triviais.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// COMPOSICAO: NotificacaoService TEM-UM Logger.
// Pode trocar logger em teste, pode compor com outras coisas.
class NotificacaoService
{
    public function __construct(
        private readonly Logger $logger,
        private readonly EmailSender $emailSender,
    ) {}

    public function enviarEmail(string $to, string $body): void
    {
        $this->logger->info("Enviando email para $to");
        $this->emailSender->enviar($to, $body);
    }
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// HERANCA APENAS PARA REUSO: NotificacaoService herda Logger.
// Nao da pra trocar o logger em teste sem subclasse.
// Acoplado a toda a interface publica de Logger.
class NotificacaoService extends Logger
{
    public function enviarEmail(string $to, string $body): void
    {
        $this->info("Enviando email para $to");
        // ...
    }
}
```

**Referencias:** POO-019, POO-042

---

### POO-021 -- Maximo 2 niveis de heranca [AVISO]

**Regra:** Hierarquias de heranca tem no maximo 2 niveis: classe abstrata/interface base + 1 nivel de subclasses concretas. Hierarquias mais profundas viram intratavel.

**Verifica:** `grep -rn "class.*extends.*extends" inc/` -- raro mas detectavel. Em code review, mapear visualmente a arvore de heranca; mais de 2 niveis e violacao.

**Por quê:** Cada nivel de heranca multiplica a quantidade de "metodo virtual" que voce precisa rastrear quando le um trecho. Tres niveis: voce precisa olhar 3 arquivos para entender uma chamada. Quatro niveis: voce desistiu. No projeto, ja tivemos `Lancamento extends Movimentacao extends Registro extends EntidadeBase` -- todo metodo virtual era uma surpresa. Achatar resolve.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// 2 niveis: abstract base + concrete.
abstract class Forma
{
    abstract public function area(): float;
}

class Quadrado extends Forma
{
    public function __construct(private readonly float $lado) {}
    public function area(): float { return $this->lado ** 2; }
}

class Circulo extends Forma
{
    public function __construct(private readonly float $raio) {}
    public function area(): float { return M_PI * $this->raio ** 2; }
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// 4 niveis. Para entender Lancamento::salvar() voce precisa abrir
// Movimentacao, Registro e EntidadeBase. Mais um override em cada.
abstract class EntidadeBase                          // nivel 1
{
    public function salvar(): void { /* ... */ }
}
abstract class Registro extends EntidadeBase         // nivel 2
{
    public function salvar(): void { /* override */ }
}
abstract class Movimentacao extends Registro        // nivel 3
{
    public function salvar(): void { /* override */ }
}
class Lancamento extends Movimentacao               // nivel 4
{
    public function salvar(): void { /* override */ }
}
```

**Referencias:** POO-019, POO-020, POO-034

---

### POO-022 -- Classes finais por padrao [AVISO]

**Regra:** Toda classe concreta nasce `final`. So removemos o `final` quando ha um caso real (e revisado em code review) de necessidade de extensao.

**Verifica:** `grep -rn "^class " inc/ | grep -v "abstract\|final"` -- classes sem `final` ou `abstract` sao candidatas a violacao.

**Por quê:** `final` previne heranca acidental e libera o autor da classe da obrigacao de manter contratos virtuais. Se voce deixa toda classe estensivel, qualquer mudanca interna e breaking change para alguma subclasse hipotetica. `final` deixa voce refatorar a classe livremente. Quando alguem realmente precisar estender, a discussao acontece em PR -- e voce avalia se isso e o caminho ou se composicao resolve.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// Classe final: protege a integridade interna e libera refatoracao.
final class Lancamento
{
    // ...
}

// Classe abstrata: planejada para ser estendida.
abstract class Forma { /* ... */ }

// Classe nao-final: revisada em PR, justificada pela necessidade
// real de uma hierarquia (POO-019, POO-021).
class ContaBancaria { /* ... */ }
class ContaCorrente extends ContaBancaria { /* ... */ }
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// ERRADO: classe extensivel "por preguica". Daqui a 6 meses,
// alguem extende em outro modulo. Quando voce mudar a classe,
// quebra os outros sem aviso.
class Lancamento
{
    public function valorLiquido(): int { /* ... */ }
}
```

**Referencias:** POO-019, POO-020, POO-021

---

### POO-023 -- Liskov Substitution Principle (LSP) [ERRO]

**Regra:** Subclasses devem ser substituiveis pela superclasse sem quebrar o comportamento esperado. Subclasse nao pode:
- exigir parametros mais restritos do que a superclasse;
- retornar valores menos compativeis;
- lancar excecoes nao previstas pela superclasse;
- enfraquecer pos-condicoes ou fortalecer pre-condicoes.

**Verifica:** Em code review, simular: "se eu tiver `Forma $f = new Quadrado(); ...uso $f...`, o codigo do uso continua valido?". Override que muda assinatura, lanca excecao nova ou retorna tipo mais estreito e violacao.

**Por quê:** LSP e o que faz polimorfismo funcionar. Se subclasse nao se comporta como a superclasse, polimorfismo vira mina terrestre: voce nunca sabe se o codigo generico vai explodir num caso particular. O caso classico do "Quadrado extends Retangulo" mostra: ao setar largura, Quadrado tambem altera altura (porque "tem que ser igual") -- viola a expectativa de quem usa Retangulo.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// Hierarquia respeita LSP: ambas as subclasses se comportam
// como Forma em qualquer contexto.
abstract class Forma
{
    abstract public function area(): float;
}

final class Circulo extends Forma
{
    public function __construct(private readonly float $raio) {}
    public function area(): float { return M_PI * $this->raio ** 2; }
}

final class Quadrado extends Forma
{
    public function __construct(private readonly float $lado) {}
    public function area(): float { return $this->lado ** 2; }
}

// Codigo polimorfico funciona: nao precisa saber qual e qual.
function somaAreas(array $formas): float
{
    return array_sum(array_map(fn(Forma $f) => $f->area(), $formas));
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// O classico que viola LSP: Quadrado nao se comporta como Retangulo.
class Retangulo
{
    public function __construct(
        protected float $largura,
        protected float $altura,
    ) {}

    public function setLargura(float $w): void { $this->largura = $w; }
    public function setAltura(float $h): void { $this->altura = $h; }
    public function area(): float { return $this->largura * $this->altura; }
}

class Quadrado extends Retangulo
{
    public function setLargura(float $w): void
    {
        $this->largura = $w;
        $this->altura = $w;   // surpresa! quem usa Retangulo nao espera isso
    }

    public function setAltura(float $h): void
    {
        $this->largura = $h;
        $this->altura = $h;   // mesma surpresa
    }
}

// Codigo polimorfico quebra:
function aumentarLargura(Retangulo $r): void
{
    $r->setLargura($r->largura * 2);
    // Para Quadrado, altura tambem dobrou. Surpresa.
}
```

**Referencias:** POO-019, POO-037, POO-022

---

### POO-024 -- Nao herdar para reusar codigo [ERRO]

**Regra:** Heranca *nunca* e a resposta para "preciso reusar este codigo". A resposta e: extrair em metodo, em classe, em colaborador injetado. Heranca e modelagem de hierarquia de tipos, nao mecanismo de reuso.

**Verifica:** Em code review do `extends`, perguntar: "qual e o motivo?". Se a resposta for "para reusar a logica X", refatorar para extracao + composicao. Toda subclasse que so existe para chamar metodos da superclasse e violacao.

**Por quê:** Heranca usada como "macro de reuso" cria hierarquias bizarras: `RelatorioMensal extends RelatorioBase extends DataLoader extends EntityHelper`. Cada nivel adicionou um metodo util e uma camada de confusao. Quando voce precisa do metodo `formatarData()`, a resposta nao e estender uma classe que tem -- e injetar um `DateFormatter`.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// Reuso por composicao: cada classe tem o que precisa.
class RelatorioMensal
{
    public function __construct(
        private readonly DateFormatter $dataFormatter,
        private readonly LancamentoRepository $repositorio,
    ) {}

    public function gerar(string $mesAno): string
    {
        $lancamentos = $this->repositorio->buscarPorMes($mesAno);
        $linhas = array_map(
            fn($l) => $this->dataFormatter->formatar($l->criadoEm()),
            $lancamentos
        );
        return implode("\n", $linhas);
    }
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// ERRADO: heranca "porque RelatorioBase ja tem formatarData".
// Acoplado a toda a hierarquia que nao tem nada a ver com relatorio.
class RelatorioMensal extends RelatorioBase
{
    public function gerar(string $mesAno): string
    {
        $lancamentos = $this->loadEntities('lancamentos', $mesAno);
        return implode("\n", array_map(
            fn($l) => $this->formatarData($l->criadoEm),  // metodo da super
            $lancamentos
        ));
    }
}

abstract class RelatorioBase extends DataLoader
{
    protected function formatarData(\DateTimeInterface $d): string
    {
        return $d->format('d/m/Y');
    }
}

abstract class DataLoader extends EntityHelper
{
    protected function loadEntities(string $tipo, string $param): array
    {
        // ...
    }
}
```

**Referencias:** POO-019, POO-020

---

## 5. Polimorfismo

> Polimorfismo e "varios objetos respondem a mesma mensagem de jeitos
> diferentes". Ele troca cadeia de `if/switch` por dispatch automatico.
> Quando bem usado, abre o codigo a extensao sem mudar o que ja existe.

### POO-025 -- Polimorfismo via interface, nao via condicional [ERRO]

**Regra:** Quando o codigo precisa decidir "qual versao do comportamento executar", crie uma interface (ou classe abstrata) e deixe o objeto que voce ja tem responder por si. Nada de `if ($tipo === 'X') ... elseif ($tipo === 'Y') ...`.

**Verifica:** `grep -rn "switch.*tipo\|if.*tipo.*===\|elseif.*tipo" inc/` -- cadeias de decisao por tipo sao candidatos a polimorfismo. Tres `elseif` no mesmo metodo ja e violacao.

**Por quê:** Cada cadeia de `if` e uma armadilha aberta para o futuro: quando aparecer um tipo novo, voce tem que achar todas as cadeias e adicionar uma branch. Esquece uma -- bug em producao. Polimorfismo elimina o problema: voce cria a nova classe, ela implementa a interface, e funciona em todo lugar que ja era polimorfico. O sistema fica aberto para extensao (POO-036).

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

interface CalculadoraImposto
{
    public function calcular(int $baseCents): int;
}

final class IcmsSp implements CalculadoraImposto
{
    public function calcular(int $baseCents): int
    {
        return (int) round($baseCents * 0.18);
    }
}

final class IcmsRj implements CalculadoraImposto
{
    public function calcular(int $baseCents): int
    {
        return (int) round($baseCents * 0.20);
    }
}

// Codigo cliente nao sabe qual e qual.
class Faturamento
{
    public function totalComImposto(int $baseCents, CalculadoraImposto $imposto): int
    {
        return $baseCents + $imposto->calcular($baseCents);
    }
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// Cadeia condicional. Cada estado novo e mais um elseif aqui
// e em todos os outros lugares que tem a mesma cadeia.
class Faturamento
{
    public function totalComImposto(int $baseCents, string $estado): int
    {
        if ($estado === 'SP') {
            $imposto = (int) round($baseCents * 0.18);
        } elseif ($estado === 'RJ') {
            $imposto = (int) round($baseCents * 0.20);
        } elseif ($estado === 'MG') {
            $imposto = (int) round($baseCents * 0.18);
        } else {
            $imposto = 0;
        }
        return $baseCents + $imposto;
    }
}
```

**Referencias:** POO-026, POO-029, POO-036

---

### POO-026 -- Substitua condicional de tipo por polimorfismo [ERRO]

**Regra:** Quando voce ve `if ($obj instanceof X) ...`, e quase sempre indicio de polimorfismo faltante. Mover o comportamento para um metodo da interface e deixar cada subclasse responder.

**Verifica:** `grep -rn "instanceof" inc/` -- cada match e candidato a refatoracao. Casos legitimos sao raros (factory que precisa decidir baseado em tipo concreto recem-criado, type guards em fronteira do sistema).

**Por quê:** `instanceof` e a ferramenta de quem nao tem polimorfismo bom. Cada `instanceof` extra acopla o codigo a uma hierarquia concreta. Se a hierarquia muda, voce caça os `instanceof`. Refatorar para polimorfismo elimina o caçar -- adiciona-se uma classe nova, e nada precisa ser tocado nos consumidores.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

interface PagamentoMethod
{
    public function processar(int $valorCents): TransacaoId;
    public function descricaoNoExtrato(): string;
}

final class Pix implements PagamentoMethod
{
    public function processar(int $valorCents): TransacaoId { /* ... */ }
    public function descricaoNoExtrato(): string
    {
        return 'PIX recebido';
    }
}

final class Boleto implements PagamentoMethod
{
    public function processar(int $valorCents): TransacaoId { /* ... */ }
    public function descricaoNoExtrato(): string
    {
        return 'Boleto compensado';
    }
}

// Cliente nao usa instanceof. Confia na interface.
$descricao = $metodo->descricaoNoExtrato();
$id = $metodo->processar($valorCents);
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// ERRADO: caso a caso por instanceof. Cada novo metodo de
// pagamento exige tocar este codigo (e provavelmente outros).
function descricaoNoExtrato(PagamentoMethod $m): string
{
    if ($m instanceof Pix) {
        return 'PIX recebido';
    }
    if ($m instanceof Boleto) {
        return 'Boleto compensado';
    }
    if ($m instanceof Cartao) {
        return 'Cartao de credito';
    }
    return 'Desconhecido';
}
```

**Referencias:** POO-025, POO-036

---

### POO-027 -- Override muda comportamento, nunca contrato [ERRO]

**Regra:** Subclasse pode mudar como o metodo faz, nunca o que ele promete. Mesma assinatura, mesmas pre-condicoes (ou mais fracas), mesmas pos-condicoes (ou mais fortes), mesmas excecoes esperadas. Tudo o que muda e a implementacao.

**Verifica:** Override que adiciona excecao nova, restringe parametro, ou retorna tipo mais especifico do que a superclasse e violacao. PHPStan/Psalm com nivel maximo apontam.

**Por quê:** E aqui que LSP (POO-023) se manifesta no dia a dia. Voce escreveu codigo polimorfico contra a superclasse; espera que toda subclasse honre o mesmo contrato. Quando uma subclasse decide "ah, mas no meu caso, lanco essa excecao a mais", o codigo polimorfico quebra ao encontrar essa subclasse. O contrato e da superclasse, nao da subclasse.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

abstract class Notificador
{
    /**
     * @throws NotificacaoException se nao puder enviar.
     */
    abstract public function enviar(Mensagem $msg): void;
}

final class NotificadorEmail extends Notificador
{
    public function enviar(Mensagem $msg): void
    {
        try {
            $this->smtp->enviar($msg);
        } catch (SmtpException $e) {
            // Mantem o contrato: lanca o tipo previsto pela superclasse.
            throw new NotificacaoException($e->getMessage(), 0, $e);
        }
    }
}

final class NotificadorSlack extends Notificador
{
    public function enviar(Mensagem $msg): void
    {
        try {
            $this->slack->postar($msg);
        } catch (SlackApiException $e) {
            throw new NotificacaoException($e->getMessage(), 0, $e);
        }
    }
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

abstract class Notificador
{
    /**
     * @throws NotificacaoException
     */
    abstract public function enviar(Mensagem $msg): void;
}

final class NotificadorEmail extends Notificador
{
    public function enviar(Mensagem $msg): void
    {
        // ERRADO: quebra o contrato lancando excecao diferente.
        // Codigo polimorfico que captura NotificacaoException nao captura essa.
        if (!filter_var($msg->destinatario(), FILTER_VALIDATE_EMAIL)) {
            throw new \InvalidArgumentException('email invalido');
        }
        $this->smtp->enviar($msg);
    }
}
```

**Referencias:** POO-023, POO-045

---

### POO-028 -- Override marcado explicitamente [AVISO]

**Regra:** Quando uma subclasse sobrescreve um metodo, marcar a intencao de forma visivel. Em PHP 8.3+, usar atributo `#[\Override]`. Em versoes anteriores, comentario explicito (`/** @override */`) e nome do metodo identico ao da superclasse.

**Verifica:** Em PHP 8.3+, override sem `#[\Override]` em uma classe que estende outra e violacao. Em versoes anteriores, override sem comentario e candidato a violacao.

**Por quê:** Override implicito e armadilha: o desenvolvedor pensa que esta criando metodo novo, mas esta sobrescrevendo. Ou pior: a superclasse muda a assinatura, e a subclasse silenciosamente para de overrider e vira metodo novo (com bug). O atributo `#[\Override]` faz o PHP errar ao se a superclasse nao tiver mais o metodo.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

abstract class Notificador
{
    abstract public function enviar(Mensagem $msg): void;

    public function logarEnvio(Mensagem $msg): void
    {
        error_log("[Notificador] enviando: {$msg->assunto()}");
    }
}

final class NotificadorEmail extends Notificador
{
    #[\Override]
    public function enviar(Mensagem $msg): void
    {
        $this->smtp->enviar($msg);
    }

    #[\Override]
    public function logarEnvio(Mensagem $msg): void
    {
        error_log("[Email] enviando para: {$msg->destinatario()}");
    }
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

abstract class Notificador
{
    abstract public function enviar(Mensagem $msg): void;
}

final class NotificadorEmail extends Notificador
{
    // Sem #[\Override]: se a superclasse mudar para enviarMensagem(),
    // este metodo continua existindo e VIRA metodo novo. O codigo
    // polimorfico nao chama mais este, e o bug some no silencio.
    public function enviar(Mensagem $msg): void
    {
        $this->smtp->enviar($msg);
    }
}
```

**Referencias:** POO-023, POO-027

---

### POO-029 -- Strategy pattern para variacoes de comportamento [AVISO]

**Regra:** Quando um metodo precisa variar SO O ALGORITMO (nao o conceito), use Strategy: extraia o algoritmo em uma interface, e o objeto principal recebe a estrategia por composicao. Regra a aplicar: se a variacao pode mudar em runtime ou durante o ciclo de vida do objeto, e provavelmente Strategy.

**Verifica:** Em code review, quando aparece `if/switch` para escolher COMO calcular algo (nao QUAL conceito usar), considerar Strategy.

**Por quê:** Strategy abre o codigo a novas estrategias sem tocar o objeto principal. No projeto, a forma de calcular pontuacao da Avaliacao no Taito tem 4 variacoes (peso simples, peso por nivel, peso por importancia, peso ponderado por trilha). Em vez de `if ($tipo === ...)` no metodo, cada estrategia e uma classe -- e adicionar uma quinta nao toca em codigo existente.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

interface CalculadoraPontuacao
{
    public function calcular(Avaliacao $avaliacao): int;
}

final class PesoSimples implements CalculadoraPontuacao
{
    public function calcular(Avaliacao $a): int
    {
        return array_sum($a->respostas()) / count($a->respostas());
    }
}

final class PesoPorNivel implements CalculadoraPontuacao
{
    public function calcular(Avaliacao $a): int
    {
        // ... usa pesos por nivel
    }
}

final class Avaliacao
{
    public function __construct(
        private readonly CalculadoraPontuacao $calculadora,
        // ...
    ) {}

    public function pontuacao(): int
    {
        return $this->calculadora->calcular($this);
    }
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

class Avaliacao
{
    private string $tipoCalculo;

    public function pontuacao(): int
    {
        // Cadeia que cresce a cada novo modo de calcular.
        if ($this->tipoCalculo === 'simples') {
            return array_sum($this->respostas) / count($this->respostas);
        }
        if ($this->tipoCalculo === 'por_nivel') {
            // ...
        }
        if ($this->tipoCalculo === 'por_importancia') {
            // ...
        }
        // ...
    }
}
```

**Referencias:** POO-025, POO-026, POO-036

---

## 6. Interfaces e classes abstratas

> Interfaces sao contratos: "qualquer coisa que se diz X faz isto".
> Classes abstratas sao templates parciais: "todo X faz isto, e estes
> daqui voce decide como". Saber qual usar quando e metade do design.

### POO-030 -- Programe para interface, nao para implementacao [ERRO]

**Regra:** Tipos de parametros, retornos, atributos e dependencias usam o tipo mais abstrato que o codigo realmente precisa. Se voce so chama `salvar()`, dependa de `LancamentoRepository` (interface), nao de `LancamentoRepositoryMysql` (implementacao concreta).

**Verifica:** Em code review, para cada `private readonly XYZ $dep` ou parametro `XYZ`, perguntar: "preciso de um XYZ concreto, ou bastaria de uma interface?". Quase sempre, basta a interface.

**Por quê:** Acoplar a implementacao concreta amarra voce a ela: nao tem como trocar (mudou o banco?), nao tem como mockar (nao tem como testar isolado), nao tem como ter duas (online vs offline). Acoplar a interface deixa tudo em aberto -- voce decide a implementacao no ponto de wiring (composicao raiz, container, factory).

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

interface LancamentoRepository
{
    public function buscarPorId(int $id): ?Lancamento;
    public function salvar(Lancamento $lancamento): void;
}

final class FinanceiroManager
{
    // Depende de INTERFACE. A implementacao real e injetada.
    public function __construct(
        private readonly LancamentoRepository $repositorio,
    ) {}

    public function confirmarLancamento(int $id): void
    {
        $lancamento = $this->repositorio->buscarPorId($id);
        $lancamento->confirmar();
        $this->repositorio->salvar($lancamento);
    }
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

final class FinanceiroManager
{
    // Acoplado a uma implementacao especifica de banco.
    // Para testar, voce precisa de um MySQL real ou uma subclasse
    // de LancamentoRepositoryMysql que sobrescreva metodos.
    public function __construct(
        private readonly LancamentoRepositoryMysql $repositorio,
    ) {}
}
```

**Referencias:** POO-039, POO-042, POO-049

---

### POO-031 -- Interface define contrato, classe abstrata define template [AVISO]

**Regra:** Use **interface** quando voce precisa apenas declarar "todo X expoe estes metodos", sem nenhum codigo compartilhado. Use **classe abstrata** quando ha codigo (campo, metodo nao abstrato) que todas as subclasses devem reusar.

**Verifica:** Em code review, classe abstrata sem nenhum metodo nao-abstrato e sem atributo deveria ser interface. Interface com codigo "compartilhado" colado dentro de cada implementacao deveria ser classe abstrata.

**Por quê:** Interfaces sao multiplas (uma classe pode implementar varias). Classes abstratas sao unicas (heranca em PHP nao permite multipla). Trocar uma pela outra impacta o que mais a classe pode ser. Alem disso, interface puramente abstrata e o caminho para abstracoes estaveis (POO-018); classe abstrata e o caminho para compartilhar implementacao real.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// INTERFACE: contrato puro, sem codigo. Multiplas classes podem implementar.
interface Comparavel
{
    public function compararCom(Comparavel $outro): int;
}

interface Serializavel
{
    public function paraArray(): array;
}

// Uma classe pode implementar varias interfaces.
final class Lancamento implements Comparavel, Serializavel { /* ... */ }

// CLASSE ABSTRATA: tem codigo compartilhado e contrato.
abstract class Notificador
{
    public function __construct(
        protected readonly Logger $logger,    // compartilhado
    ) {}

    public function enviarComLog(Mensagem $msg): void   // compartilhado
    {
        $this->logger->info("Enviando {$msg->assunto()}");
        $this->enviar($msg);
        $this->logger->info("Enviado");
    }

    abstract protected function enviar(Mensagem $msg): void;  // contrato
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// ERRADO: classe abstrata sem nada compartilhado deveria ser interface.
// E forca heranca, que limita -- a classe nao pode estender outra.
abstract class Comparavel
{
    abstract public function compararCom($outro): int;
}

abstract class Serializavel
{
    abstract public function paraArray(): array;
}

// E uma classe so pode estender uma. Acabou.
class Lancamento extends Comparavel { /* ... */ }   // nao pode tambem ser Serializavel
```

**Referencias:** POO-030, POO-034, POO-038

---

### POO-032 -- Interface Segregation Principle [ERRO]

**Regra:** Clientes nao devem ser forcados a depender de metodos que nao usam. Interfaces grandes (`AdminRepository` com 30 metodos) viram bolo unico; quebrar em interfaces pequenas e coesas (`LancamentoLeitura`, `LancamentoEscrita`, `LancamentoAuditoria`).

**Verifica:** Interface com mais de 7-8 metodos e candidata a quebra. Em code review, perguntar: "todos os clientes desta interface usam todos os metodos?". Se nao, segregar.

**Por quê:** Interface grande forca todos os implementadores a implementar tudo, mesmo o que nao faz sentido para eles (metodos vazios, throw "not supported"). Acopla clientes que so leem aos detalhes da escrita. No projeto, ja tivemos `Repositorio` generico com 25 metodos -- toda implementacao tinha 12 stubs vazios. Quando segregamos em interfaces pequenas, cada repositorio implementou exatamente o que precisava.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// Tres interfaces pequenas e coesas.
interface LancamentoLeitura
{
    public function buscarPorId(int $id): ?Lancamento;
    public function buscarPorUsuario(int $userId): array;
}

interface LancamentoEscrita
{
    public function salvar(Lancamento $lancamento): void;
    public function deletar(int $id): void;
}

interface LancamentoAuditoria
{
    public function historicoDe(int $id): array;
}

// Implementacao completa pode juntar.
final class LancamentoRepositoryMysql implements
    LancamentoLeitura,
    LancamentoEscrita,
    LancamentoAuditoria
{
    // ...
}

// Mas servicos dependem so do que precisam.
final class RelatorioMensal
{
    public function __construct(
        private readonly LancamentoLeitura $repo,  // <-- so leitura
    ) {}
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// Interface "tudo num pacote so".
interface LancamentoRepository
{
    public function buscarPorId(int $id): ?Lancamento;
    public function buscarPorUsuario(int $userId): array;
    public function salvar(Lancamento $lancamento): void;
    public function deletar(int $id): void;
    public function historicoDe(int $id): array;
    public function exportarCsv(): string;
    public function reindexar(): void;
    public function migrarLegado(): void;
    // ...
}

// RelatorioMensal so le, mas depende da interface inteira:
// se um metodo de escrita muda, o relatorio fica acoplado.
final class RelatorioMensal
{
    public function __construct(
        private readonly LancamentoRepository $repo,
    ) {}
}
```

**Referencias:** POO-038, POO-040

---

### POO-033 -- Interfaces pequenas, focadas e coesas [AVISO]

**Regra:** Cada interface representa uma capacidade unica do dominio (`Comparavel`, `Serializavel`, `LancamentoLeitura`). Interfaces "do tipo grande misturado" (LancamentoRepositoryEFazTudoMais) sao quebradas em interfaces pequenas.

**Verifica:** Sintoma de interface ruim: nome generico (`Service`, `Manager`, `Helper`), 10+ metodos, ou metodos sem coesao tematica. Tres ou mais "areas" no mesmo grupo de metodos sao indicio de quebra.

**Por quê:** Interfaces pequenas sao componiveis (POO-032), refatoraveis (mudar uma nao quebra todas) e mais faciis de mockar em testes. Quando voce tem `Comparavel`, e claro o que ela exige; quando voce tem `EntidadeCompletaRepositorio`, voce nao sabe nem por onde comecar.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// Capacidades pequenas e ortogonais.
interface Hasheavel
{
    public function hash(): string;
}

interface Comparavel
{
    public function compararCom(Comparavel $outro): int;
}

interface Serializavel
{
    public function paraArray(): array;
}

interface Identificavel
{
    public function id(): int;
}

// Composicao de capacidades:
final class Lancamento implements
    Identificavel,
    Hasheavel,
    Comparavel,
    Serializavel
{
    // ...
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// Misturado: hashing + comparacao + serializacao + ID.
// Quem so quer comparar nao deveria ter que saber serializar.
interface EntidadeBase
{
    public function id(): int;
    public function hash(): string;
    public function compararCom($outro): int;
    public function paraArray(): array;
    public function paraJson(): string;
    public function paraXml(): string;
    public function clonar(): self;
    public function imprimir(): void;
}
```

**Referencias:** POO-032, POO-040

---

### POO-034 -- Classe abstrata so quando ha codigo real compartilhado [AVISO]

**Regra:** Use classe abstrata apenas quando ha codigo (campo ou metodo concreto) que TODAS as subclasses usam exatamente igual. Se cada subclasse sobrescreve o metodo "compartilhado", o codigo na superclasse nao e compartilhado de verdade -- e mistura. Refatorar para template method ou para composicao.

**Verifica:** Em code review da hierarquia: se 80%+ dos metodos da abstract sao sobrescritos por todas as subclasses, ela esta servindo so como agrupador -- candidato a interface + objetos colaboradores.

**Por quê:** Classe abstrata "vazia" (so com `abstract`) e interface fingindo ser classe (POO-031). Classe abstrata com codigo que ninguem aproveita e ainda pior: parece reuso, mas e dead weight. Quando o template method e o padrao, a classe abstrata brilha; fora disso, interface + composicao tendem a ser mais limpos.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// Classe abstrata com TEMPLATE METHOD: enviar() e fixo,
// usa hooks que cada subclasse define.
abstract class NotificadorBase
{
    public function __construct(
        protected readonly Logger $logger,
    ) {}

    // Template method: o algoritmo e fixo.
    final public function enviar(Mensagem $msg): void
    {
        $this->logger->info("Enviando: {$msg->assunto()}");
        try {
            $this->doEnviar($msg);
            $this->logger->info("Enviado com sucesso");
        } catch (\Throwable $e) {
            $this->logger->error("Falha: {$e->getMessage()}");
            throw $e;
        }
    }

    // Hook: cada subclasse define.
    abstract protected function doEnviar(Mensagem $msg): void;
}

final class NotificadorEmail extends NotificadorBase
{
    protected function doEnviar(Mensagem $msg): void
    {
        $this->smtp->enviar($msg);
    }
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// Classe abstrata que NAO compartilha nada de verdade.
// Cada subclasse sobrescreve enviar() do zero.
// E so um agrupador -- deveria ser interface.
abstract class NotificadorBase
{
    public function enviar(Mensagem $msg): void
    {
        // implementacao default que ninguem usa
        throw new \LogicException('subclasse deve sobrescrever');
    }
}

final class NotificadorEmail extends NotificadorBase
{
    public function enviar(Mensagem $msg): void
    {
        $this->smtp->enviar($msg);
    }
}

final class NotificadorSlack extends NotificadorBase
{
    public function enviar(Mensagem $msg): void
    {
        $this->slack->postar($msg);
    }
}
```

**Referencias:** POO-031, POO-021

---

## 7. SOLID

> SOLID nao e cinco principios desconectados -- e um sistema. SRP cria
> classes pequenas; OCP exige polimorfismo; LSP exige polimorfismo correto;
> ISP cria interfaces enxutas; DIP inverte a dependencia entre dominio e
> infra. As secoes anteriores ja tocaram em quase todos; aqui consolidamos.

### POO-035 -- Single Responsibility Principle (SRP) [ERRO]

**Regra:** Toda classe tem **um motivo unico para mudar**. Se voce consegue listar duas razoes plausiveis para alterar uma classe ("preciso mudar a regra X" e "preciso mudar a forma de persistir"), ela esta fazendo duas coisas.

**Verifica:** Em code review, perguntar: "se mudar a regra Y, qual classe muda? se mudar o jeito de persistir, qual classe muda?" Se a resposta for "a mesma", violacao. Classes com 200+ linhas costumam ser candidatas; classes com nome composto ("LancamentoEFinanceiroService") quase sempre violam.

**Por quê:** SRP e o principio que reduz acoplamento na fonte. Quando uma classe faz duas coisas, mudancas em uma area arriscam quebrar a outra; testes ficam mais frageis; review fica mais lento. Quando cada classe faz uma coisa so, mudancas sao localizadas. No projeto, refatoracoes que mais ganham produtividade sao as que separam "calcular pontuacao" de "gravar avaliacao" de "notificar colaborador".

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// Tres classes, tres motivos para mudar.
final class Avaliacao
{
    public function pontuacao(): int { /* regra de calculo */ }
    public function aprovou(): bool { /* regra de aprovacao */ }
}

final class AvaliacaoRepository
{
    public function salvar(Avaliacao $a): void { /* persistencia */ }
}

final class NotificadorAvaliacao
{
    public function enviar(Avaliacao $a, Colaborador $c): void { /* notificacao */ }
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// Tres motivos para mudar, uma classe so. Cada mudanca toca tudo.
final class AvaliacaoService
{
    public function calcularPontuacao(array $respostas): int { /* ... */ }

    public function salvar(Avaliacao $a): void
    {
        $stmt = $this->pdo->prepare("INSERT INTO avaliacoes ...");
        $stmt->execute([/* ... */]);
    }

    public function notificar(Avaliacao $a, Colaborador $c): void
    {
        $this->mailer->send(/* ... */);
    }

    public function gerarRelatorioPdf(array $avaliacoes): string { /* ... */ }
}
```

**Referencias:** POO-001, POO-013, POO-040

---

### POO-036 -- Open/Closed Principle (OCP) [ERRO]

**Regra:** Modulos sao **abertos para extensao, fechados para modificacao**. Adicionar comportamento novo nao deve exigir mexer em codigo testado e estavel. Mecanismo principal: polimorfismo.

**Verifica:** Quando uma feature exige editar varias classes existentes para adicionar um caso novo, o sistema viola OCP. Cadeias de `if/switch` por tipo (POO-025) sao o sintoma classico.

**Por quê:** Codigo que ja funciona e ja foi testado e patrimonio. Cada vez que voce abre para mexer, voce arrisca regredir. Sistemas que respeitam OCP crescem por adicao de classes -- raramente por edicao. No projeto, o calculo de impostos respeita OCP: para um imposto novo (ICMS-MG, por exemplo), criamos uma classe nova que implementa `CalculadoraImposto` e registramos. Nada do codigo existente muda. Zero regressao.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

interface CalculadoraImposto
{
    public function calcular(int $baseCents): int;
    public function aplicaPara(string $estado): bool;
}

final class IcmsSp implements CalculadoraImposto { /* ... */ }
final class IcmsRj implements CalculadoraImposto { /* ... */ }
final class IcmsMg implements CalculadoraImposto { /* ... */ }   // adicionado depois

final class CalculadoraImpostoFactory
{
    /** @var CalculadoraImposto[] */
    public function __construct(private array $calculadoras) {}

    public function paraEstado(string $estado): CalculadoraImposto
    {
        foreach ($this->calculadoras as $c) {
            if ($c->aplicaPara($estado)) {
                return $c;
            }
        }
        throw new ImpostoNaoSuportadoException($estado);
    }
}

// Adicionar IcmsMg: criar a classe, registrar na factory. Pronto.
// Codigo de Faturamento, da factory, dos outros impostos: nao muda.
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// Cada estado novo exige tocar este metodo. Cada toque arrisca regredir.
class Faturamento
{
    public function calcularImposto(int $baseCents, string $estado): int
    {
        if ($estado === 'SP') {
            return (int) round($baseCents * 0.18);
        } elseif ($estado === 'RJ') {
            return (int) round($baseCents * 0.20);
        } elseif ($estado === 'MG') {                  // adicionado depois
            return (int) round($baseCents * 0.18);
        }
        return 0;
    }
}
```

**Referencias:** POO-025, POO-026, POO-029

---

### POO-037 -- Liskov Substitution Principle (LSP) [ERRO]

**Regra:** (Ver POO-023.) Subclasses devem ser substituiveis pelas superclasses sem alterar a corretude do programa. Esta regra e aqui apenas para fechar o conjunto SOLID; o detalhe esta em POO-023.

**Verifica:** Ver POO-023.

**Por quê:** Ver POO-023.

**Exemplo correto:** Ver POO-023.

**Exemplo incorreto:** Ver POO-023.

**Referencias:** POO-023, POO-027

---

### POO-038 -- Interface Segregation Principle (ISP) [ERRO]

**Regra:** (Ver POO-032.) Clientes nao devem depender de metodos que nao usam. Esta regra e aqui apenas para fechar o conjunto SOLID; o detalhe esta em POO-032.

**Verifica:** Ver POO-032.

**Por quê:** Ver POO-032.

**Exemplo correto:** Ver POO-032.

**Exemplo incorreto:** Ver POO-032.

**Referencias:** POO-032, POO-033

---

### POO-039 -- Dependency Inversion Principle (DIP) [ERRO]

**Regra:** Modulos de alto nivel (dominio, regra de negocio) nao dependem de modulos de baixo nivel (infra). Ambos dependem de abstracoes (interfaces). E as abstracoes sao definidas pelo modulo de alto nivel -- nao pelo modulo de infra.

**Verifica:** Em code review, mapear `use` statements: dominio nao deve importar infra. Interface de repositorio fica no namespace do dominio (`Dominio\Financeiro\LancamentoRepository`), implementacao fica em infra (`Infra\Persistencia\LancamentoRepositoryMysql`). Ver POO-018 para a direcao completa.

**Por quê:** DIP inverte a tendencia natural ("o servico chama o banco diretamente") e protege a regra de negocio. O dominio define o que precisa (interface no namespace dele); a infra serve o dominio (implementa a interface). Isso permite trocar de banco, frameworks, e libs sem encostar na regra de negocio. No projeto, a entidade `Lancamento` ja sobreviveu a duas trocas de driver de banco.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// DOMINIO: define a interface que precisa.
namespace Dominio\Financeiro;

interface LancamentoRepository
{
    public function buscarPorId(int $id): ?Lancamento;
    public function salvar(Lancamento $lancamento): void;
}

final class FinanceiroManager
{
    public function __construct(
        private readonly LancamentoRepository $repositorio, // do dominio
    ) {}
}

// INFRA: implementa a interface do dominio.
namespace Infra\Persistencia;

use Dominio\Financeiro\Lancamento;
use Dominio\Financeiro\LancamentoRepository;

final class LancamentoRepositoryMysql implements LancamentoRepository
{
    public function __construct(private readonly \PDO $pdo) {}
    public function buscarPorId(int $id): ?Lancamento { /* ... */ }
    public function salvar(Lancamento $l): void { /* ... */ }
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// ERRADO: dominio depende direto de PDO. Inverte a direcao.
namespace Dominio\Financeiro;

final class FinanceiroManager
{
    public function __construct(
        private readonly \PDO $pdo,    // dominio acoplado a infra
    ) {}

    public function confirmarLancamento(int $id): void
    {
        $stmt = $this->pdo->prepare("SELECT * FROM lancamentos WHERE id = ?");
        $stmt->execute([$id]);
        // ...
    }
}
```

**Referencias:** POO-018, POO-030, POO-042

---

## 8. Coesao e acoplamento

> Coesao alta dentro do modulo, acoplamento baixo entre modulos. Esta e
> a regra-soma de toda OO sa. Quase toda regra anterior reforca uma
> destas duas direcoes.

### POO-040 -- Alta coesao: classe sobre um tema unico [ERRO]

**Regra:** Todos os metodos e atributos de uma classe devem girar em torno do mesmo tema do dominio. Quando voce nota dois "blocos" de metodos com pouco em comum, e duas classes coladas.

**Verifica:** Em code review, agrupar metodos da classe por afinidade. Se aparecem dois ou mais grupos sem interseccao, candidato a quebra. Test smell: setUp() do teste prepara duas coisas independentes.

**Por quê:** Coesao alta e a contrapartida de SRP (POO-035) na perspectiva do conteudo da classe. Classe coesa e facil de entender (tudo faz sentido junto), facil de testar (um cenario base) e facil de mover de namespace. Classe sem coesao e sempre dois bandos pelejando -- e os PRs ficam tocando os dois mesmo quando voce so queria mexer num.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// Coesa: tudo gira em torno do conceito "Lancamento".
final class Lancamento
{
    private string $status;
    private int $valorCents;
    private int $descontoCents;

    public function valorLiquido(): int { /* ... */ }
    public function aplicarDesconto(int $cents): void { /* ... */ }
    public function confirmar(): void { /* ... */ }
    public function cancelar(): void { /* ... */ }
    public function estaConfirmado(): bool { /* ... */ }
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// Sem coesao: lancamento + envio de email + relatorio. Tres temas.
final class Lancamento
{
    public function valorLiquido(): int { /* ... */ }
    public function confirmar(): void { /* ... */ }

    // tema "envio de email" -- nao deveria estar aqui
    public function enviarConfirmacaoPorEmail(string $emailDoUsuario): void
    {
        $this->mailer->send(/* ... */);
    }

    // tema "relatorio" -- nao deveria estar aqui
    public function gerarLinhaCsv(): string
    {
        return "{$this->id};{$this->valorCents};{$this->status}";
    }
}
```

**Referencias:** POO-001, POO-035, POO-013

---

### POO-041 -- Acoplamento baixo: dependencias minimas e por interface [ERRO]

**Regra:** Cada classe depende do menor numero possivel de outras classes, e via interfaces sempre que possivel. Mais de 3-4 dependencias no construtor sao sintoma de classe inflada (POO-035) ou dependencias dispensaveis.

**Verifica:** Construtor com 5+ dependencias e candidato a violacao. Em code review, perguntar: "essa dependencia e usada em quantos metodos? Ela e mesmo necessaria?". Se a resposta for "em um metodo so", talvez seja parametro do metodo, nao do construtor.

**Por quê:** Cada dependencia e uma corda que prende a classe. Mais cordas = mais dificil de mover, testar, refatorar. Construtor com 8 dependencias precisa de 8 mocks no teste -- ja perdeu o que ia testar. Reduzir dependencias geralmente exige descobrir que a classe faz coisas demais (POO-035).

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// Tres dependencias justificadas. Cada uma e usada em varios metodos.
final class FinanceiroManager
{
    public function __construct(
        private readonly LancamentoRepository $lancamentos,
        private readonly Clock $clock,
        private readonly Notificador $notificador,
    ) {}
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// Sete dependencias: classe inflada. Provavelmente faz coisas demais.
final class FinanceiroManager
{
    public function __construct(
        private readonly LancamentoRepository $lancamentos,
        private readonly UsuarioRepository $usuarios,
        private readonly ContaRepository $contas,
        private readonly Notificador $notificador,
        private readonly EmailSender $email,
        private readonly Logger $logger,
        private readonly RelatorioGenerator $relatorio,
        private readonly Clock $clock,
    ) {}
}
```

**Referencias:** POO-035, POO-040, POO-042

---

### POO-042 -- Dependencias explicitas via construtor [ERRO]

**Regra:** Toda dependencia colaboradora de uma classe e injetada pelo construtor. Sem `new` interno, sem `Service::getInstance()`, sem `global`, sem chamada estatica que esconde dependencia.

**Verifica:** `grep -rn "new [A-Z][a-zA-Z]*(" inc/` dentro de classes de servico/dominio -- toda criacao interna de colaborador real (nao value object) e violacao. `grep -rn "::getInstance\|global \$" inc/` deve retornar vazio.

**Por quê:** Dependencia injetada e visivel: voce le o construtor e sabe tudo que a classe usa. Dependencia escondida (singleton, global, `new` interno) e invisivel: voce so descobre que existe quando o teste explode. No projeto, refatorar um servico para receber `Clock` em vez de chamar `time()` direto ja salvou meses de bugs sutis em testes -- o teste pode "viver em qualquer dia".

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

interface Clock
{
    public function agora(): DateTimeImmutable;
}

final class ClockReal implements Clock
{
    public function agora(): DateTimeImmutable
    {
        return new DateTimeImmutable();
    }
}

final class FinanceiroManager
{
    public function __construct(
        private readonly LancamentoRepository $repositorio,
        private readonly Clock $clock,
    ) {}

    public function lancamentosVencidos(): array
    {
        $agora = $this->clock->agora();   // injetada, mockavel em teste
        return $this->repositorio->vencidosAte($agora);
    }
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

final class FinanceiroManager
{
    public function lancamentosVencidos(): array
    {
        // Dependencia escondida 1: cria repositorio internamente.
        $repositorio = new LancamentoRepositoryMysql();

        // Dependencia escondida 2: usa relogio do sistema direto.
        $agora = new DateTimeImmutable();   // teste nao consegue fixar a data

        return $repositorio->vencidosAte($agora);
    }
}
```

**Referencias:** POO-030, POO-039, POO-049

---

### POO-043 -- Sem singletons, sem estado global [ERRO]

**Regra:** Singletons (instancia unica acessada via `getInstance()`), variaveis globais e propriedades estaticas mutaveis sao proibidos como mecanismo de injecao de dependencia. Constantes e factories puras sao aceitas.

**Verifica:** `grep -rn "private static.*Self\|getInstance\|global \$" inc/` deve retornar vazio. Atributos `static` mutaveis em classes de dominio/servico sao violacao.

**Por quê:** Singleton e dependencia escondida com globalidade no topo. Tres problemas: (1) testes ficam acoplados a estado de outros testes, (2) impossivel ter duas configuracoes em paralelo, (3) refatorar exige caçar todos os `getInstance()`. No projeto, a remocao do "DbConnection::getInstance()" antigo e injecao via construtor reduziu tempo de teste em 60% e bugs intermitentes em quase tudo.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// Composition root cria UMA vez e injeta para quem precisa.
$pdo = new PDO($dsn, $user, $pass);
$repositorio = new LancamentoRepositoryMysql($pdo);
$clock = new ClockReal();
$manager = new FinanceiroManager($repositorio, $clock);

$manager->confirmarLancamento(123);
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// SINGLETON: dependencia global escondida.
final class DbConnection
{
    private static ?self $instance = null;
    public static function getInstance(): self
    {
        return self::$instance ??= new self();
    }
}

// Servico que silenciosamente depende de tudo.
final class FinanceiroManager
{
    public function confirmarLancamento(int $id): void
    {
        $pdo = DbConnection::getInstance()->pdo();   // dependencia escondida
        // ...
    }
}
```

**Referencias:** POO-042, POO-049

---

### POO-044 -- Direcao de dependencia entre camadas [ERRO]

**Regra:** Camadas dependem em uma direcao unica:
1. **Dominio** (entidades, VOs, eventos) -- nao depende de mais nada do projeto;
2. **Aplicacao** (servicos, gerenciadores, casos de uso) -- depende do dominio;
3. **Infra** (repositorios concretos, drivers, frameworks) -- depende do dominio (via interface) e da aplicacao quando preciso;
4. **Apresentacao** (handlers, controllers, templates) -- depende da aplicacao.

Camada interna nunca importa camada externa.

**Verifica:** Em code review, mapear os `use`/`namespace` por classe. `use Infra\...` em classe de `Dominio\...` e violacao instantanea. `use Apresentacao\...` em `Aplicacao\...` idem.

**Por quê:** Direcao certa de dependencia e o que faz o sistema sustentavel. O dominio (regra de negocio) e o nucleo: muda pouco e merece protecao maxima. Quando uma camada interna depende de uma externa, a regra fica refem da infra/apresentacao. No projeto, manter a direcao deixou a entidade `Lancamento` reusada em CLI, web e cron -- sem refatoracao, porque ela nao depende de quem chama.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// dominio nao importa nada
namespace Dominio\Financeiro;
class Lancamento { /* ... */ }
interface LancamentoRepository { /* ... */ }

// aplicacao importa dominio
namespace Aplicacao\Financeiro;
use Dominio\Financeiro\Lancamento;
use Dominio\Financeiro\LancamentoRepository;
final class ConfirmarLancamentoUseCase { /* ... */ }

// infra importa dominio (interface) e aplicacao (se preciso)
namespace Infra\Persistencia;
use Dominio\Financeiro\Lancamento;
use Dominio\Financeiro\LancamentoRepository;
final class LancamentoRepositoryMysql implements LancamentoRepository { /* ... */ }

// apresentacao importa aplicacao
namespace Apresentacao\Http;
use Aplicacao\Financeiro\ConfirmarLancamentoUseCase;
final class ConfirmarLancamentoHandler { /* ... */ }
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// Dominio importa infra: violacao.
namespace Dominio\Financeiro;
use Infra\Persistencia\LancamentoRepositoryMysql;   // ERRADO

class Lancamento
{
    public function persistir(): void
    {
        $repo = new LancamentoRepositoryMysql();   // ERRADO
        $repo->salvar($this);
    }
}
```

**Referencias:** POO-018, POO-039, PHP-026

---

## 9. Tratamento de erros e invariantes

> A maneira como uma classe lida com estado invalido define quanto de
> bug ela vai gerar para o resto do sistema. Falhar cedo, falhar bonito,
> com excecoes tipadas que carregam contexto.

### POO-045 -- Falhe rapido com excecoes tipadas de dominio [ERRO]

**Regra:** Quando uma operacao nao pode ser executada por uma regra de dominio violada, lance excecao tipada de dominio (`SaldoInsuficienteException`, `TransicaoInvalidaException`). Nunca retorne `null` "no silencio", nunca `false` para "falhei", nunca `\Exception` generica.

**Verifica:** `grep -rn "return null" inc/` em metodos de dominio que poderiam falhar -- candidato a violacao. `grep -rn "throw new \\\\Exception\|throw new \\\\RuntimeException\|throw new \\\\LogicException" inc/` deve retornar vazio (POO-048).

**Por quê:** `null` retornado para "deu errado" e armadilha: quem chama esquece de verificar, e o `null` se propaga ate explodir tres camadas adiante, sem contexto. Excecao tipada explode no ponto certo, com classe que carrega o motivo. O handler captura o tipo certo e responde adequadamente. No projeto, isso ja transformou bugs intermitentes em erros 100% reproduziveis com mensagem util.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

final class ContaBancaria
{
    public function sacar(int $valorCents): void
    {
        if ($valorCents <= 0) {
            throw new ValorInvalidoException($valorCents);
        }
        if (!$this->temSaldo($valorCents)) {
            throw new SaldoInsuficienteException(
                $this->id,
                $valorCents,
                $this->saldoCents
            );
        }
        $this->saldoCents -= $valorCents;
    }
}

// Handler captura o tipo certo, responde com mensagem certa.
try {
    $conta->sacar($valorCents);
} catch (SaldoInsuficienteException $e) {
    $this->responderErro('Saldo insuficiente.');
} catch (ValorInvalidoException $e) {
    $this->responderErro('Valor invalido.');
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

final class ContaBancaria
{
    // Retorna bool: o handler nao sabe se foi saldo, valor ou outra coisa.
    public function sacar(int $valorCents): bool
    {
        if ($valorCents <= 0 || !$this->temSaldo($valorCents)) {
            return false;
        }
        $this->saldoCents -= $valorCents;
        return true;
    }
}

// Handler nao consegue diferenciar.
if (!$conta->sacar($valorCents)) {
    // Foi saldo? Foi valor? Foi outra coisa? Mensagem unica e ruim.
    $this->responderErro('Operacao falhou.');
}
```

**Referencias:** POO-048, PHP-034

---

### POO-046 -- Estado invalido e impossivel de construir [ERRO]

**Regra:** Construtor (e named constructors) sao a unica forma publica de criar um objeto. Eles validam todas as invariantes. Se nao da para construir um objeto valido com os parametros recebidos, o construtor lanca excecao -- e o objeto nunca existe.

**Verifica:** Construtor que aceita "tudo" e tem validacao espalhada nos metodos e violacao. Em code review, verificar: "depois do construtor rodar com sucesso, alguma propriedade ainda pode estar invalida?". Se sim, mover validacao para o construtor.

**Por quê:** Quando o construtor garante invariante, todos os metodos confiam. Quando nao garante, todos os metodos defendem. Na primeira escolha, voce escreve a validacao uma vez; na segunda, dezenas de vezes. No projeto, a entidade `Lancamento` valida no construtor -- nenhum dos 12 metodos publicos precisa re-checar `$this->valorCents > 0`.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

final class ContaBancaria
{
    public function __construct(
        private readonly int $id,
        private readonly string $titular,
        private int $saldoCents,
        private string $status = self::STATUS_ATIVA,
    ) {
        // Invariantes garantidas no construtor:
        if ($id <= 0) {
            throw new IdInvalidoException($id);
        }
        if (trim($titular) === '') {
            throw new TitularObrigatorioException();
        }
        if ($saldoCents < 0) {
            throw new SaldoNegativoException($saldoCents);
        }
        if (!in_array($status, self::STATUS_VALIDOS, true)) {
            throw new StatusInvalidoException($status);
        }
    }

    public function sacar(int $valorCents): void
    {
        // NAO precisa revalidar id, titular, status -- o construtor garantiu.
        if (!$this->temSaldo($valorCents)) {
            throw new SaldoInsuficienteException();
        }
        $this->saldoCents -= $valorCents;
    }
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

final class ContaBancaria
{
    public function __construct(
        private int $id,
        private string $titular,
        private int $saldoCents,
        private string $status,
    ) {} // sem nenhuma validacao

    public function sacar(int $valorCents): void
    {
        // Tem que revalidar tudo em todo metodo.
        if ($this->id <= 0 || trim($this->titular) === '') {
            throw new \Exception('estado invalido');
        }
        if ($this->saldoCents < 0) {
            throw new \Exception('saldo invalido');
        }
        if (!$this->temSaldo($valorCents)) {
            throw new \Exception('saldo insuficiente');
        }
        $this->saldoCents -= $valorCents;
    }
}
```

**Referencias:** POO-012, POO-047, POO-008

---

### POO-047 -- Invariantes mantidas em todas as transicoes [ERRO]

**Regra:** Todo metodo que muda estado (POO-008) preserva as invariantes da classe. Se uma invariante nao puder ser mantida, o metodo lanca excecao e nao muda o estado. Nunca deixar a classe num "estado intermediario invalido".

**Verifica:** Em code review, simular cada metodo de mutacao com entradas de borda: "esse metodo pode deixar a classe num estado que viola a invariante?". Se sim, refatorar para checar antes ou usar transacao interna.

**Por quê:** Invariante quebrada e um cancer silencioso. A classe parece valida, mas em algum momento metodo X explode porque metodo Y a deixou invalida. No projeto, ja tivemos uma `ContaBancaria` com saldo negativo "porque o saque rodou em duas etapas e a segunda falhou". A correcao foi fazer todo metodo de mutacao validar antes e mudar tudo de uma vez (ou nada).

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

final class ContaBancaria
{
    public function transferirPara(ContaBancaria $destino, int $valorCents): void
    {
        // 1. Verificar TUDO antes de mudar qualquer coisa.
        if ($valorCents <= 0) {
            throw new ValorInvalidoException();
        }
        if (!$this->temSaldo($valorCents)) {
            throw new SaldoInsuficienteException();
        }
        if (!$destino->estaAtiva()) {
            throw new ContaDestinoInativaException();
        }

        // 2. So depois, executar. Se falhar aqui, ainda da pra rollback.
        $this->saldoCents -= $valorCents;
        $destino->saldoCents += $valorCents;
    }
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

final class ContaBancaria
{
    public function transferirPara(ContaBancaria $destino, int $valorCents): void
    {
        // ERRADO: muda primeiro, valida depois. Se a 2a falhar, fica meio.
        $this->saldoCents -= $valorCents;
        if (!$destino->estaAtiva()) {
            throw new ContaDestinoInativaException();
            // saldo ja foi tirado da origem -- agora esta perdido
        }
        $destino->saldoCents += $valorCents;
    }
}
```

**Referencias:** POO-008, POO-046

---

### POO-048 -- Excecoes de dominio carregam contexto [ERRO]

**Regra:** Excecoes de dominio sao classes proprias que herdam de `\DomainException` (ou similar) e carregam dados estruturados pelo construtor. Mensagem amigavel e propriedades acessiveis. Nunca passar so uma string.

**Verifica:** `grep -rn "throw new.*Exception(" inc/` -- excecoes lancadas com so uma string, sem contexto, sao candidatas a melhorar. Excecoes que herdam de `\Exception` direto, em vez de uma hierarquia de dominio, sao violacao.

**Por quê:** Quando a excecao chega no logger ou no handler, voce quer saber: qual usuario? qual entidade? qual valor? Sem contexto estruturado, voce so tem a mensagem ("saldo insuficiente") -- inutil para debug. Com contexto, voce tem `id da conta`, `valor solicitado`, `saldo no momento`. Tres meses depois, esse contexto resolve em segundos um bug que duraria dias.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

abstract class FinanceiroException extends \DomainException {}

final class SaldoInsuficienteException extends FinanceiroException
{
    public function __construct(
        public readonly int $contaId,
        public readonly int $valorSolicitadoCents,
        public readonly int $saldoAtualCents,
    ) {
        parent::__construct(sprintf(
            'Saldo insuficiente. Conta %d, solicitado %d centavos, saldo %d centavos.',
            $contaId,
            $valorSolicitadoCents,
            $saldoAtualCents
        ));
    }
}

// Uso:
throw new SaldoInsuficienteException(
    $this->id,
    $valorSolicitadoCents,
    $this->saldoCents
);

// Captura com contexto:
try {
    $conta->sacar($valor);
} catch (SaldoInsuficienteException $e) {
    error_log(sprintf(
        '[FINANCEIRO][ERRO] Saque negado. conta=%d, solicitado=%d, saldo=%d',
        $e->contaId,
        $e->valorSolicitadoCents,
        $e->saldoAtualCents
    ));
    throw $e;
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// Generico, sem contexto, sem hierarquia.
throw new \Exception('saldo insuficiente');

// Captura com pouco a oferecer:
try {
    $conta->sacar($valor);
} catch (\Exception $e) {
    error_log($e->getMessage());   // "saldo insuficiente" -- e dai?
}
```

**Referencias:** POO-045, PHP-034, PHP-051

---

## 10. Testabilidade e dependencias

> Toda regra deste documento aponta na mesma direcao: classe testavel.
> Se voce respeita SRP, encapsulamento, DI por construtor e DIP, os
> testes saem rapidos, isolados e estaveis. Esta secao consolida os
> compromissos de testabilidade.

### POO-049 -- Toda classe de dominio/aplicacao testavel sem infraestrutura [ERRO]

**Regra:** Entidades, value objects e servicos de aplicacao devem ser testaveis com `new ClasseSob Test()` direto, sem banco, sem rede, sem framework, sem container. Tudo que e infra entra por mock/stub na injecao.

**Verifica:** Em code review do teste: existe banco de dados rodando? `setUp` faz alguma chamada de I/O real? Se sim, ou e teste de integracao (deve estar em pasta separada) ou e violacao em teste unitario.

**Por quê:** Teste rapido = teste rodado. Quando o teste depende de banco, o ciclo "salvar -> rodar teste -> ler resultado" demora demais e o desenvolvedor para de rodar. No projeto, a suite de testes unitarios roda em segundos porque entidades e servicos nao tocam infra. Os testes de integracao (banco, HTTP, fila) ficam separados e rodam em CI dedicado.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// Entidade pura: testavel com new direto.
final class Lancamento
{
    public function __construct(
        private readonly int $id,
        private int $valorCents,
        private string $status,
    ) {}

    public function confirmar(): void { /* ... */ }
    public function valorLiquido(): int { /* ... */ }
}

// Teste unitario: zero infra.
public function testConfirmarMudaStatus(): void
{
    $lancamento = new Lancamento(1, 1000, Lancamento::STATUS_PENDENTE);
    $lancamento->confirmar();
    $this->assertTrue($lancamento->estaConfirmado());
}

// Servico testavel com mocks por interface.
public function testConfirmarLancamentoSalva(): void
{
    $repositorio = $this->createMock(LancamentoRepository::class);
    $repositorio->expects($this->once())->method('salvar');
    $manager = new FinanceiroManager($repositorio);
    $manager->confirmarLancamento(1);
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// Entidade que abre conexao de banco internamente.
final class Lancamento
{
    public function confirmar(): void
    {
        $pdo = new PDO('mysql:host=localhost', 'user', 'pass');
        $pdo->exec("UPDATE lancamentos SET status = 'confirmado' WHERE id = {$this->id}");
    }
}

// Teste exige banco rodando, schema migrado, dado inicial preparado.
public function testConfirmar(): void
{
    // ... 30 linhas de setUp para ter um banco usavel ...
    $lancamento = new Lancamento(1, 1000, 'pendente');
    $lancamento->confirmar();
    // ... 10 linhas de assertion no banco ...
}
```

**Referencias:** POO-026, POO-039, POO-042, PHP-026

---

### POO-050 -- Mocks/stubs por interface, nunca por classe concreta [AVISO]

**Regra:** Em testes, dependencias sao substituidas por implementacoes que respeitam a interface (mock/stub/spy/fake). Nunca por subclasse de uma classe concreta com `protected` enganados, nem por reflection que mexe em propriedades privadas.

**Verifica:** `grep -rn "ReflectionProperty.*setAccessible\|->setAccessible(true)" tests/` -- toque em propriedade privada via reflection no teste e violacao. Subclasse anonima de classe concreta com override de metodo protegido para "fingir" comportamento e candidato a refatoracao para interface.

**Por quê:** Mock por interface confirma que voce esta testando contra o contrato real, nao contra detalhe de implementacao. Mock por classe concreta amarra o teste a estrutura da classe -- mudou a estrutura, mock quebrou. Reflection em teste e o pior dos mundos: o teste nao corresponde a nenhum uso real, e a refatoracao destroi tudo.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// Mock pela interface: respeita o contrato.
public function testConfirmarLancamentoSalva(): void
{
    $repositorio = $this->createMock(LancamentoRepository::class);
    $repositorio->method('buscarPorId')->willReturn(
        new Lancamento(1, 1000, Lancamento::STATUS_PENDENTE)
    );
    $repositorio->expects($this->once())
        ->method('salvar')
        ->with($this->isInstanceOf(Lancamento::class));

    $manager = new FinanceiroManager($repositorio);
    $manager->confirmarLancamento(1);
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// Subclasse com override de metodo protegido para "simular".
public function testConfirmarLancamentoSalva(): void
{
    $repositorio = new class extends LancamentoRepositoryMysql {
        public function __construct() {} // pula construtor
        public function buscarPorId(int $id): ?Lancamento
        {
            return new Lancamento(1, 1000, 'pendente');
        }
    };
    // Acoplado a estrutura concreta de LancamentoRepositoryMysql.
    // Mudou a classe? O teste quebra mesmo com a interface intacta.
}
```

**Referencias:** POO-030, POO-039

---

### POO-051 -- Testes unitarios rodam em milissegundos [AVISO]

**Regra:** Cada teste unitario de classe de dominio/aplicacao roda em menos de 100ms. Suite inteira de testes unitarios deve rodar em segundos, no maximo dezenas de segundos.

**Verifica:** Configurar PHPUnit (ou equivalente) para reportar testes lentos. Qualquer teste unitario com mais de 100ms e candidato a investigacao: provavelmente toca infra ou faz setup pesado.

**Por quê:** Teste rapido e teste rodado. Quando a suite demora 5 minutos, o desenvolvedor roda uma vez por dia -- erros so aparecem em CI. Quando a suite demora 5 segundos, ela roda a cada save, e os erros saem na hora. No projeto, a suite atual roda em ~3 segundos para 200+ testes unitarios; dela depende a confianca no refactoring.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// Testes unitarios com fixtures inline e zero IO.
final class LancamentoTest extends TestCase
{
    public function testValorLiquido(): void
    {
        $l = new Lancamento(id: 1, valorCents: 1000, descontoCents: 100);
        $this->assertSame(900, $l->valorLiquido());
    }

    public function testConfirmarMudaStatus(): void
    {
        $l = new Lancamento(id: 1, valorCents: 1000, descontoCents: 0);
        $l->confirmar();
        $this->assertTrue($l->estaConfirmado());
    }
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// Setup de banco no teste unitario: lento, fragil, irreproduzivel.
final class LancamentoTest extends TestCase
{
    protected function setUp(): void
    {
        $this->pdo = new PDO('mysql:host=localhost', 'test', 'test');
        $this->pdo->exec(file_get_contents(__DIR__ . '/schema.sql'));
        $this->pdo->exec(file_get_contents(__DIR__ . '/fixtures.sql'));
        $this->repositorio = new LancamentoRepositoryMysql($this->pdo);
    }

    public function testConfirmarMudaStatus(): void
    {
        $l = $this->repositorio->buscarPorId(1);   // I/O: 80ms
        $l->confirmar();
        $this->repositorio->salvar($l);            // I/O: 80ms
        $l2 = $this->repositorio->buscarPorId(1);  // I/O: 80ms
        $this->assertTrue($l2->estaConfirmado());
        // total: ~250ms por teste, e fragil.
    }
}
```

**Referencias:** POO-049

---

### POO-052 -- Construir cenarios de teste com factories e builders [AVISO]

**Regra:** Em vez de instanciar entidades com 8 parametros em todo teste, criar factories ou builders que entregam um objeto valido por padrao e permitem customizar apenas o que importa para aquele caso. `LancamentoBuilder::valido()->comStatus('cancelado')->build()`.

**Verifica:** Em testes, `new Lancamento($a, $b, $c, $d, $e, $f, $g, $h)` repetido em varios testes e candidato a builder. Quando o teste mostra muitos parametros e voce so quer destacar 1 ou 2, builder ajuda.

**Por quê:** Builder no teste: o sinal/ruido melhora drasticamente. O leitor ve em uma linha o que importa (o que muda em relacao ao "valido padrao"), nao 8 parametros sem destaque. Tambem isola o teste de mudancas no construtor: se a entidade ganha um parametro novo, atualiza-se o builder em um lugar so, e nao em 50 testes.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

final class LancamentoBuilder
{
    private int $id = 1;
    private int $valorCents = 1000;
    private int $descontoCents = 0;
    private string $status = Lancamento::STATUS_PENDENTE;
    private DateTimeImmutable $criadoEm;

    public function __construct()
    {
        $this->criadoEm = new DateTimeImmutable('2026-01-01');
    }

    public function comStatus(string $status): self
    {
        $b = clone $this;
        $b->status = $status;
        return $b;
    }

    public function comValor(int $cents): self
    {
        $b = clone $this;
        $b->valorCents = $cents;
        return $b;
    }

    public function build(): Lancamento
    {
        return new Lancamento(
            $this->id,
            $this->valorCents,
            $this->descontoCents,
            $this->status,
            $this->criadoEm,
        );
    }
}

// Teste expressivo: ve-se o que importa.
public function testCancelarRejeitaConfirmado(): void
{
    $lancamento = (new LancamentoBuilder())
        ->comStatus(Lancamento::STATUS_CONFIRMADO)
        ->build();

    $this->expectException(TransicaoInvalidaException::class);
    $lancamento->cancelar();
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// Repete construtor inteiro em todo teste; 8 parametros, ninguem
// sabe qual e qual relevante para este teste.
public function testCancelarRejeitaConfirmado(): void
{
    $lancamento = new Lancamento(
        1,                                  // id
        1000,                               // valorCents
        0,                                  // descontoCents
        Lancamento::STATUS_CONFIRMADO,      // status (o que importa aqui)
        new DateTimeImmutable('2026-01-01'),// criadoEm
        null,                               // descricao
        [],                                 // tags
        100,                                // userId
    );

    $this->expectException(TransicaoInvalidaException::class);
    $lancamento->cancelar();
}
```

**Referencias:** POO-049, POO-051

---

## 11. Boas praticas adicionais (BP do livro)

> Esta secao consolida as boas praticas do Capitulo 9 do livro do
> Thiago Leite e Carvalho (BP01 a BP15). As BPs que ja foram cobertas
> em secoes anteriores aparecem como referencias cruzadas; as que
> faltavam viram regras proprias aqui.
>
> Mapa explicito BP -> regra deste documento:
>
> - BP01 (coesao e acoplamento) -> POO-040, POO-041
> - BP02 (strings com parcimonia) -> POO-053 (e POO-014, POO-015)
> - BP03 (seja objetivo, nao tente prever o futuro) -> POO-054
> - BP04 (crie metodos com carinho) -> POO-013, PHP-030, PHP-031, PHP-032
> - BP05 (conheca e use colecoes) -> POO-055
> - BP06 (sobrescreva equals/hashCode/toString) -> POO-056
> - BP07 (associar em vez de herdar) -> POO-020, POO-057
> - BP08 (evite heranca/sobrescrita) -> POO-022, POO-058
> - BP09 (encapsulamento) -> POO-006 a POO-012
> - BP10 (interface vs classe abstrata) -> POO-031, POO-034
> - BP11 (nao especialize o ja especializado) -> POO-059
> - BP12 (estaticos com parcimonia) -> POO-060
> - BP13 (clonagem) -> POO-061
> - BP14 (facilidades da linguagem) -> POO-062
> - BP15 (convencoes de codificacao) -> padroes-php.md inteiro (PSR-12)

### POO-053 -- Strings sao para texto livre, nada mais (BP02 do livro) [ERRO]

**Regra:** `string` em PHP e o tipo certo apenas para texto livre genuino: descricoes, comentarios, observacoes, mensagens. Para qualquer dado com forma definida (data, hora, CPF, CNPJ, CEP, e-mail, telefone, dinheiro, status fixo, sexo, UF, moeda), usar o tipo apropriado: `DateTimeImmutable`, Value Object, ou `enum`. Mesmo que o framework receba string da request (POO-020 -- validacao na fronteira), a entidade nunca aceita string crua para esses conceitos.

**Verifica:** `grep -rn "string \$cpf\|string \$cep\|string \$email\|string \$telefone\|string \$data\|string \$status\|string \$sexo\|string \$uf\|string \$moeda" inc/entidades/` -- match e candidato a violacao. Inspecionar tambem assinaturas de servicos: parametros `string $algo` que carregam regra de dominio sao violacao.

**Por quê:** Thiago Leite e direto: `string` aceita qualquer coisa. "Brasil", "BRASIL", "BR", "br ", "Brazil" sao todos validos para uma `string $pais` -- e cinco bugs em potencial. `Pais::BR` (enum) so aceita um valor por estado. `DateTimeImmutable` ja sabe somar dias, calcular diferencas, formatar. `Cpf` ja valida o digito verificador no construtor. Cada vez que voce escolhe `string`, voce paga depois -- em validacao espalhada, em bugs de comparacao, em queries ineficientes.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

enum Sexo: string
{
    case Feminino = 'F';
    case Masculino = 'M';
    case NaoInformado = 'N';
}

enum Uf: string
{
    case AC = 'AC';
    case AL = 'AL';
    case AM = 'AM';
    // ... 27 casos
}

final class Cpf
{
    public function __construct(public readonly string $valor)
    {
        if (!preg_match('/^\d{11}$/', $valor) || !self::digitoOk($valor)) {
            throw new CpfInvalidoException($valor);
        }
    }
    private static function digitoOk(string $cpf): bool { /* ... */ return true; }
}

final class Endereco
{
    public function __construct(
        public readonly string $logradouro,
        public readonly string $numero,
        public readonly string $bairro,
        public readonly string $cidade,
        public readonly Uf $uf,
        public readonly string $cep,
    ) {}
}

class Colaborador
{
    public function __construct(
        private readonly Cpf $cpf,
        private readonly DateTimeImmutable $dataNascimento,
        private readonly Sexo $sexo,
        private readonly Endereco $endereco,
        private string $nome,
    ) {}

    public function idade(): int
    {
        return $this->dataNascimento->diff(new DateTimeImmutable())->y;
    }
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// O exato anti-padrao apresentado em BP02 do livro: tudo string.
class Colaborador
{
    public function __construct(
        private string $nome,
        private string $cpf,                    // sem validacao
        private string $dataNascimento,         // "01/01/1990"? "1990-01-01"?
        private string $sexo,                   // "M"? "Masculino"? "masculino"?
        private string $endereco,               // "Rua X, 100, Bairro Y, Cidade-UF, CEP" -- agora extrai a cidade
    ) {}

    public function idade(): int
    {
        // tortura: parse manual, fuso horario, fim de mes...
        $partes = explode('/', $this->dataNascimento);
        // ...
    }
}
```

**Referencias:** POO-014, POO-015, POO-016, BP02 do livro

---

### POO-054 -- KISS: seja objetivo, nao tente prever o futuro (BP03 do livro) [ERRO]

**Regra:** Modelar o que o sistema *precisa hoje*. Hierarquias preventivas, classes "genericas" pensadas para um possivel uso futuro, abstracoes "para o caso de", interfaces sem implementacao concreta -- tudo isso e violacao. Quando a necessidade real surgir, refatorar e mais barato do que carregar abstracao morta.

**Verifica:** Em code review, perguntar para cada `abstract class` ou `interface`: "qual e a segunda implementacao concreta? existe ou e hipotetica?". Se hipotetica, simplificar. Para hierarquia de heranca: "alem da subclasse atual, ha outra ja usada?". Se nao, virar classe simples.

**Por quê:** Thiago Leite e enfatico (citando KISS, "Keep It Simple, Stupid"): "Quando sao criadas classes genericas demais, torna-se muito dificil entende-las. Elas podem ficar sem sentido algum, mas, mesmo assim, estarao presentes em todo lugar. Alem disso, um acoplamento muito alto sera criado". O livro da o exemplo perfeito: se o sistema so vende para pessoa fisica hoje, nao crie `Pessoa` abstrata + `PessoaFisica` -- apenas `PessoaFisica`. Quando aparecer pessoa juridica, refatore. Refatoracao guiada por necessidade real bate codigo "flexivel" especulativo todas as vezes.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// O sistema hoje so trata PessoaFisica. Modelagem direta:
final class PessoaFisica
{
    public function __construct(
        private readonly Cpf $cpf,
        private readonly string $nome,
    ) {}
}

// Quando (e SE) aparecer PessoaJuridica, refatoramos para:
//   abstract class Pessoa { ... }
//   final class PessoaFisica extends Pessoa { ... }
//   final class PessoaJuridica extends Pessoa { ... }
//
// Ate la, nao temos abstracao morta no codigo.
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// "Vou ja deixar abstrato porque um dia pode ter pessoa juridica."
abstract class Pessoa { /* ... */ }

final class PessoaFisica extends Pessoa
{
    private readonly Cpf $cpf;
}

// (PessoaJuridica nao existe e nunca existira no escopo atual.)

// Resultado: 2 classes em vez de 1. Acoplamento entre elas.
// Ninguem sabe quais membros pertencem a Pessoa generica e quais sao
// especificos. Manutencao paga juros sobre essa "previsao".
```

**Referencias:** POO-019, POO-021, POO-022, BP03 do livro

---

### POO-055 -- Conheca e use a colecao certa (BP05 do livro) [AVISO]

**Regra:** Para cada situacao, escolher a estrutura de colecao apropriada e usa-la com seus metodos nativos:
- **Lista** (`array` indexado) quando a ordem importa e duplicatas sao validas;
- **Mapa** (`array` associativo) quando ha chave -> valor e acesso rapido por chave;
- **Conjunto** (Value Object/array com unicidade verificada) quando duplicatas sao proibidas;
- **Iterador**/`Generator` quando a colecao e grande e nao precisa caber inteira em memoria.

Operacoes em colecoes usam funcoes nativas (`array_map`, `array_filter`, `array_reduce`, `array_unique`, `array_key_exists`, `in_array(..., true)`) em vez de loops manuais reinventando a roda.

**Verifica:** Em code review, todo `for ($i = 0; ...; $i++)` que percorre array e candidato a `foreach`/`array_map`. Loop que filtra com `if` interno e candidato a `array_filter`. Loop que acumula soma e candidato a `array_sum`/`array_reduce`.

**Por quê:** O livro alerta para o caso do "vetor de tamanho fixo" -- problema de Java/C# que em PHP nao temos. Mas o ponto continua: usar a estrutura errada gera codigo verboso e bugs. Em PHP, `in_array($x, $a)` (sem `true`) compara com `==`, e silenciosamente mistura tipos -- bug pronto. `in_array($x, $a, true)` e a forma correta. `array_unique` e `array_intersect_key` substituem 30 linhas de logica manual.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// Mapa: acesso O(1) por chave.
$lancamentosPorId = [];
foreach ($lancamentos as $lancamento) {
    $lancamentosPorId[$lancamento->id()] = $lancamento;
}

// Filtro funcional: claro, idiomatico, testavel.
$confirmados = array_filter(
    $lancamentos,
    fn(Lancamento $l) => $l->estaConfirmado()
);

// Reducao: somar valores.
$total = array_reduce(
    $confirmados,
    fn(int $acc, Lancamento $l) => $acc + $l->valorLiquido(),
    0
);

// Unicidade com comparacao estrita.
if (in_array($status, self::STATUS_VALIDOS, true)) {
    // ...
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// Loop manual reinventando array_filter + array_reduce.
$total = 0;
for ($i = 0; $i < count($lancamentos); $i++) {
    if ($lancamentos[$i]->getStatus() === 'confirmado') {
        $total = $total + $lancamentos[$i]->getValor() - $lancamentos[$i]->getDesconto();
    }
}

// in_array sem strict: "1" == 1 == true -- bug silencioso.
if (in_array($status, self::STATUS_VALIDOS)) {
    // ...
}
```

**Referencias:** POO-005, BP05 do livro

---

### POO-056 -- Identidade e igualdade implementadas explicitamente (BP06 do livro) [ERRO]

**Regra:** Toda entidade (POO-004) expoe um metodo `id(): int` (ou `uuid()`) e um metodo `ehMesmo(self $outro): bool` que compara por identidade. Todo Value Object (POO-014) expoe um metodo `igualA(self $outro): bool` que compara por valor de TODOS os campos. Para uso em colecoes ou cache que dependem de hash, expor tambem um metodo `chave(): string` deterministico.

**Verifica:** Em code review, toda entidade deve ter `id()` e `ehMesmo()`. Todo Value Object deve ter `igualA()`. Comparacao de objetos por `==` ou `===` em codigo de aplicacao e violacao -- usar os metodos.

**Por quê:** Thiago Leite dedica BP06 inteira a este ponto -- e adverte que nao implementar `equals`/`hashCode` (em Java/C#) faz colecoes (List, Set, Map) se comportarem de forma imprevista. Em PHP, o problema e equivalente: `array_search`, `in_array`, `array_unique` precisam saber como comparar objetos. Sem metodo explicito, comparacoes acontecem por identidade de instancia (referencia), nao por valor de dominio. Buscar "este CPF ja existe na lista" sem `igualA()` retorna `false` mesmo quando o CPF esta la -- porque sao instancias diferentes.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// ENTIDADE: identidade por id.
class Lancamento
{
    public function id(): int { return $this->id; }

    public function ehMesmo(Lancamento $outro): bool
    {
        return $this->id === $outro->id;
    }
}

// VALUE OBJECT: igualdade por valor de TODOS os campos.
final class Cep
{
    public function __construct(public readonly string $valor) {}

    public function igualA(Cep $outro): bool
    {
        return $this->valor === $outro->valor;
    }
}

final class Money
{
    public function __construct(
        public readonly int $cents,
        public readonly string $moeda = 'BRL',
    ) {}

    public function igualA(Money $outro): bool
    {
        return $this->cents === $outro->cents
            && $this->moeda === $outro->moeda;
    }

    // Chave deterministica para usar em arrays associativos.
    public function chave(): string
    {
        return sprintf('%s:%d', $this->moeda, $this->cents);
    }
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// Sem metodos de comparacao explicita.
class Cep
{
    public function __construct(public readonly string $valor) {}
}

// Resultado: o desenvolvedor compara assim, e da errado:
$ceps = [new Cep('01234-567'), new Cep('98765-432')];
$buscado = new Cep('01234-567');
in_array($buscado, $ceps);          // false! sao instancias diferentes
in_array($buscado, $ceps, true);    // false! sao instancias diferentes
```

**Referencias:** POO-004, POO-014, BP06 do livro

---

### POO-057 -- Nao estenda colecoes nem classes utilitarias da linguagem (BP07 do livro) [ERRO]

**Regra:** Classes do nucleo da linguagem (`ArrayObject`, `ArrayIterator`, `SplDoublyLinkedList`, `\PDO`, `\DateTime`) nao sao superclasses de entidades de dominio. Para reusar capacidades dessas classes, **compor** (atributo do tipo desejado), nunca **herdar**.

**Verifica:** `grep -rn "class.*extends \(ArrayObject\|ArrayIterator\|SplDoublyLinkedList\|\\\\DateTime\|\\\\PDO\)" inc/` -- match e violacao instantanea.

**Por quê:** O livro usa o exemplo classico de `CarrinhoCompras extends ArrayList` (Java). E ruim por tres motivos: (1) **quebra semantica** -- carrinho nao **e** uma lista; carrinho **tem** uma lista; (2) **quebra encapsulamento** -- expoe toda a API de `ArrayList` para o mundo; (3) **forte acoplamento** -- mudou a API da colecao base, seu carrinho quebra. Em PHP, o equivalente seria estender `ArrayObject` para representar um agregado de dominio. O resultado e o mesmo: voce expos detalhes internos que nao sao seus.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// CarrinhoCompras TEM uma lista de produtos. Nao E uma lista.
final class CarrinhoCompras
{
    /** @var Produto[] */
    private array $produtos = [];

    public function adicionar(Produto $produto): void
    {
        $this->produtos[] = $produto;
    }

    public function remover(Produto $produto): void
    {
        $this->produtos = array_filter(
            $this->produtos,
            fn(Produto $p) => !$p->ehMesmo($produto)
        );
    }

    public function quantidade(): int
    {
        return count($this->produtos);
    }

    public function total(): Money
    {
        $cents = array_reduce(
            $this->produtos,
            fn(int $acc, Produto $p) => $acc + $p->precoCents(),
            0
        );
        return new Money($cents);
    }
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// HERANCA SEM RELACAO "E-UM": carrinho nao e ArrayObject.
// Toda a API de ArrayObject (offsetSet, offsetExists, count, getIterator,
// asort, natsort, append, exchangeArray, ...) virou parte da API publica
// do carrinho -- incluindo metodos que nao fazem sentido.
class CarrinhoCompras extends \ArrayObject
{
    public function total(): Money
    {
        // ...
    }
}

// Cliente pode fazer o que nao deveria poder:
$carrinho = new CarrinhoCompras();
$carrinho->offsetSet('produto-secreto', $algumaCoisa);  // bypass do adicionar()
$carrinho->exchangeArray([]);                           // esvazia tudo
```

**Referencias:** POO-019, POO-020, BP07 do livro

---

### POO-058 -- Bloqueie heranca de classes finalizadas (BP08 do livro) [AVISO]

**Regra:** Quando uma classe representa um conceito completo do dominio que nao tem subtipos previstos, marque-a `final` (POO-022). Quando metodos especificos nao devem ser sobrescritos por subclasses (porque alterar seu comportamento quebraria invariantes), marcar **o metodo** como `final`.

**Verifica:** Em code review, classes que representam conceitos terminais (CPF, Email, Money, e a maioria dos VOs) precisam ser `final`. Metodos publicos que aplicam invariante critica em uma hierarquia (`confirmar()` numa abstract `Operacao` que tem 5 subclasses) devem ser `final`.

**Por quê:** O livro usa `String` (em Java) como exemplo: `String` e `final` justamente porque trocar o comportamento de manipulacao de texto introduziria bugs em todo lugar. A mesma logica vale para classes-conceito do nosso dominio: se voce permite extensao "porque pode", alguem vai estender e mudar invariantes que voce nem sabia que dependiam de imutabilidade. `final` (em classe ou metodo) e um contrato com seu eu-do-futuro.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// Value Object terminal.
final class Cpf
{
    public function __construct(public readonly string $valor) { /* ... */ }
}

// Hierarquia onde alguns metodos nao devem ser sobrescritos.
abstract class Operacao
{
    // Subclasses customizam isso.
    abstract protected function executar(): void;

    // O fluxo de auditoria nao pode ser sobrescrito -- se alguem
    // sobrescrever, o sistema deixa de auditar e os reguladores caem.
    final public function executarComAuditoria(): void
    {
        $this->auditoria->registrarInicio($this);
        $this->executar();
        $this->auditoria->registrarFim($this);
    }
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// Sem final, alguem extende em outro modulo daqui a 6 meses.
class Cpf
{
    public function __construct(public string $valor) {}  // sem readonly tambem
}

class CpfQueIgnoraValidacao extends Cpf
{
    // Subclasse pode burlar a regra. Cpf invalido em producao.
    public function __construct(string $valor) { $this->valor = $valor; }
}

// Idem para metodos: a auditoria sumiu da subclasse.
abstract class Operacao
{
    public function executarComAuditoria(): void { /* ... */ }
}

class OperacaoSemAuditoria extends Operacao
{
    public function executarComAuditoria(): void
    {
        $this->executar();   // pula a auditoria
    }
}
```

**Referencias:** POO-022, POO-027, POO-028, BP08 do livro

---

### POO-059 -- Nao especialize o ja especializado (BP11 do livro) [ERRO]

**Regra:** Classe concreta nao deve ser superclasse de outra classe concreta. Quando voce sente vontade de fazer `B extends A` e ambas sao concretas, refatorar: extraia uma `abstract A_Base` no topo da hierarquia, e que `A` e `B` herdem dela.

**Verifica:** `grep -rn "^class .* extends [A-Z]" inc/ | grep -v "abstract\|extends Exception"` para mapear cadeias de heranca; cada match onde a superclasse e concreta e candidato a violacao.

**Por quê:** Thiago Leite dedica BP11 inteira a este ponto. Tres consequencias graves: (1) **quebra semantica** -- a classe concreta ja era "a forma mais especifica do conceito"; criar subtipo dela sobrepoe responsabilidades; (2) **quebra encapsulamento** -- subclasse passa a ter acesso a metodos publicos que nao deveriam ser sobrescritos; (3) **resultado inesperado** -- o usuario do supertipo recebe a subclasse e o comportamento e diferente do contratado. O exemplo do livro -- `ResidenteAnestesista extends Anestesista` -- mostra que residente nao **e** anestesista pleno; e um subtipo que nao pode fazer tudo que o anestesista faz, mas heranca de classe concreta diz que pode.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// Hierarquia com base abstrata. Ambas as concretas sao "irmas".
abstract class Anestesia
{
    abstract public function podeAplicar(Paciente $p): bool;
    abstract public function aplicar(Paciente $p): void;
}

final class Anestesista extends Anestesia
{
    public function podeAplicar(Paciente $p): bool
    {
        return true;   // habilitado pleno
    }
    public function aplicar(Paciente $p): void { /* ... */ }
}

final class ResidenteAnestesista extends Anestesia
{
    public function podeAplicar(Paciente $p): bool
    {
        // Residente nao pode em casos complexos.
        return $p->casoEhSimples();
    }
    public function aplicar(Paciente $p): void { /* ... */ }
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// Anestesista e concreta. ResidenteAnestesista herda dela --
// e agora "e um anestesista pleno", o que viola a realidade
// hospitalar e abre brecha para residente operar caso complexo.
class Anestesista
{
    public function podeAplicar(Paciente $p): bool { return true; }
    public function aplicar(Paciente $p): void { /* ... */ }
}

class ResidenteAnestesista extends Anestesista
{
    // Sobrescrita parcial: pode "esquecer" um metodo critico,
    // e por heranca, ele continua chamavel da forma da super.
    public function podeAplicar(Paciente $p): bool
    {
        return $p->casoEhSimples();
    }
    // aplicar() nao foi sobrescrito -- usa a versao da super,
    // que nao impoe a restricao de "caso simples".
}
```

**Referencias:** POO-019, POO-021, POO-022, POO-023, BP11 do livro

---

### POO-060 -- Membros estaticos com parcimonia (BP12 do livro) [ERRO]

**Regra:** Atributos estaticos sao proibidos em classes de dominio (entidades, VOs, agregados). Sao aceitos apenas como **constantes** (`public const`, `private const`, `enum`). Metodos estaticos sao proibidos em logica de negocio. Sao aceitos em classes utilitarias puras (sem estado, sem efeito colateral) e em **named constructors** (`Cpf::de('...')`, `Money::brl(int $cents)`).

**Verifica:** `grep -rn "private static \$\|protected static \$\|public static \$" inc/entidades/ inc/dominio/` -- atributo estatico mutavel em dominio e violacao. `grep -rn "public static function" inc/entidades/` exceto para named constructors e violacao.

**Por quê:** O livro detalha BP12 com o exemplo do `Cliente` com `static $produtos`: `Fulano` e `Beltrano` adicionam um produto cada e ambos veem 2 -- porque a lista e da classe, nao do objeto. Os metodos estaticos somam outros problemas: nao tem polimorfismo (POO-025), nao tem sobrescrita (POO-027), nao acessam estado de instancia (quebram encapsulamento), e ainda criam acoplamento global escondido (POO-043). Em dominio, isso e inaceitavel; em utilitarias, e aceitavel.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// CONSTANTES estaticas (imutaveis): OK.
class Lancamento
{
    public const STATUS_PENDENTE = 'pendente';
    public const STATUS_CONFIRMADO = 'confirmado';
    public const STATUS_CANCELADO = 'cancelado';

    public const STATUS_VALIDOS = [
        self::STATUS_PENDENTE,
        self::STATUS_CONFIRMADO,
        self::STATUS_CANCELADO,
    ];
}

// NAMED CONSTRUCTOR estatico: OK -- so cria objeto, sem estado.
final class Money
{
    public function __construct(
        public readonly int $cents,
        public readonly string $moeda,
    ) {}

    public static function brl(int $cents): self
    {
        return new self($cents, 'BRL');
    }

    public static function zero(string $moeda = 'BRL'): self
    {
        return new self(0, $moeda);
    }
}

// CLASSE UTILITARIA pura: OK. Sem estado, sem efeito colateral.
final class Hash
{
    public static function sha256(string $valor): string
    {
        return hash('sha256', $valor);
    }
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// Atributo estatico mutavel em dominio: o caso classico do livro.
class Cliente
{
    private string $nome;
    /** @var Produto[] */
    private static array $produtos = [];   // ERRADO: compartilhado por TODOS

    public function adicionarProduto(Produto $p): void
    {
        self::$produtos[] = $p;
    }

    public function quantidadeProdutos(): int
    {
        return count(self::$produtos);
    }
}

$fulano = new Cliente();
$fulano->adicionarProduto($p1);
$beltrano = new Cliente();
$beltrano->adicionarProduto($p2);
$fulano->quantidadeProdutos();    // retorna 2 -- bug, era pra ser 1

// Metodo estatico de regra de negocio: sem polimorfismo, sem sobrescrita.
class FinanceiroService
{
    public static function calcularJurosCompostos(int $cents, int $meses): int
    {
        // ...
    }
}
// Como mockar isso em teste? Nao da. Como variar por contexto? Nao da.
```

**Referencias:** POO-007, POO-029, POO-042, POO-043, BP12 do livro

---

### POO-061 -- Copia defensiva: clonagem profunda quando expor mutavel (BP13 do livro) [AVISO]

**Regra:** Quando um metodo retorna um objeto mutavel ou colecao mutavel que pertence ao estado interno da classe, ele retorna uma **copia profunda**, nao a referencia original. Quando um metodo recebe um objeto mutavel como parametro e armazena, ele armazena uma **copia profunda**, nao a referencia. Excecao: o tipo retornado/recebido e imutavel (POO-007).

**Verifica:** Em code review de getters que retornam objeto/array: o valor e imutavel? Se nao, deve haver clonagem. Em code review de setters/construtores que aceitam objeto/array mutavel: ha `clone` ou copia explicita?

**Por quê:** O livro usa BP13 inteira para explicar shallow vs deep copy. O ponto pratico: quando o cliente recebe a referencia interna, ele pode mexer no estado interno da classe pelas costas. Voce expos um getter inocente, e na verdade abriu o estado privado. Em PHP, `clone` e cooperativo -- voce precisa implementar `__clone()` corretamente para fazer deep copy de propriedades que sao objetos. Em VO `readonly`, isso nao e problema (POO-007); fora dai, e problema sempre.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

class Pedido
{
    /** @var Produto[] */
    private array $produtos = [];

    public function __construct(private DateTimeInterface $criadoEm) {}

    // Recebe e ARMAZENA copia (DateTime e mutavel).
    public function reagendar(DateTimeInterface $novaData): void
    {
        $this->criadoEm = clone $novaData;
    }

    // Retorna copia profunda da lista.
    public function produtos(): array
    {
        return array_map(fn(Produto $p) => clone $p, $this->produtos);
    }

    public function __clone(): void
    {
        // Deep clone das propriedades que sao objetos mutaveis.
        $this->criadoEm = clone $this->criadoEm;
        $this->produtos = array_map(fn(Produto $p) => clone $p, $this->produtos);
    }
}

// MELHOR AINDA: usar tipos imutaveis. Sem clone, sem dor.
class PedidoImutavel
{
    /** @var Produto[] */
    private array $produtos = [];

    // DateTimeImmutable nao precisa de clone.
    public function __construct(private DateTimeImmutable $criadoEm) {}
}
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

class Pedido
{
    /** @var Produto[] */
    private array $produtos = [];

    public function __construct(private DateTime $criadoEm) {}

    public function produtos(): array
    {
        return $this->produtos;   // referencia DIRETA da lista interna
    }
}

$p = new Pedido(new DateTime());
$lista = $p->produtos();
$lista[] = new Produto('item-injetado');   // alterou o estado interno!

// Idem para data:
$p->criadoEm()->modify('+10 years');       // alterou o pedido pelas costas
```

**Referencias:** POO-007, POO-013, BP13 do livro

---

### POO-062 -- Use as facilidades idiomaticas da linguagem (BP14 e BP15 do livro) [AVISO]

**Regra:** Para problemas resolvidos pela biblioteca padrao da linguagem ou pelo ecossistema, usar a solucao da linguagem. Em PHP especificamente:
- **Concatenacao em loop** -> usar `sprintf` ou `implode([...])` ou buffer; nao `.=` em loop grande.
- **Aritmetica monetaria** -> trabalhar em centavos `int` ou usar `bcmath`; nunca `float` para dinheiro.
- **Iteracao** -> `foreach` em vez de `for ($i = 0; $i < count(...); $i++)`.
- **Datas** -> `DateTimeImmutable` em vez de timestamps inteiros ou strings.
- **Filtragem/mapeamento** -> `array_filter`, `array_map`, `array_reduce`.
- **Interpolacao** -> double-quoted strings ou heredoc, nao concatenacao manual.
- **Convencoes** -> seguir PSR-1, PSR-4, PSR-12 e regras de `padroes-php.md`.

**Verifica:** Em code review, padroes anti-idiomaticos: `for` numerico em array, `$total = $a + $b;` para dinheiro com `float`, `.=` em loop, `mktime()` em vez de `DateTimeImmutable`, manipulacao manual de string em vez de `sprintf`.

**Por quê:** Thiago Leite cobre BP14 (facilidades) e BP15 (convencoes) como duas faces da mesma moeda: a linguagem ja resolveu varios problemas, e ignorar isso e criar mais codigo, mais bug e mais texto para revisar. Em PHP, o caso mais grave e dinheiro em `float`: `0.1 + 0.2 !== 0.3` -- exatamente o exemplo do livro. Em sistemas financeiros (e o Taito tem Brio, que vale custo de produto), errar isso e prejuizo real.

**Exemplo correto:**
```php
<?php
declare(strict_types=1);

// Aritmetica monetaria em centavos (int).
$totalCents = $valorCents + $impostoCents;

// Datas via DateTimeImmutable.
$proximoMes = (new DateTimeImmutable('2026-05-08'))->modify('+1 month');

// Iteracao idiomatica.
foreach ($lancamentos as $lancamento) {
    $lancamento->confirmar();
}

// String construida com sprintf -- legivel, sem concatenacao.
$msg = sprintf(
    'Sr. %s, sua reclamacao foi recebida. Prazo: %d dias.',
    $usuario->nome(),
    $reclamacao->prazoDias()
);

// Filtragem funcional.
$confirmados = array_filter(
    $lancamentos,
    fn(Lancamento $l) => $l->estaConfirmado()
);
```

**Exemplo incorreto:**
```php
<?php
declare(strict_types=1);

// Float para dinheiro: precisao se perde.
$total = 0.1 + 0.2;
if ($total === 0.3) { /* nunca cai aqui */ }

// for numerico em array.
for ($i = 0; $i < count($lancamentos); $i++) {
    $lancamentos[$i]->confirmar();
}

// Concatenacao em loop, datas como string.
$msg = 'Sr. ' . $usuario->getNome() . ', sua reclamacao foi recebida em ' . date('d/m/Y') . '. Prazo: ' . $reclamacao->getPrazoDias() . ' dias.';

// Strings para datas.
$dataNovaStr = $dataAntigaStr; // "01/01/2026"... agora soma 30 dias na string
```

**Referencias:** PHP-014 ate PHP-048, POO-053, BP14 do livro, BP15 do livro

---

## Glossario OO

**Classe.** Modelo (template) que descreve um conceito: que estado tem, que comportamento expoe, que invariantes preserva.

**Objeto.** Instancia de uma classe -- um conceito materializado, com seu proprio estado e identidade.

**Identidade.** O que diferencia um objeto de outro mesmo quando os campos sao iguais. Em entidades, e o `$id`/`$uuid`. Value Objects nao tem identidade.

**Estado.** O conjunto dos valores dos atributos de um objeto em um momento. Pode ser mutavel (entidades) ou imutavel (Value Objects).

**Comportamento.** O conjunto dos metodos que um objeto expoe -- o que ele sabe fazer e o que ele responde.

**Invariante.** Verdade que vale para todo objeto da classe, em todo momento da sua existencia. "Saldo nunca e negativo" e invariante de `ContaBancaria`.

**Encapsulamento.** Esconder o como, expor so o porque/o que. Atributos privados, metodos publicos com nomes de dominio.

**Abstracao.** Mostrar so o que importa para quem usa, esconder o resto. Boa abstracao tem nome de dominio e API minima.

**Heranca.** Mecanismo para modelar relacao "e-um". Subclasse e versao especifica da superclasse.

**Polimorfismo.** Mesma mensagem, varios objetos respondem de jeitos diferentes. Faz cadeias if/switch sumirem.

**Composicao.** Um objeto TEM outro como colaborador. Mais flexivel que heranca; preferivel quando a relacao nao e "e-um".

**Coesao.** O quao "do mesmo tema" sao os elementos de uma classe. Alta coesao = tudo gira em torno do mesmo conceito.

**Acoplamento.** O quao uma classe depende de outras. Baixo acoplamento = classe troca pouca informacao com poucos vizinhos.

**SOLID.**
- *S*ingle Responsibility (POO-035)
- *O*pen/Closed (POO-036)
- *L*iskov Substitution (POO-023, POO-037)
- *I*nterface Segregation (POO-032, POO-038)
- *D*ependency Inversion (POO-039)

**Lei de Demeter.** "Fale apenas com seus amigos imediatos." Maximo um nivel de cadeia (POO-011).

**Tell, Don't Ask.** Mande o objeto fazer, nao pergunte para decidir externamente (POO-010).

**KISS.** Keep It Simple, Stupid. Solucao mais simples que resolve. Nao adicione abstracao sem necessidade.

**YAGNI.** You Aren't Gonna Need It. Nao implemente o que nao e exigido pelo caso real.

**DRY.** Don't Repeat Yourself. Uma regra, um lugar (PHP-002, POO-035).

**Value Object.** Classe imutavel sem identidade, igualdade por valor (POO-014).

**Entidade.** Classe com identidade, estado mutavel atraves de lifecycle methods, invariantes mantidas em transicoes (POO-017).

**Repository.** Abstracao que persiste entidades. Interface no dominio, implementacao na infra (POO-039, POO-044).

**Service / Manager / Use Case.** Classe que orquestra entidades para realizar uma operacao do dominio. Sem logica de regra de negocio que pertenca a entidade (POO-017).

**Strategy.** Algoritmo encapsulado em classe, injetado por composicao (POO-029).

**Template Method.** Algoritmo fixo na superclasse com hooks abstratos para subclasses (POO-034).

**Composition Root.** Ponto unico onde objetos sao criados e ligados; geralmente o `bootstrap` ou o container (POO-042, POO-043).

**Gap semantico (Cap. 3.4 do livro).** Distancia entre como o especialista de dominio descreve o problema e como o codigo o representa. OO existe para reduzir esse gap. Codigo de dominio em ingles enquanto produto fala portugues, primitivos em vez de VOs, logica de regra em servicos -- tudo aumenta o gap (Secao 0).

**Pilar (do livro).** Os tres pilares da OO segundo Thiago Leite: **abstracao** (esconder o acidental), **reuso** (evitar repeticao via heranca ou associacao) e **encapsulamento** (esconder implementacao e estado interno). Heranca, polimorfismo e associacao sao mecanismos, nao pilares.

**Gap-killing.** Termo que usamos quando uma alteracao reduz o gap semantico -- por exemplo, trocar `string $cpf` por `Cpf $cpf`, ou trocar `bool $aprovado` por uma maquina de estados. Toda PR tem como meta secundaria fazer gap-killing.

**Interface gorda (Fat Interface).** Termo do livro (BP10 e Apendice IV.4): interface ou classe abstrata com muitos metodos sem coesao, forcando implementadores a stub-ar. Curado por ISP (POO-032, POO-038).

**Vazamento de interface.** Quando uma classe implementa metodos da interface que nao precisa, "vazando" responsabilidade para um lugar errado. Mesmo que ISP (POO-032).

**Classe curinga.** Termo do livro (BP10): classe com mais de uma responsabilidade -- mistura conceitos. Anti-padrao curado por SRP (POO-035) e por refatoracao para hierarquia abstrata.

**Modelo anemico.** Termo do livro (Capitulo 8 e BP09): classes so com getters e setters, sem comportamento. O oposto de entidade rica (POO-017).

**BP01-BP15.** Numeracao do Capitulo 9 do livro. Cada uma mapeia para regras deste documento (ver inicio da Secao 11).

---

## Cross-references com outros documentos

| Tema OO | padroes-poo | padroes-php | padroes-seguranca |
|---------|-------------|-------------|-------------------|
| Tipos e contratos | POO-004, POO-014, POO-015, POO-053 | PHP-014, PHP-015, PHP-016, PHP-017 | -- |
| Encapsulamento | POO-006 a POO-012, POO-058 | PHP-018, PHP-019, PHP-022, PHP-023 | SEG-015, SEG-017 |
| Entidades ricas + FSM | POO-017, POO-046, POO-047 | PHP-022, PHP-024, PHP-025 | -- |
| Validacao na fronteira | POO-045, POO-046, POO-047 | PHP-040 | SEG-003, SEG-004 |
| Erros tipados | POO-045, POO-048 | PHP-034, PHP-035, PHP-036, PHP-051 | -- |
| Direcao de dependencia | POO-018, POO-039, POO-044 | PHP-026 | -- |
| Testabilidade | POO-049, POO-050, POO-051, POO-052 | -- | -- |
| Heranca / composicao | POO-019 a POO-024, POO-057, POO-059 | -- | -- |
| Polimorfismo / SOLID | POO-025 a POO-039 | -- | -- |
| Idiomas da linguagem | POO-053, POO-055, POO-061, POO-062 | PHP-043 a PHP-048 | -- |
| Identidade / igualdade | POO-004, POO-014, POO-056 | -- | -- |
| Boas praticas (BP01-BP15) | POO-040, POO-041, POO-053 a POO-062 | -- | -- |

---

## 12. Padrões arquiteturais do projeto BGR

> Regras específicas dos projetos da BGR Software House. Definem os padrões
> arquiteturais concretos (entidade, repositório, gerenciador, handler) usados
> em todos os projetos PHP/WP da casa. Complementam as regras universais acima.

### POO-063 — Entidade: Rich Domain Model com FSM [ERRO]

**Regra:** Toda entidade com estado segue o padrão Rich Domain Model com máquina de estados finita. Padrão obrigatório, alinhado com a UniBGR.

**Verifica:** Entidades em `inc/entidades/` devem seguir a estrutura obrigatória abaixo. Ausência de qualquer item é violação.

**Por quê:** O padrão Rich Domain Model com FSM garante que toda transição de estado passa por validação, que a entidade é sempre auto-consistente, e que a hidratação do banco é tolerante. Este padrão nasceu na BGR e é aplicado em todos os projetos da casa.

Estrutura obrigatória:
1. Constantes de status
2. `STATUS_TRANSITIONS` definindo transições válidas
3. Construtor parametrizado (estado válido desde a criação)
4. Getters sem prefixo `get_`
5. Lifecycle methods (`confirmar()`, `cancelar()`) com Tell, Don't Ask
6. Predicados de estado (`estaConfirmado()`, `estaPendente()`)
7. `podeTransicionarPara()` público
8. `fromRow()` tolerante (nunca lança exception)
9. `toArray()` para serialização

```php
class Lancamento
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
        private readonly int $contaId,
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

    // Hidratação tolerante
    public static function fromRow(object $row): self
    {
        $entity = (new \ReflectionClass(self::class))
            ->newInstanceWithoutConstructor();

        $entity->id = (int) $row->id;
        $entity->userId = (int) $row->user_id;
        $entity->contaId = (int) $row->conta_id;
        $entity->valorCents = (int) $row->valor_cents;
        $entity->status = (string) $row->status;

        return $entity;
    }

    // Serialização
    public function toArray(): array
    {
        return [
            'id' => $this->id,
            'user_id' => $this->userId,
            'conta_id' => $this->contaId,
            'valor_cents' => $this->valorCents,
            'status' => $this->status,
        ];
    }
}
```

**Referencias:** POO-003, POO-010, POO-017, POO-046, POO-047

---

### POO-064 — Repositório: interface uniforme [ERRO]

**Regra:** Todo repositório segue a mesma estrutura de métodos. Padrão alinhado com a UniBGR.

**Verifica:** Repositórios em `inc/repositorios/` ou equivalente devem ter todos os métodos obrigatórios.

**Por quê:** Interface uniforme permite que qualquer desenvolvedor saiba exatamente o que esperar de qualquer repositório do projeto. Reduz curva de aprendizado e facilita code review.

Métodos obrigatórios:
1. `findById(int $id): ?Entidade`
2. `findAll(): array`
3. `create(Entidade $e): int`
4. `update(Entidade $e): bool`
5. `delete(int $id): bool`
6. `tableName(): string` (privado)
7. `hydrate(object $row): Entidade` (privado)

```php
class LancamentoRepository
{
    public function __construct(
        private readonly \wpdb $wpdb,
        private readonly Criptografia $cripto,
    ) {}

    public function findById(int $id): ?Lancamento
    {
        $row = $this->wpdb->get_row($this->wpdb->prepare(
            "SELECT * FROM {$this->tableName()} WHERE id = %d",
            $id
        ));

        return $row ? $this->hydrate($row) : null;
    }

    public function create(Lancamento $lancamento): int
    {
        $this->wpdb->insert($this->tableName(), [
            'user_id' => $lancamento->userId(),
            'valor_cents' => $this->cripto->criptografar((string) $lancamento->valorCents()),
            'status' => $lancamento->status(),
        ]);

        return (int) $this->wpdb->insert_id;
    }

    private function tableName(): string
    {
        return $this->wpdb->prefix . 'financeiro_lancamentos';
    }

    private function hydrate(object $row): Lancamento
    {
        $row->valor_cents = (int) $this->cripto->descriptografar($row->valor_cents);
        return Lancamento::fromRow($row);
    }
}
```

**Referencias:** POO-030, POO-039, POO-044, POO-063

---

### POO-065 — Gerenciador: orquestração sem lógica de domínio [ERRO]

**Regra:** Gerenciadores coordenam operações entre entidades e repositórios. A lógica de domínio vive na entidade, não no gerenciador.

**Verifica:** `grep -rn "->getStatus\|->setStatus\|->getValor" inc/gerenciadores/` — lógica que manipula estado da entidade no gerenciador é violação.

**Por quê:** Gerenciador com lógica de domínio é o caminho para entidade anêmica. A regra de negócio fica espalhada em N gerenciadores, e quando muda, você caça em todos.

```php
// correto — gerenciador orquestra
class FinanceiroManager
{
    public function __construct(
        private readonly LancamentoRepository $lancamentos,
        private readonly ContaBancariaRepository $contas,
    ) {}

    public function confirmarLancamento(int $lancamentoId): void
    {
        $lancamento = $this->lancamentos->findById($lancamentoId);

        if (!$lancamento) {
            throw new LancamentoNaoEncontradoException($lancamentoId);
        }

        $lancamento->confirmar(); // lógica na entidade
        $this->lancamentos->update($lancamento);
    }
}

// incorreto — gerenciador com lógica de domínio
class FinanceiroManager
{
    public function confirmarLancamento(int $id): void
    {
        $lancamento = $this->lancamentos->findById($id);

        if ($lancamento->status() !== 'pendente') { // lógica deveria estar na entidade
            throw new \Exception('Não pode confirmar');
        }

        // ... muda status diretamente
    }
}
```

**Referencias:** POO-010, POO-017, POO-035, POO-063

---

### POO-066 — Handler: fronteira do sistema [ERRO]

**Regra:** Handlers são a fronteira entre o mundo externo (request HTTP/AJAX) e o domínio. Responsabilidades:
1. Verificar autenticação e autorização (nonce + roles)
2. Sanitizar e validar input
3. Delegar para o gerenciador
4. Retornar resposta

Handlers nunca contêm lógica de domínio nem acessam `$wpdb` diretamente.

**Verifica:** `grep -rn "\$wpdb" inc/handlers/` deve retornar vazio. Lógica de negócio em handlers é violação.

**Por quê:** Handler que acessa banco ou contém lógica de domínio acopla a fronteira ao núcleo. Quando a API muda (de AJAX para REST, por exemplo), a lógica de domínio precisa ser reescrita — porque estava colada ao handler.

```php
class FinanceiroAjaxHandler
{
    private const ALLOWED_ROLES = ['acp_admin', 'acp_user'];

    public function __construct(
        private readonly FinanceiroManager $manager,
    ) {}

    public function register(): void
    {
        add_action('wp_ajax_acp_confirmar_lancamento', [$this, 'handleConfirmarLancamento']);
    }

    public function handleConfirmarLancamento(): void
    {
        $this->checkPermission();

        $lancamentoId = absint($_POST['lancamento_id'] ?? 0);

        if (!$lancamentoId) {
            wp_send_json_error(['mensagem' => 'ID do lançamento é obrigatório.']);
        }

        try {
            $this->manager->confirmarLancamento($lancamentoId);
            wp_send_json_success(['mensagem' => 'Lançamento confirmado.']);
        } catch (LancamentoNaoEncontradoException $e) {
            wp_send_json_error(['mensagem' => 'Lançamento não encontrado.']);
        } catch (TransicaoInvalidaException $e) {
            wp_send_json_error(['mensagem' => 'Transição de status inválida.']);
        }
    }

    private function checkPermission(): void
    {
        check_ajax_referer('acp_nonce', 'nonce');

        $user = wp_get_current_user();
        $hasRole = array_intersect(self::ALLOWED_ROLES, $user->roles);

        if (empty($hasRole)) {
            wp_send_json_error(['mensagem' => 'Sem permissão.'], 403);
        }
    }
}
```

**Referencias:** POO-044, POO-065

---

### POO-067 — Enums para domínios fechados [AVISO]

**Regra:** Status, tipos e categorias com conjunto fixo de valores devem usar PHP Enums (8.1+), não strings soltas.

**Verifica:** `grep -rn "= 'receita'\|= 'despesa'\|= 'corrente'" inc/entidades/` — strings soltas para status/tipo são candidatas a enum.

**Por quê:** Enum garante que só valores válidos existem. String solta aceita qualquer coisa — inclusive typo silencioso que vira bug.

```php
// correto
enum TipoLancamento: string
{
    case Receita = 'receita';
    case Despesa = 'despesa';
    case Transferencia = 'transferencia';
}

enum TipoConta: string
{
    case Corrente = 'corrente';
    case Poupanca = 'poupanca';
    case Carteira = 'carteira';
    case Investimento = 'investimento';
}

// incorreto — string solta
$tipo = 'receita'; // pode ser qualquer coisa, sem validação
```

**Referencias:** POO-053

---

### POO-068 — Usar DateTimeImmutable, nunca strings de data [ERRO]

**Regra:** Datas são objetos, não strings. Usar `DateTimeImmutable` para todas as propriedades temporais.

**Verifica:** `grep -rn "private string \$criadoEm\|private ?string \$prazo\|string \$data" inc/entidades/` — strings para datas são violação.

**Por quê:** `DateTimeImmutable` sabe somar dias, calcular diferenças, formatar, comparar. String precisa de parse manual, com bugs de fuso horário e formato garantidos.

```php
// correto
private readonly DateTimeImmutable $criadoEm;
private ?DateTimeImmutable $prazo;

// incorreto
private string $criadoEm; // '2026-04-07'
private ?string $prazo;
```

**Referencias:** POO-053, POO-062

---

## 13. Regras derivadas de incidentes

> Regras adicionadas a partir de erros reais documentados em `aprendizado/erros/`. Cada uma referencia o incidente que a originou.

### POO-069 — Toda entidade persistida DEVE ter from_row() [ERRO]

**Regra:** Se uma entidade é salva e lida do banco via repositório, ela DEVE implementar `from_row()` (ou equivalente de hidratação). Entidade sem hidratação = fatal latente no repositório na primeira leitura. O repositório chama `Entidade::fromRow($row)` — se o método não existe, é `Call to undefined method`.

**Verifica:** Para cada entidade em `inc/entidades/`, verificar se existe `public static function fromRow`. Se a entidade é usada por um repositório e não tem `fromRow`, é violação.

```php
// correto — entidade persistida com from_row()
class EmailTemplate
{
    public static function fromRow(object $row): self { /* ... */ }
}

// incorreto — entidade persistida sem from_row()
class EmailTemplate
{
    // repositório vai chamar EmailTemplate::fromRow() e explodir
}
```

**Origem:** incidente 0007 — `EmailTemplate` sem `from_row()` causou fatal em produção em toda tentativa de carregar template do banco.

**Referencias:** POO-063

---

### POO-070 — Método chamado em entidade DEVE existir na classe [ERRO]

**Regra:** Ao usar uma entidade, verificar se o método público existe de fato. Não assumir que `titulo()` existe porque parece lógico — a entidade pode usar `pergunta()` em vez de `titulo()`. Sempre conferir a API real.

**Verifica:** Antes de chamar método em entidade, confirmar via grep ou leitura que o método está declarado na classe.

```php
// correto — verifica que o método existe na entidade
$texto = $enquete->pergunta();  // método real da classe Enquete

// incorreto — assume que titulo() existe
$texto = $enquete->titulo();    // método não existe, fatal
```

**Origem:** incidente 0036 — helper chamava `$enquete->titulo()`, `$enquete->tipo()` e `$enquete->opcoes()`, nenhum dos três existe na entidade `Enquete`.

---

### POO-071 — Lógica de domínio replica produção existente, não inventa [ERRO]

**Regra:** Ao implementar lógica de domínio que já existe em outro módulo ou projeto (ex: montagem de teste, cálculo de score, seleção de perguntas), replicar a lógica real de produção — não inventar algoritmo novo sem aprovação explícita. Grep a implementação existente antes de escrever.

**Verifica:** Quando a tarefa envolve replicar lógica existente, `grep` a implementação atual antes de escrever código novo. Comparar com a lógica real.

```php
// correto — replica lógica existente da UniBGR
// seleção por competência + nível + cap dinâmico + round-robin
$perguntas = $this->selecionarPorCompetencia($competencias, $niveis, $cap);

// incorreto — inventou lógica simplificada
// "1 pergunta aleatória por comportamento = 123 fixo"
$perguntas = $this->selecionarAleatorio(123);
```

**Origem:** incidente 0053 — `handle_iniciar` montava teste com lógica inventada em vez de replicar o modelo real da UniBGR.

---

## Checklist de auditoria

A skill `/auditar-poo` deve verificar, para cada arquivo:

### Do documento de padrões universais (POO-001 a POO-062)

| # | Item | Regras | Verificação |
|---|------|--------|-------------|
| 1 | Cada classe modela conceito do domínio (sem "Helper", "Utils") | POO-001 | Nome e responsabilidade explicáveis em uma frase do domínio |
| 2 | Vocabulário do domínio em classes, métodos, atributos | POO-002, POO-016 | Bater nomes com Notion/Slack do produto |
| 3 | Atributos privados, sem setters públicos genéricos | POO-006, POO-008 | `grep -rn "public \$" inc/` retorna só VOs com `readonly` |
| 4 | Imutabilidade quando não há motivo para mutar | POO-007 | Construtor usa `private readonly` em campos estáveis |
| 5 | Tell, Don't Ask: lógica mora junto dos dados | POO-010, POO-017 | Sem `->getX() === Y; ->setZ()` nos chamadores |
| 6 | Lei de Demeter respeitada | POO-011 | Sem cadeias `->a->b->c->d` |
| 7 | Construtor garante objeto válido ou lança | POO-012, POO-046, POO-047 | Invariantes validadas no construtor |
| 8 | Value Objects para conceitos sem identidade | POO-014, POO-015 | CPF, Email, Money, Cep tipados, não primitivos |
| 9 | Herança apenas para "é-um", máximo 2 níveis | POO-019, POO-021 | Sem herança para reuso, sem cadeia profunda |
| 10 | Composição em vez de herança quando possível | POO-020, POO-024 | Reuso por colaborador injetado, não por extends |
| 11 | Classes finais por padrão | POO-022 | `grep -rn "^class" inc/` mostra `final` ou `abstract` |
| 12 | LSP respeitado em hierarquias | POO-023, POO-027, POO-037 | Subclasse substitui superclasse sem surpresa |
| 13 | Polimorfismo em vez de cadeias if/instanceof | POO-025, POO-026 | `grep -rn "instanceof\|elseif.*tipo"` baixo |
| 14 | Override marcado com `#[\Override]` | POO-028 | Em PHP 8.3+, todo override marcado |
| 15 | Programar para interface | POO-030 | Tipos de parâmetros usam interfaces |
| 16 | Interfaces pequenas, segregadas e coesas | POO-032, POO-033 | Máximo ~7 métodos por interface |
| 17 | Classe abstrata só com código real compartilhado | POO-031, POO-034 | Sem "interface fingindo ser classe" |
| 18 | SRP: um motivo único para mudar | POO-035 | Nome composto ("XEYService") = candidato a quebra |
| 19 | OCP: aberto para extensão, fechado para modificação | POO-036 | Tipos novos viram classe nova, não if novo |
| 20 | DIP: domínio define interfaces, infra implementa | POO-039 | Namespace de interface vive no domínio |
| 21 | Coesão alta, acoplamento baixo | POO-040, POO-041 | Construtor com <= 4 dependências |
| 22 | Dependências por construtor, sem singleton/global | POO-042, POO-043 | `grep -rn "getInstance\|global \$"` retorna vazio |
| 23 | Direção de dependência entre camadas | POO-044 | `use Infra\...` só em arquivos de Infra ou raiz |
| 24 | Falha rápida com exceção tipada de domínio | POO-045, POO-048 | Sem `return null` para erro; sem `\Exception` genérica |
| 25 | Exceções carregam contexto estruturado | POO-048 | Exceções com construtor por dados, não só string |
| 26 | Classes de domínio testáveis sem infra | POO-049 | `new Classe()` no teste, sem banco/rede |
| 27 | Mocks por interface, nunca por reflection | POO-050 | Sem `setAccessible(true)` no teste |
| 28 | Suite unitária roda em segundos | POO-051 | PHPUnit reporta tempo, alvo < 5s para 100+ testes |
| 29 | Builders/factories de teste para reduzir ruído | POO-052 | Testes destacam 1-2 parâmetros, não 8 |
| 30 | Strings só para texto livre (BP02) | POO-053 | Datas, status, sexo, UF -> tipos próprios |
| 31 | Sem hierarquias preventivas (BP03 / KISS) | POO-054 | Toda abstract/interface tem >= 1 implementação real |
| 32 | Coleção certa, com funções idiomáticas (BP05) | POO-055 | `array_map`/`filter`/`reduce`; `in_array(..., true)` |
| 33 | Identidade e igualdade explícitas (BP06) | POO-056 | Entidade tem `id()` e `ehMesmo()`; VO tem `igualA()` |
| 34 | Não estender coleções/utilitários da linguagem (BP07) | POO-057 | Carrinho TEM produtos, não É lista |
| 35 | `final` em classes terminais e métodos críticos (BP08) | POO-058 | Métodos com invariante crítica -> `final` |
| 36 | Não especializar o já especializado (BP11) | POO-059 | Concretas não herdam de concretas |
| 37 | Estáticos com parcimônia (BP12) | POO-060 | Sem `static $` mutável em domínio; métodos estáticos só em utilitárias |
| 38 | Cópia defensiva quando expor mutável (BP13) | POO-061 | Getter retorna `clone`; ou usar `readonly` (preferido) |
| 39 | Idiomas da linguagem (BP14, BP15) | POO-062 | Sem `float` em dinheiro; `foreach` em array; `DateTimeImmutable` em data |

### Dos padrões arquiteturais BGR (POO-063 a POO-068)

| # | Item | Regras | Verificação |
|---|------|--------|-------------|
| 40 | Entidade segue Rich Domain Model (FSM, lifecycle, predicados, fromRow, toArray) | POO-063 | Estrutura de 9 pontos presente |
| 41 | Repositório segue interface uniforme (findById, findAll, create, update, delete, hydrate) | POO-064 | 7 métodos obrigatórios presentes |
| 42 | Gerenciador orquestra sem lógica de domínio | POO-065 | Sem manipulação direta de estado da entidade |
| 43 | Handler valida e delega (nunca acessa $wpdb, nunca contém lógica de domínio) | POO-066 | `grep "\$wpdb" handlers/` vazio |
| 44 | Enums para domínios fechados (status, tipos, categorias) | POO-067 | Sem strings soltas para conjuntos fixos |
| 45 | DateTimeImmutable para todas as datas | POO-068 | Sem `string $criadoEm` |

### Das regras derivadas de incidentes (POO-069 a POO-071)

| # | Item | Regras | Verificação |
|---|------|--------|-------------|
| 46 | Entidade persistida tem fromRow() | POO-069 | Toda entidade usada por repositório tem `fromRow` |
| 47 | Métodos chamados na entidade existem de fato | POO-070 | Grep confirma existência antes de chamar |
| 48 | Lógica de domínio replica produção existente | POO-071 | Lógica nova comparada com implementação real |

## Processo

### Fase 1 — Carregar a régua

1. Ler a seção **Padrões mínimos exigidos** deste documento (seções 0-13, 71 regras no total).
2. Internalizar todas as regras com seus IDs, descrições, exemplos e severidades (ERRO/AVISO).
3. Não resumir nem recitar o documento de volta.

### Fase 2 — Identificar o PR aberto

1. Executar `gh pr list --state open --base develop --json number,title,headBranch --limit 1` para encontrar o PR aberto mais recente contra `develop`.
2. Se houver mais de um PR aberto, listar todos e perguntar ao usuário qual auditar.
3. Se não houver PR aberto, informar o usuário e encerrar.
4. Executar `gh pr diff <numero>` para obter o diff completo do PR.
5. Filtrar apenas arquivos `.php` dentro do projeto.

### Fase 3 — Auditar arquivo por arquivo

Para cada arquivo PHP alterado no PR:

1. Ler o arquivo completo (não apenas o diff — contexto importa).
2. Comparar contra **cada regra** das seções 0-13 deste documento, uma por uma, na ordem do documento:
   - Seções 0-11: princípios universais de OO (POO-001 a POO-062)
   - Seção 12: padrões arquiteturais BGR (POO-063 a POO-068)
   - Seção 13: regras derivadas de incidentes (POO-069 a POO-071)
3. Para cada violação encontrada, registrar:
   - **Arquivo** e **linha(s)** onde ocorre
   - **ID da regra** violada (ex.: POO-063)
   - **Severidade** (ERRO ou AVISO)
   - **O que está errado** — descrição concisa
   - **Como corrigir** — correção específica para aquele trecho
4. Se o arquivo não viola nenhuma regra, registrar como aprovado.

### Fase 4 — Relatório

Apresentar o relatório ao usuário no seguinte formato:

```
## Relatório de auditoria POO

**PR:** #<numero> — <titulo>
**Branch:** <branch>
**Arquivos auditados:** <quantidade>
**Régua:** 71 regras (POO-001 a POO-071)

### Resumo

- Erros: <quantidade>
- Avisos: <quantidade>
- Arquivos aprovados: <quantidade>

### Violações

#### <arquivo.php>

| Linha | Regra | Severidade | Descrição | Correção |
|-------|-------|------------|-----------|----------|
| 10 | POO-003 | ERRO | Entidade anêmica, só getters/setters | Adicionar lógica de domínio |
| 25 | POO-010 | ERRO | Decisão de status fora da entidade | Mover para lifecycle method |

#### <outro-arquivo.php>
Aprovado — nenhuma violação encontrada.
```

### Fase 5 — Plano de correções

Se houver violações do tipo ERRO:

1. Listar as correções necessárias agrupadas por arquivo.
2. Ordenar por severidade (ERROs primeiro, AVISOs depois).
3. Para cada correção, indicar exatamente o que mudar e onde.
4. Perguntar ao usuário: "Quer que eu execute as correções agora?"

Se houver apenas AVISOs ou nenhuma violação:

> "Nenhum erro bloquante. Os avisos são recomendações — quer que eu corrija algum?"

## Regras

- **Nunca alterar código durante a auditoria.** A skill é read-only até o usuário pedir correção explicitamente.
- **Nunca auditar arquivos fora do PR.** Apenas arquivos PHP alterados no PR aberto.
- **Sempre referenciar o ID da regra violada.** O relatório deve ser rastreável ao documento de padrões.
- **Nunca inventar regras.** A régua é exclusivamente este documento — sem opinião, sem sugestões extras.
- **Ser metódica e processual.** Cada arquivo é comparado contra cada regra, na ordem do documento, sem pular.
- **Fidelidade ao documento.** Se o código viola uma regra do documento, reportar. Se o documento não cobre o caso, não reportar.
- **Mostrar o relatório completo antes de qualquer ação.** Nunca executar correções sem aprovação explícita.
