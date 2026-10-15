# Trabajo Práctico N.º 3
## Automatización de tareas, servicios y procesamiento de registros en Linux

**Alumno:** Alan Fernandez  
**Legajo:** 7167  
**Token personal:** 71670529  
**DNI:** 45.210.529  
**Carrera:** Tecnicatura Superior en Administración de Sistemas y Software Libre  
**Institución:** CURZAS - Universidad Nacional del Comahue  
**Año:** 2026

---

## Descripción del trabajo práctico

El objetivo de este trabajo práctico es aplicar herramientas de automatización y administración de sistemas Linux mediante scripts desarrollados en Bash, la programación de tareas con Cron y At, la creación de servicios y temporizadores con Systemd, la modificación controlada del hostname y el procesamiento de registros del sistema utilizando AWK.

Durante el desarrollo se crearon scripts que permiten automatizar tareas periódicas, registrar información en archivos de log, programar descargas, verificar la conectividad de red, modificar la identificación del equipo y filtrar mensajes de error a partir de archivos de registro.

También se realizaron pruebas de funcionamiento para comprobar que los scripts respondan correctamente ante diferentes situaciones, incluyendo validaciones de permisos, parámetros y resultados de ejecución.

Las evidencias de las tareas se encuentran almacenadas en el directorio `capturastp/`, ubicado en la raíz del proyecto.

---

## Estructura del proyecto

```text
tp3-fernandez-7167/
├── codigo/
│   ├── cambiar_hostname.sh
│   ├── descarga_programada.sh
│   ├── diagnostico_red.sh
│   ├── filtrar_errores.sh
│   └── monitorear_usuarios.sh
├── config/
│   ├── monitoreo_7167.service
│   └── monitoreo_7167.timer
├── descargas/
│   ├── master.zip
│   └── master.zip.1
├── logs/
│   ├── ping_report_7167.log
│   ├── reporte_errores_7167.txt
│   └── usuarios_activos_7167.log
├── recursos/
│   └── syslog_prueba.txt
├── capturastp/
│   ├── 2.png
│   ├── tarea5.png
│   ├── cron.png
│   ├── diagnositco.png
│   ├── hostname.png
│   └── monitorear_usuarios.png
└── README.md
```

---

## Tarea 1: Automatización de tareas con Cron

### Objetivo

Desarrollar un script en Bash que registre periódicamente la cantidad de usuarios conectados al sistema y automatizar su ejecución mediante Cron.

### Script utilizado

`codigo/monitorear_usuarios.sh`

El script obtiene la cantidad de sesiones de usuario activas mediante el comando `who | wc -l` y registra la fecha, la hora y el resultado en un archivo de log.

El archivo generado se encuentra en:

`logs/usuarios_activos_7167.log`

De esta manera, se mantiene un registro de las ejecuciones y de la cantidad de usuarios conectados en cada comprobación.

### Configuración de Cron

Se configuró una tarea programada para ejecutar el script cada diez minutos, de lunes a viernes.

La entrada agregada al crontab es:

```cron
*/10 * * * 1-5 /home/alancito/Documentos/tp3-fernandez-7167/codigo/monitorear_usuarios.sh
```

Para consultar la programación configurada se utiliza:

```bash
crontab -l
```

Para comprobar el estado del servicio:

```bash
systemctl is-active cron
```

### Pruebas realizadas

Se ejecutó el script manualmente para verificar que funcione correctamente y genere el registro correspondiente. También se comprobó la configuración del crontab y el estado del servicio Cron.

### Evidencias

- **`capturastp/cron.png`:** muestra la configuración de la tarea programada mediante Cron y la programación establecida.
- **`capturastp/monitorear_usuarios.png`:** muestra la ejecución del script de monitoreo y el registro de la cantidad de usuarios conectados en el archivo de log.

---

## Tarea 2: Programación de tareas con At

### Objetivo

Desarrollar un script que permita descargar un archivo desde una URL y programar su ejecución diferida utilizando la herramienta At.

### Script utilizado

`codigo/descarga_programada.sh`

El script recibe una URL como argumento, valida que corresponda a un enlace HTTP o HTTPS y utiliza `wget` para descargar el archivo.

Los archivos descargados se almacenan en el directorio:

`descargas/`

### Ejecución del script

Para ejecutar manualmente el script se utiliza:

```bash
./codigo/descarga_programada.sh "https://github.com/octocat/Hello-World/archive/refs/heads/master.zip"
```

La descarga también se programó para ejecutarse cinco minutos después mediante At.

La programación se realizó con:

```bash
echo '/home/alancito/Documentos/tp3-fernandez-7167/codigo/descarga_programada.sh "https://github.com/octocat/Hello-World/archive/refs/heads/master.zip"' | at now + 5 minutes
```

### Verificación

Para consultar las tareas pendientes se utiliza:

```bash
atq
```

Para comprobar el estado del servicio:

```bash
systemctl status atd
```

Para verificar los archivos descargados:

```bash
ls -lh descargas/
```

También se utilizó el comando `file` para comprobar el tipo de archivo obtenido.

### Pruebas realizadas

Se ejecutó la descarga de manera manual y programada. Se verificó la existencia del archivo descargado y se comprobó que la tarea programada se ejecutara correctamente.

Una vez finalizada la tarea, la cola de At quedó vacía, ya que no había trabajos pendientes.

### Evidencia

- **`capturastp/2.png`:** muestra las comprobaciones realizadas para verificar la descarga programada, la existencia del archivo descargado y el funcionamiento de At.

---

## Tarea 3: Automatización mediante Systemd

### Objetivo

Crear un servicio y un temporizador de Systemd para ejecutar periódicamente un diagnóstico de conectividad de red.

### Script utilizado

`codigo/diagnostico_red.sh`

El script realiza una comprobación de conectividad mediante el comando `ping` hacia la puerta de enlace de la red local:

`192.168.1.1`

Los resultados se registran en el archivo:

`logs/ping_report_7167.log`

El registro permite consultar la fecha y hora de la comprobación, el resultado obtenido y el estado de la conectividad.

### Servicio Systemd

Se creó el archivo:

`config/monitoreo_7167.service`

Este servicio ejecuta el script de diagnóstico de red. Se configuró como `oneshot`, por lo que inicia el proceso, ejecuta el diagnóstico y finaliza una vez completada la tarea.

La configuración establece que el servicio se ejecute después de que la red esté disponible.

### Temporizador Systemd

Se creó el archivo:

`config/monitoreo_7167.timer`

El temporizador se configuró para realizar una primera ejecución un minuto después del inicio del sistema y repetir la tarea cada cinco minutos.

Los principales parámetros utilizados son:

```ini
[Timer]
OnBootSec=1min
OnUnitActiveSec=5min
Unit=monitoreo_7167.service
```

### Activación y verificación

Para habilitar e iniciar el temporizador se utilizó:

```bash
sudo systemctl enable --now monitoreo_7167.timer
```

Para comprobar su estado:

```bash
systemctl status monitoreo_7167.timer
```

Para consultar los temporizadores programados:

```bash
systemctl list-timers
```

Para consultar el estado del servicio:

```bash
systemctl status monitoreo_7167.service
```

Para revisar los registros de ejecución:

```bash
journalctl -u monitoreo_7167.service
```

Para consultar el resultado del diagnóstico:

```bash
cat logs/ping_report_7167.log
```

### Pruebas realizadas

Se comprobó que el temporizador estuviera habilitado y activo, y que el servicio se ejecutara correctamente.

También se verificó la conectividad con la puerta de enlace `192.168.1.1`. La prueba realizada obtuvo un resultado satisfactorio, sin pérdida de paquetes.

Los resultados quedaron registrados en el archivo de log correspondiente.

### Evidencia

- **`capturastp/diagnositco.png`:** muestra las comprobaciones relacionadas con el diagnóstico de red, la ejecución del servicio y los resultados registrados.

---

## Tarea 4: Modificación del hostname mediante Bash

### Objetivo

Desarrollar un script que permita cambiar el hostname del sistema, incorporando controles de seguridad y validación de los parámetros recibidos.

### Script utilizado

`codigo/cambiar_hostname.sh`

El script permite modificar el nombre del equipo mediante `hostnamectl`, siempre que se cumplan las condiciones establecidas.

Entre las validaciones implementadas se encuentran:

- Comprobar que el script se ejecute con permisos de administrador.
- Verificar que se proporcione un nombre de hostname como argumento.
- Validar que el nombre cumpla con el formato establecido para el trabajo práctico.
- Generar copias de seguridad de los archivos de configuración antes de realizar las modificaciones.
- Informar los errores cuando no se cumplen las condiciones necesarias.

El formato de hostname utilizado para el trabajo es:

`curzas-alumno-7167`

### Ejecución del script

Para ejecutar el script con el nombre correspondiente se utiliza:

```bash
sudo ./codigo/cambiar_hostname.sh curzas-alumno-7167
```

Para verificar el hostname configurado:

```bash
hostname
```

También se puede consultar el contenido del archivo:

```bash
cat /etc/hostname
```

### Pruebas realizadas

Se realizaron tres pruebas para comprobar el funcionamiento de las validaciones:

1. **Ejecución sin permisos de administrador:** se comprobó que el script rechace la ejecución cuando no se utiliza `sudo`.
2. **Nombre inválido:** se verificó que el script rechace un hostname que no cumpla con el formato establecido.
3. **Cambio correcto del hostname:** se ejecutó el script con permisos de administrador y el nombre `curzas-alumno-7167`, comprobando posteriormente el nombre configurado en el sistema.

Estas pruebas permiten verificar tanto el control de permisos como la validación de los parámetros y la ejecución correcta del cambio de hostname.

### Evidencia

- **`capturastp/hostname.png`:** muestra las pruebas realizadas con el script, incluyendo el rechazo de una ejecución sin permisos, la validación de un nombre incorrecto y la comprobación del hostname final.

---

## Tarea 5: Procesamiento de registros con AWK

### Objetivo

Desarrollar un script que permita analizar archivos de registro y extraer las líneas que contengan mensajes relacionados con errores o fallos, utilizando AWK para procesar el contenido.

### Script utilizado

`codigo/filtrar_errores.sh`

El script analiza un archivo de registro y busca mensajes que contengan las siguientes palabras clave:

- `ERROR`
- `FAIL`
- `CRITICAL`

La búsqueda no distingue entre mayúsculas y minúsculas.

Para realizar las pruebas se utilizó el archivo de ejemplo:

`recursos/syslog_prueba.txt`

El reporte generado se almacena en:

`logs/reporte_errores_7167.txt`

### Funcionamiento

El script procesa las líneas del archivo de entrada y selecciona aquellas que contienen alguna de las palabras clave definidas.

Para cada coincidencia, organiza la información en columnas que incluyen:

- Fecha.
- Hora.
- Proceso que generó el mensaje.
- Descripción del mensaje.

Además, elimina el identificador del proceso entre corchetes cuando aparece junto al nombre del proceso y limita la longitud del mensaje para facilitar la lectura del reporte.

### Ejecución del script

Para ejecutar el procesamiento sobre el archivo de prueba se utiliza:

```bash
./codigo/filtrar_errores.sh recursos/syslog_prueba.txt
```

Para consultar el reporte generado:

```bash
cat logs/reporte_errores_7167.txt
```

Antes de ejecutar el script también se comprobó su sintaxis mediante:

```bash
bash -n codigo/filtrar_errores.sh
```

### Pruebas realizadas

Se utilizó un archivo de registro de prueba que contiene mensajes de error, fallos de autenticación, mensajes críticos y registros informativos.

Se verificó que el script identificara los mensajes relevantes y excluyera las líneas que no contenían las palabras clave buscadas.

El resultado fue un reporte con cuatro coincidencias, correspondiente a los mensajes que contenían `ERROR`, `Failed`, `CRITICAL` y `failed`.

### Evidencia

- **`capturastp/tarea5.png`:** muestra la ejecución del script de procesamiento con AWK y el reporte generado a partir del archivo de prueba.

---

## Validación general de los scripts

Durante el desarrollo se comprobó la sintaxis de los scripts mediante `bash -n`.

Para realizar la validación de todos los scripts del directorio `codigo/` se utilizó:

```bash
for script in codigo/*.sh; do
    echo "Verificando: $script"
    bash -n "$script" && echo "Sintaxis correcta" || echo "Error de sintaxis"
done
```

La validación permitió comprobar que los scripts no presentaran errores de sintaxis de Bash.

Además, se realizaron pruebas individuales para verificar el funcionamiento de las tareas programadas, los servicios, las validaciones de hostname y el procesamiento de registros.

---

## Archivos de log generados

Los resultados de las tareas se almacenan en el directorio `logs/`.

| Archivo | Descripción |
|---|---|
| `usuarios_activos_7167.log` | Registra la cantidad de usuarios conectados al sistema y la fecha y hora de cada ejecución. |
| `ping_report_7167.log` | Registra los resultados de las comprobaciones de conectividad de red. |
| `reporte_errores_7167.txt` | Contiene los mensajes identificados por el script de procesamiento de registros con AWK. |

Estos archivos permiten conservar los resultados de las ejecuciones y facilitan la comprobación del funcionamiento de los scripts.

---

## Herramientas utilizadas

Para el desarrollo del trabajo práctico se utilizaron las siguientes herramientas y componentes de Linux:

- **Bash:** lenguaje utilizado para desarrollar los scripts de automatización.
- **Cron:** herramienta para programar tareas periódicas.
- **At:** herramienta para programar la ejecución diferida de tareas.
- **Systemd:** sistema de administración de servicios y temporizadores.
- **AWK:** herramienta de procesamiento y filtrado de texto.
- **wget:** utilidad para descargar archivos desde direcciones web.
- **ping:** herramienta para comprobar la conectividad de red.
- **hostnamectl:** herramienta para consultar y modificar el hostname.
- **systemctl:** herramienta para administrar servicios y temporizadores.
- **journalctl:** herramienta para consultar los registros de servicios de Systemd.

---

## Conclusión

A través de este trabajo práctico se implementaron diferentes mecanismos de automatización y administración en un entorno Linux.

Se desarrollaron scripts en Bash para monitorear usuarios, descargar archivos, diagnosticar la conectividad de red, modificar el hostname y procesar registros del sistema.

También se utilizaron Cron y At para programar tareas, mientras que Systemd permitió configurar un servicio y un temporizador para ejecutar periódicamente el diagnóstico de red.

Finalmente, se realizaron pruebas de funcionamiento y validaciones de sintaxis para comprobar el comportamiento de los scripts. Los resultados obtenidos quedaron registrados en archivos de log y se documentaron mediante capturas de pantalla.

El trabajo permitió aplicar herramientas habituales de administración de sistemas Linux, reforzando los conocimientos relacionados con la automatización, la programación de tareas, la administración de servicios y el procesamiento de registros.

---

## Evidencias del trabajo práctico

Las capturas de pantalla se encuentran en el directorio `capturastp/`, dentro de la carpeta principal del proyecto.

| Tarea | Archivo de evidencia | Descripción |
|---|---|---|
| Tarea 1: Cron | `capturastp/cron.png` | Configuración y programación de la tarea periódica con Cron. |
| Tarea 1: Cron | `capturastp/monitorear_usuarios.png` | Ejecución del script y registro de usuarios conectados. |
| Tarea 2: At | `capturastp/2.png` | Comprobación de la descarga programada y funcionamiento de At. |
| Tarea 3: Systemd | `capturastp/diagnositco.png` | Diagnóstico de conectividad y comprobación del servicio y temporizador. |
| Tarea 4: Hostname | `capturastp/hostname.png` | Pruebas de permisos, validación del nombre y cambio del hostname. |
| Tarea 5: AWK | `capturastp/tarea5.png` | Ejecución del filtro de errores y generación del reporte. |

Las evidencias complementan la documentación y permiten visualizar las pruebas realizadas durante el desarrollo de cada tarea.

---
