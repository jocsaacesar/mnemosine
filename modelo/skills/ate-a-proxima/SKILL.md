---
name: ate-a-proxima
description: Encerramento de sessão. Audita o que foi feito, atualiza estado, sincroniza memórias, commita pendências, gera briefing e se despede. APENAS quando o usuário digitar /ate-a-proxima. Nunca disparar automaticamente.
---

# /ate-a-proxima — Encerramento de sessão

O agente não sai sem fechar a porta. Esta skill encerra a sessão de trabalho salvando todo o estado, registrando o que foi feito, e preparando o terreno pra próxima sessão começar onde esta parou.

## Quando usar

- **APENAS** quando o usuário digitar `/ate-a-proxima` explicitamente
- **Nunca** disparar por cumprimentos, despedidas ou sinais implícitos
- **Nunca** disparar automaticamente — o usuário decide quando o dia acaba

## Processo

### Fase 1 — Auditar a sessão

1. **O que foi feito hoje?** Revisar o histórico da conversa e listar:
   - Decisões tomadas
   - Arquivos criados ou editados
   - Skills criadas ou atualizadas
   - Planos criados ou executados
   - Incidentes registrados
   - Commits e pushes realizados

2. **O que ficou pendente?** Identificar:
   - Tarefas mencionadas mas não concluídas
   - Planos aprovados mas não executados
   - Fios soltos que surgiram durante o trabalho

3. **Check de incidentes não-registrados** — varrer a sessão por:
   - CI vermelho que aconteceu (mesmo que tenha sido corrigido)
   - Bug, exception ou erro operacional
   - Auditoria que pegou algo que devia ter sido pego antes
   - Qualquer auto-reconhecimento de erro pela IA

   **Para CADA sinal encontrado**, verificar se há incidente correspondente em
   `aprendizado/erros/`. Se NÃO houver, **alertar antes de encerrar a sessão**:

   > "Encontrei {N} sinais de incidente nesta sessão sem registro formal:
   > - {sinal 1}
   > - {sinal 2}
   > Não posso fechar a sessão sem rodar `/aprendizado-ativo` pra cada um.
   > Quer que eu rode agora? (recomendado) ou autoriza encerrar mesmo assim?"

   **Não encerrar sem resolução explícita do usuário.** Se houver incidente sem registro
   e o usuário autorizar encerrar mesmo assim, registrar essa decisão no estado da sessão
   como "incidentes pendentes pra próxima sessão" — mas só com autorização explícita.

### Fase 2 — Atualizar o estado

1. **Estado dos planos no `CLAUDE.md`** — atualizar a seção "Estado dos planos":
   - Atualizar a data: `(atualizado: YYYY-MM-DD)`
   - **Operacionais:** atualizar status de cada ops (novo progresso, concluído, bloqueado). Se concluído → remover da tabela e mover arquivo pra `planos/arquivo/`.
   - **Emergenciais:** adicionar se surgiram, remover se resolvidos.
   - **Backlog:** adicionar novos, atualizar resumo se houve progresso, remover se descartados.
   - **Novos planos criados na sessão:** adicionar na tabela correspondente.
   - Esta seção é a **fonte de verdade rápida** — o `/iniciar` lê ela, não os arquivos de plano.

2. **CLAUDE.md** — atualizar:
   - "Estado atual": resumo do que foi feito na sessão
   - Skills: se novas skills foram criadas, adicionar na tabela
   - Estrutura: se novas pastas foram criadas, atualizar

3. **Planos** — se algum plano foi executado ou progrediu:
   - Atualizar status no arquivo do plano
   - Marcar tarefas concluídas com `[x]`

### Fase 3 — Sincronizar memórias

1. Copiar memórias do projeto pra pasta do sistema:
   ```bash
   cp memoria/*.md ~/.claude/projects/$(pwd | sed 's|/|-|g')/memory/ 2>/dev/null
   ```

2. Atualizar memórias do sistema se necessário:
   - Criar nova memória se algo relevante pra futuras sessões surgiu

### Fase 4 — Commitar e pushar pendências

1. Verificar se há mudanças não commitadas:
   ```bash
   git status
   ```

2. Se houver, commitar com mensagem descritiva:
   ```
   Fechamento de sessão: {resumo do que mudou}
   ```

3. Pushar pro remote.

4. Verificar se há mudanças pendentes em subprojetos:
   ```bash
   for p in projetos/*/; do echo "$p: $(git -C $p status --short | wc -l) pendências"; done
   ```
   Se houver, alertar — não commitar sem aprovação.

### Fase 5 — Healthcheck (opcional)

Se o projeto tiver URLs de produção, testar todas. Se qualquer uma falhar, alertar antes de encerrar.

```bash
# Exemplo — adapte as URLs para o seu projeto
URLS=(
  "https://seu-dominio.com.br"
)

for url in "${URLS[@]}"; do
  code=$(curl -sI -o /dev/null -w "%{http_code}" --max-time 10 "$url" 2>/dev/null)
  echo "$url: $code"
done
```

- **200 e 302 são OK.**
- **Qualquer outro código é alerta.** Reportar ao usuário antes de fechar.

### Fase 6 — Registrar telemetria

```bash
bash ~/seu-projeto/infra/scripts/mnemosine-log.sh ate-a-proxima - CONCLUIDO {duração} "Sessão encerrada. {N} decisões, {M} commits, {P} planos. Próximo: {resumo}"
```

### Fase 7 — Briefing de fechamento

Apresentar um resumo executivo do dia. Formato:

```
## Sessão {data}

### O que fizemos
- {item 1}
- {item 2}
- ...

### Números
- {N} commits | {M} arquivos alterados | {P} planos
- Skills: {Z} ativas

### Pendente pra próxima
- {item 1}
- {item 2}

### Decisões críticas (revisitar em 7 dias)
- {decisão, se houver}
```

### Fase 8 — Despedida

Despedir-se no personagem definido no CLAUDE.md. Curto, com atitude.

Exemplos de tom:

Se foi um dia produtivo:
> "Bom trabalho hoje. {N} commits, {M} planos, e nenhuma linha medíocre. Amanhã `/iniciar` e estou aqui."

Se ficou coisa pendente:
> "Dia cheio. {X} ficou pendente — não vou esquecer. Quando voltar, `/iniciar` que eu retomo."

Se foi um dia de fundação:
> "Hoje construímos a fundação. {N} skills, {M} processos. Amanhã começa o trabalho de verdade."

## Regras

- **Nunca sair sem atualizar o estado.** CLAUDE.md desatualizado é amnésia institucional.
- **Nunca sair sem telemetria.** Se não registrou, a sessão não existiu.
- **Nunca sair sem pushar.** Trabalho local que não vai pro remote é trabalho perdido.
- **Nunca despejar um log técnico.** O briefing é pra humano, não pra máquina.
- **A despedida é curta.** 2-3 linhas no máximo.
- **Alertar sobre pendências.** Se algo ficou pra trás, dizer. Não fingir que está tudo fechado.
