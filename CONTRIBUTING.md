# Guía de Contribución para LAN Synchronizer

¡Hola! Nos encanta que estés interesado en contribuir a LAN Synchronizer. Esta guía te ayudará a poner en marcha tu entorno de desarrollo y a entender nuestras convenciones.

## 🚀 Entorno de Desarrollo

El proyecto está escrito en `bash` y utiliza `bats-core` para los tests.

### 1. Prerrequisitos

*   `git`
*   `bash`

### 2. Clonar el Repositorio

Este proyecto utiliza **submódulos de Git** para gestionar las dependencias de testing. Por lo tanto, es crucial que clones el repositorio de forma recursiva para descargar todo lo necesario.

```bash
git clone --recurse-submodules https://github.com/<tu-usuario>/lan-synchronizer.git
cd lan-synchronizer
```

Si ya has clonado el repositorio sin el flag `--recurse-submodules`, puedes inicializar los submódulos manualmente con:
```bash
git submodule update --init
```

### 3. Estructura del Proyecto

*   `report_ip.sh`, `update_ssh_config.sh`: Scripts principales.
*   `config.env.example`: Plantilla de configuración.
*   `test/`: Contiene toda la suite de tests.
    *   `test/libs/`: Submódulos de Git con las librerías de testing.
    *   `test/test_helper.bash`: Funciones compartidas para los tests.
    *   `*.bats`: Ficheros de test.

## ✅ Ejecutar los Tests

La suite de tests es la mejor forma de verificar que tus cambios no han roto nada.

Para ejecutar **todos** los tests del proyecto, utiliza el script de ayuda:

```bash
./run_tests.sh
```

Si quieres pasar argumentos adicionales a `bats` (por ejemplo, para una salida más detallada), puedes hacerlo directamente:

```bash
# Ejecutar con el formateador "pretty"
./run_tests.sh --pretty

# Ejecutar un único fichero de test
./run_tests.sh test/report_ip.bats

# Ejecutar un único test por su nombre
./run_tests.sh --filter "Debe crear un fichero de host" test/report_ip.bats
```

## 📝 Guía de Estilo

Para mantener la coherencia en el código, por favor, sigue estas convenciones:

### Mensajes de Commit

Utilizamos **Conventional Commits**. Esto nos ayuda a generar automáticamente los `changelogs` y a mantener un historial limpio.

*   **feat:** Para nuevas funcionalidades.
*   **fix:** Para correcciones de bugs.
*   **docs:** Para cambios en la documentación.
*   **test:** Para añadir o refactorizar tests.
*   **chore:** Para tareas de mantenimiento (actualizar dependencias, etc.).

Ejemplo: `feat: add automatic retry on git push failure`

### Código y Comentarios

*   **Código:** Todo el código (nombres de variables, funciones, ficheros) debe estar en **inglés**.
*   **Comentarios:** Los comentarios en el código y la documentación (`.md`) deben estar en **castellano**.

---

¡Gracias por tu ayuda!
