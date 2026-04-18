# Instalação em projeto existente

Este guia é para quem **já tem um projeto rodando** e quer adicionar a Mnemósine sem quebrar nada. Se está começando do zero, use o template ou veja o [README](../README.md).

---

## Método rápido (recomendado)

```bash
# Na raiz do seu projeto
curl -sSL https://raw.githubusercontent.com/jocsaacesar/mnemosine/main/install.sh | bash
```

O instalador pergunta o que instalar (completo, essencial ou escolher componente por componente) e copia tudo nos lugares certos.

---

## Método manual

### 1. Baixe o framework

```bash
# Em qualquer lugar fora do seu projeto
git clone https://github.com/jocsaacesar/mnemosine.git
```

### 2. Copie as skills

```bash
# Dentro da pasta do seu projeto
mkdir -p .claude/skills
cp -r /caminho/para/mnemosine/modelo/skills/*/ .claude/skills/
```

Se já tiver `.claude/skills/`, as skills são adicionadas sem apagar as existentes.

### 3. Copie os componentes que quiser

```bash
# Auditoras (opcional)
mkdir -p biblioteca/auditoras
cp -r /caminho/para/mnemosine/modelo/biblioteca/auditoras/*/ biblioteca/auditoras/

# Padrões mínimos (opcional)
mkdir -p padroes-minimos
cp /caminho/para/mnemosine/modelo/padroes-minimos/*.md padroes-minimos/

# Templates de pipeline (opcional)
mkdir -p biblioteca/projeto
cp -r /caminho/para/mnemosine/modelo/biblioteca/projeto/*/ biblioteca/projeto/
```

### 4. Crie a estrutura de pastas

```bash
mkdir -p aprendizado/{erros,contexto-situacao,correcao,mitigacao}
mkdir -p planos/{backlog,operacional,emergencial,arquivo}
mkdir -p memoria
mkdir -p infra/scripts
cp /caminho/para/mnemosine/modelo/infra/scripts/mnemosine-log.sh infra/scripts/
chmod +x infra/scripts/mnemosine-log.sh
```

### 5. Atualize seu .gitignore

**Não sobrescreva seu `.gitignore`.** Adicione estas linhas ao final:

```gitignore
# Mnemósine — dados pessoais
memoria/
memory/
logs/
```

### 6. Rode o onboarding

```bash
claude
# digite: /comece-por-aqui
```

A skill entrevista você e gera um `CLAUDE.md` personalizado.

---

## Cuidados

### Você já tem um `CLAUDE.md`

O `/comece-por-aqui` vai tentar criar um novo. Antes de rodar:

1. Renomeie temporariamente — `mv CLAUDE.md CLAUDE.backup.md`
2. Rode `/comece-por-aqui` — deixe a skill gerar o novo
3. Mescle manualmente — pegue as instruções do backup e adicione ao novo

### Você já tem `.claude/skills/`

Sem problema. O `cp -r` adiciona ao lado das suas. Nenhuma skill existente é sobrescrita.

---

## O que o framework cria no seu projeto

Depois do `/comece-por-aqui`:

```
seu-projeto/
├── .claude/skills/          ← Skills (você copiou)
├── CLAUDE.md                ← Identidade da sua IA (gerado pela skill)
├── memoria/                 ← Criada pelo /comece-por-aqui (no .gitignore)
│   └── MEMORY.md
├── aprendizado/             ← Registro de incidentes
├── planos/                  ← Gestão de trabalho
└── infra/scripts/           ← Script de telemetria
```

---

## Como desinstalar

```bash
# Remover skills
rm -rf .claude/skills/{iniciar,ate-a-proxima,comece-por-aqui,criar-skill,aprendizado-ativo,aprovar-pr,telemetria,revisar-texto,tornar-publico,marketplace}

# Remover estrutura (opcional — contém seus dados)
rm -rf memoria/ aprendizado/ planos/ biblioteca/ padroes-minimos/ infra/

# Remover CLAUDE.md (decisão sua — pode querer manter)
# Remover entradas do .gitignore (edite manualmente)
```

Nenhum resíduo global. Seu projeto volta a ser como era antes.
