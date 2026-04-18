#!/bin/bash
# Mnemósine — Installer for existing projects
# Usage: curl -sSL https://raw.githubusercontent.com/jocsaacesar/mnemosine/main/en/install.sh | bash
# Or:    bash install.sh [--full | --minimal | --choose]
#
# Installs the Mnemósine framework in the current directory.
# After installing, open Claude Code and type /get-started to personalize everything.

set -euo pipefail

REPO="jocsaacesar/mnemosine"
BRANCH="main"
RAW_URL="https://raw.githubusercontent.com/${REPO}/${BRANCH}"
TEMP_DIR=""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

info()  { echo -e "${CYAN}→${NC} $1"; }
ok()    { echo -e "${GREEN}✓${NC} $1"; }
warn()  { echo -e "${YELLOW}!${NC} $1"; }
fail()  { echo -e "${RED}✗${NC} $1"; exit 1; }

cleanup() {
    [ -n "$TEMP_DIR" ] && rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

# ─────────────────────────────────────────────
# Checks
# ─────────────────────────────────────────────

if [ ! -d ".git" ]; then
    warn "This directory is not a git repository."
    read -rp "Continue anyway? (y/N) " resp
    [[ "$resp" =~ ^[yY]$ ]] || exit 0
fi

if [ -f ".claude/skills/start/SKILL.md" ]; then
    warn "Mnemósine already appears to be installed in this project."
    read -rp "Reinstall and overwrite? (y/N) " resp
    [[ "$resp" =~ ^[yY]$ ]] || exit 0
fi

# ─────────────────────────────────────────────
# Download repository
# ─────────────────────────────────────────────

info "Downloading Mnemósine..."

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

ok "Download complete."

# ─────────────────────────────────────────────
# Installation mode
# ─────────────────────────────────────────────

MODE="${1:-}"

if [ -z "$MODE" ]; then
    echo ""
    echo -e "${BOLD}How would you like to install Mnemósine?${NC}"
    echo ""
    echo "  1) Full        — Skills, auditors, standards, learning, everything."
    echo "  2) Essential   — Session skills + learning + memory. No auditors/standards."
    echo "  3) Choose      — Select component by component."
    echo ""
    read -rp "Option (1/2/3): " choice
    case "$choice" in
        1) MODE="--full" ;;
        2) MODE="--minimal" ;;
        3) MODE="--choose" ;;
        *) MODE="--full" ;;
    esac
fi

# Component flags
INSTALL_SKILLS=true
INSTALL_AUDITORS=false
INSTALL_STANDARDS=false
INSTALL_PROJECT=false
INSTALL_LEARNING=true
INSTALL_PLANS=true
INSTALL_MEMORY=true
INSTALL_TEMPLATES=false
INSTALL_INFRA=true
INSTALL_GUIDES=false
INSTALL_EXAMPLES=false
INSTALL_ORCHESTRATOR=false

case "$MODE" in
    --full|--tudo)
        INSTALL_AUDITORS=true
        INSTALL_STANDARDS=true
        INSTALL_PROJECT=true
        INSTALL_TEMPLATES=true
        INSTALL_GUIDES=true
        INSTALL_EXAMPLES=true
        INSTALL_ORCHESTRATOR=true
        ;;
    --minimal|--minimo)
        # Defaults already cover the minimum
        ;;
    --choose|--escolher)
        echo ""
        ask_yn() {
            read -rp "$1 (y/N) " resp
            [[ "$resp" =~ ^[yY]$ ]]
        }

        ask_yn "Code auditors? (PHP, JS, OOP, security, etc.)" && INSTALL_AUDITORS=true
        ask_yn "Minimum standards? (250+ auditable rules per stack)" && INSTALL_STANDARDS=true
        ask_yn "Pipeline templates? (planner, executor, tester, auditor)" && INSTALL_PROJECT=true
        ask_yn "Orchestrator? (manual for when to call each skill)" && INSTALL_ORCHESTRATOR=true
        ask_yn "Reusable templates? (skill, identity, memory templates)" && INSTALL_TEMPLATES=true
        ask_yn "Usage guides? (how to write CLAUDE.md, create skills, etc.)" && INSTALL_GUIDES=true
        ask_yn "Reference example? (Leland Hawkins — full implementation)" && INSTALL_EXAMPLES=true
        echo ""
        ;;
esac

# ─────────────────────────────────────────────
# Installation
# ─────────────────────────────────────────────

echo ""
info "Installing components..."

# Global skills → .claude/skills/
if [ "$INSTALL_SKILLS" = true ]; then
    mkdir -p .claude/skills
    cp -r "$MODELO"/skills/*/ .claude/skills/ 2>/dev/null || true
    ok "10 global skills → .claude/skills/"
fi

# Auditors → library/auditors/
if [ "$INSTALL_AUDITORS" = true ]; then
    mkdir -p library/auditors
    cp -r "$MODELO"/biblioteca/auditoras/*/ library/auditors/ 2>/dev/null || true
    ok "7 auditors → library/auditors/"
fi

# Minimum standards
if [ "$INSTALL_STANDARDS" = true ]; then
    mkdir -p standards
    cp "$MODELO"/padroes-minimos/*.md standards/ 2>/dev/null || true
    ok "9 minimum standards → standards/"
fi

# Pipeline templates
if [ "$INSTALL_PROJECT" = true ]; then
    mkdir -p library/project
    cp -r "$MODELO"/biblioteca/projeto/*/ library/project/ 2>/dev/null || true
    ok "4 pipeline templates → library/project/"
fi

# Learning
if [ "$INSTALL_LEARNING" = true ]; then
    mkdir -p learning/{errors,context,fix,prevention}
    cp "$MODELO"/aprendizado/README.md learning/ 2>/dev/null || true
    ok "Learning system → learning/"
fi

# Plans
if [ "$INSTALL_PLANS" = true ]; then
    mkdir -p plans/{backlog,operational,emergency,archive}
    ok "Plan management → plans/"
fi

# Memory
if [ "$INSTALL_MEMORY" = true ]; then
    mkdir -p memory
    cp "$MODELO"/memoria/MEMORY.md memory/ 2>/dev/null || true
    ok "Memory system → memory/"
fi

# Orchestrator
if [ "$INSTALL_ORCHESTRATOR" = true ]; then
    cp "$MODELO"/ORCHESTRATOR.md . 2>/dev/null || true
    ok "Orchestrator → ORCHESTRATOR.md"
fi

# Templates
if [ "$INSTALL_TEMPLATES" = true ]; then
    mkdir -p templates/skill-template templates/skill-project
    cp -r "$MODELO"/modelos/* templates/ 2>/dev/null || true
    ok "Reusable templates → templates/"
fi

# Infra (telemetry script)
if [ "$INSTALL_INFRA" = true ]; then
    mkdir -p infra/scripts
    cp "$MODELO"/infra/scripts/mnemosine-log.sh infra/scripts/ 2>/dev/null || true
    chmod +x infra/scripts/mnemosine-log.sh 2>/dev/null || true
    ok "Telemetry script → infra/scripts/"
fi

# Guides
if [ "$INSTALL_GUIDES" = true ]; then
    mkdir -p guides
    cp "$GUIAS"/*.md guides/ 2>/dev/null || true
    ok "5 usage guides → guides/"
fi

# Examples
if [ "$INSTALL_EXAMPLES" = true ]; then
    mkdir -p examples
    cp -r "$EXEMPLOS"/* examples/ 2>/dev/null || true
    ok "Reference example → examples/"
fi

# CLAUDE.md placeholder (if it doesn't exist)
if [ ! -f "CLAUDE.md" ]; then
    cp "$MODELO"/CLAUDE.md . 2>/dev/null || true
    ok "Identity template → CLAUDE.md"
else
    warn "CLAUDE.md already exists — not overwritten. The template is in templates/CLAUDE.md"
    if [ "$INSTALL_TEMPLATES" != true ]; then
        mkdir -p templates
        cp "$MODELO"/CLAUDE.md templates/CLAUDE.md 2>/dev/null || true
    fi
fi

# ─────────────────────────────────────────────
# Done
# ─────────────────────────────────────────────

echo ""
echo -e "${GREEN}${BOLD}Mnemósine installed.${NC}"
echo ""
echo -e "Next step:"
echo -e "  ${CYAN}claude${NC}              ← open Claude Code"
echo -e "  ${CYAN}/get-started${NC}        ← the AI interviews you and personalizes everything"
echo ""
echo -e "Available skills after onboarding:"
echo -e "  ${CYAN}/start${NC}              ← begin a session"
echo -e "  ${CYAN}/wrap-up${NC}            ← end session and save state"
echo ""
echo -e "Documentation: ${CYAN}https://github.com/${REPO}${NC}"
