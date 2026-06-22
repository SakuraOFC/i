#!/bin/bash
# Script lanzador para ejecutar el menú correctamente

REPO_USER="Sakura0FC"  # Cambia esto si es diferente
REPO_NAME="i"
BRANCH="main"
RAW_URL="https://raw.githubusercontent.com/$REPO_USER/$REPO_NAME/$BRANCH"

echo -e "\033[0;34m📥 Descargando menú desde $RAW_URL/menu.sh...\033[0m"

# Descargar el menú con verificación
if curl -sSL -o /tmp/the-diosbot-menu.sh "$RAW_URL/menu.sh"; then
    if [ -s /tmp/the-diosbot-menu.sh ]; then
        echo -e "\033[0;32m✅ Menú descargado correctamente\033[0m"
        chmod +x /tmp/the-diosbot-menu.sh
        echo -e "\033[0;34m🚀 Ejecutando menú...\033[0m\n"
        exec bash /tmp/the-diosbot-menu.sh
    else
        echo -e "\033[0;31m❌ Error: El archivo descargado está vacío\033[0m"
        echo -e "\033[0;33mVerifica que el archivo menu.sh exista en tu repositorio\033[0m"
        exit 1
    fi
else
    echo -e "\033[0;31m❌ Error: No se pudo descargar menu.sh\033[0m"
    echo -e "\033[0;33mVerifica la URL: $RAW_URL/menu.sh\033[0m"
    exit 1
fi
