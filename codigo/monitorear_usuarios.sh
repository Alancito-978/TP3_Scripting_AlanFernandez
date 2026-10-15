#!/bin/bash

# Obtener la ruta absoluta del proyecto
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROYECTO_DIR="$(dirname "$SCRIPT_DIR")"

# Definir el archivo de registro
LOG="$PROYECTO_DIR/logs/usuarios_activos_7167.log"

# Crear el directorio de logs si no existe
mkdir -p "$(dirname "$LOG")"

# Crear el archivo con el encabezado si no existe
if [[ ! -f "$LOG" ]]; then
    {
        echo "Legajo: 7167 | Token: 71670529"
        echo "========================================"
    } > "$LOG"
fi

# Obtener fecha y hora
FECHA=$(date '+%Y-%m-%d %H:%M:%S')

# Contar las sesiones de usuarios activos
USUARIOS=$(who | wc -l)

# Registrar la información
echo "$FECHA - Usuarios activos: $USUARIOS" >> "$LOG"

