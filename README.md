# 🚀 Integración Completa de Node.js, PNPM & PM2 para HestiaCP (v1.10.x / v1.10.5+)

```text
 ██╗  ██╗███████╗███████╗████████╗██╗ █████╗  ██████╗██████╗ 
 ██║  ██║██╔════╝██╔════╝╚══██╔══╝██║██╔══██╗██╔════╝██╔══██╗
 ███████║█████╗  ███████╗   ██║   ██║███████║██║     ██████╔╝
 ██╔══██║██╔══╝  ╚════██║   ██║   ██║██╔══██║██║     ██╔═══╝ 
 ██║  ██║███████╗███████║   ██║   ██║██║  ██║╚██████╗██║     
 ╚═╝  ╚═╝╚══════╝╚══════╝   ╚═╝   ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝     
         NODE.JS, PNPM & PM2 ENTERPRISE INTEGRATION
                by pochii-dev / PochiiGreen
```

[![Author: pochii-dev](https://img.shields.io/badge/Author-pochii--dev-blueviolet.svg)](https://github.com/PochiiGreen)
[![HestiaCP](https://img.shields.io/badge/HestiaCP-v1.10.5%20Tested-red.svg)](https://hestiacp.com)
[![Node.js](https://img.shields.io/badge/Node.js-18%20|%2020%20LTS%20|%2022-green.svg)](https://nodejs.org)
[![Package Manager](https://img.shields.io/badge/Package%20Manager-PNPM%20|%20NPM%20|%20Yarn-orange.svg)](https://pnpm.io)
[![PM2](https://img.shields.io/badge/PM2-Daemon%20Auto--start-blue.svg)](https://pm2.keymetrics.io)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Módulo de integración nativa de **Node.js**, **PNPM** y **PM2** para **Hestia Control Panel (HestiaCP)** desarrollado por **[pochii-dev / PochiiGreen](https://github.com/PochiiGreen)**. Diseñado específicamente para **HestiaCP v1.10.5** y versiones superiores en Debian/Ubuntu.

Permite desplegar, configurar, supervisar y escalar aplicaciones Node.js en **cualquier puerto local (ej: 3041, 3000, 8080, etc.)** directamente desde el **Panel Web (Quick Install App)** con icono oficial o mediante comandos de consola **CLI** (`v-*`), con plantilla �nica Nginx de alto rendimiento, soporte WebSocket y persistencia de arranque multi-usuario con `systemd`.

---

## ⚡ Solución Rápida: Desinstalar Versión Previa

Si instalaste una versión anterior y experimentaste un error 500 al entrar a *Quick Install App*, puedes desinstalarlo inmediatamente con un solo comando como `root`:

```bash
sudo rm -rf /usr/local/hestia/web/src/app/WebApp/Installers/NodeJS
```

O ejecutando el desinstalador completo:

```bash
curl -fsSL https://raw.githubusercontent.com/PochiiGreen/hestia-nodejs/main/uninstall.sh | sudo bash
```

---

## 🌟 Características Destacadas

* ⚡ **Compatibilidad Total con HestiaCP v1.10.x & v1.10.5**: Esquema de clases, metadatos y requerimientos de PHP validados para evitar errores 500 en PHP 8.2+.
* 📦 **Soporte Nativo para PNPM**: Gestor de paquetes ultrarrápido y eficiente en espacio de disco (`pnpm install --prod`), con alternativa para `npm` y `yarn`.
* 🔌 **Soporte para Cualquier Puerto (ej: 3041, 4000, 5000, etc.)**: 
  * Asigna **cualquier puerto local** a cada dominio o subdominio.
  * Nginx resuelve el puerto de forma dinámica mediante el archivo `nodeport.conf` sin alterar plantillas del sistema.
* 🚀 **Ecosystem PM2 Automático & Ejecución Inmediata**:
  * Genera `ecosystem.config.js` y `ecosystem.config.cjs` (para compatibilidad total con CommonJS y ES Modules `"type": "module"`).
  * Inicia la aplicación de inmediato bajo el usuario del dominio y guarda el estado en PM2 (`pm2 save`).
* 🎨 **Quick Install App en el Panel Web de HestiaCP**:
  * Catálogo de aplicaciones con icono oficial de Node.js (300×300 px).
  * Formulario completo: Nombre de la app PM2, puerto local (ej: 3041), archivo de inicio (`app.js`, `server.js`, `index.js`), gestor de paquetes (`pnpm`/`npm`/`yarn`), entorno (`production`/`development`), clúster (1, 2, 4 o `max`) e inicio automático.
* 🌐 **Plantilla �nica Nginx Reverse Proxy**:
  * `nodejs.tpl` y `nodejs.stpl` (SSL) con WebSockets nativos (`Upgrade` y `Connection $connection_upgrade`).
  * Despacho ultra-rápido de archivos estáticos (.css, .js, imágenes, webp, fuentes) directamente desde Nginx con caché de 30 días.
* 🔄 **Persistencia y Aislamiento Multi-usuario (PM2 + Systemd)**:
  * Servicio `pm2-<usuario>.service` en `systemd` que auto-inicia los procesos tras cualquier reinicio del servidor.
* 💻 **Suite de Comandos CLI HestiaCP**:
  * `v-add-web-domain-nodejs`
  * `v-restart-web-domain-nodejs`
  * `v-stop-web-domain-nodejs`
  * `v-start-web-domain-nodejs`
  * `v-list-web-domain-nodejs`
  * `v-delete-web-domain-nodejs`

---

## 📋 Requisitos del Sistema

* Servidor VPS o dedicado con **HestiaCP** instalado (v1.10.x recomendado, compatible con v1.4.0+).
* Sistema operativo: **Debian 11 / 12** o **Ubuntu 20.04 / 22.04 / 24.04**.
* Acceso `root` por SSH.

---

## 📥 Instalación Actualizada desde GitHub

Ejecuta el siguiente comando en tu servidor HestiaCP como usuario `root`:

```bash
curl -fsSL https://raw.githubusercontent.com/PochiiGreen/hestia-nodejs/main/install.sh | sudo bash
```

### Instalar una versión específica de Node.js
Si requieres Node.js 22.x o 18.x en vez del 20.x LTS predeterminado:

```bash
curl -fsSL https://raw.githubusercontent.com/PochiiGreen/hestia-nodejs/main/install.sh | sudo NODE_VERSION=22 bash
```

---

## 🖥️ Uso desde el Panel Web (Quick Install App)

1. Ingresa a tu panel de **HestiaCP**.
2. Dirígete a la pestaña **WEB** y edita el dominio deseado.
3. Haz clic en **Quick Install App** en la esquina superior.
4. Selecciona la tarjeta **NodeJS** (con el icono verde oficial).
5. Completa el formulario:
   * **App Name (PM2)**: Nombre identificador del proceso (ej. `mi-app`).
   * **Port**: Puedes poner **3041**, **3000**, o cualquier puerto libre.
   * **Startup Entry File**: `app.js`, `server.js`, `index.js`, etc.
   * **Package Manager**: `pnpm`, `npm` o `yarn`.
   * **Starter Template**: Express, Fastify, Minimal o Blank.
   * **Environment**: `production` o `development`.
   * **PM2 Cluster Instances**: `1`, `2`, `4` o `max`.
   * **Start PM2 Process Immediately**: `Yes`.
6. Haz clic en **Save** y ¡tu app estará online al instante!

---

## 💻 Uso desde la Consola (CLI)

```bash
# Crear app en el puerto 3041 con PNPM y Express
v-add-web-domain-nodejs admin midominio.com 3041 mi-app app.js pnpm express production 1 yes

# Reiniciar la aplicación
v-restart-web-domain-nodejs admin midominio.com

# Detener la aplicación
v-stop-web-domain-nodejs admin midominio.com

# Iniciar la aplicación
v-start-web-domain-nodejs admin midominio.com

# Ver lista de todas las apps y puertos activos en el servidor
v-list-web-domain-nodejs

# Eliminar app y restaurar plantilla web por defecto
v-delete-web-domain-nodejs admin midominio.com
```

---

## 📁 Estructura del Dominio Creado

```text
/home/<usuario>/web/<dominio>/
├── conf/
│   └── web/
│       └── <dominio>/
│           └── nodeport.conf         <-- Define: set $node_port 3041;
├── logs/
│   ├── <app_name>-error.log          <-- Logs de errores
│   └── <app_name>-out.log            <-- Logs de salida estándar
└── public_html/
    ├── .env                          <-- PORT=3041, NODE_ENV=production
    ├── ecosystem.config.js           <-- Configuración oficial de PM2
    ├── ecosystem.config.cjs          <-- Soporte para ES Modules ("type": "module")
    ├── package.json
    ├── app.js
    └── public/
        └── index.html
```

---

## 🗑️ Desinstalación Completa

Para remover completamente la integración de Node.js en HestiaCP:

```bash
curl -fsSL https://raw.githubusercontent.com/PochiiGreen/hestia-nodejs/main/uninstall.sh | sudo bash
```

---

## 👤 Autor

Desarrollado y mantenido por **[pochii-dev / PochiiGreen](https://github.com/PochiiGreen)**.

---

## 📄 Licencia

Este proyecto está bajo la Licencia [MIT](LICENSE).
