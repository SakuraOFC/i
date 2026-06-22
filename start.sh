#!/bin/bash
# Script inicial que descarga y ejecuta el menú real

REPO_URL="https://raw.githubusercontent.com/The-DiosBot-MD/i/main"
TEMP_DIR="/tmp/the-diosbot-$$"
mkdir -p "$TEMP_DIR"

# Descargar el menú real
curl -sSL -o "$TEMP_DIR/menu_real.sh" "$REPO_URL/menu_real.sh"
chmod +x "$TEMP_DIR/menu_real.sh"

# Ejecutar el menú real con una terminal interactiva
exec bash -i "$TEMP_DIR/menu_real.sh"
