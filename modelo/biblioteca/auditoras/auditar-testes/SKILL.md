---
name: auditar-testes
description: Audita testes PHPUnit do PR aberto contra as regras definidas em docs/padroes-testes.md. Entrega relatorio de violacoes e plano de correcoes. Trigger manual apenas.
---

# /auditar-testes — Auditora de padroes de testes

Le as regras de `docs/padroes-testes.md`, identifica os arquivos de teste alterados no PR aberto (nao mergeado) e compara cada arquivo contra cada regra aplicavel. Foco em qualidade de testes: organizacao, nomenclatura, cobertura por camada, determinismo, isolamento e antipadroes.

Complementa `/auditar-php` (sintaxe) e `/auditar-poo` (arquitetura).

## Quando usar

- **APENAS** quando o usuario digitar `/auditar-testes` explicitamente.
- Rodar antes de mergear um PR — funciona como gate de qualidade dos testes.
- **Nunca** disparar automaticamente, nem como parte de outra skill.

## Padroes minimos exigidos

> Esta secao contem os padroes completos usados pela auditoria. Edite para personalizar ao seu projeto.

# Padrao de testes

## Descricao

Documento de referencia para auditoria de testes no projeto. Define como testes devem ser escritos, organizados e o que devem cobrir. A skill `/auditar-testes` le este documento e compara contra os testes do PR aberto.

Complementa `docs/padroes-php.md` (sintaxe) e `docs/padroes-poo.md` (arquitetura).

## Escopo

- Testes PHPUnit dentro de `testes/`
- Cobertura de: entidades, repositorios, gerenciadores, handlers
- Foco em testes que simulam condicoes reais de uso
- Organizacao em 5 camadas conforme a piramide de testes

## Referencias

- `docs/padroes-php.md` — Regras de linguagem PHP
- `docs/padroes-poo.md` — Padroes de arquitetura OOP
- [PHPUnit 12.x](https://docs.phpunit.de/en/12.0/)

## Severidade

- **ERRO** — Violacao bloqueia aprovacao. Deve ser corrigida antes de merge.
- **AVISO** — Recomendacao forte. Deve ser justificada se ignorada.

---

## 1. Piramide de testes

### TST-001 — Cinco camadas, base larga, topo estreito [ERRO]

O projeto adota a piramide de testes com 5 camadas. Cada camada tem escopo, custo e proporcao definidos. A base (unitarios) concentra o maior volume de testes. O topo (funcionais) tem poucos testes de alto valor.

| Camada | Pasta | O que testa | Custo/Esforco |
|--------|-------|-------------|---------------|
| Unitarios | `testes/unitarios/` | Entidades, Value Objects — logica pura de dominio | Baixo |
| Componentes | `testes/componentes/` | Gerenciadores com mocks — orquestracao isolada | Baixo-medio |
| Integracao | `testes/integracao/` | Repositorios com banco real, criptografia | Medio |
| API | `testes/api/` | Handlers — request/response completo | Medio-alto |
| Funcionais | `testes/funcionais/` | Pagina renderiza, fluxos end-to-end | Alto |

Proporcao esperada (aproximada):

```
         /\          Funcionais       ~5%
        /  \         API              ~10%
       /    \        Integracao       ~15%
      /      \       Componentes      ~20%
     /________\      Unitarios        ~50%
```

**Regra:** quanto mais alto na piramide, menos testes e mais seletivos.

### TST-002 — Cada teste vive na camada correta [ERRO]

Um teste que acessa banco de dados nao e unitario. Um teste que mocka tudo nao e de integracao. Classificar corretamente:

| Se o teste... | Camada |
|---------------|--------|
| Testa logica pura sem dependencia externa | Unitario |
| Testa orquestracao com mocks de repositorios | Componente |
| Acessa banco de dados real | Integracao |
| Simula requisicao HTTP com autenticacao | API |
| Verifica se a pagina renderiza com framework carregado | Funcional |

---

## 2. Filosofia

### TST-003 — Testes simulam condicoes reais [ERRO]

Testes existem para provar que o codigo funciona em situacoes que acontecem de verdade. Nao testar cenarios inventados que nunca ocorrem em producao.

```php
// correto — simula uso real
public function testConfirmarPedidoPendenteTransicionaParaConfirmado(): void
{
    $pedido = PedidoFactory::pendente();

    $pedido->confirmar();

    $this->assertSame('confirmado', $pedido->status());
}

// incorreto — cenario que nunca acontece
public function testPedidoComIdNegativo(): void
{
    // IDs negativos nunca existem no banco, teste inutil
}
```

### TST-004 — Bug encontrado = teste faltando [ERRO]

Se um bug aparece, o primeiro passo e escrever um teste que reproduz o bug. Depois corrigir. O teste garante que o bug nunca volta.

### TST-005 — Todo codigo novo tem teste [ERRO]

Toda entidade, repositorio, gerenciador e handler entregue em PR deve ter testes correspondentes na camada adequada da piramide. Codigo sem teste nao mergeia.

---

## 3. Organizacao e nomenclatura

### TST-006 — Estrutura de pastas espelha o codigo em 5 camadas [ERRO]

```
projeto/
├── inc/
│   ├── entidades/Pedido.php
│   ├── repositorios/PedidoRepository.php
│   ├── gerenciadores/PedidoManager.php
│   └── handlers/PedidoHandler.php
└── testes/
    ├── unitarios/
    │   ├── PedidoTest.php
    │   └── DinheiroTest.php
    ├── componentes/
    │   └── PedidoManagerTest.php
    ├── integracao/
    │   └── PedidoRepositoryTest.php
    ├── api/
    │   └── PedidoHandlerTest.php
    └── funcionais/
        └── PaginaInicialTest.php
```

### TST-007 — Nomes de teste descrevem comportamento com contexto [ERRO]

Usar o padrao: `test` + acao + contexto + resultado esperado. Sem a palavra "deve" (should).

```php
// correto — comportamento claro
public function testConfirmarQuandoPendenteTransicionaParaConfirmado(): void {}
public function testConfirmarQuandoJaConfirmadoLancaExcecao(): void {}
public function testCriarComValorNegativoLancaExcecao(): void {}

// incorreto — vago, nao diz o que espera
public function testConfirmar(): void {}
public function testPedido(): void {}
public function testDeveConfirmarOPedido(): void {} // "deve" proibido
```

### TST-008 — Descricoes curtas, maximo 100 caracteres [AVISO]

---

## 4. Estrutura do teste

### TST-009 — Padrao AAA: Arrange, Act, Assert [ERRO]

Todo teste segue tres blocos separados por linha em branco: preparar, executar, verificar.

```php
// correto — AAA claro
public function testConfirmarQuandoPendenteTransiciona(): void
{
    // Arrange
    $pedido = PedidoFactory::pendente();

    // Act
    $pedido->confirmar();

    // Assert
    $this->assertSame('confirmado', $pedido->status());
}
```

### TST-010 — Uma assercao por teste unitario [AVISO]

Testes unitarios e de componentes validam um unico comportamento com uma assercao. Testes de integracao, API e funcionais podem ter ate 3 assercoes relacionadas.

### TST-011 — Testar os tres caminhos: feliz, invalido, limite [ERRO]

Todo comportamento testado cobre:
1. **Caminho feliz** — funciona como esperado
2. **Caso invalido** — rejeita entrada errada
3. **Caso limite** — comportamento na fronteira (zero, vazio, maximo)

---

## 5. Dados de teste

### TST-012 — Factories, nunca fixtures [ERRO]

Usar factories para criar objetos de teste. Factories sao controlaveis, flexiveis e explicitas. Fixtures sao frageis e opacas.

```php
// correto — factory
class PedidoFactory
{
    public static function pendente(array $overrides = []): Pedido
    {
        return new Pedido(
            id: $overrides['id'] ?? 1,
            userId: $overrides['userId'] ?? 100,
            valorCents: $overrides['valorCents'] ?? 15000,
            status: Pedido::STATUS_PENDENTE,
        );
    }

    public static function confirmado(array $overrides = []): Pedido
    {
        $pedido = self::pendente($overrides);
        $pedido->confirmar();
        return $pedido;
    }
}
```

### TST-013 — Criar apenas o necessario [AVISO]

Cada teste constroi estritamente o minimo de dados para o cenario.

### TST-014 — Sem valores soltos duplicados entre setup e assercao [ERRO]

Nunca repetir literais entre a construcao e a verificacao. Ler do objeto, nao de strings duplicadas.

```php
// correto — le do objeto
$pedido = PedidoFactory::pendente(['valorCents' => 5000]);
$id = $this->repository->create($pedido);
$salvo = $this->repository->findById($id);
$this->assertSame($pedido->valorCents(), $salvo->valorCents());

// incorreto — valor duplicado
$this->assertSame(5000, $salvo->valorCents()); // 5000 repetido
```

---

## 6. Isolamento por camada

### TST-015 — Testes unitarios: sem dependencia externa [ERRO]

Testes em `testes/unitarios/` trabalham com objetos em memoria. Sem banco, sem rede, sem filesystem.

### TST-016 — Testes de componentes: mocks de dependencias [ERRO]

Testes em `testes/componentes/` isolam o sujeito mockando suas dependencias.

### TST-017 — Testes de integracao: banco real, sem mocks [ERRO]

Testes em `testes/integracao/` usam banco de dados real. Sem mocks do banco.

### TST-018 — Testes de API: request/response completo [ERRO]

Testes em `testes/api/` simulam requisicoes completas, incluindo autenticacao e payload.

### TST-019 — Testes funcionais: framework carregado, pagina renderiza [ERRO]

Testes em `testes/funcionais/` carregam o framework completo e verificam que paginas renderizam corretamente.

### TST-020 — Mockar dependencias externas, nunca o sujeito [ERRO]

Mock em dependencias que nao sao responsabilidade do teste. Nunca mockar o objeto que esta sendo testado.

### TST-021 — Sem dependencia de estado externo [ERRO]

Testes nao dependem de variaveis de ambiente, hora do sistema, arquivos em disco ou estado de outros testes. Cada teste e autossuficiente.

---

## 7. Determinismo

### TST-022 — Testes sao deterministicos [ERRO]

O mesmo teste rodando 100 vezes produz o mesmo resultado. Sem `time()`, `rand()`, `uniqid()`, `new DateTimeImmutable()` sem argumento.

### TST-023 — Ordem de execucao nao importa [ERRO]

Nenhum teste depende de outro teste ter rodado antes. Cada teste prepara seu proprio estado.

---

## 8. Cobertura por camada

### TST-024 — Unitarios: entidades cobrem FSM completa [ERRO]

Toda entidade com maquina de estados deve ter testes unitarios para:
1. Cada transicao valida
2. Cada transicao invalida (lanca excecao)
3. Cada predicado de estado
4. Construcao com parametros validos
5. Construcao com parametros invalidos
6. `fromRow()` com dados limpos
7. `fromRow()` com dados sujos (nao explode)
8. `toArray()` retorna todos os campos

### TST-025 — Componentes: gerenciadores cobrem orquestracao [ERRO]

### TST-026 — Integracao: repositorios cobrem CRUD + criptografia [ERRO]

### TST-027 — API: handlers cobrem seguranca e contrato [ERRO]

### TST-028 — Funcionais: fluxos criticos e renderizacao [AVISO]

---

## 9. Antipadroes

### TST-029 — Sem hooks complexos nem estado compartilhado [AVISO]

Evitar `setUp()` complexos que constroem estado compartilhado entre testes.

### TST-030 — Sem testes que testam o framework [ERRO]

Nao testar se funcoes nativas do PHP funcionam. Testar o **nosso** codigo.

### TST-031 — Sem testes fantasiosos [ERRO]

Nao testar cenarios impossiveis ou extremamente improvaveis que nunca acontecem em uso real.

---

## Checklist de auditoria

A skill `/auditar-testes` deve verificar, para cada arquivo de teste:

**Piramide:**
- [ ] Teste esta na camada correta
- [ ] Proporcao da piramide respeitada

**Filosofia:**
- [ ] Testes simulam condicoes reais de uso
- [ ] Todo codigo novo tem teste correspondente
- [ ] Tres caminhos cobertos: feliz, invalido, limite

**Organizacao:**
- [ ] Estrutura de pastas em 5 camadas espelha o codigo
- [ ] Nomes descrevem comportamento com contexto (sem "deve")

**Estrutura:**
- [ ] Padrao AAA (Arrange, Act, Assert)
- [ ] Uma assercao por teste unitario/componente
- [ ] Sem valores soltos duplicados

**Dados:**
- [ ] Factories usadas, nunca fixtures
- [ ] Apenas dados necessarios criados

**Isolamento:**
- [ ] Unitarios: sem banco, sem rede
- [ ] Componentes: mocks de dependencias
- [ ] Integracao: banco real, sem mocks
- [ ] API: request/response completo
- [ ] Mocks apenas em dependencias, nunca no sujeito
- [ ] Sem dependencia de estado externo

**Determinismo:**
- [ ] Sem time(), rand(), uniqid() ou DateTimeImmutable sem argumento
- [ ] Ordem de execucao nao importa

**Cobertura:**
- [ ] Unitarios: entidades com FSM completa testada
- [ ] Componentes: gerenciadores com orquestracao testada
- [ ] Integracao: repositorios com CRUD
- [ ] API: handlers com seguranca

**Antipadroes:**
- [ ] Sem setUp() complexo nem estado compartilhado
- [ ] Sem testes que testam o framework
- [ ] Sem testes fantasiosos

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
5. Filtrar arquivos `*Test.php` dentro de `testes/`.
6. Tambem verificar se arquivos PHP alterados no PR possuem testes correspondentes.

### Fase 3 — Auditar arquivo por arquivo

Para cada arquivo de teste alterado no PR:

1. Ler o arquivo completo (nao apenas o diff — contexto importa).
2. Comparar contra **cada regra** de `docs/padroes-testes.md`, uma por uma, na ordem do documento.
3. Para cada violacao encontrada, registrar:
   - **Arquivo** e **linha(s)** onde ocorre
   - **ID da regra** violada (ex.: padroes-testes.md, TST-009)
   - **Severidade** (ERRO ou AVISO)
   - **O que esta errado** — descricao concisa
   - **Como corrigir** — correcao especifica para aquele trecho
4. Se o arquivo nao viola nenhuma regra, registrar como aprovado.

### Fase 4 — Relatorio

Apresentar o relatorio ao usuario no formato padrao de auditoria (tabela com Linha, Regra, Severidade, Descricao, Correcao).

### Fase 5 — Plano de correcoes

Se houver violacoes do tipo ERRO:

1. Listar as correcoes necessarias agrupadas por arquivo.
2. Ordenar por severidade (ERROs primeiro, AVISOs depois).
3. Perguntar ao usuario: "Quer que eu execute as correcoes agora?"

## Regras

- **Nunca alterar codigo durante a auditoria.** A skill e read-only ate o usuario pedir correcao explicitamente.
- **Nunca auditar arquivos fora do PR.** Apenas arquivos de teste e codigo alterados no PR aberto.
- **Sempre referenciar o ID da regra violada.** O relatorio deve ser rastreavel ao documento de padroes.
- **Nunca inventar regras.** A regua e exclusivamente o `docs/padroes-testes.md`.
- **Ser metodica e processual.** Cada arquivo e comparado contra cada regra, na ordem do documento, sem pular.
- **Fidelidade ao documento.** Se o teste viola uma regra do documento, reportar. Se o documento nao cobre o caso, nao reportar.
- **Verificar cobertura cruzada.** Se o PR tem codigo novo sem teste, reportar como TST-005.
- **Mostrar o relatorio completo antes de qualquer acao.** Nunca executar correcoes sem aprovacao explicita.
