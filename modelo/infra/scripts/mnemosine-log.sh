#!/bin/bash
# Utilitário de logging para skills
# Uso: mnemosine-log.sh <skill> <projeto> <status> <duracao> <descricao>
#
# Exemplos:
#   mnemosine-log.sh auditar-php meu-app CONCLUIDO 45s "12 arquivos, 3 violações ERRO"
#   mnemosine-log.sh iniciar - CONCLUIDO 2s "Sessão iniciada, 4 memórias carregadas"
#   mnemosine-log.sh auditar-seguranca meu-app ERRO 12s "Falha ao ler arquivo"
#
# Configuração:
#   MNEMOSINE_LOGS_DIR — diretório de logs (padrão: ../../../logs relativo ao script)

LOGS_DIR="${MNEMOSINE_LOGS_DIR:-$(dirname "$(dirname "$(dirname "$(readlink -f "$0")")")")/logs}"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

SKILL="${1:?Skill obrigatória}"
PROJETO="${2:--}"
STATUS="${3:?Status obrigatório}"
DURACAO="${4:--}"
DESCRICAO="${5:?Descrição obrigatória}"

ENTRADA="[${TIMESTAMP}] [${SKILL}] [${PROJETO}] [${STATUS}] [${DURACAO}] — ${DESCRICAO}"

# Criar diretórios se não existirem
mkdir -p "${LOGS_DIR}/skills" "${LOGS_DIR}/projetos"

# Log geral
echo "$ENTRADA" >> "${LOGS_DIR}/atividade.log"

# Log por skill
echo "$ENTRADA" >> "${LOGS_DIR}/skills/${SKILL}.log"

# Log por projeto (se não for global)
if [ "$PROJETO" != "-" ]; then
    echo "$ENTRADA" >> "${LOGS_DIR}/projetos/${PROJETO}.log"
fi
