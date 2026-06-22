#!/bin/bash

# ============================================
# THE DIOSBOT-MD - SCRIPT MANAGER
# ============================================

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Configuración
REPO_USER="Sakura0FC"
REPO_NAME="i"
BRANCH="main"
RAW_URL="https://raw.githubusercontent.com/$REPO_USER/$REPO_NAME/$BRANCH"

# Crear directorio temporal
TEMP_DIR="/tmp/the-diosbot-$$"
mkdir -p "$TEMP_DIR"

# ============================================
# FUNCIONES
# ============================================

cleanup() {
    echo -e "\n${YELLOW}🧹 Limpiando archivos temporales...${NC}"
    rm -rf "$TEMP_DIR"
    echo -e "${GREEN}✅ Todo limpiado. ¡Hasta luego!${NC}\n"
    exit 0
}

trap cleanup EXIT INT TERM

# Descargar script
download_script() {
    local script_name=$1
    local script_url="$RAW_URL/$script_name"
    local temp_script="$TEMP_DIR/$script_name"
    
    echo -ne "  Descargando $script_name... "
    if curl -sSL -o "$temp_script" "$script_url" 2>/dev/null; then
        if [ -s "$temp_script" ] && ! grep -q "^404:" "$temp_script"; then
            chmod +x "$temp_script"
            echo -e "${GREEN}✓${NC}"
            return 0
        else
            echo -e "${RED}✗ Archivo vacío o no encontrado${NC}"
            rm -f "$temp_script"
            return 1
        fi
    else
        echo -e "${RED}✗ Falló${NC}"
        return 1
    fi
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
    local script_path="$TEMP_DIR/$script_name"
    
    clear
    echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}${BOLD}   🚀 EJECUTANDO: $script_name${NC}"
    echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
    
    if [ -f "$script_path" ]; then
        bash "$script_path"
        echo -e "\n${GREEN}✅ Script finalizado${NC}"
    else
        echo -e "${RED}❌ Error: No se encontró $script_name${NC}"
        echo -e "${YELLOW}💡 Intentando descargar ahora...${NC}"
        if download_script "$script_name"; then
            bash "$script_path"
            echo -e "\n${GREEN}✅ Script finalizado${NC}"
        else
            echo -e "${RED}❌ No se pudo descargar $script_name${NC}"
            echo -e "${YELLOW}💡 Verifica que el archivo exista en: $RAW_URL/$script_name${NC}"
        fi
    fi
    
    echo ""
    echo -ne "${BLUE}📌 Presiona [ENTER] para continuar...${NC}"
    read -r
}

# ============================================
# PROGRAMA PRINCIPAL
# ============================================

echo -e "${BLUE}📥 Preparando entorno...${NC}"

# Descargar todos los scripts
echo -e "${BLUE}📥 Descargando scripts desde GitHub...${NC}"
scripts=("bluepin.sh" "dash.sh" "panel.sh" "paymenter.sh")

for script in "${scripts[@]}"; do
    download_script "$script"
done

echo -e "${GREEN}✅ Entorno listo${NC}\n"
sleep 1

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
