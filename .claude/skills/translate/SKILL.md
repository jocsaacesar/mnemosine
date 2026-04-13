---
name: translate
description: Traduz documentação PT-BR para inglês na pasta en/, traduzindo apenas arquivos novos ou modificados. Trigger manual apenas.
---

# /translate — Tradução incremental PT-BR → EN

Mantém uma versão em inglês de toda a documentação do projeto dentro da pasta `en/`, espelhando a estrutura original. Usa um manifesto de hashes para traduzir **apenas o que mudou** desde a última execução.

## Quando usar

- **APENAS** quando o usuário digitar `/translate`, `/translate --all` ou `/translate --status` explicitamente.
- Nunca disparar automaticamente.

## Modos

- **`/translate`** — Traduz apenas arquivos novos ou modificados (padrão).
- **`/translate --all`** — Força retradução de todos os arquivos, ignorando o manifesto.
- **`/translate --status`** — Mostra quais arquivos estão desatualizados, novos ou removidos. Não traduz nada.

## Arquivos traduzíveis

Todos os arquivos `.md` na raiz e subpastas do projeto, **exceto:**

- `en/` (a própria pasta de saída)
- `memoria/`, `estudos/`, `troca/` (dados pessoais)
- `.claude/` (skills e configuração — não traduzir)
- `JOURNAL.md` (histórico, manter apenas em PT-BR)
- `exemplos/` (referência em PT-BR)
- Qualquer arquivo dentro de `.git/`

## Processo

### Fase 1 — Inventário e comparação

1. Listar todos os arquivos `.md` traduzíveis no projeto (respeitando as exclusões acima).
2. Ler o manifesto `en/.translation-manifest.json`. Se não existir, tratar todos os arquivos como novos.
3. Para cada arquivo traduzível, calcular o hash SHA-256 do conteúdo atual.
4. Comparar com o hash armazenado no manifesto.
5. Classificar cada arquivo em uma de três categorias:
   - **Novo** — existe no projeto mas não no manifesto (nunca foi traduzido).
   - **Modificado** — hash atual difere do hash no manifesto.
   - **Atualizado** — hash é idêntico (não precisa retraduzir).
6. Verificar se há arquivos no manifesto que **não existem mais** no projeto (removidos).

**Se o modo for `--status`:** Apresentar o relatório e parar aqui. Não traduzir.

**Se o modo for `--all`:** Ignorar os hashes e marcar todos como "modificado".

### Fase 2 — Apresentar plano

Mostrar ao usuário:

```
## /translate — Plano de tradução

### Arquivos a traduzir:
- [NOVO] README.md
- [MODIFICADO] CONTRIBUTING.md
- [MODIFICADO] guias/instalacao-projeto-existente.md

### Já atualizados (sem mudanças):
- CLAUDE-IC.md
- GLOSSARIO_DE_SKILLS.md

### Removidos do projeto (serão removidos de en/):
- (nenhum)

Total: 3 arquivos para traduzir. Continuar?
```

Esperar confirmação antes de prosseguir.

### Fase 3 — Traduzir arquivo por arquivo

Para cada arquivo a traduzir, **um de cada vez**:

1. Ler o conteúdo original em PT-BR.
2. Traduzir para inglês seguindo as regras de tradução (ver abaixo).
3. Criar a estrutura de pastas espelho em `en/` se necessário (ex.: `en/guias/`).
4. Escrever o arquivo traduzido no caminho espelho dentro de `en/`.
5. Informar progresso: `✓ README.md traduzido (1/3)`

**Não carregar todos os arquivos de uma vez.** Ler, traduzir e escrever um por um para economizar contexto.

### Fase 4 — Atualizar manifesto

Após todas as traduções:

1. Construir o manifesto atualizado com o hash SHA-256 de cada arquivo traduzível **no estado atual**.
2. Incluir timestamp da última execução.
3. Escrever `en/.translation-manifest.json` no formato:

```json
{
  "last_run": "2026-04-13T15:30:00Z",
  "files": {
    "README.md": {
      "hash": "sha256:abc123...",
      "translated_at": "2026-04-13T15:30:00Z"
    },
    "CONTRIBUTING.md": {
      "hash": "sha256:def456...",
      "translated_at": "2026-04-13T15:28:00Z"
    }
  }
}
```

### Fase 5 — Lidar com remoções

Se há arquivos no manifesto que não existem mais no projeto:

1. Listar os arquivos removidos.
2. Perguntar ao usuário: "Estes arquivos foram removidos do projeto. Devo remover as traduções correspondentes de en/?"
3. Se sim, deletar os arquivos de `en/` e remover do manifesto.

### Fase 6 — Relatório final

```
## Tradução concluída

- 3 arquivos traduzidos
- 2 arquivos já estavam atualizados
- 0 arquivos removidos
- Manifesto atualizado em en/.translation-manifest.json
```

## Regras de tradução

- **Traduzir o conteúdo, não transliterar.** A versão em inglês deve soar natural para um falante nativo. Não é tradução literal.
- **Manter a estrutura Markdown intacta.** Headings, listas, tabelas, blocos de código, links — tudo preservado.
- **Não traduzir nomes próprios.** "Mnemosine", "Joc", "Leland", "Claude Code" ficam como estão.
- **Não traduzir nomes de arquivos e caminhos.** `CLAUDE.md`, `memoria/`, `.claude/skills/` ficam como estão.
- **Não traduzir blocos de código.** Comandos bash, exemplos de código e outputs ficam em inglês (que já são).
- **Não traduzir nomes de skills.** `/iniciar`, `/comece-por-aqui` etc. ficam como estão — são comandos.
- **Links internos devem apontar para os arquivos em en/.** Ex.: `[CLAUDE-IC.md](CLAUDE-IC.md)` vira `[CLAUDE-IC.md](CLAUDE-IC.md)` (o link relativo já funciona dentro de `en/`).
- **Manter o tom.** Se o original é informal e direto, a tradução também é. Se é técnico, mantém técnico.
- **Adicionar uma nota no topo de cada arquivo traduzido:**
  ```
  > *This is an English translation of the original Portuguese file. Source: `<caminho-original>`*
  ```

## Regras da skill

- **Nunca traduzir sem mostrar o plano antes.** Sempre apresentar o que vai ser traduzido e esperar confirmação.
- **Nunca sobrescrever uma tradução atualizada.** Se o hash não mudou, não toca no arquivo (exceto em `--all`).
- **Um arquivo por vez.** Não acumular conteúdo — ler, traduzir, escrever, próximo.
- **Não alterar arquivos originais em PT-BR.** A skill só escreve dentro de `en/`.
- **Se a tradução de um arquivo falhar, pular e continuar.** Reportar no relatório final.
- **O manifesto é a fonte de verdade.** Sem ele, a skill trata tudo como novo.
