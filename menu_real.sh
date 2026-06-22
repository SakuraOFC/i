#!/bin/bash
# Script del menú real que se ejecuta localmente

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Directorio temporal (se pasa como variable desde el script padre)
if [ -z "$TEMP_DIR" ]; then
    TEMP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

# Función para limpiar al salir
cleanup() {
    echo -e "\n${YELLOW}🧹 Limpiando archivos temporales...${NC}"
    rm -rf "$TEMP_DIR"
    echo -e "${GREEN}✅ Todo limpiado. ¡Hasta luego!${NC}\n"
    exit 0
}

trap cleanup EXIT INT TERM

# Función para mostrar menú
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
    echo -e " ${CYAN}[${YELLOW}1${CYAN}]${NC} ${GREEN}💕 Paymenter - Instalar y configurar${NC}"
    echo -e " ${CYAN}[${YELLOW}4${CYAN}]${NC} ${RED}🚪 Salir (Borrará todo)${NC}"
    echo ""
    echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -ne "${YELLOW}👉 Selecciona una opción [1-5]: ${NC}"
}

# Función para ejecutar script
run_script() {
    local script_name=$1
    local script_url="https://raw.githubusercontent.com/The-DiosBot-MD/i/main/$script_name"
    local temp_script="$TEMP_DIR/$script_name"
    
    clear
    echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}${BOLD}   🚀 EJECUTANDO: $script_name${NC}"
    echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
    
    # Descargar el script específico si no existe
    if [ ! -f "$temp_script" ]; then
        echo -e "${BLUE}📥 Descargando $script_name...${NC}"
        curl -sSL -o "$temp_script" "$script_url"
        chmod +x "$temp_script"
        echo -e "${GREEN}✅ Descargado${NC}\n"
    fi
    
    # Ejecutar el script
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
    bash "$temp_script"
    
    echo -e "\n${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✅ Script finalizado${NC}"
    echo ""
    echo -ne "${BLUE}📌 Presiona [ENTER] para volver al menú...${NC}"
    read -r
}

# Descargar todos los scripts al inicio
echo -e "${BLUE}📥 Preparando entorno...${NC}"
for script in bluepin.sh dash.sh panel.sh; do
    curl -sSL -o "$TEMP_DIR/$script" "https://raw.githubusercontent.com/The-DiosBot-MD/i/main/$script"
    chmod +x "$TEMP_DIR/$script" 2>/dev/null
done
echo -e "${GREEN}✅ Entorno listo${NC}\n"
sleep 1

# Bucle principal
while true; do
    show_menu
    read -r option
    
    case $option in
        1)
            run_script "bluepin.sh"
            ;;
        2)
            run_script "dash.sh"
            ;;
        3)
            run_script "panel.sh"
            ;;
        4)
            run_script "paymer.sh"
            ;;
        5)
            cleanup
            ;;
        *)
            echo -e "\n${RED}❌ Opción inválida. Usa 1, 2, 3 ,etc.${NC}"
            sleep 2
            ;;
    esac
done
