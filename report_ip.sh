#!/bin/bash
#
# report_ip.sh
#
# Este script se encarga de reportar la IP local de la máquina
# al repositorio central de Git.

# --- Configuración Inicial y Carga de Entorno ---

# Nos aseguramos de que el script se ejecuta desde el directorio donde reside.
# Esto es crucial para que encuentre el fichero 'config.env'.
cd "$(dirname "$0")"

# Comprobamos si el fichero de configuración existe.
if [ ! -f "config.env" ]; then
  echo "¡Error! No se encuentra el fichero 'config.env'." >&2
  echo "Por favor, copia 'config.env.example' a 'config.env' y configúralo." >&2
  exit 1
fi

# Cargamos la configuración. Las variables como HOSTNAME_ID y SSH_USER estarán disponibles.
set -a
source config.env
set +a

# Verificamos que las variables necesarias de config.env no estén vacías.
if [ -z "$HOSTNAME_ID" ] || [ -z "$SSH_USER" ]; then
  echo "¡Error! HOSTNAME_ID y SSH_USER deben estar definidos en 'config.env'." >&2
  exit 1
fi

# --- Lógica Principal ---

# Obtenemos la IP de la máquina.
# Este comando busca las IPs de tipo 'global' (no las locales como 127.0.0.1)
# y coge la primera que encuentra. Es bastante robusto para la mayoría de sistemas.
# Usamos 'head -n 1' para asegurarnos de que solo obtenemos una IP si hay varias.
IP=$(ip -4 addr show scope global | grep inet | awk '{print $2}' | cut -d '/' -f 1 | head -n 1)

if [ -z "$IP" ]; then
  echo "¡Error! No se pudo determinar la dirección IP." >&2
  exit 1
fi

echo "Soy '$HOSTNAME_ID' y mi IP es '$IP'. Reportando..."

# --- Sincronización con Git ---

echo "Navegando al repositorio de datos: $HOSTS_REPO_PATH"
cd "$HOSTS_REPO_PATH" || exit 1

# Primero, actualizamos el repositorio de datos para evitar conflictos.
echo "1. Actualizando el repositorio de datos..."
git pull

# Creamos el contenido para el fichero de host.
# Formato: IP,USUARIO_SSH
HOST_FILE_CONTENT="${IP},${SSH_USER}"
HOST_FILE_PATH="${HOSTNAME_ID}" # El fichero se crea en el directorio actual (que es el repo de datos)

# Escribimos la información en el fichero correspondiente.
echo "2. Escribiendo la configuración en '$HOST_FILE_PATH'..."
echo "$HOST_FILE_CONTENT" > "$HOST_FILE_PATH"

# Hacemos commit y push de los cambios.
echo "3. Subiendo los cambios al repositorio de datos..."
git add "$HOST_FILE_PATH"

# Hacemos commit solo si hay cambios que subir.
if ! git diff --staged --quiet; then
  git commit -m "Report: Update IP for ${HOSTNAME_ID}"
  git push
  echo "¡Hecho! IP actualizada en el repositorio."
else
  echo "No había cambios en la IP. No se ha hecho nada."
fi


exit 0
