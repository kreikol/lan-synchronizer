#!/usr/bin/env bats

# --- Carga de Librerías y Ayudantes ---
load 'test_helper.bash'
load_libs

# --- Entorno de Test ---
setup() {
  # 1. Creamos la estructura de directorios y mocks.
  setup_test_directories
  setup_git_mock

  # 2. Creamos la configuración necesaria para este script.
  create_config_env \
    "HOSTS_DIR=${FAKE_DATA_REPO_DIR}" \

  # 3. Poblamos el repositorio falso con varios hosts.
  echo "192.168.1.10,user-a" > "${FAKE_DATA_REPO_DIR}/HOST-A"
  echo "192.168.1.20,user-b" > "${FAKE_DATA_REPO_DIR}/HOST-B"
  echo "esto-no-es-valido" > "${FAKE_DATA_REPO_DIR}/HOST-C-MALFORMED"

  # 4. Creamos un HOME falso para no tocar el real.
  FAKE_HOME_DIR="${TEST_RUN_DIR}/fake-home"
  mkdir -p "${FAKE_HOME_DIR}/.ssh"
  export HOME="$FAKE_HOME_DIR"

  # 5. Copiamos el script real a nuestro entorno.
  cp ./update_ssh_config.sh "${TEST_RUN_DIR}/"
}

# --- Tests para update_ssh_config.sh ---

@test "Debe generar un fichero config_dinamica con el contenido correcto" {
  cd "$TEST_RUN_DIR"
  run env PATH="$MOCK_PATH" ./update_ssh_config.sh

  assert_success

  # La ruta al fichero que esperamos que se cree.
  local ssh_config_file="${HOME}/.ssh/config_dinamica"

  # Aserción 1: El fichero debe existir.
  assert [ -f "$ssh_config_file" ]

  # Aserción 2: Verificamos el contenido exacto del fichero.
  # Usamos `run cat` para cargar el contenido en `$output` y luego `assert_output`.
  run cat "$ssh_config_file"
  assert_output --partial "Host host-a"
  assert_output --partial "HostName 192.168.1.10"
  assert_output --partial "User user-a"
  assert_output --partial "Host host-b"
  assert_output --partial "HostName 192.168.1.20"
  assert_output --partial "User user-b"
  
  # Aserción 3: Verificamos que el host mal formado NO está en el fichero.
  refute_output --partial "HOST-C-MALFORMED"
}

@test "Debe llamar a 'git pull' en el repositorio de datos" {
  cd "$TEST_RUN_DIR"
  run env PATH="$MOCK_PATH" ./update_ssh_config.sh

  assert_success

  # Cargamos el log de git en `$output` para poder analizarlo.
  run cat "$GIT_CALL_LOG"
  assert_output "pull"
}
