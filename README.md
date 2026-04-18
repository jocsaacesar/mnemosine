# Mnemósine

> *Na neurociência, engrama é o traço que uma experiência deixa no cérebro — a marca física que transforma vivência em identidade. Mnemósine transforma a relação entre humano e IA em algo com a mesma profundidade.*

Framework de colaboração humano-IA para o [Claude Code](https://claude.ai/code). Dá à sua IA **identidade, memória, skills, regras auditáveis e aprendizado com erros** — tudo dentro do seu repositório.

## Antes vs Depois

| Sem framework | Com Mnemósine |
|---------------|---------------|
| IA genérica, sem contexto entre sessões | IA com identidade, memória persistente e personalidade |
| "Faz isso pra mim" → resultado inconsistente | Skills padronizadas → mesmo processo, mesmo resultado |
| Bugs passam no review | 250+ regras auditáveis por stack, com ID e severidade |
| Erros se repetem | Protocolo de aprendizado: erro → contexto → correção → mitigação |
| Sessões começam do zero | `/iniciar` carrega tudo, `/ate-a-proxima` salva tudo |

## Instalação

### Projeto novo — Use como template

1. Clique em **"Use this template"** no topo desta página
2. Crie seu repositório a partir do template
3. Abra o Claude Code e digite `/comece-por-aqui`

### Projeto existente — Uma linha

```bash
curl -sSL https://raw.githubusercontent.com/jocsaacesar/mnemosine/main/install.sh | bash
```

O instalador pergunta o que você quer:

| Modo | O que instala |
|------|---------------|
| **Completo** | Skills, auditoras, padrões, aprendizado, guias, exemplos — tudo |
| **Essencial** | Skills de sessão + aprendizado + memória (leve e funcional) |
| **Escolher** | Você seleciona componente por componente |

Após instalar, abra o Claude Code e rode `/comece-por-aqui` — a IA entrevista você e personaliza tudo.

### Manual

```bash
git clone https://github.com/jocsaacesar/mnemosine.git
cp -r mnemosine/modelo/ seu-projeto/
cd seu-projeto && claude
# digite: /comece-por-aqui
```

## O que vem no framework

### Skills globais (10)

| Skill | O que faz |
|-------|-----------|
| `/iniciar` | Bootstrap da sessão — carrega identidade, memórias, estado dos planos |
| `/ate-a-proxima` | Encerramento — audita sessão, salva estado, sincroniza memórias |
| `/comece-por-aqui` | Onboarding — entrevista o usuário e constrói a configuração |
| `/criar-skill` | Meta-skill — cria novas skills por entrevista guiada |
| `/aprendizado-ativo` | Registra incidentes com protocolo de 4 arquivos |
| `/aprovar-pr` | Revisão de PR com orquestração de auditoras |
| `/telemetria` | Consulta logs de atividade das skills |
| `/revisar-texto` | Revisão ortográfica e de convenções em .md |
| `/tornar-publico` | Sanitiza e publica trabalho (protege dados pessoais) |
| `/marketplace` | Explora skills disponíveis |

### Auditoras de código (7)

Cada auditora lê o padrão mínimo correspondente e aplica regra por regra. Violações são referenciadas por ID (ex: `PHP-025`). ERRO bloqueia merge, AVISO exige justificativa.

| Auditora | Stack |
|----------|-------|
| `/auditar-php` | PHP |
| `/auditar-poo` | Orientação a objetos |
| `/auditar-testes` | Testes (unit, integration, API) |
| `/auditar-seguranca` | Segurança (OWASP, sanitização, auth) |
| `/auditar-frontend` | Frontend (HTML, CSS, acessibilidade) |
| `/auditar-js` | JavaScript/TypeScript |
| `/auditar-cripto` | Criptografia |

### Padrões mínimos (8 + modelo)

Documentos de regras auditáveis com IDs únicos, severidade (ERRO/AVISO) e seção "Verifica:" para cada regra. Inclui um modelo para criar seus próprios padrões.

### Pipeline de projeto

4 templates de skills de projeto para criar seu pipeline:

```
Usuário pede algo → Gerente orquestra:
    1. Planejadora (interpreta, cria plano)
    2. Executora (pega o plano, escreve código)
    3. Teste (cria testes contra padrões mínimos)
    4. Auditora (orquestra auditorias da stack)
```

### Sistema de aprendizado

Quando algo dá errado, o `/aprendizado-ativo` registra 4 arquivos:

```
aprendizado/
├── erros/0001-descricao.md              # O que aconteceu
├── contexto-situacao/0001-descricao.md  # Por que aconteceu
├── correcao/0001-descricao.md           # O que corrigiu
└── mitigacao/0001-descricao.md          # Como prevenir
```

A IA consulta esse histórico antes de agir em áreas com incidentes anteriores.

## Estrutura completa

<details>
<summary>Clique para expandir</summary>

```
modelo/
├── CLAUDE.md                      # Template de identidade da IA
├── ORCHESTRATOR.md                # Manual de orquestração de skills
├── padroes-minimos/               # Regras auditáveis por stack
│   ├── padroes-php.md
│   ├── padroes-poo.md
│   ├── padroes-testes.md
│   ├── padroes-seguranca.md
│   ├── padroes-frontend.md
│   ├── padroes-js.md
│   ├── padroes-rest-api.md
│   ├── padroes-criptografia.md
│   └── padroes-modelo.md          # Template para criar novos padrões
├── biblioteca/
│   ├── auditoras/                 # 7 skills de auditoria
│   │   ├── auditar-php/
│   │   ├── auditar-poo/
│   │   ├── auditar-testes/
│   │   ├── auditar-seguranca/
│   │   ├── auditar-frontend/
│   │   ├── auditar-js/
│   │   └── auditar-cripto/
│   └── projeto/                   # 4 templates de pipeline
│       ├── skill-planejadora/
│       ├── skill-executora/
│       ├── skill-teste/
│       └── skill-auditora/
├── skills/                        # 10 skills globais
│   ├── iniciar/
│   ├── ate-a-proxima/
│   ├── comece-por-aqui/
│   ├── criar-skill/
│   ├── aprendizado-ativo/
│   ├── aprovar-pr/
│   ├── telemetria/
│   ├── revisar-texto/
│   ├── tornar-publico/
│   └── marketplace/
├── planos/
│   ├── backlog/                   # Ideias, melhorias, dívida técnica
│   ├── operacional/               # Tarefas com entrega e prazo
│   ├── emergencial/               # Produção quebrou — prioridade máxima
│   └── arquivo/                   # Planos concluídos ou descartados
├── aprendizado/
│   ├── erros/
│   ├── contexto-situacao/
│   ├── correcao/
│   └── mitigacao/
├── memoria/                       # Memórias persistentes
├── modelos/                       # Templates reutilizáveis
├── infra/
│   └── scripts/                   # Script de telemetria
└── projetos/                      # Seus projetos aqui
exemplos/
└── leland/                        # Implementação de referência completa
guias/
├── claude-md.md                   # Como escrever o CLAUDE.md
├── skills.md                      # Como criar e usar skills
├── memoria.md                     # Como funciona o sistema de memória
├── taxonomia-skills.md            # Níveis e tipos de skills
└── instalacao-projeto-existente.md
```

</details>

## Segurança

- Todas as skills são **locais ao projeto** por padrão. Nada toca `~/.claude/` globalmente.
- O `/tornar-publico` sanitiza dados pessoais antes de publicar.
- Revise o conteúdo das skills antes de usar — elas executam comandos no seu ambiente.
- Para uso global, copie manualmente para `~/.claude/skills/`.

## Exemplo de referência

A pasta `exemplos/leland/` contém uma implementação completa com identidade multi-personalidade, memórias tipadas e skills de sessão. Use como referência para construir a sua.

## Contribuindo

Contribuições são bem-vindas. Abra uma issue ou envie um PR.

## Licença

MIT
