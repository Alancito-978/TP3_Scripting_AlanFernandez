#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROYECTO_DIR="$(dirname "$SCRIPT_DIR")"

ARCHIVO="${1:-/var/log/syslog}"
SALIDA="$PROYECTO_DIR/logs/reporte_errores_7167.txt"

# Verificar que exista el archivo de entrada
if [[ ! -f "$ARCHIVO" ]]; then
    echo "Error: no existe el archivo $ARCHIVO"
    exit 1
fi

# Crear el directorio de salida
if ! mkdir -p "$(dirname "$SALIDA")"; then
    echo "Error: no se pudo crear el directorio de salida."
    exit 1
fi

# Encabezado del reporte
{
    echo "REPORTE DE ERRORES DEL SISTEMA"
    echo "Legajo: 7167"
    echo "Archivo analizado: $ARCHIVO"
    echo "=============================================================="
    printf "%-7s %-8s %-18s %-50s\n" \
        "Fecha" "Hora" "Proceso" "Mensaje"
    echo "------------------------------------------------------------------------------------------"
} > "$SALIDA"

# Filtrar y procesar los registros
awk '
tolower($0) ~ /error|fail|critical/ {
    fecha = $1 " " $2
    hora = $3
    proceso = $5

    gsub(/:$/, "", proceso)
    gsub(/\[[0-9]+\]/, "", proceso)

    mensaje = ""
    for (i = 6; i <= NF; i++) {
        mensaje = mensaje $i " "
    }

    sub(/[[:space:]]+$/, "", mensaje)
    mensaje = substr(mensaje, 1, 50)

    printf "%-7s %-8s %-18s %-50s\n", \
        fecha, hora, proceso, mensaje
}
' "$ARCHIVO" >> "$SALIDA"

echo "Reporte generado en: $SALIDA"
