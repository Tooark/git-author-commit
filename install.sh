#!/usr/bin/env bash
# Instala o arkgit no PATH do usuário (Linux/macOS)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${HOME}/.local/bin"

mkdir -p "$TARGET_DIR"
cp "$SCRIPT_DIR/bin/arkgit" "$TARGET_DIR/arkgit"
chmod +x "$TARGET_DIR/arkgit"

echo "arkgit instalado em $TARGET_DIR/arkgit"

if ! echo ":$PATH:" | grep -q ":$TARGET_DIR:"; then
  echo ""
  echo "Aviso: $TARGET_DIR não está no seu PATH."
  echo "Adicione ao seu ~/.bashrc ou ~/.zshrc:"
  echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
fi

echo ""
echo "Teste com: arkgit help"
