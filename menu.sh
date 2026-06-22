#!/bin/bash

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ============================================
# CONFIGURACIÓN
# ============================================
REPO_URL="https://raw.githubusercontent.com/The-DiosBot-MD/i/main"
TEMP_DIR="/tmp/the-diosbot-$$"
mkdir -p "$TEMP_DIR"

# ============================================
# FUNCIONES
# ============================================

# Limpiar al salir
cleanup() {
    echo -e "\n${YELLOW}🧹 Limpiando archivos temporales...${NC}"
    rm -rf "$TEMP_DIR"
    echo -e "${GREEN}✅ Todo limpiado. ¡Hasta luego!${NC}\n"
    exit 0
}

trap cleanup EXIT INT TERM

# Descargar todos los scripts
download_all_scripts() {
    echo -e "${BLUE}📥 Descargando scripts...${NC}"
    for script in bluepin.sh dash.sh panel.sh paymenter.sh; do
        echo -ne "  Descargando $script... "
        if curl -sSL -o "$TEMP_DIR/$script" "$REPO_URL/$script" 2>/dev/null; then
            chmod +x "$TEMP_DIR/$script"
            echo -e "${GREEN}✓${NC}"
        else
            echo -e "${RED}✗ Falló${NC}"
        fi
    done
    echo -e "${GREEN}✅ Descarga completada${NC}\n"
    sleep 1
}

# Mostrar menú
show_menu() {
    clear
    echo -e "${CYAN}${BOLD}"
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║     The DiosBot-MD - Script Manager                     ║"
    echo "║          (Modo Auto-Destructivo)                        ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}${BOLD}   📋 MENÚ PRINCIPAL${NC}"
    echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e " ${CYAN}[${YELLOW}1${CYAN}]${NC} ${GREEN}🔵 BluePin - Instalar y configurar${NC}"
    echo -e " ${CYAN}[${YELLOW}2${CYAN}]${NC} ${MAGENTA}📊 Dash - Instalar y configurar${NC}"
    echo -e " ${CYAN}[${YELLOW}3${CYAN}]${NC} ${BLUE}🖥️  Panel - Instalar y configurar${NC}"
    echo -e " ${CYAN}[${YELLOW}4${CYAN}]${NC} ${GREEN}💕 Paymenter - Instalar y configurar${NC}"
    echo -e " ${CYAN}[${YELLOW}5${CYAN}]${NC} ${RED}🚪 Salir (Borrará todo)${NC}"
    echo ""
    echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -ne "${YELLOW}👉 Ingresa tu opción [1-5]: ${NC}"
}

# Ejecutar script
run_script() {
    local script_name=$1
    clear
    echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}${BOLD}   🚀 EJECUTANDO: $script_name${NC}"
    echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
    
    if [ -f "$TEMP_DIR/$script_name" ]; then
        bash "$TEMP_DIR/$script_name"
        echo -e "\n${GREEN}✅ Script finalizado${NC}"
    else
        echo -e "${RED}❌ Error: No se encontró $script_name${NC}"
    fi
    
    echo ""
    echo -ne "${BLUE}📌 Presiona [ENTER] para continuar...${NC}"
    read -r input
}

# ============================================
# PROGRAMA PRINCIPAL
# ============================================

# Descargar scripts primero
download_all_scripts

# Bucle principal
while true; do
    show_menu
    read -r option
    
    case $option in
        1) run_script "bluepin.sh" ;;
        2) run_script "dash.sh" ;;
        3) run_script "panel.sh" ;;
        4) run_script "paymenter.sh" ;;
        5) cleanup ;;
        *) 
            echo -e "\n${RED}❌ Opción inválida. Usa 1, 2, 3, 4 o 5${NC}"
            sleep 2
            ;;
    esac
done
