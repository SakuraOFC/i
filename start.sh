#!/bin/bash
# Script lanzador para ejecutar el menú correctamente

# Descargar el menú
curl -sSL -o /tmp/the-diosbot-menu.sh https://raw.githubusercontent.com/The-DiosBot-MD/i/main/menu.sh

# Dar permisos
chmod +x /tmp/the-diosbot-menu.sh

# Ejecutar el menú (esto asegura que read funcione)
exec bash /tmp/the-diosbot-menu.sh
