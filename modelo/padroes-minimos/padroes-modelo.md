# Modelo de Documento de Padrões — sua organização

> Este arquivo é um **modelo estrutural**. Ele não contém regras reais.
> Serve como guia obrigatório para a criação de qualquer documento `padroes-*.md`
> dentro da organização.
>
> **Para o Claude Code:** ao criar um novo documento de padrões, leia este modelo
> inteiro antes de escrever qualquer coisa. Siga a estrutura, o formato e as
> orientações exatamente como descritos. Conduza uma entrevista com o usuário
> para preencher o conteúdo — nunca invente regras sem validação.

---

## Como usar este modelo

### Se você é o Claude Code

1. Leia este modelo completo.
2. Identifique qual domínio o usuário quer padronizar.
3. Conduza a entrevista descrita na seção "Processo de criação".
4. Gere o documento seguindo a estrutura obrigatória.
5. Mostre o resultado para aprovação antes de salvar.

### Se você é um desenvolvedor

1. Leia o documento de padrões do domínio que afeta seu trabalho.
2. Use os IDs das regras para referenciar em PRs e code reviews.
3. Consulte o DoD antes de abrir qualquer Pull Request.

### Se você é um auditor (humano ou IA)

1. Leia o frontmatter para entender escopo e dependências.
2. Audite o código contra cada regra por ID.
3. Classifique violações pela severidade definida no documento.
4. Referencie violações pelo ID da regra (ex.: "viola PHP-038").

---

## Processo de criação de um novo documento de padrões

Quando o usuário pedir para criar um novo `padroes-*.md`, o Claude Code deve
conduzir uma entrevista estruturada antes de escrever. Nunca gerar regras
sem validação do usuário.

### Fase 1 — Entender o domínio

Perguntas obrigatórias:

1. **Qual o domínio?** (ex.: PHP, JavaScript, CSS, banco de dados, infraestrutura)
2. **Quais projetos do projeto esse padrão cobre?** (todos, ou específicos?)
3. **Já existe código em produção nesse domínio?** Se sim, quais os padrões
   que já estão sendo seguidos na prática?
4. **Existe documentação de referência externa?** (PSR, OWASP, MDN, WordPress Codex, etc.)

### Fase 2 — Identificar o que é inegociável

Perguntas obrigatórias:

5. **O que já causou problema em produção?** Incidentes, bugs, fatais, dados
   corrompidos — essas viram regras ERRO automaticamente.
6. **O que é crítico por natureza do negócio?** (ex.: dados financeiros,
   dados pessoais, autenticação)
7. **Quais práticas o time já rejeitou em code review?** Padrões implícitos
   que precisam virar regras explícitas.

### Fase 3 — Definir o nível de exigência

Perguntas obrigatórias:

8. **Esse padrão é pra time experiente ou pra onboarding?** Define a
   profundidade das explicações e exemplos.
9. **Quais regras são bloqueantes (ERRO) e quais são recomendações (AVISO)?**
   O usuário define a severidade, não o Claude.
10. **Existe alguma exceção conhecida?** Casos onde uma regra não se aplica
    devem ser documentados na própria regra.

### Fase 4 — Gerar e validar

11. Gerar o documento seguindo a estrutura obrigatória abaixo.
12. Mostrar o documento completo para o usuário.
13. Aguardar aprovação ou ajustes.
14. Salvar somente após aprovação explícita.

---

## Estrutura obrigatória do documento

Todo documento `padroes-*.md` do projeto deve seguir exatamente esta estrutura.
Seções podem ser adicionadas, mas nenhuma das obrigatórias pode ser removida.

```markdown
---
documento: padroes-{dominio}
versao: 1.0.0
criado: {YYYY-MM-DD}
atualizado: {YYYY-MM-DD}
total_regras: {número}
severidades:
  erro: {número}
  aviso: {número}
escopo: {descrição de onde este padrão se aplica}
aplica_a: [{lista de projetos ou "todos"}]
requer: [{lista de outros padroes-*.md que este documento referencia}]
substitui: [{documentos anteriores que este substitui, se houver}]
---
```

### Frontmatter — campos obrigatórios

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `documento` | string | Identificador único. Formato: `padroes-{dominio}` |
| `versao` | string | SemVer do documento. MAJOR ao alterar regras ERRO, MINOR ao adicionar regras, PATCH para correções textuais |
| `criado` | date | Data de criação (YYYY-MM-DD) |
| `atualizado` | date | Data da última alteração (YYYY-MM-DD) |
| `total_regras` | int | Quantidade total de regras no documento |
| `severidades.erro` | int | Quantidade de regras que bloqueiam merge |
| `severidades.aviso` | int | Quantidade de regras que são recomendação forte |
| `escopo` | string | Descrição textual de onde o padrão se aplica |
| `aplica_a` | list | Projetos cobertos. Use `["todos"]` para universal |
| `requer` | list | Documentos de padrões que este referencia. Vazio se independente |
| `substitui` | list | Documentos que este substitui. Vazio se é novo |

---

### Cabeçalho do documento

```markdown
# Padrões de {Domínio} — sua organização

> Documento constitucional. Contrato de entrega para todo
> desenvolvedor que toca {domínio} nos nossos projetos.
> Código que viola regras ERRO não é discutido — é devolvido.
```

**Regras do cabeçalho:**
- A frase "Contrato de entrega" é obrigatória. Reforça que não é sugestão.
- A frase sobre regras ERRO serem devolvidas é obrigatória. Define a cultura.

---

### Seção: Como usar este documento

Obrigatória. Explica como cada público deve usar o documento.
Três públicos fixos: **desenvolvedor**, **auditor**, **Claude Code**.

```markdown
## Como usar este documento

### Para o desenvolvedor
{Como consultar durante o desenvolvimento e antes de abrir PR}

### Para o auditor (humano ou IA)
{Como auditar código contra as regras por ID e severidade}

### Para o Claude Code
{Como interpretar o frontmatter, aplicar regras em code review,
e referenciar violações pelo ID}
```

---

### Seção: Severidades

Obrigatória. Sempre a mesma tabela — não alterar os significados.

```markdown
## Severidades

| Nível | Significado | Ação |
|-------|-------------|------|
| **ERRO** | Violação inegociável | Bloqueia merge. Corrigir antes de review. |
| **AVISO** | Recomendação forte | Deve ser justificada por escrito se ignorada. |
```

**Regra sobre severidades:**
- ERRO = nasceu de incidente real, risco de segurança, ou decisão explícita do projeto.
- AVISO = melhoria de qualidade que admite exceções justificadas.
- Nunca criar um terceiro nível. Dois é suficiente. Simplicidade.

---

### Seções temáticas (corpo do documento)

O corpo é organizado em **seções temáticas numeradas**. Cada seção agrupa
regras por preocupação (não por aspecto sintático).

```markdown
## {N}. {Nome da seção temática}
```

**Orientações para agrupamento:**
- Agrupar por **preocupação** (segurança, arquitetura, performance), não por
  aspecto mecânico (indentação, nomes de variáveis).
- Máximo 10 seções. Se passar de 10, o documento está tentando cobrir
  domínios demais — dividir.
- Ordem: do mais crítico para o menos crítico. Segurança antes de formatação.

**Quando criar um documento novo vs. adicionar a um existente:**
- Criar um novo `padroes-*.md` quando o domínio tem **10+ regras próprias**
  que não se encaixam naturalmente em nenhum documento existente.
- Abaixo de 10 regras, adicionar como seção no documento mais próximo.
- Na dúvida, perguntar ao usuário: "essas regras pertencem a {documento
  existente} ou justificam um documento próprio?"

---

### Formato obrigatório de cada regra

Toda regra segue exatamente este formato. Sem exceção.

```markdown
### {ID} — {Título descritivo} [{SEVERIDADE}]

**Regra:** {Descrição objetiva do que é obrigatório ou proibido.
Uma ou duas frases. Sem ambiguidade.}

**Verifica:** {Checagem mecânica concisa — como confirmar conformidade.
Uma linha, máximo duas. Pode ser comando grep, inspeção visual ou teste.}

**Por quê:** {Motivação real do projeto para esta regra. Pode ser um
incidente, uma decisão de negócio, uma limitação do contexto. Nunca
"porque é boa prática". Sempre "porque no projeto, X aconteceu/importa".}

**Exemplo correto:**
​```{linguagem}
// contexto do exemplo
{código que segue a regra}
​```

**Exemplo incorreto:**
​```{linguagem}
// contexto do exemplo
{código que viola a regra}
​```

**Exceções:** {Situações onde a regra não se aplica. Se não há exceções,
omitir esta linha.}

**Referências:** {IDs de regras relacionadas em outros documentos padrões.
Ex.: SEG-011. Se não há, omitir esta linha.}
```

### Convenção de IDs

| Componente | Formato | Exemplo |
|------------|---------|---------|
| Prefixo | Abreviação do domínio em UPPER | `PHP`, `SEG`, `WP`, `JS`, `UI` |
| Separador | Hífen | `-` |
| Número | Três dígitos, zero-padded | `001`, `042`, `100` |
| Completo | `{PREFIXO}-{NNN}` | `PHP-038`, `SEG-011` |

**Regras de IDs:**
- IDs são imutáveis. Uma vez atribuído, o ID nunca muda.
- Regras removidas ficam com status `[REMOVIDA]` — o ID não é reutilizado.
- Novas regras recebem o próximo número sequencial disponível.

### Regras sobre os exemplos

- Todo exemplo deve ser **compilável/executável** no contexto do projeto.
  Nada de pseudocódigo.
- O exemplo correto vem **sempre** antes do incorreto.
- Exemplos devem ser **mínimos** — só o código necessário pra demonstrar
  a regra. Sem boilerplate irrelevante.
- Se a regra é conceitual (ex.: princípio KISS), o exemplo mostra uma
  aplicação concreta, não o princípio abstrato.
- **Profundidade por público-alvo:** se o documento serve para onboarding
  (pergunta 8 da entrevista), exemplos devem incluir comentários explicativos
  no código e o "Por quê no projeto" deve dar mais contexto sobre o negócio.
  Se é para time experiente, exemplos mínimos sem comentários bastam.

### Regras sobre "Por quê no projeto"

- Nunca usar frases genéricas: "é boa prática", "melhora a legibilidade",
  "padrão da indústria".
- Sempre conectar à realidade do projeto: incidente, decisão de negócio,
  limitação de time, natureza dos dados.
- Se a motivação é um incidente, referenciar o PR onde aconteceu.
- Se é decisão de negócio, explicar qual (ex.: "dados financeiros exigem
  criptografia por compliance").
- A motivação ajuda a julgar exceções: se o "por quê" não se aplica ao
  caso, a regra talvez não se aplique.

---

### Seção: Documentação e versionamento

Obrigatória. Define como o código é documentado e como mudanças são
rastreadas. As regras desta seção seguem o **mesmo formato obrigatório**
de todas as outras (ID, severidade, "Por quê no projeto", exemplos).

```markdown
## {N}. Documentação e versionamento

### {PREFIXO}-{NNN} — {Título da regra de documentação} [{SEVERIDADE}]

**Regra:** {Descrição objetiva}

**Verifica:** {Checagem mecânica concisa — como confirmar conformidade.}

**Por quê:** {Motivação real}

**Exemplo correto:**
​```{linguagem}
{código/commit/changelog que segue a regra}
​```

**Exemplo incorreto:**
​```{linguagem}
{código/commit/changelog que viola a regra}
​```
```

**Temas que esta seção deve cobrir (como regras formais, não texto corrido):**
- Comentários no código: quando são obrigatórios (explicam "por quê") e
  quando são ruído (explicam "o quê"). Código autoexplicativo não precisa
  de comentário.
- Commits semânticos: formato exigido (`feat:`, `fix:`, `refactor:`,
  `docs:`, `test:`, `chore:`).
- CHANGELOG: como e quando atualizar a seção `[Unreleased]`.
- SemVer: como o projeto interpreta MAJOR/MINOR/PATCH no contexto do projeto.

---

### Seção: Definition of Done (DoD)

Obrigatória. Última seção do documento. É o checklist final antes do PR.

```markdown
## Definition of Done — Checklist de entrega

> PR que não cumpre o DoD não entra em review. É devolvido.

| # | Item | Regras | Verificação |
|---|------|--------|-------------|
| 1 | {item} | {IDs} | {como verificar} |
| 2 | {item} | {IDs} | {como verificar} |
| ... | ... | ... | ... |
```

**Regras do DoD:**
- Cada item do checklist referencia uma ou mais regras por ID.
- A coluna "Verificação" diz **como** confirmar (comando, inspeção visual, teste).
- Máximo 15 itens. Se passar, o checklist perde utilidade prática.
- Ordenar da verificação mais rápida para a mais lenta.

---

## Regras universais para todos os documentos de padrões

Estas regras se aplicam a qualquer `padroes-*.md` criado no projeto.

### Sobre o conteúdo

1. **Toda regra nasce de produção ou de decisão explícita.** Não adicionar
   regras "porque sim" ou "porque o framework recomenda". Se não há
   motivação concreta, não é regra — é opinião.

2. **Regras ERRO são inegociáveis.** Se alguém questionar uma regra ERRO,
   a resposta é: "mostre o incidente que justifica a exceção, ou corrija".

3. **Regras AVISO admitem exceções documentadas.** O desenvolvedor pode
   ignorar um AVISO se escrever a justificativa no PR. O auditor valida
   se a justificativa é aceitável.

4. **Sem duplicação entre documentos.** Se uma regra de segurança já está
   em `padroes-seguranca.md`, o documento de PHP faz cross-reference
   (ex.: "ver SEG-011"), nunca copia a regra.

5. **Exemplos são obrigatórios.** Regra sem exemplo é regra subjetiva.
   Se não consegue exemplificar, a regra não está clara o suficiente.

6. **Linguagem direta.** Sem "é recomendável", "deveria", "quando possível".
   Use "deve", "nunca", "sempre", "proibido". Ambiguidade gera
   interpretações diferentes.

### Sobre a manutenção

7. **O documento é versionado com SemVer.**
   - MAJOR: alteração em regra ERRO existente (mudança de comportamento).
   - MINOR: adição de regras novas.
   - PATCH: correção textual, melhoria de exemplo, ajuste de redação.

8. **Regras removidas não desaparecem.** Ficam marcadas como `[REMOVIDA]`
   com a justificativa e a data. O ID nunca é reutilizado.

9. **Revisão periódica.** Todo documento de padrões deve ser revisado
   quando um incidente de produção revelar uma lacuna.

10. **Quem altera o padrão precisa de aprovação.** Mudanças em regras ERRO
    passam pelo líder técnico. Mudanças em regras AVISO podem
    ser propostas por qualquer membro do time via PR.

### Sobre a relação entre documentos

11. **A constituição do projeto é a lei suprema.** Nenhum documento de padrões
    pode contradizer a constituição. Em caso de conflito, a constituição vence.

12. **Documentos de padrões são independentes mas conectados.** Cada documento
    cobre um domínio. Cross-references conectam regras relacionadas.
    A leitura de um documento deve ser autocontida — o leitor não precisa
    ler os outros para entender as regras do domínio.

13. **Hierarquia de precedência (vertical):**
    ```
    constituição do projeto          ← lei suprema, nunca violada
    └── padroes-*.md               ← regras por domínio
        └── regras de projeto      ← especializações por projeto (CLAUDE.md)
    ```
    Regras de projeto podem ser **mais restritivas** que o padrão,
    nunca **menos**.

14. **Resolução de conflitos entre documentos do mesmo nível (horizontal):**
    Documentos de padrões podem ter regras que tensionam entre si (ex.:
    "máximo 20 linhas por método" vs. "entidades ricas com lifecycle methods
    completos"). Quando isso acontecer:
    - Regra com severidade **ERRO** prevalece sobre **AVISO**.
    - Se ambas são ERRO, o **domínio mais específico** vence (ex.:
      `padroes-criptografia` vence `padroes-php` em matéria de crypto;
      `` vence `padroes-php` em matéria de WP APIs).
    - Se o conflito não se resolve por especificidade, **escalar para o
      líder técnico** (o líder técnico) para decisão documentada.
    - Conflitos resolvidos devem virar uma **exceção explícita** na regra
      que cede, referenciando a regra que prevalece.

---

## Estrutura de pastas

```

├── constituição do projeto          ← constituição (a ser criada)
├── padroes-modelo.md              ← este arquivo (modelo estrutural)
└── padroes/
    ├── padroes-php.md
    ├── padroes-poo.md
    ├── padroes-seguranca.md
    ├── padroes-testes.md
    ├──.md
    ├── padroes-frontend.md
    ├── padroes-js.md
    └── padroes-criptografia.md
```

---

## Glossário de termos usados nos documentos de padrões

Termos que aparecem nos documentos `padroes-*.md` e que podem não ser
óbvios para desenvolvedores novos no projeto.

| Termo | Definição |
|-------|-----------|
| **Fronteira do sistema** | O ponto onde dados externos entram no sistema (handlers AJAX, endpoints REST, formulários). É onde validação e sanitização acontecem. |
| **Entidade rica** | Classe de domínio que contém lógica de negócio (predicados, transições de estado, cálculos), não apenas getters e setters. Oposto de "entidade anêmica". |
| **FSM (Finite State Machine)** | Máquina de estados finitos. No projeto, implementada como constante `STATUS_TRANSITIONS` na entidade, com lifecycle methods para cada transição. |
| **from_row()** | Método estático que hidrata uma entidade a partir de uma linha do banco de dados. No projeto, deve ser tolerante (nunca lançar exception). |
| **Cross-reference** | Referência entre regras de documentos diferentes. Formato: `{ID}` (ex.: SEG-011). Evita duplicação de regras entre documentos. |
| **DoD (Definition of Done)** | Checklist de entrega que deve ser cumprido antes de abrir um PR. Funciona como contrato mínimo. |
| **Guard clause** | Retorno antecipado no início de um método para eliminar casos inválidos antes da lógica principal. Reduz aninhamento. |
| **Lifecycle method** | Método de entidade que executa uma transição de estado com validação embutida (ex.: `confirmar()`, `cancelar()`, `publicar()`). |
| **Hydrate / Hidratar** | Converter uma linha crua do banco de dados (`stdClass`) em uma instância tipada de entidade. |
| **Value Object** | Objeto imutável definido pelo seu valor, não pela identidade. Ex.: `Money(100, 'BRL')`, `Email('usuario@exemplo.com')`. Dois VOs com os mesmos valores são iguais. |
| **SemVer** | Versionamento semântico (MAJOR.MINOR.PATCH). MAJOR = breaking change, MINOR = feature nova, PATCH = correção. |
| **Ditador benevolente** | o líder técnico. Autoridade final sobre decisões técnicas e de padrões no projeto. |

**Regra:** cada documento `padroes-*.md` pode adicionar um glossário opcional
com termos específicos do seu domínio. Termos que já aparecem nesta tabela
não devem ser redefinidos — apenas referenciados.

---

## Checklist de qualidade do próprio documento

Antes de considerar um `padroes-*.md` pronto, verificar:

- [ ] Frontmatter completo com todos os campos obrigatórios
- [ ] Cabeçalho com "Contrato de entrega" e frase sobre regras ERRO
- [ ] Seção "Como usar" com os três públicos (dev, auditor, Claude Code)
- [ ] Tabela de severidades presente e inalterada
- [ ] Todas as regras seguem o formato obrigatório (ID, regra, verifica, por quê, exemplos)
- [ ] Todos os IDs seguem a convenção `{PREFIXO}-{NNN}`
- [ ] Nenhuma regra sem exemplo
- [ ] Nenhuma regra ERRO sem "Por quê no projeto" conectado a fato concreto
- [ ] Seção de documentação e versionamento presente
- [ ] DoD presente com máximo 15 itens referenciando regras por ID
- [ ] Cross-references para regras de outros documentos (sem duplicação)
- [ ] Nenhuma contradição com a constituição do projeto
- [ ] Documento revisado e aprovado pelo usuário antes de salvar
