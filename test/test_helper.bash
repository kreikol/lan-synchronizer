#!/usr/bin/env bash

# ==================================================
# === Fichero de Ayuda para los Tests de Bats    ===
# ==================================================
#
# Contiene funciones compartidas para la preparación
# de los entornos de test.

# --- Carga de Librerías ---
#
# Carga las librerías base de bats.
# Cualquier fichero de test que cargue este helper
# ya tendrá las librerías disponibles.
load_libs() {
  local TEST_DIRNAME
  TEST_DIRNAME="$(dirname "$BATS_TEST_FILENAME")"
  load "${TEST_DIRNAME}/libs/bats-support/load.bash"
  load "${TEST_DIRNAME}/libs/bats-assert/load.bash"
}

# --- Funciones de Preparación (Setup) ---

# Crea la estructura de directorios base para un test.
# Expone las variables:
# - TEST_RUN_DIR
# - FAKE_DATA_REPO_DIR
# - MOCK_DIR
setup_test_directories() {
  TEST_RUN_DIR="${BATS_TMPDIR}/test-run-$(date +%s%N)"
  mkdir -p "$TEST_RUN_DIR"

  FAKE_DATA_REPO_DIR="${TEST_RUN_DIR}/fake-lan-ips"
  mkdir -p "$FAKE_DATA_REPO_DIR"

  MOCK_DIR="${TEST_RUN_DIR}/bin"
  mkdir -p "$MOCK_DIR"
}

# Crea un fichero config.env en el directorio del test.
# Siempre añade la ruta al repositorio de datos falso.
# Acepta argumentos adicionales en formato "CLAVE=VALOR"
# para añadir más configuraciones.
create_config_env() {
  local config_file="${TEST_RUN_DIR}/config.env"
  echo "HOSTS_REPO_PATH=\"${FAKE_DATA_REPO_DIR}\"" > "$config_file"

  for var in "$@"; do
    echo "$var" >> "$config_file"
  done
}

# Crea el mock para el comando `git`.
# Expone la variable MOCK_PATH.
setup_git_mock() {
  local git_mock_file="${MOCK_DIR}/git"
  GIT_CALL_LOG="${TEST_RUN_DIR}/git_calls.log"
  cat > "$git_mock_file" <<EOF
#!/bin/bash
cat >> "${GIT_CALL_LOG}" <<< "\$@"
if [[ "\$1" == "diff" ]]; then exit 1; fi
exit 0
EOF
  chmod +x "$git_mock_file"
  MOCK_PATH="${MOCK_DIR}:${PATH}"
}

# Crea el mock para el comando `ip`.
# (No se expone MOCK_PATH aquí porque se asume que
# setup_git_mock ya lo ha hecho).
setup_ip_mock() {
  local ip_mock_file="${MOCK_DIR}/ip"
  cat > "$ip_mock_file" <<EOF
#!/bin/bash
echo "inet 10.20.30.40/24 scope global"
EOF
  chmod +x "$ip_mock_file"
}
