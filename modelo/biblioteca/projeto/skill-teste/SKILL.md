---
name: skill-teste
description: Skill de criacao de testes para projetos. Analisa codigo implementado, identifica lacunas de cobertura e cria testes seguindo a piramide de 5 camadas. Trigger manual apenas.
---

# /skill-teste — Criadora de testes

Analisa o codigo implementado no projeto, identifica lacunas de cobertura e cria testes seguindo a piramide de 5 camadas (unitarios, componentes, integracao, API, funcionais). Garante cobertura completa de FSM, CRUD, seguranca e fluxos criticos.

## Quando usar

- Apos implementacao de codigo novo (complementa a `skill-executora`).
- Quando o usuario pedir para criar testes para um modulo especifico.
- Quando uma auditoria de testes (`/auditar-testes`) encontrar lacunas.
- **Nunca** disparar automaticamente.

## Processo

### Fase 1 — Analisar o codigo alvo

1. Ler o codigo que precisa de testes.
2. Identificar a camada correta na piramide:
   - **Entidade/Value Object** -> testes unitarios
   - **Gerenciador** -> testes de componentes (com mocks)
   - **Repositorio** -> testes de integracao (com banco real)
   - **Handler** -> testes de API (request/response)
   - **Pagina/template** -> testes funcionais
3. Consultar `docs/padroes-testes.md` para as regras de cada camada.

### Fase 2 — Planejar cobertura

Para cada classe/modulo, listar os testes necessarios:

**Entidades com FSM:**
- [ ] Cada transicao valida
- [ ] Cada transicao invalida (lanca excecao)
- [ ] Cada predicado de estado
- [ ] Construcao com parametros validos
- [ ] Construcao com parametros invalidos
- [ ] `fromRow()` com dados limpos
- [ ] `fromRow()` com dados sujos (nao explode)
- [ ] `toArray()` retorna todos os campos

**Gerenciadores:**
- [ ] Chama metodos corretos do repositorio
- [ ] Lanca excecao quando entidade nao encontrada
- [ ] Delega logica de dominio para a entidade

**Repositorios:**
- [ ] `create()` persiste e retorna ID
- [ ] `findById()` retorna entidade correta
- [ ] `findById()` retorna null quando nao existe
- [ ] `update()` persiste alteracoes
- [ ] `delete()` remove registro
- [ ] Dados criptografados sao descriptografados na leitura

**Handlers:**
- [ ] Requisicao sem autenticacao e rejeitada
- [ ] Requisicao com role invalida e rejeitada
- [ ] Requisicao com dados faltando retorna erro
- [ ] Requisicao valida retorna sucesso
- [ ] Excecoes do gerenciador sao capturadas

### Fase 3 — Implementar testes

1. Criar factories quando necessario.
2. Implementar cada teste seguindo padrao AAA (Arrange, Act, Assert).
3. Nomear testes no padrao: `test` + acao + contexto + resultado.
4. Garantir que cada teste e deterministico e isolado.
5. Uma assercao por teste unitario/componente. Ate 3 em integracao/API/funcional.

### Fase 4 — Validar

1. Rodar a suite de testes:
   ```bash
   composer test
   ```
2. Verificar que todos passam.
3. Verificar que nenhum teste e SKIPPED (skipped nao e verde).
4. Apresentar resultado ao usuario.

## Regras

- **Tres caminhos obrigatorios.** Todo comportamento testado cobre: feliz, invalido, limite.
- **Factories, nunca fixtures.** Usar factories para criar objetos de teste.
- **Dados minimos.** Cada teste constroi estritamente o minimo necessario.
- **Sem valores duplicados.** Nunca repetir literais entre setup e assercao. Ler do objeto.
- **Testes simulam condicoes reais.** Nao testar cenarios inventados.
- **Sem testes fantasiosos.** Nao testar cenarios impossiveis.
- **Sem testes que testam o framework.** Testar nosso codigo, nao o do PHP.
- **Deterministico.** Sem time(), rand(), DateTimeImmutable sem argumento.
- **Isolado.** Sem dependencia de estado externo ou de outros testes.
- **Camada correta.** Teste que acessa banco nao e unitario. Teste que mocka tudo nao e integracao.
