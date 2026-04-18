#!/bin/bash
# Mnemósine — Instalador para projetos existentes
# Uso: curl -sSL https://raw.githubusercontent.com/jocsaacesar/mnemosine/main/install.sh | bash
# Ou:  bash install.sh [--tudo | --minimo | --escolher]
#
# Instala o framework Mnemósine no diretório atual.
# Após instalar, rode o Claude Code e digite /comece-por-aqui para personalizar.

set -euo pipefail

REPO="jocsaacesar/mnemosine"
BRANCH="main"
RAW_URL="https://raw.githubusercontent.com/${REPO}/${BRANCH}"
TEMP_DIR=""

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

info()  { echo -e "${CYAN}→${NC} $1"; }
ok()    { echo -e "${GREEN}✓${NC} $1"; }
warn()  { echo -e "${YELLOW}!${NC} $1"; }
erro()  { echo -e "${RED}✗${NC} $1"; exit 1; }

cleanup() {
    [ -n "$TEMP_DIR" ] && rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

# ─────────────────────────────────────────────
# Verificações
# ─────────────────────────────────────────────

if [ ! -d ".git" ]; then
    warn "Este diretório não é um repositório git."
    read -rp "Continuar mesmo assim? (s/N) " resp
    [[ "$resp" =~ ^[sS]$ ]] || exit 0
fi

if [ -f ".claude/skills/iniciar/SKILL.md" ]; then
    warn "Mnemósine já parece estar instalada neste projeto."
    read -rp "Reinstalar e sobrescrever? (s/N) " resp
    [[ "$resp" =~ ^[sS]$ ]] || exit 0
fi

# ─────────────────────────────────────────────
# Download do repositório
# ─────────────────────────────────────────────

info "Baixando Mnemósine..."

TEMP_DIR=$(mktemp -d)

if command -v git &>/dev/null; then
    git clone --depth 1 --branch "$BRANCH" "https://github.com/${REPO}.git" "$TEMP_DIR/mnemosine" 2>/dev/null
else
    curl -sSL "https://github.com/${REPO}/archive/refs/heads/${BRANCH}.tar.gz" | tar -xz -C "$TEMP_DIR"
    mv "$TEMP_DIR"/mnemosine-* "$TEMP_DIR/mnemosine"
fi

MODELO="$TEMP_DIR/mnemosine/modelo"
GUIAS="$TEMP_DIR/mnemosine/guias"
EXEMPLOS="$TEMP_DIR/mnemosine/exemplos"

ok "Download concluído."

# ─────────────────────────────────────────────
# Modo de instalação
# ─────────────────────────────────────────────

MODE="${1:-}"

if [ -z "$MODE" ]; then
    echo ""
    echo -e "${BOLD}Como quer instalar a Mnemósine?${NC}"
    echo ""
    echo "  1) Completo    — Skills, auditoras, padrões, aprendizado, tudo."
    echo "  2) Essencial   — Skills de sessão + aprendizado + memória. Sem auditoras/padrões."
    echo "  3) Escolher     — Seleciona componente por componente."
    echo ""
    read -rp "Opção (1/2/3): " choice
    case "$choice" in
        1) MODE="--tudo" ;;
        2) MODE="--minimo" ;;
        3) MODE="--escolher" ;;
        *) MODE="--tudo" ;;
    esac
fi

# Flags de componentes
INSTALL_SKILLS=true
INSTALL_AUDITORAS=false
INSTALL_PADROES=false
INSTALL_PROJETO=false
INSTALL_APRENDIZADO=true
INSTALL_PLANOS=true
INSTALL_MEMORIA=true
INSTALL_MODELOS=false
INSTALL_INFRA=true
INSTALL_GUIAS=false
INSTALL_EXEMPLOS=false
INSTALL_ORCHESTRATOR=false

case "$MODE" in
    --tudo)
        INSTALL_AUDITORAS=true
        INSTALL_PADROES=true
        INSTALL_PROJETO=true
        INSTALL_MODELOS=true
        INSTALL_GUIAS=true
        INSTALL_EXEMPLOS=true
        INSTALL_ORCHESTRATOR=true
        ;;
    --minimo)
        # Defaults já cobrem o mínimo
        ;;
    --escolher)
        echo ""
        ask_yn() {
            read -rp "$1 (s/N) " resp
            [[ "$resp" =~ ^[sS]$ ]]
        }

        ask_yn "Auditoras de código? (PHP, JS, OOP, segurança, etc.)" && INSTALL_AUDITORAS=true
        ask_yn "Padrões mínimos? (250+ regras auditáveis por stack)" && INSTALL_PADROES=true
        ask_yn "Templates de pipeline? (planejadora, executora, teste, auditora)" && INSTALL_PROJETO=true
        ask_yn "Orquestrador? (manual de quando chamar cada skill)" && INSTALL_ORCHESTRATOR=true
        ask_yn "Templates reutilizáveis? (modelos de skill, identidade, memória)" && INSTALL_MODELOS=true
        ask_yn "Guias de uso? (como escrever CLAUDE.md, criar skills, etc.)" && INSTALL_GUIAS=true
        ask_yn "Exemplo de referência? (Leland Hawkins — implementação completa)" && INSTALL_EXEMPLOS=true
        echo ""
        ;;
esac

# ─────────────────────────────────────────────
# Instalação
# ─────────────────────────────────────────────

echo ""
info "Instalando componentes..."

# Skills globais → .claude/skills/
if [ "$INSTALL_SKILLS" = true ]; then
    mkdir -p .claude/skills
    cp -r "$MODELO"/skills/*/ .claude/skills/ 2>/dev/null || true
    ok "10 skills globais → .claude/skills/"
fi

# Auditoras → biblioteca/auditoras/
if [ "$INSTALL_AUDITORAS" = true ]; then
    mkdir -p biblioteca/auditoras
    cp -r "$MODELO"/biblioteca/auditoras/*/ biblioteca/auditoras/ 2>/dev/null || true
    ok "7 auditoras → biblioteca/auditoras/"
fi

# Padrões mínimos
if [ "$INSTALL_PADROES" = true ]; then
    mkdir -p padroes-minimos
    cp "$MODELO"/padroes-minimos/*.md padroes-minimos/ 2>/dev/null || true
    ok "9 padrões mínimos → padroes-minimos/"
fi

# Templates de pipeline
if [ "$INSTALL_PROJETO" = true ]; then
    mkdir -p biblioteca/projeto
    cp -r "$MODELO"/biblioteca/projeto/*/ biblioteca/projeto/ 2>/dev/null || true
    ok "4 templates de pipeline → biblioteca/projeto/"
fi

# Aprendizado
if [ "$INSTALL_APRENDIZADO" = true ]; then
    mkdir -p aprendizado/{erros,contexto-situacao,correcao,mitigacao}
    cp "$MODELO"/aprendizado/README.md aprendizado/ 2>/dev/null || true
    ok "Sistema de aprendizado → aprendizado/"
fi

# Planos
if [ "$INSTALL_PLANOS" = true ]; then
    mkdir -p planos/{backlog,operacional,emergencial,arquivo}
    ok "Gestão de planos → planos/"
fi

# Memória
if [ "$INSTALL_MEMORIA" = true ]; then
    mkdir -p memoria
    cp "$MODELO"/memoria/MEMORY.md memoria/ 2>/dev/null || true
    ok "Sistema de memória → memoria/"
fi

# Orquestrador
if [ "$INSTALL_ORCHESTRATOR" = true ]; then
    cp "$MODELO"/ORCHESTRATOR.md . 2>/dev/null || true
    ok "Orquestrador → ORCHESTRATOR.md"
fi

# Modelos
if [ "$INSTALL_MODELOS" = true ]; then
    mkdir -p modelos/skill-modelo modelos/skill-projeto
    cp -r "$MODELO"/modelos/* modelos/ 2>/dev/null || true
    ok "Templates reutilizáveis → modelos/"
fi

# Infra (script de telemetria)
if [ "$INSTALL_INFRA" = true ]; then
    mkdir -p infra/scripts
    cp "$MODELO"/infra/scripts/mnemosine-log.sh infra/scripts/ 2>/dev/null || true
    chmod +x infra/scripts/mnemosine-log.sh 2>/dev/null || true
    ok "Script de telemetria → infra/scripts/"
fi

# Guias
if [ "$INSTALL_GUIAS" = true ]; then
    mkdir -p guias
    cp "$GUIAS"/*.md guias/ 2>/dev/null || true
    ok "5 guias de uso → guias/"
fi

# Exemplos
if [ "$INSTALL_EXEMPLOS" = true ]; then
    mkdir -p exemplos
    cp -r "$EXEMPLOS"/* exemplos/ 2>/dev/null || true
    ok "Exemplo de referência → exemplos/"
fi

# CLAUDE.md placeholder (se não existir)
if [ ! -f "CLAUDE.md" ]; then
    cp "$MODELO"/CLAUDE.md . 2>/dev/null || true
    ok "Identidade template → CLAUDE.md"
else
    warn "CLAUDE.md já existe — não sobrescrito. O template está em modelos/CLAUDE.md"
    if [ "$INSTALL_MODELOS" != true ]; then
        mkdir -p modelos
        cp "$MODELO"/CLAUDE.md modelos/CLAUDE.md 2>/dev/null || true
    fi
fi

# ─────────────────────────────────────────────
# Finalização
# ─────────────────────────────────────────────

echo ""
echo -e "${GREEN}${BOLD}Mnemósine instalada.${NC}"
echo ""
echo -e "Próximo passo:"
echo -e "  ${CYAN}claude${NC}              ← abre o Claude Code"
echo -e "  ${CYAN}/comece-por-aqui${NC}    ← a IA entrevista você e personaliza tudo"
echo ""
echo -e "Skills disponíveis após o onboarding:"
echo -e "  ${CYAN}/iniciar${NC}            ← começa uma sessão"
echo -e "  ${CYAN}/ate-a-proxima${NC}      ← encerra e salva estado"
echo ""
echo -e "Documentação: ${CYAN}https://github.com/${REPO}${NC}"
