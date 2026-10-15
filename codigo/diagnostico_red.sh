#!/bin/bash

# Obtener la ruta absoluta del proyecto
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROYECTO_DIR="$(dirname "$SCRIPT_DIR")"

# Definir el archivo de registro y el gateway
LOG="$PROYECTO_DIR/logs/ping_report_7167.log"
GATEWAY="192.168.1.1"

# Crear el directorio de logs si no existe
mkdir -p "$(dirname "$LOG")"

# Obtener fecha y hora
FECHA=$(date '+%Y-%m-%d %H:%M:%S')

# Crear el encabezado si el archivo no existe
if [[ ! -f "$LOG" ]]; then
    {
        echo "Legajo: 7167"
        echo "Gateway monitoreado: $GATEWAY"
        echo "========================================"
    } > "$LOG"
fi

# Registrar el inicio del diagnóstico
echo "[$FECHA] Comprobando gateway $GATEWAY" >> "$LOG"

# Comprobar la conectividad con el gateway
if ping -c 1 -W 2 "$GATEWAY" >> "$LOG" 2>&1; then
    echo "[$FECHA] Estado: OK" >> "$LOG"
else
    echo "[$FECHA] Estado: ERROR - Gateway no responde" >> "$LOG"
fi

echo "----------------------------------------" >> "$LOG"

