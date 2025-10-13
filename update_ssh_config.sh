#!/bin/bash
#
# update_ssh_config.sh
#
# Este script lee la información de IPs del repositorio y genera
# un fichero de configuración para SSH con todos los hosts.

# --- Configuración Inicial y Carga de Entorno ---

# Nos aseguramos de que el script se ejecuta desde el directorio donde reside.
cd "$(dirname "$0")"

# Comprobamos si el fichero de configuración existe.
if [ ! -f "config.env" ]; then
  echo "¡Error! No se encuentra el fichero 'config.env'." >&2
  echo "Por favor, copia 'config.env.example' a 'config.env' y configúralo." >&2
  exit 1
fi

# Cargamos la configuración.
set -a
source config.env
set +a

# Verificamos que HOSTS_DIR esté definido.
if [ -z "$HOSTS_DIR" ]; then
  echo "¡Error! HOSTS_DIR debe estar definido en 'config.env'." >&2
  exit 1
fi

# Definimos la ruta del fichero de configuración de SSH que vamos a generar.
# Lo guardamos en el directorio home del usuario que ejecuta el script.
SSH_CONFIG_DYN_PATH="${HOME}/.ssh/config_dinamica"

# --- Sincronización con Git ---

echo "1. Actualizando el repositorio local..."
git pull

# --- Lógica Principal ---

# Comprobamos si el directorio 'hosts' existe.
if [ ! -d "$HOSTS_DIR" ]; then
  echo "¡Error! El directorio '$HOSTS_DIR' no existe." >&2
  exit 1
fi

echo "2. Generando el fichero de configuración SSH en '$SSH_CONFIG_DYN_PATH'..."

# Creamos/limpiamos el fichero de configuración dinámica.
# Empezamos con una cabecera para que el usuario sepa que es autogenerado.
cat > "$SSH_CONFIG_DYN_PATH" << EOL
# ================================================================
# === FICHERO AUTOGENERADO por update_ssh_config.sh          ===
# === ¡NO EDITAR MANUALMENTE! Todos los cambios serán borrados. ===
# ================================================================
#
# Última actualización: $(date)
#
EOL

# Iteramos sobre cada fichero dentro del repositorio de hosts.
# 'find ... -type f' se asegura de que solo procesamos ficheros.
find "$HOSTS_REPO_PATH" -type f | while read -r host_file; do
  # El nombre del host para SSH lo sacamos del nombre del fichero.
  # 'basename' nos da el nombre del fichero sin la ruta.
  HOSTNAME_ID=$(basename "$host_file")

  # Leemos el contenido del fichero (IP,USUARIO_SSH)
  FILE_CONTENT=$(cat "$host_file")

  # Separamos la IP y el USUARIO usando la coma como delimitador.
  IP=$(echo "$FILE_CONTENT" | cut -d ',' -f 1)
  USER=$(echo "$FILE_CONTENT" | cut -d ',' -f 2)

  # Validamos que hemos podido extraer la IP y el Usuario.
  if [ -z "$IP" ] || [ -z "$USER" ]; then
    echo "  -> Aviso: Fichero '$host_file' mal formado. Saltando."
    continue # Pasamos al siguiente fichero
  fi

  # Añadimos el bloque de configuración para este host al fichero.
  # Usamos '>>' para añadir al final del fichero.
  echo "  -> Añadiendo host: $HOSTNAME_ID ($IP)"
  cat >> "$SSH_CONFIG_DYN_PATH" << EOL
Host ${HOSTNAME_ID,,} # Convertimos el nombre a minúsculas por convención
    HostName $IP
    User $USER
    # Puedes añadir aquí opciones comunes de SSH, por ejemplo:
    # ConnectTimeout 5
    # IdentityFile ~/.ssh/id_ed25519_casa

EOL

done

echo "3. ¡Configuración de SSH actualizada con éxito!"
echo "Recuerda añadir la siguiente línea a tu fichero ~/.ssh/config si no lo has hecho ya:"
echo "Include ~/.ssh/config_dinamica"

exit 0
