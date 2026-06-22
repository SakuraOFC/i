#!/bin/bash

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuración
REPO_URL="https://raw.githubusercontent.com/Sakura0FC/i/main"

# Crear carpeta temporal
TEMP_DIR="/tmp/the-diosbot"
mkdir -p "$TEMP_DIR"

# Limpiar al salir
cleanup() {
    echo -e "\n${YELLOW}🗑️  Borrando carpeta temporal...${NC}"
    rm -rf "$TEMP_DIR"
    echo -e "${GREEN}✅ Todo eliminado${NC}"
    exit 0
}
trap cleanup EXIT INT TERM

# Función para descargar scripts
descargar_scripts() {
    echo -e "${BLUE}📥 Descargando scripts...${NC}"
    
    # Lista de scripts
    scripts=("bluepin.sh" "dash.sh" "panel.sh" "paymenter.sh")
    
    for script in "${scripts[@]}"; do
        echo -n "  $script... "
        curl -sSL -o "$TEMP_DIR/$script" "$REPO_URL/$script"
        if [ -s "$TEMP_DIR/$script" ]; then
            chmod +x "$TEMP_DIR/$script"
            echo -e "${GREEN}OK${NC}"
        else
            echo -e "${RED}FALLO${NC}"
            rm -f "$TEMP_DIR/$script"
        fi
    done
}

# Función para ejecutar script
ejecutar() {
    local script=$1
    clear
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}🚀 EJECUTANDO: $script${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
    
    if [ -f "$TEMP_DIR/$script" ]; then
        bash "$TEMP_DIR/$script"
        echo -e "\n${GREEN}✅ Terminado${NC}"
    else
        echo -e "${RED}❌ Script no encontrado${NC}"
    fi
    
    echo ""
    echo -ne "${BLUE}Presiona ENTER para continuar...${NC}"
    read
}

# Menú
menu() {
    clear
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════════════╗"
    echo "║       THE DIOSBOT-MD MANAGER                  ║"
    echo "╚════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo -e "${GREEN}1) BluePin${NC}"
    echo -e "${GREEN}2) Dash${NC}"
    echo -e "${GREEN}3) Panel${NC}"
    echo -e "${GREEN}4) Paymenter${NC}"
    echo -e "${RED}5) SALIR (borra todo)${NC}"
    echo ""
    echo -ne "${YELLOW}Opción [1-5]: ${NC}"
}

# ============================================
# PROGRAMA PRINCIPAL
# ============================================

descargar_scripts

while true; do
    menu
    read opcion
    
    case $opcion in
        1) ejecutar "bluepin.sh" ;;
        2) ejecutar "dash.sh" ;;
        3) ejecutar "panel.sh" ;;
        4) ejecutar "paymenter.sh" ;;
        5) cleanup ;;
        *) echo -e "${RED}Opción inválida${NC}"; sleep 1 ;;
    esac
done
