#  LAN Synchronizer ⚡

Un sistema sencillo y robusto para mantener la configuración de SSH de tus equipos sincronizada en una red local con IPs dinámicas. ¡Nunca más tendrás que buscar la IP de una de tus máquinas!

## ¿Qué problema soluciona?

Si trabajas con varios ordenadores (portátiles, servidores, Raspberry Pis...) en la misma red, sabrás que sus IPs locales pueden cambiar. Esto convierte el simple acto de hacer `ssh mi-servidor` en una odisea de buscar IPs, actualizar ficheros `/etc/hosts` o tu `~/.ssh/config` a mano.

**LAN Synchronizer** automatiza este proceso de forma elegante, usando un repositorio Git como fuente única de verdad.

## ¿Cómo funciona?

La arquitectura se basa en dos componentes principales y dos repositorios Git:

1.  **Este Repositorio (El Código):** Contiene los scripts inteligentes que hacen la magia.
2.  **Un Repositorio de Datos (Tuyo):** Un repositorio Git privado donde cada máquina publica su IP en un fichero individual.

Los scripts son:
*   `report_ip.sh`: Cada máquina ejecuta este script para averiguar su propia IP y la publica en el repositorio de datos.
*   `update_ssh_config.sh`: Cada máquina ejecuta este script para leer las IPs de *todas* las demás máquinas desde el repositorio de datos y generar una configuración de SSH local.

## 🚀 Puesta en Marcha (Instalación)

Sigue estos pasos en **cada una de las máquinas** que quieras sincronizar.

### Prerrequisitos
*   `git` instalado.
*   Un cliente de `ssh` (OpenSSH).
*   Una shell de Unix (como `bash`).

### Paso 1: Crear el Repositorio de Datos

Primero, necesitas un lugar central donde guardar las IPs.

1.  Ve a tu proveedor de Git favorito (GitHub, GitLab, etc.) y **crea un nuevo repositorio privado**. Llamémoslo, por ejemplo, `lan-ips`.
2.  **NO** lo inicialices con un `README` ni nada. Queremos un repo vacío.

### Paso 2: Configurar la Primera Máquina

1.  **Clona el repositorio de datos** en una ruta fácil de recordar. Esta ruta será la misma en todas tus máquinas.
    ```bash
    # Ejemplo usando la home del usuario
    git clone git@github.com:<tu-usuario>/lan-ips.git ~/lan-ips
    ```

2.  **Clona este repositorio (lan-synchronizer)**.
    ```bash
    git clone git@github.com:<tu-usuario>/lan-synchronizer.git ~/lan-synchronizer
    ```

3.  **Crea y edita el fichero de configuración**.
    ```bash
    cd ~/lan-synchronizer
    cp config.env.example config.env
    nano config.env
    ```
    Rellena las variables con los datos de **esta máquina**:
    ```ini
    # Ruta ABSOLUTA al clon local del repositorio de datos.
    HOSTS_REPO_PATH="/home/mir/lan-ips"

    # Nombre único para ESTA máquina.
    HOSTNAME_ID="PORTATIL-MIR"

    # Usuario para conectar por SSH a ESTA máquina.
    SSH_USER="mir"
    ```

### Paso 3: Automatización con Cron

Vamos a programar los scripts para que se ejecuten periódicamente.

1.  Abre el editor de cron:
    ```bash
    crontab -e
    ```
2.  Añade las siguientes dos líneas. Adáptalas a tus rutas.

    ```crontab
    # Cada 5 minutos, reporta la IP de esta máquina al repositorio central.
    */5 * * * * /home/mir/lan-synchronizer/report_ip.sh >> /tmp/lan-sync-report.log 2>&1

    # Cada 5 minutos (con un pequeño desfase), actualiza la configuración de SSH local.
    1-59/5 * * * * /home/mir/lan-synchronizer/update_ssh_config.sh >> /tmp/lan-sync-update.log 2>&1
    ```
    *Nota: Redirigimos la salida a ficheros de log para poder depurar si algo falla.*

### Paso 4: Configuración Final de SSH

El script `update_ssh_config.sh` crea un fichero en `~/.ssh/config_dinamica`. Para que tu cliente de SSH lo use, tienes que "incluirlo".

1.  Abre (o crea) tu fichero `~/.ssh/config`:
    ```bash
    nano ~/.ssh/config
    ```
2.  Añade esta línea al final del fichero. **Solo necesitas hacerlo una vez.**
    ```
    # Cargar hosts de la red local gestionados por LAN Synchronizer
    Include ~/.ssh/config_dinamica
    ```

### Paso 5: Repetir en las Demás Máquinas

Ahora, simplemente repite los pasos 2 y 3 en el resto de tus máquinas, ¡asegurándote de cambiar los valores en `config.env` en cada una!

---

¡Y ya está! En unos minutos, deberías poder hacer `ssh portatil-mir` (o el nombre que hayas configurado) desde cualquier máquina y conectar sin problemas.

## 🤝 Contribuir

¡Las contribuciones son bienvenidas! Si quieres mejorar el proyecto, por favor, echa un vistazo a nuestra [**Guía de Contribución**](./CONTRIBUTING.md) para configurar tu entorno de desarrollo y aprender sobre nuestro flujo de trabajo.
