#!/usr/bin/env bash
# Falha se algum arquivo em um caminho protegido foi REMOVIDO entre BASE_REF e HEAD_REF.
# Evita, por exemplo, que um merge mal resolvido apague migrations do EF Core.
#
# Uso: scripts/check-protected-paths.sh [BASE_REF] [HEAD_REF]
#   BASE_REF padrão: origin/develop
#   HEAD_REF padrão: HEAD
set -euo pipefail

PROTECTED_PATHS=(
  ':(glob)src/**/Migrations/**'
  '.github/workflows'
  'docker-compose.yml'
  'Dockerfile'
  'scripts/01-extensions.sql'
)

BASE_REF="${1:-origin/develop}"
HEAD_REF="${2:-HEAD}"

echo "Verificando remoções em caminhos protegidos entre $BASE_REF e $HEAD_REF..."
printf '  - %s\n' "${PROTECTED_PATHS[@]}"
echo

deleted=$(git diff --name-status --diff-filter=D "$BASE_REF" "$HEAD_REF" -- "${PROTECTED_PATHS[@]}" || true)

if [ -n "$deleted" ]; then
  echo "ERRO: os arquivos abaixo foram removidos em caminhos protegidos:"
  echo "$deleted"
  echo
  echo "Se a remoção for intencional, ajuste PROTECTED_PATHS neste script e explique o motivo na PR."
  exit 1
fi

echo "OK: nenhum arquivo protegido removido."
