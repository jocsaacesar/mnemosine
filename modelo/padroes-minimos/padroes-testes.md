---
documento: padroes-testes
versao: 2.2.0
criado: 2025-01-01
atualizado: 2026-04-16
total_regras: 33
severidades:
  erro: 27
  aviso: 6
escopo: Padrões de testes automatizados para todos os projetos
aplica_a: ["todos"]
requer: ["padroes-php", "padroes-poo"]
substitui: ["padroes-testes v2.1.0"]
---

# Padrões de Testes — sua organização

> Documento constitucional. Contrato de entrega para todo
> desenvolvedor que toca testes nos nossos projetos.
> Código que viola regras ERRO não é discutido — é devolvido.

---

## Como usar este documento

### Para o desenvolvedor

1. Leia este documento antes de escrever o primeiro teste de qualquer feature.
2. Consulte o DoD no final antes de abrir qualquer Pull Request.
3. Use os IDs das regras (TST-001 a TST-033) para referenciar em PRs e code reviews.

### Para o auditor (humano ou IA)

1. Leia o frontmatter para entender escopo e dependências.
2. Audite cada arquivo de teste contra as regras por ID e severidade.
3. Classifique violações: ERRO bloqueia merge, AVISO exige justificativa.
4. Referencie violações pelo ID da regra (ex.: "viola TST-009").

### Para o Claude Code

1. Leia o frontmatter para identificar escopo e documentos relacionados.
2. Ao gerar ou revisar testes, aplique todas as regras ERRO como bloqueantes.
3. Ao reportar violações, referencie pelo ID (ex.: "TST-012 — usa fixture em vez de factory").
4. Nunca gere testes que violem regras ERRO deste documento.

---

## Severidades

| Nível | Significado | Ação |
|-------|-------------|------|
| **ERRO** | Violação inegociável | Bloqueia merge. Corrigir antes de review. |
| **AVISO** | Recomendação forte | Deve ser justificada por escrito se ignorada. |

---

## 1. Pirâmide de testes

### TST-001 — Cinco camadas, base larga, topo estreito [ERRO]

**Regra:** O projeto deve adotar a pirâmide de testes com 5 camadas. A base (unitários) concentra o maior volume. O topo (funcionais/end-to-end) tem poucos testes de alto valor.

**Verifica:** Contar arquivos por diretório (`testes/unitarios/`, `componentes/`, `integracao/`, `api/`, `funcionais/`) e validar que a proporção segue a pirâmide (unitários ≥40%).

**Por quê:** O projeto opera com times pequenos e desenvolvimento assistido por IA 24/7. Sem uma pirâmide bem definida, testes caros dominam a suite, o CI fica lento e o agente autônomo perde a capacidade de validar mudanças rapidamente. A base larga de unitários é o que permite iteração contínua sem supervisão humana.

| Camada | Diretório sugerido | O que testa | Custo/Esforço |
|--------|-------------------|-------------|---------------|
| Unitários | `testes/unitarios/` | Entidades, Value Objects — lógica pura de domínio | Baixo |
| Componentes | `testes/componentes/` | Gerenciadores/services com mocks — orquestração isolada | Baixo-médio |
| Integração | `testes/integracao/` | Repositórios com banco real, serviços externos | Médio |
| API | `testes/api/` | Endpoints/handlers — request/response completo | Médio-alto |
| Funcionais | `testes/funcionais/` | Fluxos end-to-end, renderização de páginas | Alto |

Proporção esperada (aproximada):

```
         /\          Funcionais       ~5%
        /  \         API              ~10%
       /    \        Integração       ~15%
      /      \       Componentes      ~20%
     /________\      Unitários        ~50%
```

**Exemplo correto:**
```
projeto/
└── testes/
    ├── unitarios/        # ~50% dos testes
    ├── componentes/      # ~20% dos testes
    ├── integracao/       # ~15% dos testes
    ├── api/              # ~10% dos testes
    └── funcionais/       # ~5% dos testes
```

**Exemplo incorreto:**
```
projeto/
└── testes/
    ├── unitarios/        # 3 testes
    └── funcionais/       # 47 testes — pirâmide invertida
```

### TST-002 — Cada teste vive na camada correta [ERRO]

**Regra:** Um teste que acessa banco de dados nunca é unitário. Um teste que mocka tudo nunca é de integração. Classificar cada teste na camada correta conforme suas dependências reais.

**Verifica:** Em cada arquivo de teste, verificar se as dependências reais (banco, rede, mocks) são compatíveis com a camada do diretório onde o arquivo está.

**Por quê:** Classificação errada quebra a confiança na pirâmide. Se unitários acessam banco, ficam lentos e frágeis. Se testes de integração mockam tudo, não testam nada real. O agente autônomo depende dessa classificação para decidir quais testes rodar em cada contexto.

| Se o teste... | Camada |
|---------------|--------|
| Testa lógica pura sem dependência externa | Unitário |
| Testa orquestração com mocks de dependências | Componente |
| Acessa banco de dados ou serviço externo real | Integração |
| Simula requisição HTTP completa com autenticação | API |
| Verifica renderização de página ou fluxo end-to-end | Funcional |

**Exemplo correto:**
```php
// testes/unitarios/PedidoTest.php — sem dependência externa
public function testCancelarQuandoPendenteTransiciona(): void
{
    $pedido = PedidoFactory::pendente();
    $pedido->cancelar();
    $this->assertSame('cancelado', $pedido->status());
}
```

**Exemplo incorreto:**
```php
// testes/unitarios/PedidoTest.php — acessa banco, deveria ser integração
public function testCriarPedidoPersiste(): void
{
    $id = $this->repository->create(PedidoFactory::pendente());
    $this->assertNotNull($this->repository->findById($id));
}
```

---

## 2. Filosofia

### TST-003 — Testes simulam condições reais [ERRO]

**Regra:** Testes devem provar que o código funciona em situações que acontecem de verdade em produção. Nunca testar cenários inventados que nunca ocorrem.

**Verifica:** Para cada teste, confirmar que o cenário descrito no nome corresponde a um caso de uso real do sistema.

**Por quê:** O projeto desenvolve com IA gerando código autonomamente. Testes são a única rede de segurança que garante que o código gerado funciona em condições reais. Testes de cenários fictícios consomem tempo de CI sem agregar proteção.

**Exemplo correto:**
```php
// simula uso real — transição de estado que acontece em produção
public function testConfirmarPedidoPendenteTransicionaParaConfirmado(): void
{
    $pedido = PedidoFactory::pendente();

    $pedido->confirmar();

    $this->assertSame('confirmado', $pedido->status());
}
```

**Exemplo incorreto:**
```php
// cenário que nunca acontece
public function testPedidoComIdNegativo(): void
{
    // IDs negativos nunca existem no banco, teste inútil
}
```

### TST-004 — Bug encontrado = teste faltando [ERRO]

**Regra:** Quando um bug aparece em produção ou em review, o primeiro passo é escrever um teste que reproduz o bug. Depois corrigir. O teste garante que o bug nunca volta.

**Verifica:** Em PRs de bugfix, verificar que existe pelo menos um teste novo cujo nome referencia o bug e que falha sem o fix aplicado.

**Por quê:** Times pequenos não têm QA manual dedicado. Se um bug escapa uma vez sem teste de regressão, vai escapar de novo — especialmente com IA gerando código que pode reintroduzir o mesmo padrão problemático.

**Exemplo correto:**
```php
// Bug #142: desconto negativo permitido — teste de regressão
public function testAplicarDescontoNegativoLancaExcecao(): void
{
    $pedido = PedidoFactory::confirmado();

    $this->expectException(DomainException::class);
    $pedido->aplicarDesconto(-500);
}
```

**Exemplo incorreto:**
```php
// Bug reportado, corrigido direto no código sem teste
// → nenhum teste escrito, bug pode voltar na próxima refatoração
```

### TST-005 — Todo código novo tem teste [ERRO]

**Regra:** Toda entidade, repositório, service e endpoint entregue em PR deve ter testes correspondentes na camada adequada da pirâmide. Código sem teste nunca mergeia.

**Verifica:** Comparar arquivos de código adicionados/modificados no PR com arquivos de teste existentes. Cada classe nova deve ter pelo menos um arquivo de teste correspondente.

**Por quê:** O agente autônomo opera 24/7 sem supervisão humana. Código sem teste é código que pode quebrar silenciosamente. No projeto, testes são o contrato de funcionamento — não um bônus, mas requisito mínimo de entrega.

**Exemplo correto:**
```php
// PR adiciona entidade Produto + testes unitários completos
// testes/unitarios/ProdutoTest.php existe com cobertura dos 3 caminhos
```

**Exemplo incorreto:**
```php
// PR adiciona entidade Produto sem nenhum teste
// "vou adicionar os testes depois" — nunca acontece
```

**Exceções:** Templates puros de apresentação (HTML com chamadas de framework como `get_header()`, `render()`) não exigem testes unitários — são cobertos por testes funcionais quando o fluxo justifica.

---

## 3. Organização e nomenclatura

### TST-006 — Estrutura de pastas espelha o código em 5 camadas [ERRO]

**Regra:** A estrutura de diretórios de teste deve espelhar a estrutura do código-fonte, organizada nas 5 camadas da pirâmide. Cada classe testável deve ter seu arquivo de teste correspondente na camada correta.

**Verifica:** Confirmar que existem os 5 diretórios da pirâmide e que cada arquivo de teste está no diretório correspondente à sua camada.

**Por quê:** Estrutura previsível permite que o agente autônomo encontre e execute testes relevantes sem configuração manual. Quando um arquivo de código muda, o agente sabe exatamente onde está o teste correspondente.

**Exemplo correto:**
```
projeto/
├── src/
│   ├── entidades/Pedido.php
│   ├── repositorios/PedidoRepository.php
│   ├── services/PedidoService.php
│   └── endpoints/PedidoEndpoint.php
└── testes/
    ├── unitarios/
    │   └── PedidoTest.php
    ├── componentes/
    │   └── PedidoServiceTest.php
    ├── integracao/
    │   └── PedidoRepositoryTest.php
    ├── api/
    │   └── PedidoEndpointTest.php
    └── funcionais/
        └── FluxoPedidoTest.php
```

**Exemplo incorreto:**
```
projeto/
└── tests/
    ├── PedidoTest.php            # tudo num diretório só
    ├── PedidoRepositoryTest.php  # sem separação por camada
    └── PedidoEndpointTest.php    # impossível saber o que cada teste faz
```

### TST-007 — Nomes de teste descrevem comportamento com contexto [ERRO]

**Regra:** Usar o padrão: `test` + ação + contexto + resultado esperado. Sem a palavra "deve" (should). Contextos com "quando", "com", "sem".

**Verifica:** Buscar por `function test` nos arquivos de teste. Nenhum nome deve conter "deve"/"should". Cada nome deve ter ação + contexto + resultado.

**Por quê:** Nomes descritivos funcionam como documentação viva. Quando o agente autônomo reporta uma falha, o nome do teste deve dizer exatamente o que quebrou — sem precisar abrir o código.

**Exemplo correto:**
```php
public function testConfirmarQuandoPendenteTransicionaParaConfirmado(): void {}
public function testConfirmarQuandoJaConfirmadoLancaExcecao(): void {}
public function testCriarComValorNegativoLancaExcecao(): void {}
public function testCalcularTotalSemItensRetornaZero(): void {}
```

**Exemplo incorreto:**
```php
public function testConfirmar(): void {}            // vago
public function testPedido(): void {}               // não diz nada
public function testDeveConfirmarOPedido(): void {} // "deve" proibido
```

### TST-008 — Descrições curtas, máximo 100 caracteres [AVISO]

**Regra:** Se o nome do teste ultrapassar 100 caracteres, o cenário é complexo demais — dividir em testes menores ou usar contextos mais concisos.

**Verifica:** `grep -oP 'function \K(test\w+)'` em cada arquivo de teste e medir comprimento. Nenhum nome >100 caracteres.

**Por quê:** Nomes longos quebram a formatação de relatórios de CI e dificultam a leitura rápida de resultados pelo agente autônomo e pelo desenvolvedor.

**Exemplo correto:**
```php
public function testCancelarQuandoPendenteRemoveDoEstoque(): void {}
// 55 caracteres — claro e conciso
```

**Exemplo incorreto:**
```php
public function testCancelarPedidoQuandoStatusEhPendenteEUsuarioTemPermissaoDeAdminRemoveItensDoEstoqueENotificaGerente(): void {}
// 130 caracteres — dividir em testes menores
```

---

## 4. Estrutura do teste

### TST-009 — Padrão AAA: Arrange, Act, Assert [ERRO]

**Regra:** Todo teste segue três blocos separados por linha em branco: preparar (Arrange), executar (Act), verificar (Assert).

**Verifica:** Inspecionar corpo de cada teste — deve haver 3 blocos visuais separados por linha em branco. Testes one-liner ou sem separação violam.

**Por quê:** AAA torna testes legíveis por qualquer pessoa ou IA que nunca viu o código. No projeto, o agente autônomo precisa entender a intenção do teste para sugerir correções. Testes sem estrutura clara são opacos.

**Exemplo correto:**
```php
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

**Exemplo incorreto:**
```php
public function testConfirmar(): void
{
    $this->assertSame('confirmado', PedidoFactory::pendente()->confirmar()->status());
}
```

### TST-010 — Uma asserção por teste unitário [AVISO]

**Regra:** Testes unitários e de componentes devem validar um único comportamento com uma asserção. Testes de integração, API e funcionais podem ter até 3 asserções relacionadas.

**Verifica:** Contar `assert*` por método em `unitarios/` e `componentes/` — máximo 1. Em `integracao/`, `api/`, `funcionais/` — máximo 3.

**Por quê:** Uma asserção por teste torna a falha cirúrgica — quando quebra, o nome do teste diz exatamente o que falhou. Com múltiplas asserções, a primeira falha mascara as demais.

**Exemplo correto:**
```php
// unitário — uma asserção
public function testConfirmarTransicionaStatus(): void
{
    $pedido = PedidoFactory::pendente();

    $pedido->confirmar();

    $this->assertSame('confirmado', $pedido->status());
}

// integração — até 3 asserções relacionadas
public function testCriarPedidoPersisteTodosOsCampos(): void
{
    $id = $this->repository->create($pedido);

    $salvo = $this->repository->findById($id);
    $this->assertNotNull($salvo);
    $this->assertSame($pedido->totalCents(), $salvo->totalCents());
    $this->assertSame($pedido->status(), $salvo->status());
}
```

**Exemplo incorreto:**
```php
// unitário com múltiplas asserções — dividir em testes separados
public function testConfirmar(): void
{
    $pedido = PedidoFactory::pendente();
    $pedido->confirmar();

    $this->assertSame('confirmado', $pedido->status());
    $this->assertNotNull($pedido->dataConfirmacao());
    $this->assertTrue($pedido->estaConfirmado());
}
```

### TST-011 — Testar os três caminhos: feliz, inválido, limite [ERRO]

**Regra:** Todo comportamento testado deve cobrir: caminho feliz (funciona como esperado), caso inválido (rejeita entrada errada) e caso limite (comportamento na fronteira: zero, vazio, máximo).

**Verifica:** Para cada comportamento testado, confirmar que existem pelo menos 3 testes: um feliz, um inválido (exceção/rejeição) e um limite (zero/vazio/máximo).

**Por quê:** Código gerado por IA tende a cobrir apenas o caminho feliz. Os bugs reais vivem nos limites e nas entradas inválidas. Sem cobertura dos três caminhos, a rede de segurança tem buracos.

**Exemplo correto:**
```php
// Caminho feliz
public function testConfirmarQuandoPendenteTransiciona(): void {}

// Caso inválido
public function testConfirmarQuandoCanceladoLancaExcecao(): void {}

// Caso limite
public function testCalcularTotalSemItensRetornaZero(): void {}
```

**Exemplo incorreto:**
```php
// Apenas caminho feliz — sem cobertura de erro ou limite
public function testConfirmarTransiciona(): void {}
// e nada mais
```

---

## 5. Dados de teste

### TST-012 — Factories, nunca fixtures [ERRO]

**Regra:** Usar factories para criar objetos de teste. Fixtures (JSON, YAML, arquivos compartilhados) são proibidas.

**Verifica:** Buscar por `fixture`, `.json`, `.yaml` nos diretórios de teste. Buscar por classes `*Factory` — devem existir para cada entidade testada.

**Por quê:** Factories são explícitas — o teste mostra exatamente o que está construindo. Fixtures são opacas, frágeis e geram acoplamento entre testes. Na operação autônoma, o agente precisa entender o setup do teste lendo apenas o código, sem caçar arquivos externos.

**Exemplo correto:**
```php
class PedidoFactory
{
    public static function pendente(array $overrides = []): Pedido
    {
        return new Pedido(
            id: $overrides['id'] ?? 1,
            clienteId: $overrides['clienteId'] ?? 100,
            totalCents: $overrides['totalCents'] ?? 15000,
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

**Exemplo incorreto:**
```php
// fixtures/pedido.json — frágil, difícil de rastrear, compartilhada entre testes
// fixtures/pedido.yaml — mesmo problema
```

### TST-013 — Criar apenas o necessário [AVISO]

**Regra:** Cada teste deve construir estritamente o mínimo de dados para o cenário. Sem carregar objetos completos quando um parcial resolve.

**Verifica:** Inspecionar o Arrange de cada teste — objetos criados que não são usados no Act ou Assert indicam setup excessivo.

**Por quê:** Setup excessivo torna testes lentos e dificulta identificar o que realmente está sendo testado. Na operação com IA, testes inchados geram contexto desnecessário que consome tokens e reduz a qualidade da análise.

**Exemplo correto:**
```php
public function testEstaAtivoRetornaTrueQuandoStatusAtivo(): void
{
    $conta = ContaFactory::ativa();

    $this->assertTrue($conta->estaAtiva());
}
```

**Exemplo incorreto:**
```php
public function testEstaAtivo(): void
{
    $usuario = UsuarioFactory::completo();
    $conta = ContaFactory::completaComUsuario($usuario);
    $pedido1 = PedidoFactory::pendente(['contaId' => $conta->id()]);
    $pedido2 = PedidoFactory::confirmado(['contaId' => $conta->id()]);
    // ... só pra testar se a conta está ativa
}
```

### TST-014 — Sem valores soltos duplicados entre setup e asserção [ERRO]

**Regra:** Nunca repetir literais entre a construção do objeto e a verificação. Ler o valor do objeto, não de strings ou números duplicados.

**Verifica:** Comparar literais no Arrange com literais no Assert. Se o mesmo valor aparece nos dois blocos, o assert deve ler do objeto, não repetir o literal.

**Por quê:** Valores duplicados criam testes que passam por coincidência. Quando o valor muda no setup, o teste continua passando com o literal antigo na asserção. Bugs reais escapam.

**Exemplo correto:**
```php
public function testCriarPedidoPersiste(): void
{
    $pedido = PedidoFactory::pendente(['totalCents' => 5000]);

    $id = $this->repository->create($pedido);
    $salvo = $this->repository->findById($id);

    $this->assertSame($pedido->totalCents(), $salvo->totalCents());
}
```

**Exemplo incorreto:**
```php
public function testCriarPedidoPersiste(): void
{
    $pedido = PedidoFactory::pendente(['totalCents' => 5000]);

    $id = $this->repository->create($pedido);
    $salvo = $this->repository->findById($id);

    $this->assertSame(5000, $salvo->totalCents()); // 5000 repetido
}
```

---

## 6. Isolamento por camada

### TST-015 — Testes unitários: sem dependência externa [ERRO]

**Regra:** Testes unitários trabalham com objetos em memória. Sem banco, sem rede, sem filesystem, sem framework. Testam entidades e Value Objects puros.

**Verifica:** Em `unitarios/`, buscar por `$wpdb`, `$this->repository`, `file_get_contents`, `curl`, `$this->db`. Qualquer ocorrência é violação.

**Por quê:** Unitários devem rodar em milissegundos. São executados a cada commit pelo agente autônomo. Qualquer dependência externa torna a suite lenta e frágil, comprometendo o ciclo de feedback rápido que a operação 24/7 exige.

**Exemplo correto:**
```php
// unitário puro — sem dependência externa
public function testConfirmarQuandoPendenteTransiciona(): void
{
    $pedido = PedidoFactory::pendente();

    $pedido->confirmar();

    $this->assertSame('confirmado', $pedido->status());
}
```

**Exemplo incorreto:**
```php
// "unitário" que acessa banco — não é unitário
public function testConfirmarPedido(): void
{
    $pedido = $this->repository->findById(1); // acessa banco
    $pedido->confirmar();
    $this->repository->update($pedido);       // acessa banco de novo
}
```

### TST-016 — Testes de componentes: mocks de dependências [ERRO]

**Regra:** Testes de componentes isolam o sujeito mockando suas dependências (repositórios, serviços externos). Testam orquestração sem tocar infraestrutura.

**Verifica:** Em `componentes/`, confirmar que dependências são `createMock()` e que nenhum acesso real a banco/rede existe.

**Por quê:** Componentes validam que a lógica de orquestração funciona — que os métodos certos são chamados na ordem certa. Sem mocks, o teste vira integração disfarçada, mais lento e mais frágil.

**Exemplo correto:**
```php
public function testConfirmarPedidoAtualizaRepositorio(): void
{
    $repository = $this->createMock(PedidoRepository::class);
    $repository->expects($this->once())
        ->method('findById')
        ->willReturn(PedidoFactory::pendente());
    $repository->expects($this->once())
        ->method('update');

    $service = new PedidoService($repository);

    $service->confirmarPedido(1);
}
```

**Exemplo incorreto:**
```php
// "componente" que acessa banco real — deveria ser integração
public function testConfirmarPedido(): void
{
    $service = new PedidoService($this->realRepository);
    $service->confirmarPedido(1);
}
```

### TST-017 — Testes de integração: infraestrutura real, sem mocks [ERRO]

**Regra:** Testes de integração usam infraestrutura real (banco de dados, serviços externos). Testam repositórios, persistência e integrações de ponta a ponta. Sem mocks da camada de dados.

**Verifica:** Em `integracao/`, buscar por `createMock` de repositórios ou classes de banco. Qualquer mock de persistência é violação.

**Por quê:** A única forma de garantir que a persistência funciona é testá-la contra o banco real. Mocks de banco escondem bugs de SQL, mapeamento e criptografia que só aparecem em produção — quando já é tarde demais.

**Exemplo correto:**
```php
public function testCriarPedidoPersiste(): void
{
    $pedido = PedidoFactory::pendente(['totalCents' => 5000]);

    $id = $this->repository->create($pedido);
    $salvo = $this->repository->findById($id);

    $this->assertSame($pedido->totalCents(), $salvo->totalCents());
}
```

**Exemplo incorreto:**
```php
// "integração" que mocka o banco — não testa nada real
public function testCriarPedido(): void
{
    $db = $this->createMock(Database::class);
    $db->method('insert')->willReturn(1);
    // mock não valida SQL, não valida schema, não valida nada
}
```

### TST-018 — Testes de API: request/response completo [ERRO]

**Regra:** Testes de API simulam requisições HTTP completas, incluindo autenticação, autorização e payload. Testam endpoints como caixa preta: entrada completa, saída verificada.

**Verifica:** Em `api/`, confirmar que cada teste monta request HTTP completo (método, path, headers) e verifica status code + body.

**Por quê:** Endpoints são a fronteira do sistema — onde dados externos entram. Na operação autônoma, o agente gera endpoints que devem rejeitar requisições inválidas sem supervisão humana. Testes de API validam esse contrato.

**Exemplo correto:**
```php
public function testConfirmarPedidoSemAutenticacaoRetorna401(): void
{
    // Arrange — requisição sem token/nonce
    $request = new Request('POST', '/pedidos/1/confirmar');

    // Act
    $response = $this->app->handle($request);

    // Assert
    $this->assertSame(401, $response->getStatusCode());
}

public function testConfirmarPedidoComDadosValidosRetornaSucesso(): void
{
    // Arrange — requisição autenticada
    $request = new Request('POST', '/pedidos/1/confirmar', [
        'Authorization' => 'Bearer ' . $this->validToken,
    ]);

    // Act
    $response = $this->app->handle($request);

    // Assert
    $this->assertSame(200, $response->getStatusCode());
}
```

**Exemplo incorreto:**
```php
// Testa endpoint sem autenticação — não valida segurança
public function testConfirmarPedido(): void
{
    $response = $this->endpoint->confirmar(1);
    $this->assertTrue($response['success']);
}
```

### TST-019 — Testes funcionais: aplicação carregada, fluxo end-to-end [ERRO]

**Regra:** Testes funcionais carregam a aplicação completa e verificam que páginas renderizam, assets são carregados e fluxos end-to-end funcionam como esperado.

**Verifica:** Em `funcionais/`, confirmar que a aplicação é carregada via client HTTP real e que asserts verificam status + conteúdo renderizado.

**Por quê:** Testes funcionais são a última linha de defesa. Validam que todas as camadas funcionam juntas. No projeto, com deploys frequentes e operação autônoma, esses testes garantem que nenhuma integração entre camadas quebrou silenciosamente.

**Exemplo correto:**
```php
public function testPaginaPrincipalRenderizaComAssetsCorretos(): void
{
    $response = $this->client->get('/');

    $this->assertSame(200, $response->getStatusCode());
    $this->assertStringContainsString('<link', $response->getBody());
    $this->assertStringContainsString('<script', $response->getBody());
}

public function testFluxoCompletoDeCadastro(): void
{
    // cadastro
    $response = $this->client->post('/cadastro', $dadosValidos);
    $this->assertSame(302, $response->getStatusCode());

    // login
    $response = $this->client->post('/login', $credenciais);
    $this->assertSame(200, $response->getStatusCode());
}
```

**Exemplo incorreto:**
```php
// "funcional" que não carrega a aplicação — é teste de unidade disfarçado
public function testPaginaPrincipal(): void
{
    $html = file_get_contents('templates/index.html');
    $this->assertStringContainsString('titulo', $html);
}
```

### TST-020 — Mockar dependências externas, nunca o sujeito [ERRO]

**Regra:** Mocks devem ser usados apenas nas dependências que não são responsabilidade do teste. Nunca mockar o objeto que está sendo testado.

**Verifica:** Em cada teste com `createMock`, verificar que a classe mockada nunca é a mesma que o sujeito sob teste (a instanciada com `new`).

**Por quê:** Mockar o sujeito é auto-engano — o teste não valida comportamento real, apenas confirma que o mock retorna o que foi programado para retornar. Na operação autônoma, isso gera falsa confiança: o CI passa verde, mas o código real está quebrado.

**Exemplo correto:**
```php
// mock da dependência (repositório)
public function testConfirmarPedidoAtualizaRepositorio(): void
{
    $repository = $this->createMock(PedidoRepository::class);
    $repository->expects($this->once())->method('update');

    $service = new PedidoService($repository);
    $service->confirmarPedido(1);
}
```

**Exemplo incorreto:**
```php
// mock do sujeito — não testa nada real
public function testPedido(): void
{
    $pedido = $this->createMock(Pedido::class);
    $pedido->method('estaConfirmado')->willReturn(true);
    $this->assertTrue($pedido->estaConfirmado()); // testou o mock, não o Pedido
}
```

### TST-021 — Sem dependência de estado externo [ERRO]

**Regra:** Testes nunca dependem de variáveis de ambiente, hora do sistema, arquivos em disco ou estado de outros testes. Cada teste é autossuficiente.

**Verifica:** Buscar por `getenv`, `$_ENV`, `$_SERVER`, `file_get_contents` sem mock, `new DateTimeImmutable()` sem argumento nos testes. Qualquer uso direto é violação.

**Por quê:** O agente autônomo roda testes em horários diferentes, em ambientes diferentes, em ordem aleatória. Testes que dependem de estado externo falham intermitentemente, gerando ruído que impede o agente de distinguir falha real de falha ambiental.

**Exemplo correto:**
```php
// tempo controlado — injetado explicitamente
public function testPedidoVencidoQuandoDataPassou(): void
{
    $dataPassada = new DateTimeImmutable('2025-01-01');
    $pedido = PedidoFactory::pendente(['dataVencimento' => $dataPassada]);

    $this->assertTrue($pedido->estaVencido(new DateTimeImmutable('2026-04-08')));
}
```

**Exemplo incorreto:**
```php
// depende do relógio real — quebra dependendo do dia
public function testPedidoVencido(): void
{
    $pedido = PedidoFactory::pendente(['dataVencimento' => new DateTimeImmutable('yesterday')]);
    $this->assertTrue($pedido->estaVencido()); // flaky
}
```

---

## 7. Determinismo

### TST-022 — Testes são determinísticos [ERRO]

**Regra:** O mesmo teste rodando 100 vezes deve produzir o mesmo resultado. Proibido usar funções não-determinísticas sem controle: `time()`, `rand()`, `uniqid()`, `new DateTimeImmutable()` sem argumento, `Date.now()`, `Math.random()`.

**Verifica:** Buscar por `time()`, `rand(`, `random_int(`, `uniqid(`, `Date.now()`, `Math.random()`, `new DateTimeImmutable()` (sem argumento) nos arquivos de teste.

**Por quê:** Testes flaky são piores que testes ausentes. Na operação 24/7, um teste intermitente paralisa o pipeline — o agente não sabe se é bug real ou falha espúria e não pode tomar decisão autônoma.

**Exemplo correto:**
```php
$agora = new DateTimeImmutable('2026-04-08 10:00:00');
$id = 42;
```

**Exemplo incorreto:**
```php
$agora = new DateTimeImmutable(); // muda a cada execução
$id = random_int(1, 1000);       // não determinístico
```

### TST-023 — Ordem de execução não importa [ERRO]

**Regra:** Nenhum teste depende de outro teste ter rodado antes. Cada teste prepara seu próprio estado e limpa depois se necessário.

**Verifica:** Buscar por referências a IDs fixos ou dados criados em outros métodos de teste. Cada teste deve criar seus próprios dados no Arrange.

**Por quê:** Frameworks de teste podem executar em ordem aleatória (PHPUnit `--random-order`, pytest `--randomly`, Jest `--randomize`). Dependência de ordem gera falhas fantasma que consomem horas de investigação.

**Exemplo correto:**
```php
public function testCriarPedido(): void
{
    // cria seu próprio estado
    $pedido = PedidoFactory::pendente();
    $id = $this->repository->create($pedido);
    $this->assertNotNull($id);
}

public function testBuscarPedido(): void
{
    // cria seu próprio estado — não depende de testCriarPedido
    $pedido = PedidoFactory::pendente();
    $id = $this->repository->create($pedido);

    $salvo = $this->repository->findById($id);
    $this->assertNotNull($salvo);
}
```

**Exemplo incorreto:**
```php
// testBuscarPedido assume que testCriarPedido já rodou e criou ID 1
public function testBuscarPedido(): void
{
    $salvo = $this->repository->findById(1); // depende do teste anterior
    $this->assertNotNull($salvo);
}
```

---

## 8. Cobertura por camada

### TST-024 — Unitários: entidades cobrem FSM completa [ERRO]

**Regra:** Toda entidade com máquina de estados deve ter testes unitários para: cada transição válida, cada transição inválida (lança exceção), cada predicado de estado, construção com parâmetros válidos e inválidos, e métodos de serialização/hidratação.

**Verifica:** Para cada entidade com FSM, listar transições do diagrama de estados e confirmar que existem testes para cada transição válida + cada transição inválida + predicados.

**Por quê:** Entidades são o coração do domínio. No projeto, IA gera código que manipula entidades — se a FSM não está 100% coberta, uma transição inválida pode corromper dados sem que ninguém perceba até o cliente reclamar.

**Exemplo correto:**
```php
// Cobertura mínima para entidade com FSM
public function testCriarPedidoPendente(): void {}
public function testConfirmarQuandoPendenteTransiciona(): void {}
public function testConfirmarQuandoCanceladoLancaExcecao(): void {}
public function testCancelarQuandoPendenteTransiciona(): void {}
public function testCancelarQuandoJaCanceladoLancaExcecao(): void {}
public function testEstaConfirmadoRetornaTrueQuandoConfirmado(): void {}
public function testEstaPendenteRetornaTrueQuandoPendente(): void {}
public function testPodeTransicionarParaConfirmadoQuandoPendente(): void {}
public function testNaoPodeTransicionarParaConfirmadoQuandoCancelado(): void {}
public function testFromRowComDadosLimposHidrataCorretamente(): void {}
public function testFromRowComDadosSujosNaoExplode(): void {}
public function testToArrayRetornaTodosOsCampos(): void {}
```

**Exemplo incorreto:**
```php
// Apenas caminho feliz — FSM parcialmente coberta
public function testConfirmar(): void {}
public function testCancelar(): void {}
// faltam: transições inválidas, predicados, from_row, to_array
```

### TST-025 — Componentes: services cobrem orquestração [ERRO]

**Regra:** Services/gerenciadores devem ter testes de componentes com mocks de repositórios, verificando: chamadas corretas aos métodos do repositório, exceção quando entidade não encontrada, e delegação de lógica de domínio para a entidade.

**Verifica:** Para cada service, confirmar testes com `expects($this->once())->method(...)` no repo mockado + teste de `EntityNotFoundException` quando `findById` retorna null.

**Por quê:** Services são a cola entre domínio e infraestrutura. Se a orquestração falha, dados corretos não são persistidos ou exceções não são tratadas. Na operação autônoma, falha silenciosa de orquestração é a categoria de bug mais difícil de diagnosticar.

**Exemplo correto:**
```php
public function testConfirmarPedidoChamaUpdateNoRepositorio(): void
{
    $repository = $this->createMock(PedidoRepository::class);
    $repository->method('findById')->willReturn(PedidoFactory::pendente());
    $repository->expects($this->once())->method('update');

    $service = new PedidoService($repository);
    $service->confirmarPedido(1);
}

public function testConfirmarPedidoInexistenteLancaExcecao(): void
{
    $repository = $this->createMock(PedidoRepository::class);
    $repository->method('findById')->willReturn(null);

    $service = new PedidoService($repository);

    $this->expectException(EntityNotFoundException::class);
    $service->confirmarPedido(999);
}
```

**Exemplo incorreto:**
```php
// Testa service sem verificar interação com repositório
public function testConfirmarPedido(): void
{
    $service = new PedidoService($this->realRepository);
    $service->confirmarPedido(1);
    // sem asserção sobre o que o repositório recebeu
}
```

### TST-026 — Integração: repositórios cobrem CRUD completo [ERRO]

**Regra:** Todo repositório deve ter testes de integração para: `create()` persiste e retorna ID, `findById()` retorna entidade correta, `findById()` retorna null quando não existe, `update()` persiste alterações, `delete()` remove registro.

**Verifica:** Para cada repositório, confirmar que existem testes para os 5 métodos CRUD (create, findById sucesso, findById null, update, delete).

**Por quê:** Repositórios são a fronteira com o banco de dados. Erros de SQL, mapeamento ou encoding só aparecem com banco real. No projeto, dados financeiros e pessoais passam por repositórios — qualquer falha de persistência pode corromper dados críticos.

**Exemplo correto:**
```php
public function testCreatePersisteERetornaId(): void
{
    $pedido = PedidoFactory::pendente();
    $id = $this->repository->create($pedido);
    $this->assertIsInt($id);
    $this->assertGreaterThan(0, $id);
}

public function testFindByIdRetornaNullQuandoNaoExiste(): void
{
    $resultado = $this->repository->findById(999999);
    $this->assertNull($resultado);
}
```

**Exemplo incorreto:**
```php
// Apenas testa create, ignora find/update/delete
public function testCreate(): void
{
    $id = $this->repository->create(PedidoFactory::pendente());
    $this->assertNotNull($id);
}
```

### TST-027 — API: endpoints cobrem segurança e contrato [ERRO]

**Regra:** Todo endpoint deve ter testes de API para: requisição sem autenticação é rejeitada, requisição com permissão inválida é rejeitada, requisição com dados faltando retorna erro, requisição válida retorna sucesso, exceções do service são capturadas e retornadas como erro.

**Verifica:** Para cada endpoint, confirmar 5 testes mínimos: sem auth (401/403), role inválida (403), dados faltando (400/422), sucesso (200/201), exceção do service (500/erro).

**Por quê:** Endpoints são a porta de entrada do sistema. Na operação autônoma, o agente gera endpoints que devem ser seguros por padrão. Se testes de API não cobrem autenticação e autorização, falhas de segurança passam despercebidas.

**Exemplo correto:**
```php
public function testEndpointSemAutenticacaoRetornaErro(): void {}
public function testEndpointComRoleInvalidaRetornaForbidden(): void {}
public function testEndpointComDadosFaltandoRetornaValidationError(): void {}
public function testEndpointComDadosValidosRetornaSucesso(): void {}
public function testEndpointQuandoServiceLancaExcecaoRetornaErro(): void {}
```

**Exemplo incorreto:**
```php
// Apenas caminho feliz — segurança não testada
public function testEndpointRetornaSucesso(): void
{
    $response = $this->endpoint->handle($dadosValidos);
    $this->assertTrue($response['success']);
}
```

### TST-028 — Funcionais: fluxos críticos e renderização [AVISO]

**Regra:** Testes funcionais devem cobrir: página carrega sem erro (HTTP 200), assets essenciais estão carregados, seções obrigatórias renderizam, fluxos end-to-end críticos.

**Verifica:** Em `funcionais/`, confirmar pelo menos: teste de status 200 da home, teste de presença de `<link>`/`<script>`, teste de fluxo crítico de negócio (se aplicável).

**Por quê:** Testes funcionais são caros e devem ser seletivos — cobrem caminhos críticos, não cada variação. No projeto, validam que o sistema funciona de ponta a ponta após deploys automatizados.

**Exemplo correto:**
```php
public function testPaginaPrincipalCarrega(): void
{
    $response = $this->client->get('/');
    $this->assertSame(200, $response->getStatusCode());
}

public function testFluxoCriticoDeCompra(): void
{
    // cadastro → login → adicionar ao carrinho → checkout
    // teste seletivo de fluxo que gera receita
}
```

**Exemplo incorreto:**
```php
// 50 testes funcionais testando cada variação de formulário
// — deveria ser unitário/componente, não funcional
```

---

## 9. Antipadrões

### TST-029 — Sem hooks complexos nem estado compartilhado [AVISO]

**Regra:** Evitar `setUp()` / `beforeEach()` complexos que constroem estado compartilhado entre testes. Se o setup tem mais de 5 linhas, provavelmente o teste precisa de factory.

**Verifica:** Contar linhas de `setUp()` / `beforeEach()` em cada classe de teste. Mais de 5 linhas é violação.

**Por quê:** Estado compartilhado entre testes cria acoplamento invisível. Quando o agente autônomo modifica um teste, o setup compartilhado pode quebrar outros testes sem relação óbvia — gerando cascatas de falhas que paralisam o pipeline.

**Exemplo correto:**
```php
public function testConfirmarPedido(): void
{
    $pedido = PedidoFactory::pendente(); // factory no teste

    $pedido->confirmar();

    $this->assertSame('confirmado', $pedido->status());
}
```

**Exemplo incorreto:**
```php
// setUp com 15 linhas construindo estado global
protected function setUp(): void
{
    $this->usuario = UsuarioFactory::admin();
    $this->conta = ContaFactory::ativa(['userId' => $this->usuario->id()]);
    $this->pedido = PedidoFactory::pendente(['contaId' => $this->conta->id()]);
    $this->repository = new PedidoRepository($this->db);
    $this->service = new PedidoService($this->repository);
    $this->id = $this->repository->create($this->pedido);
    // ... cada teste usa parte desse estado, nenhum usa tudo
}
```

### TST-030 — Sem testes que testam o framework [ERRO]

**Regra:** Nunca testar se funções nativas da linguagem ou do framework funcionam. Testar exclusivamente o código do projeto.

**Verifica:** Inspecionar asserts — se o sujeito do assert é uma função nativa (`json_encode`, `array_map`, método do ORM) sem lógica de projeto envolvida, é violação.

**Por quê:** Testar o framework é desperdício de CI. Na operação 24/7, cada segundo de CI conta. Testes que validam `json_encode()`, `array_map()` ou métodos nativos do ORM consomem recursos sem agregar proteção ao código do projeto.

**Exemplo correto:**
```php
// Testa lógica do projeto
public function testCalcularDescontoAplicaPorcentagem(): void
{
    $pedido = PedidoFactory::pendente(['totalCents' => 10000]);

    $pedido->aplicarDesconto(10); // 10%

    $this->assertSame(9000, $pedido->totalCents());
}
```

**Exemplo incorreto:**
```php
// Testa o PHP, não nosso código
public function testJsonEncodeRetornaString(): void
{
    $this->assertIsString(json_encode(['a' => 1]));
}
```

### TST-031 — Sem testes fantasiosos [ERRO]

**Regra:** Nunca testar cenários impossíveis ou extremamente improváveis que nunca acontecem em uso real. Testes existem para validar comportamento de produção.

**Verifica:** Para cada teste, confirmar que o cenário descrito no nome é plausível em uso real. Valores absurdos (bilhões, IDs negativos) sem justificativa de negócio são violação.

**Por quê:** Testes fantasiosos consomem tempo de escrita, tempo de CI e atenção de review — sem proteger contra nenhum cenário real. Na operação autônoma, o agente pode gerar testes desnecessários se não tiver essa restrição explícita.

**Exemplo correto:**
```php
// cenário real — valor máximo suportado pelo sistema
public function testPedidoComValorMaximoPermitido(): void
{
    $pedido = PedidoFactory::pendente(['totalCents' => 99999999]); // R$ 999.999,99
    $this->assertSame(99999999, $pedido->totalCents());
}
```

**Exemplo incorreto:**
```php
// cenário fantasioso — nunca vai acontecer
public function testPedidoComBilhaoDeReais(): void
{
    $pedido = PedidoFactory::pendente(['totalCents' => 100000000000000]);
    // ... nunca vai acontecer no sistema
}
```

---

## 10. Documentação e versionamento

### TST-032 — Comentários em testes explicam o porquê, não o quê [AVISO]

**Regra:** Comentários em testes são permitidos apenas para explicar por que um cenário específico é testado (ex.: regressão de bug). O nome do teste deve ser suficiente para explicar o quê.

**Verifica:** Inspecionar comentários nos testes. Comentários que descrevem o que o código faz (em vez de por que) são violação. Comentários de regressão com referência a bug/PR são aceitos.

**Por quê:** Testes bem nomeados (TST-007) são auto-documentados. Comentários que repetem o que o código faz são ruído. Comentários que explicam a motivação (ex.: "Bug #142 — desconto negativo passava pela validação") agregam contexto que o nome não comporta.

**Exemplo correto:**
```php
// Regressão: Bug #142 — desconto negativo era aplicado sem validação
public function testAplicarDescontoNegativoLancaExcecao(): void
{
    $pedido = PedidoFactory::confirmado();

    $this->expectException(DomainException::class);
    $pedido->aplicarDesconto(-500);
}
```

**Exemplo incorreto:**
```php
// Testa se o desconto negativo lança exceção  ← repete o nome do teste
public function testAplicarDescontoNegativoLancaExcecao(): void
{
    // cria um pedido confirmado  ← descreve o óbvio
    $pedido = PedidoFactory::confirmado();
    // espera exceção  ← descreve o óbvio
    $this->expectException(DomainException::class);
    $pedido->aplicarDesconto(-500);
}
```

### TST-033 — Teste de hidratação prova nome real de coluna [ERRO]

**Regra:** Toda entidade que tenha método de hidratação (`from_row()`, `fromArray()`, `from_db()`, etc.) deve ter teste que prove que **cada campo lido bate com o nome real da coluna no schema**. O teste de hidratação seeda o array/objeto de origem usando **literalmente** o nome da coluna canônica e verifica que o getter da entidade retorna o valor seedado. Quando o nome interno PHP for diferente do nome da coluna SQL (ex: `$score100` propriedade ↔ `score_100` coluna), adicionar teste **sentinel** que seeda o nome ERRADO e espera o valor default — se alguém regredir pro nome errado, o teste falha.

**Verifica:** Para cada entidade com `from_row`/`fromArray`, confirmar: (1) teste com seed usando nome canônico da coluna SQL, (2) teste sentinel seedando nome PHP errado e esperando default, para cada campo onde camelCase != snake_case.

**Por quê:** Bugs de mismatch entre nome de propriedade PHP e nome de coluna SQL passam silenciosos quando bug e teste compartilham o mesmo erro. Um incidente real mostrou isso na prática: um método `from_row()` lia `$row->score100` em vez de `$row->score_100`, e o teste seedava `'score100'` (chave errada) — tanto o bug quanto o teste tinham o mesmo defeito, então o CI ficava verde enquanto a produção retornava `score_100 = 0` em todas as competências por 2 dias. Origem: um PR com batch automático adicionando `from_row()` em 33 entidades sem cruzar nomes com schema. A regra existe pra fechar esse buraco.

**Exemplo correto:**
```php
#[Test]
public function from_row_le_score_100_com_underscore_da_coluna_real(): void
{
    // Seed usa LITERALMENTE o nome da coluna do schema (snake_case)
    $row = (object) [
        'id'        => 1,
        'score_100' => 75.5,  // ← nome canônico da coluna
        // ...
    ];

    $entity = ResultadoCompetencia::from_row($row);

    self::assertSame(75.5, $entity->score_100());
}

#[Test]
public function from_row_ignora_propriedade_score100_sem_underscore(): void
{
    // Sentinel anti-regressão: seeda o nome ERRADO (camelCase),
    // espera default. Se alguém voltar pra `$row->score100`, falha.
    $row = (object) [
        'id'       => 1,
        'score100' => 99.9,  // ← chave errada, deve ser ignorada
        // ...
    ];

    $entity = ResultadoCompetencia::from_row($row);

    self::assertSame(0.0, $entity->score_100());  // default, não 99.9
}
```

**Exemplo incorreto:**
```php
#[Test]
public function from_row_hidrata_corretamente(): void
{
    // ❌ seed usa nome de propriedade interna PHP (camelCase),
    //    mesma string que o `from_row` lê — bug e teste batem
    //    por coincidência sem nunca exercitar o caminho real
    $row = (object) [
        'id'       => 1,
        'score100' => 75.5,
    ];

    $entity = ResultadoCompetencia::from_row($row);
    self::assertSame(75.5, $entity->score_100());
    // CI verde, mas produção retorna 0.0 porque a coluna real é `score_100`
}
```

**Cobertura mínima por entidade com hidratação:**
1. **Caminho feliz** — seed com nome canônico de cada campo, asserção sobre cada getter (pelo menos os campos críticos: identidade, valores numéricos, status)
2. **Sentinel anti-regressão** — pra cada campo onde nome PHP camelCase ≠ coluna SQL snake_case, um teste que seeda o nome errado e espera default
3. **Tolerância a dados sujos** (TST-024 + Lição #7) — `from_row_com_dados_sujos_nao_explode` seedando string em campo numérico, valor inválido em enum, etc.

Mitigação automática complementar: teste estático que varre todos os `from_row()` do projeto e cruza `$row->XYZ` com schema das migrations SQL — se a coluna não existir na tabela alvo, falha. Esse teste é PR follow-up rastreado no incidente 0008.

**Sinal de alerta:** PR que adiciona/modifica `from_row()` em batch (>5 entidades) sem teste que exercite o caminho real de cada coluna; teste de hidratação cujo seed usa nome de propriedade interna PHP em vez de coluna SQL.

---

## Definition of Done — Checklist de entrega

> PR que não cumpre o DoD não entra em review. É devolvido.

| # | Item | Regras | Verificação |
|---|------|--------|-------------|
| 1 | Testes estão na camada correta da pirâmide | TST-001, TST-002 | Inspecionar diretório de cada teste |
| 2 | Nomes descrevem comportamento com contexto | TST-007, TST-008 | Inspecionar nomes dos métodos de teste |
| 3 | Padrão AAA respeitado em todos os testes | TST-009 | Inspecionar estrutura de cada teste |
| 4 | Três caminhos cobertos: feliz, inválido, limite | TST-011 | Verificar existência dos três tipos por comportamento |
| 5 | Factories usadas, sem fixtures | TST-012 | Buscar por `fixture`, `json`, `yaml` nos testes |
| 6 | Sem valores soltos duplicados | TST-014 | Comparar setup vs. asserção em cada teste |
| 7 | Unitários sem dependência externa | TST-015 | Buscar por acesso a banco, rede ou filesystem em `unitarios/` |
| 8 | Mocks apenas em dependências, nunca no sujeito | TST-020 | Inspecionar `createMock` — sujeito nunca é mockado |
| 9 | Testes determinísticos | TST-022, TST-023 | Buscar por `time()`, `rand()`, `Date.now()`, `DateTimeImmutable()` sem argumento |
| 10 | Entidades com FSM cobrem todos os estados | TST-024 | Verificar cobertura de transições válidas + inválidas |
| 11 | Endpoints cobrem segurança | TST-027 | Verificar testes de autenticação e autorização |
| 12 | Todo código novo tem teste | TST-005 | Comparar arquivos de código vs. arquivos de teste no PR |
| 13 | Bug corrigido tem teste de regressão | TST-004 | Verificar se PR de fix inclui teste que reproduz o bug |
| 14 | Sem testes que testam o framework | TST-030 | Inspecionar asserções — devem testar código do projeto |
| 15 | Sem testes fantasiosos | TST-031 | Inspecionar cenários — devem refletir uso real |
| 16 | Hidratação prova nome real de coluna | TST-033 | Inspecionar testes de `from_row()` — seed usa coluna SQL canônica + sentinel anti-regressão para campos camelCase |
