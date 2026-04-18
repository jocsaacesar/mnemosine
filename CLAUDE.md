# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## O que é Mnemósine

Framework de colaboração humano-IA. Transforma a relação entre um humano e uma IA de assistente genérico em **parceria operacional estruturada** — com identidade, regras, memória persistente, skills reutilizáveis, auditoria e governança.

Nasceu da prática real de uma software house brasileira (2026), onde uma IA opera como gestora de múltiplos projetos, 10+ skills globais, 7 auditoras de código, e um conjunto de 250+ regras auditáveis — tudo orquestrado por um único humano.

## Para quem

Desenvolvedores, times e empresas que querem replicar esse modelo: um humano + uma IA operando com estrutura, consistência e rastreabilidade.

## Estrutura do framework

```
modelo/                            # Template — copie e customize
├── CLAUDE.md                      # Identidade da IA (persona, regras, economia de token)
├── ORCHESTRATOR.md                # Manual de orquestração (quando chamar cada skill)
├── padroes-minimos/               # Regras auditáveis por stack (PHP, JS, OOP, etc.)
├── biblioteca/
│   ├── auditoras/                 # Skills de auditoria (linkadas por projeto via symlink)
│   └── projeto/                   # Templates de skills de projeto (planejadora, executora, etc.)
├── skills/                        # 10 skills globais (sessão, gestão, operacional)
├── planos/                        # Gestão de trabalho (backlog / operacional / emergencial)
├── aprendizado/                   # Registro de incidentes (erros, contexto, correção, mitigação)
├── memoria/                       # Memórias persistentes entre sessões
├── modelos/                       # Templates reutilizáveis (skill, identidade, memória)
├── infra/                         # Scripts operacionais (telemetria, logs)
└── projetos/                      # Projetos independentes com skills locais
exemplos/                          # Implementação de referência (Leland Hawkins)
guias/                             # Guias de uso (memória, skills, identidade, instalação)
```

## Princípios

1. **Identidade, não ferramenta.** A IA tem persona, regras de comportamento e propósito.
2. **Regras auditáveis, não sugestões.** Padrões referenciáveis por ID que bloqueiam merge quando violados.
3. **Memória que persiste.** Contexto sobrevive entre sessões sem depender do humano repetir.
4. **Skills como receitas.** Automação consistente — mesmos passos, mesmo resultado.
5. **Economia de token.** Carregar só o essencial por sessão, consultar o resto sob demanda.
6. **Errar uma vez é aprendizado, repetir é inaceitável.** Incidentes viram protocolo, não desculpa.
7. **O humano decide, a IA executa com excelência.** Desafiar quando necessário, obedecer quando vencido no argumento.

## Idioma

Português brasileiro. O framework é agnóstico de idioma, mas a documentação e exemplos são em pt-BR.

## Como usar

1. Clone este repositório
2. Copie a pasta `modelo/` para o seu projeto
3. Rode `/comece-por-aqui` — a IA vai entrevistar você e construir sua configuração
4. Use `/iniciar` no começo de cada sessão e `/ate-a-proxima` no final

Para projetos existentes, veja `guias/instalacao-projeto-existente.md`.
