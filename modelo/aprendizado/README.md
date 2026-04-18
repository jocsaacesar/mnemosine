# Aprendizado

> *"Errar uma vez é aprendizado. Errar o mesmo erro duas vezes é inaceitável."*

Este diretório é o registro vivo de tudo que deu errado e o que foi feito a respeito. Não é um mural da vergonha — é uma biblioteca de imunidade.

## Estrutura

```
aprendizado/
├── erros/                 # O que aconteceu (fato, sem julgamento)
├── contexto-situacao/     # A situação que ocasionou (os elos da corrente)
├── correcao/              # O que fizemos pra corrigir (ação imediata)
└── mitigacao/             # O que fizemos pra nunca mais acontecer (prevenção)
```

## Como registrar

Cada incidente gera **4 arquivos** com o mesmo prefixo numérico:

```
erros/0001-descricao-curta.md
contexto-situacao/0001-descricao-curta.md
correcao/0001-descricao-curta.md
mitigacao/0001-descricao-curta.md
```

## Quem consulta

- **A IA** — antes de tomar decisões em áreas onde já errou
- **Skills** — ao auditar código em domínios com histórico de incidentes
- **O usuário** — quando quiser entender padrões de falha
- **Novos agentes** — como parte do onboarding, para não repetir

## Regra

Se um erro registrado aqui acontecer de novo, o incidente é tratado como **violação das regras do projeto**, não como erro operacional.
