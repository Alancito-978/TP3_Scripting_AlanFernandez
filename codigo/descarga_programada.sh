#!/bin/bash

# Verificar que se haya recibido una URL
if [[ $# -ne 1 ]]; then
    echo "Uso: $0 <URL>"
    exit 1
fi

URL="$1"

# Obtener la ruta absoluta del proyecto
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROYECTO_DIR="$(dirname "$SCRIPT_DIR")"
DESTINO="$PROYECTO_DIR/descargas"

# Validar que la URL tenga un formato válido
if [[ ! "$URL" =~ ^https?:// ]]; then
    echo "Error: debe proporcionar una URL HTTP o HTTPS válida."
    exit 1
fi

# Crear la carpeta de descargas
if ! mkdir -p "$DESTINO"; then
    echo "Error: no se pudo crear la carpeta de descargas."
    exit 1
fi

# Descargar el archivo
if wget -P "$DESTINO" "$URL"; then
    echo "Descarga realizada correctamente."
    echo "Ubicación: $DESTINO"
else
    echo "Error: no se pudo descargar el archivo."
    exit 1
fi
