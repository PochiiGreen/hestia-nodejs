# 🚀 Integración Completa de Node.js & PM2 para HestiaCP

```text
 ██╗  ██╗███████╗███████╗████████╗██╗ █████╗  ██████╗██████╗ 
 ██║  ██║██╔════╝██╔════╝╚══██╔══╝██║██╔══██╗██╔════╝██╔══██╗
 ███████║█████╗  ███████╗   ██║   ██║███████║██║     ██████╔╝
 ██╔══██║██╔══╝  ╚════██║   ██║   ██║██╔══██║██║     ██╔═══╝ 
 ██║  ██║███████╗███████║   ██║   ██║██║  ██║╚██████╗██║     
 ╚═╝  ╚═╝╚══════╝╚══════╝   ╚═╝   ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝     
             NODE.JS & PM2 ENTERPRISE INTEGRATION
                     by pochii-dev
```

[![Author: pochii-dev](https://img.shields.io/badge/Author-pochii--dev-blueviolet.svg)](https://github.com/pochii-dev)
[![HestiaCP](https://img.shields.io/badge/HestiaCP-v1.4.0+-red.svg)](https://hestiacp.com)
[![Node.js](https://img.shields.io/badge/Node.js-18%20|%2020%20LTS%20|%2022-green.svg)](https://nodejs.org)
[![PM2](https://img.shields.io/badge/PM2-Daemon%20Managed-blue.svg)](https://pm2.keymetrics.io)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Módulo de integración nativa de **Node.js** y **PM2** para **Hestia Control Panel (HestiaCP)** desarrollado por **[pochii-dev](https://github.com/pochii-dev)**. Diseñado para distribuciones Debian y Ubuntu, permite desplegar, configurar, supervisar y escalar aplicaciones Node.js en **cualquier puerto (ejemplo: 3041, 3000, 8080, etc.)** directamente desde el **Panel Web (Quick Install App)** con icono oficial o mediante comandos de consola **CLI** (`v-*`), con plantillas Nginx de alto rendimiento, soporte WebSocket y persistencia de arranque multi-usuario con `systemd`.

---

## 🌟 Características Destacadas

* ⚡ **Instalación en 1 Comando**: Ejecutable directamente desde GitHub con `curl -fsSL ... | bash` con telemetría en tiempo real y banners ASCII.
* 🔌 **Soporte de Cualquier Puerto (ej: 3041, 4000, 5000, etc.)**: 
  * Puedes asignar **cualquier puerto local que desees** a cada dominio o subdominio.
  * La plantilla Nginx Reverse Proxy lee el puerto dinámicamente desde el archivo de configuración del dominio (`nodeport.conf`).
* 📦 **Node.js & PM2 Globales**: Configuración automatizada con el repositorio oficial NodeSource (LTS 20.x por defecto, 18.x o 22.x a elección) y PM2 con rotación de logs (`pm2-logrotate`).
* 🎨 **Quick Install App en el Panel Web de HestiaCP**:
  * Aparece en el catálogo de *Quick Install App* con su icono oficial (300×300 px).
  * Formulario completo: Nombre de la app PM2, puerto local (ej: 3041), archivo de inicio (`app.js`, `server.js`, `index.js`), entorno (`production`/`development`), clúster (1, 2, 4 o `max` cores) e inicio inmediato.
* 🌐 **Plantillas Nginx Reverse Proxy Optimizadas**:
  * `nodejs.tpl` y `nodejs.stpl` (SSL) con WebSockets nativos (`Upgrade` y `Connection $connection_upgrade`).
  * Despacho ultra-rápido de estáticos (.css, .js, imágenes, webp, fuentes) directamente desde Nginx con caché de 30 días.
  * Soporte para configuración SSL automática Let's Encrypt de HestiaCP.
* 🛠️ **Plantillas Iniciales (Boilerplates)**:
  * **Express.js**: Servidor Express con REST API, endpoints `/health`, `/api/status` y landing interactiva.
  * **Fastify**: Servidor ultrarrápido y asíncrono para microservicios.
  * **Nativo (Minimal)**: Servidor HTTP estándar sin dependencias de `npm` (corre al instante).
  * **Blank / Existente**: Para proyectos subidos o clonados directamente por el usuario.
* 🔄 **Persistencia y Aislamiento Multi-usuario (PM2 + Systemd)**:
  * Cada usuario (`admin`, `cliente1`, etc.) tiene su propio entorno PM2 aislado.
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

* Servidor VPS o dedicado con **HestiaCP** instalado (v1.4.0 o superior).
* Sistema operativo: **Debian 11 / 12** o **Ubuntu 20.04 / 22.04 / 24.04**.
* Acceso `root` por SSH.

---

## 📥 Instalación Rápida desde GitHub

Ejecuta el siguiente comando en tu servidor HestiaCP como usuario `root`:

```bash
curl -fsSL https://raw.githubusercontent.com/pochii-dev/hestia-nodejs/main/install.sh | sudo bash
```

### Instalar una versión específica de Node.js
Si requieres Node.js 22.x o 18.x en vez del 20.x LTS predeterminado:

```bash
curl -fsSL https://raw.githubusercontent.com/pochii-dev/hestia-nodejs/main/install.sh | sudo NODE_VERSION=22 bash
```

### Instalación Manual (Clonando)

```bash
git clone https://github.com/pochii-dev/hestia-nodejs.git /root/hestia-nodejs
cd /root/hestia-nodejs
chmod +x install.sh
sudo ./install.sh
```

---

## ❓ ¿Cómo funciona cualquier puerto (ejemplo: 3041)?

¡No estás limitado a puertos fijos! Cada dominio en HestiaCP puede correr en un puerto totalmente diferente:

* **Dominio 1:** `api.midominio.com` ➔ Puerto **3000**
* **Dominio 2:** `panel.midominio.com` ➔ Puerto **3041**
* **Dominio 3:** `chat.midominio.com` ➔ Puerto **8080**

### ¿Cómo lo maneja Nginx?
La plantilla `nodejs.stpl` / `nodejs.tpl` incluye la directiva:
```nginx
set $node_port 3000;
include %home%/%user%/conf/web/%domain%/nodeport.conf*;
proxy_pass http://127.0.0.1:$node_port;
```
Cuando asignas el puerto **3041**, el instalador genera automáticamente en el dominio:
```nginx
# /home/<usuario>/conf/web/<dominio>/nodeport.conf
set $node_port 3041;
```
Y configura el archivo `.env` y `ecosystem.config.js` con `PORT=3041`. Nginx reenvía el tráfico HTTPS en el puerto 443 directamente hacia `http://127.0.0.1:3041` de forma transparente.

---

## 🖥️ Uso desde el Panel Web (Quick Install App)

1. Ingresa a tu panel de **HestiaCP**.
2. Dirígete a la pestaña **WEB** y edita el dominio deseado.
3. Haz clic en **Quick Install App** en la esquina superior.
4. Selecciona la tarjeta **Node.js & PM2** (con el icono verde oficial).
5. Completa el formulario:
   * **App Name (PM2)**: Nombre identificador del proceso (ej. `mi-app`).
   * **Port**: Puedes poner **3041**, **3000**, o cualquier puerto libre.
   * **Startup Entry File**: `app.js`, `server.js`, `index.js`, etc.
   * **Starter Template**: Express, Fastify, Minimal o Blank.
   * **Environment**: `production` o `development`.
   * **PM2 Cluster Instances**: `1`, `2`, `4` o `max`.
   * **Start PM2 Process Immediately**: `Yes`.
6. Haz clic en **Save** y ¡listo!

---

## 💻 Uso desde la Consola (CLI)

```bash
# Crear app en el puerto 3041 con Express
v-add-web-domain-nodejs admin midominio.com 3041 mi-app app.js express production 1 yes

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
    ├── package.json
    ├── app.js
    └── public/
        └── index.html
```

---

## 🚀 Despliegue de Frameworks

* **Next.js**: Configura `output: 'standalone'` en `next.config.js`, sube la carpeta `.next/standalone` a `public_html`, configura `script: 'server.js'` en `ecosystem.config.js` y asigna tu puerto (ej: 3041).
* **Nuxt 3**: Sube `.output` y usa `script: '.output/server/index.mjs'`.
* **NestJS**: Sube `dist/` y `package.json`, usa `script: 'dist/main.js'`.

---

## 🗑️ Desinstalación

Para remover completamente la integración de Node.js en HestiaCP:

```bash
cd /root/hestia-nodejs
sudo ./uninstall.sh
```

---

## 👤 Autor

Desarrollado y mantenido por **[pochii-dev](https://github.com/pochii-dev)**.

---

## 📄 Licencia

Este proyecto está bajo la Licencia [MIT](LICENSE).
