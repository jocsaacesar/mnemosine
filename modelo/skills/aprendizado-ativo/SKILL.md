---
name: aprendizado-ativo
description: Registra erros e incidentes seguindo protocolo estruturado. Conduz entrevista para documentar erro, contexto, correção e mitigação. Trigger manual ou quando a IA identificar um incidente.
---

# /aprendizado-ativo — Registro de incidentes

Conduz o protocolo de aprendizado do projeto. Quando algo dá errado, esta skill guia o registro completo: o que aconteceu, por que aconteceu, o que fizemos pra corrigir, e o que fizemos pra nunca mais acontecer.

Não é punição. É vacina.

## Quando usar

- Quando o usuário digitar `/aprendizado-ativo` explicitamente
- Quando a IA identificar um incidente que precisa ser registrado
- Quando algo der errado e alguém disser "registra isso"
- **Nunca** disparar automaticamente sem confirmação — erros precisam de contexto humano

## Quando outras skills devem SUGERIR `/aprendizado-ativo`

Skills auxiliares (`/aprovar-pr`, auditoras, gerentes de projeto)
devem **sugerir explicitamente** que o usuário rode `/aprendizado-ativo` quando
detectarem qualquer um destes sinais durante seu fluxo:

- **CI vermelho** que não era esperado
- **Exception não tratada** ou bug em produção descoberto durante a skill
- **Fix tardio** — mudança em código que deveria ter sido validada antes
- **Auditoria que pegou algo grande** — finding de severidade alta que devia ter sido visto antes
- **Auto-reconhecimento de erro** pela IA
- **Skip de validação** descoberto em retrospectiva (ex: teste SKIPPED que mascarou bug)

A sugestão deve ser **explícita e proativa**:

> "Detectei [tipo de erro] durante este fluxo. Recomendo rodar
> `/aprendizado-ativo` pra registrar o incidente formal antes de prosseguir.
> Confirma que rodamos?"

**Não disparar automaticamente** (regra dura acima) — apenas sugerir, esperar
confirmação do usuário. Mas a sugestão deve aparecer antes da skill seguir adiante,
não como nota de rodapé escondida.

## Processo

### Fase 1 — Identificar o incidente

Verificar o próximo número sequencial disponível em `aprendizado/erros/`:

```bash
ls aprendizado/erros/*.md 2>/dev/null | wc -l
```

O número do incidente é sequencial: `0001`, `0002`, etc. Uma vez atribuído, nunca muda.

### Fase 2 — Entrevista (uma pergunta por vez)

#### Pergunta 1 — O que aconteceu?

> "Me conta o que deu errado. Fato, sem julgamento. O que aconteceu exatamente?"

**Capturar:** Descrição objetiva do erro. Sem culpa, sem justificativa — só o fato.

#### Pergunta 2 — Qual era o contexto?

> "Qual era a situação? O que estava sendo feito? Quais foram os elos da corrente que levaram a isso?"

**Capturar:** A sequência de eventos e decisões. Os elos da corrente. Por que aconteceu, não quem fez.

#### Pergunta 3 — O que fizemos pra corrigir?

> "Como resolvemos? Qual foi a ação imediata? Se ainda não corrigiu, o que precisa ser feito?"

**Capturar:** A correção aplicada ou planejada. Ação concreta, não intenção.

#### Pergunta 4 — O que fazemos pra nunca mais acontecer?

> "Qual é a mitigação? O que muda no processo, na documentação, nas regras pra que isso vire imunidade?"

**Capturar:** Ação preventiva. Pode ser: nova regra no projeto, atualização de skill, novo check na auditoria, documentação adicional.

### Fase 3 — Gerar os 4 arquivos

Com base nas respostas, gerar:

#### `aprendizado/erros/{NNNN}-{slug}.md`
```markdown
---
incidente: {NNNN}
data: {YYYY-MM-DD}
projeto: {projeto ou "geral"}
status: resolvido | em-andamento
---

# {Título descritivo do erro}

{Descrição objetiva do que aconteceu. Fato, sem julgamento.}
```

#### `aprendizado/contexto-situacao/{NNNN}-{slug}.md`
```markdown
---
incidente: {NNNN}
---

# Contexto — {Título}

## Situação
{O que estava sendo feito}

## Elos da corrente
{Sequência de eventos e decisões que levaram ao erro}

## Indicadores ignorados
{Sinais que poderiam ter prevenido, se existirem}
```

#### `aprendizado/correcao/{NNNN}-{slug}.md`
```markdown
---
incidente: {NNNN}
corrigido_em: {YYYY-MM-DD}
---

# Correção — {Título}

## Ação imediata
{O que foi feito pra resolver}

## Arquivos alterados
{Lista de arquivos modificados, se aplicável}

## Verificação
{Como confirmar que a correção funcionou}
```

#### `aprendizado/mitigacao/{NNNN}-{slug}.md`
```markdown
---
incidente: {NNNN}
mitigado_em: {YYYY-MM-DD}
tipo: regra | skill | processo | documentacao
---

# Mitigação — {Título}

## O que muda
{Descrição da mudança preventiva}

## Onde muda
{Regras do projeto? Padrão mínimo? Skill? Processo?}

## Como verificar que a mitigação funciona
{Teste ou check que comprova a prevenção}
```

### Fase 4 — Mostrar e aprovar

Mostrar os 4 arquivos completos para o usuário antes de salvar.

> "Aqui está o registro do incidente. Lê com calma — quer ajustar alguma coisa antes de eu salvar?"

Esperar aprovação explícita.

### Fase 5 — Salvar e registrar telemetria

1. Salvar os 4 arquivos em `aprendizado/`
2. Registrar telemetria:

```bash
bash ~/seu-projeto/infra/scripts/mnemosine-log.sh aprendizado-ativo {projeto} CONCLUIDO {duração} "Incidente {NNNN} registrado: {título}"
```

3. Se a mitigação envolver mudança nas regras do projeto ou padrões, informar:

> "A mitigação sugere uma mudança no {documento}. Quer que eu proponha a alteração agora?"

### Fase 6 — Consulta de incidentes passados

Se o usuário chamar `/aprendizado-ativo` e perguntar sobre incidentes existentes (ex.: "já tivemos problema com isso?"), a skill deve:

1. Buscar em `aprendizado/erros/` por palavras-chave
2. Se encontrar incidente relacionado, mostrar o resumo
3. Alertar: "Já tivemos o incidente {NNNN} sobre isso. A mitigação foi: {resumo}. Verifique se está sendo seguida."

## Regras

- **Uma pergunta por vez.** Não despejar o formulário inteiro.
- **Sem julgamento.** O registro é factual. Não há culpados individuais.
- **Mostrar antes de salvar.** Sempre. Sem exceção.
- **Slug descritivo.** O nome do arquivo deve ser legível: `0001-force-push-sobrescreveu-repo.md`, não `0001-erro.md`.
- **Nunca apagar incidentes.** Incidentes resolvidos ficam como registro. São vacina, não vergonha.
- **Telemetria obrigatória.** Registrar no script de log ao concluir.
