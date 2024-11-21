#!/bin/bash

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Limpiar pantalla
clear

# ASCII Art Banner con color
echo -e "${CYAN}"
echo "
 _____                           _____                     
|   __|___ ___ _ _ _ ___ ___   |   __|___ ___ ___ ___ 
|__   | . | .'| | | |   |   |  |__   | . | .'|  _| -_|
|_____|  _|__,|_____|_|_|_|_|  |_____|  _|__,|___|___|
      |_|                            |_|                
"
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}              Desarrollado por UserZero075${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"

# Función para mostrar progreso
show_progress() {
    echo -e "\r${GREEN}[${1}]${NC} ${2}"
}

# Función para mostrar error
show_error() {
    echo -e "${RED}[ERROR] ${1}${NC}"
}

# Validación de entrada
while true; do
    echo -e "\n${CYAN}[?]${NC} Por favor, ingrese el tamaño deseado de swap en GB (1-64): "
    read swap_size
    if [[ "$swap_size" =~ ^[0-9]+$ ]] && [ "$swap_size" -ge 1 ] && [ "$swap_size" -le 64 ]; then
        break
    else
        show_error "Por favor ingrese un número válido entre 1 y 64"
    fi
done

# Convertir GB a bytes (para dd)
count=$((swap_size * 1024))

echo -e "\n${YELLOW}[+]${NC} Iniciando proceso de configuración de swap..."
echo -e "${CYAN}[i]${NC} Tamaño seleccionado: ${YELLOW}${swap_size}GB${NC}"

# Verificar espacio disponible
free_space=$(df -BG / | awk 'NR==2 {print $4}' | sed 's/G//')
if [ "$free_space" -lt "$swap_size" ]; then
    show_error "No hay suficiente espacio disponible. Espacio libre: ${free_space}GB"
    exit 1
fi

# Desactivar swap actual
echo -e "\n${YELLOW}[*]${NC} Desactivando swap actual..."
sudo swapoff -a 2>/dev/null
show_progress "✓" "Swap desactivado exitosamente"

# Crear archivo swap
echo -e "\n${YELLOW}[*]${NC} Creando nuevo archivo swap..."
echo -e "${CYAN}[i]${NC} Esto puede tomar varios minutos dependiendo del tamaño..."
sudo dd if=/dev/zero of=/swapfile bs=1M count=$count status=progress
show_progress "✓" "Archivo swap creado exitosamente"

# Establecer permisos
echo -e "\n${YELLOW}[*]${NC} Configurando permisos..."
sudo chmod 0600 /swapfile
show_progress "✓" "Permisos configurados correctamente"

# Configurar swap
echo -e "\n${YELLOW}[*]${NC} Preparando área de swap..."
sudo mkswap /swapfile
sudo swapon /swapfile
show_progress "✓" "Swap activado y configurado"

# Banner final
echo -e "\n${GREEN}════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}"
echo "
 _____                           _____                     
|   __|___ ___ _ _ _ ___ ___   |   __|___ ___ ___ ___ 
|__   | . | .'| | | |   |   |  |__   | . | .'|  _| -_|
|_____|  _|__,|_____|_|_|_|_|  |_____|  _|__,|___|___|
      |_|                            |_|                
"
echo -e "${GREEN}           ¡Configuración Completada con Éxito!${NC}"
echo -e "${YELLOW}              Script desarrollado por UserZero075!${NC}"
echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}"

# Mostrar información final del swap
echo -e "\n${CYAN}[i]${NC} Información del swap configurado:"
free -h | grep -i swap
