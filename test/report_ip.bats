#!/usr/bin/env bats

# --- Carga de Librerías y Ayudantes ---
load 'test_helper.bash'
load_libs

# --- Entorno de Test ---
setup() {
  # 1. Creamos la estructura de directorios y mocks.
  setup_test_directories
  setup_git_mock
  setup_ip_mock

  # 2. Creamos la configuración específica para este script.
  create_config_env \
    "HOSTNAME_ID=TEST-MACHINE" \
    "SSH_USER=test-user"

  # 3. Copiamos el script real a nuestro entorno.
  cp ./report_ip.sh "${TEST_RUN_DIR}/"
}

# --- Tests para report_ip.sh ---

@test "Debe crear un fichero de host con la IP y el usuario correctos" {
  # Nos movemos al directorio único de este test.
  cd "$TEST_RUN_DIR"

  # Ejecutamos el script con el PATH modificado solo para esta ejecución.
  run env PATH="$MOCK_PATH" ./report_ip.sh

  assert_success

  local host_file="${FAKE_DATA_REPO_DIR}/TEST-MACHINE"
  assert [ -f "$host_file" ]
  assert_equal "$(cat "$host_file")" "10.20.30.40,test-user"
}

@test "Debe llamar a git con los comandos y el orden correctos" {
  # Nos movemos al directorio único de este test.
  cd "$TEST_RUN_DIR"
  
  # Ejecutamos el script con el PATH modificado solo para esta ejecución.
  run env PATH="$MOCK_PATH" ./report_ip.sh

  assert_success

  # Cargamos el log de git en `$output` para poder analizarlo.
  local git_log="${TEST_RUN_DIR}/git_calls.log"
  run cat "$git_log"
  
  # Ahora las funciones `assert_line` operarán sobre ese `$output` limpio.
  assert_line --index 0 "pull"
  assert_line --index 1 "add TEST-MACHINE"
  assert_line --index 2 "diff --staged --quiet"
  assert_line --index 3 "commit -m Report: Update IP for TEST-MACHINE"
  assert_line --index 4 "push"
}