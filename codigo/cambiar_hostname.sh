#!/bin/bash

# Verificar privilegios de administrador
if [[ $EUID -ne 0 ]]; then
    echo "Error: este script requiere privilegios de administrador."
    echo "Ejecutelo utilizando sudo."
    exit 1
fi

# Verificar que se haya recibido un nombre
if [[ $# -ne 1 ]]; then
    echo "Uso: sudo $0 <nuevo_hostname>"
    exit 1
fi

NUEVO_HOSTNAME="$1"
HOSTNAME_ANTERIOR=$(hostnamectl --static)

# Validar el formato del hostname solicitado
if [[ ! "$NUEVO_HOSTNAME" =~ ^curzas-alumno-[0-9]+$ ]]; then
    echo "Error: el hostname debe tener el formato curzas-alumno-7167."
    exit 1
fi

# Evitar cambios innecesarios
if [[ "$NUEVO_HOSTNAME" == "$HOSTNAME_ANTERIOR" ]]; then
    echo "El hostname ya tiene ese valor."
    exit 0
fi

# Verificar que los archivos de configuración existan
if [[ ! -f /etc/hostname || ! -f /etc/hosts ]]; then
    echo "Error: no se encontraron los archivos de configuración necesarios."
    exit 1
fi

# Guardar copias de seguridad antes de modificar los archivos
cp -a /etc/hostname /etc/hostname.bak-7167 || {
    echo "Error: no se pudo respaldar /etc/hostname."
    exit 1
}

cp -a /etc/hosts /etc/hosts.bak-7167 || {
    echo "Error: no se pudo respaldar /etc/hosts."
    exit 1
}

# Actualizar /etc/hostname
if ! printf '%s\n' "$NUEVO_HOSTNAME" > /etc/hostname; then
    echo "Error: no se pudo modificar /etc/hostname."
    exit 1
fi

# Actualizar el nombre estático anterior en /etc/hosts, si aparece
if grep -qw "$HOSTNAME_ANTERIOR" /etc/hosts; then
    if ! sed -i "s/\\b${HOSTNAME_ANTERIOR}\\b/${NUEVO_HOSTNAME}/g" /etc/hosts; then
        cp -a /etc/hostname.bak-7167 /etc/hostname
        echo "Error: no se pudo actualizar /etc/hosts."
        exit 1
    fi
else
    echo "Aviso: el hostname anterior no aparece en /etc/hosts; no se reemplazó ninguna entrada."
fi

# Aplicar el nuevo hostname
if ! hostnamectl set-hostname "$NUEVO_HOSTNAME"; then
    cp -a /etc/hostname.bak-7167 /etc/hostname
    cp -a /etc/hosts.bak-7167 /etc/hosts
    echo "Error: no se pudo establecer el nuevo hostname. Se restauraron los archivos."
    exit 1
fi

echo "Hostname actualizado correctamente."
echo "Anterior: $HOSTNAME_ANTERIOR"
echo "Nuevo: $NUEVO_HOSTNAME"
echo "Copias de seguridad: /etc/hostname.bak-7167 y /etc/hosts.bak-7167"
