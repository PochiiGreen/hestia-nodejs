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

Módulo de integración nativa de **Node.js**, **PNPM** y **PM2** para **Hestia Control Panel (HestiaCP)** desarrollado por **[pochii-dev / PochiiGreen](https://github.com/PochiiGreen)**. Diseñado específicamente para **HestiaCP v1.10.5** y versiones superiores en Debian / Ubuntu.

Permite desplegar, configurar, supervisar y escalar aplicaciones Node.js en **cualquier puerto local (ej: 3041, 3000, 8080, etc.)** directamente desde el **Panel Web (Quick Install App)** con icono oficial o mediante comandos de consola **CLI** (`v-*`), con una **única plantilla Nginx** de alto rendimiento, soporte WebSocket nativo y persistencia de arranque multi-usuario con `systemd`.

---

## ⚡ Solución Rápida: Desinstalar Versión Previa

Si instalaste una versión anterior y deseas comenzar desde cero, puedes desinstalarlo inmediatamente con un solo comando como `root`:

```bash
curl -fsSL https://raw.githubusercontent.com/PochiiGreen/hestia-nodejs/main/uninstall.sh | sudo bash
```

---

## 🌟 Características Destacadas

* 🛡️ **Arquitectura Aislada y Segura (`private/nodeapp`)**:
  * El código fuente de Node.js, `node_modules`, archivos `.env` y el `ecosystem.config.cjs` se instalan en `~/web/<dominio>/private/nodeapp`.
  * La carpeta `public_html` funciona como gateway y almacén de archivos estáticos públicos, evitando exponer archivos confidenciales por la web.
* ⚡ **Ejecución Limpia de PM2 (Sin Instancias Duplicadas)**:
  * Modo **`fork` con 1 sola instancia por defecto**, garantizando un uso óptimo de recursos (sin arranques dobles ni workers zombies).
  * Limpieza y sustitución automática del proceso PM2 previo antes de arrancar.
  * Opcionalmente soporta **Cluster Mode** (2, 4 o `max` cores).
* ⚡ **Compatibilidad Total con HestiaCP v1.10.x & v1.10.5**:
  * Implementación estricta de `Hestia\WebApp\BaseSetup` con propiedades tipadas en PHP 8.2+ (`protected array $info`, `protected array $config`), sin errores 500.
* 📦 **Soporte Nativo para PNPM**:
  * Gestor de paquetes ultrarrápido y eficiente en espacio de disco (`pnpm install --prod`), con alternativa para `npm` y `yarn`.
* 🔌 **Soporte para Cualquier Puerto (ej: 3041, 4000, 5000, etc.)**: 
  * Asigna **cualquier puerto local** a cada dominio o subdominio.
  * Nginx resuelve el puerto de forma dinámica mediante `nodeport.conf` sin alterar plantillas del sistema.
* 🌐 **Plantilla Única Nginx Reverse Proxy**:
  * `nodejs.tpl` y `nodejs.stpl` (SSL) con proxy directo en `location /` hacia el backend Node.js y WebSockets nativos (`Upgrade` y `Connection`).
  * Despacho ultra-rápido de archivos estáticos directamente desde Nginx con caché de 30 días.
* 🔄 **Persistencia y Aislamiento Multi-usuario (PM2 + Systemd)**:
  * Servicio `pm2-<usuario>.service` en `systemd` que auto-inicia los procesos tras cualquier reinicio del servidor.

---

## 📥 Instalación en 1 Línea

Ejecuta el siguiente comando como usuario `root` en tu servidor con HestiaCP v1.10.5:

```bash
curl -fsSL https://raw.githubusercontent.com/PochiiGreen/hestia-nodejs/main/install.sh | sudo bash
```

El instalador detecta automáticamente el sistema (Debian 13.x, Ubuntu, arquitectura, versión de HestiaCP), instala Node.js LTS, PNPM, PM2, Yarn, registra la plantilla Nginx y habilita el módulo Quick Install en el panel.

---

## 🖥️ Uso desde el Panel Web (Quick Install App)

1. Inicia sesión en **HestiaCP**.
2. Ve a **WEB** y haz clic sobre el dominio donde deseas correr tu aplicación Node.js.
3. Haz clic en **Quick Install App** (Instalar Aplicación Web).
4. Selecciona **NodeJS** (con el logotipo oficial de Node.js).
5. Configura los parámetros:
   * **App Name**: Nombre del proceso en PM2 (ej: `servicios`).
   * **Port**: Cualquier puerto que desees asignar (ej: `3041`, `4000`, `8080`).
   * **Entry Script**: Archivo principal (ej: `app.js` o `server.js`).
   * **Package Manager**: Selecciona `pnpm` (recomendado), `npm` o `yarn`.
   * **Starter Template**: Selecciona `Express.js`, `Fastify`, `Minimal` o `Blank`.
   * **PM2 Mode & Instances**: `1 Instance (Fork mode - Recomendado)`.
   * **Auto Start with PM2?**: `Yes` (inicia de inmediato y activa persistencia en arranque).
6. Haz clic en **Save / Guardar**.

¡Tu aplicación quedará corriendo de inmediato en producción detrás de Nginx con SSL y WebSockets!

---

## 💻 Uso desde la Consola (CLI de HestiaCP)

Puedes crear y gestionar aplicaciones directamente por SSH usando los comandos nativos `v-*-nodejs`:

### 1. Crear y arrancar una aplicación en cualquier puerto (ej: 3041 con PNPM):
```bash
v-add-web-domain-nodejs admin midominio.com 3041 mi-app app.js pnpm express production 1 yes
```

### 2. Reiniciar la aplicación:
```bash
v-restart-web-domain-nodejs admin midominio.com
```

### 3. Ver estado de las aplicaciones Node.js:
```bash
v-list-web-domain-nodejs
```

### 4. Detener la aplicación:
```bash
v-stop-web-domain-nodejs admin midominio.com
```

### 5. Iniciar la aplicación:
```bash
v-start-web-domain-nodejs admin midominio.com
```

### 6. Eliminar la configuración Node.js de un dominio:
```bash
v-delete-web-domain-nodejs admin midominio.com
```

---

## 📁 Estructura del Proyecto

```text
hestia-nodejs/
├── bin/                             # Comandos nativos CLI de HestiaCP (/usr/local/hestia/bin)
│   ├── v-add-web-domain-nodejs      # Creación de app en private/nodeapp, gateway en public_html y PM2
│   ├── v-restart-web-domain-nodejs  # Reinicio de proceso PM2
│   ├── v-stop-web-domain-nodejs     # Parada de proceso PM2
│   ├── v-start-web-domain-nodejs    # Inicio de proceso PM2
│   ├── v-delete-web-domain-nodejs   # Eliminación y limpieza de proceso PM2
│   └── v-list-web-domain-nodejs     # Listado y telemetría de apps activas
├── starters/                        # Plantillas de inicio limpias
│   ├── express/                     # Express.js + Logger + Healthcheck
│   ├── fastify/                     # Fastify High Performance
│   └── minimal/                     # Servidor nativo Node.js sin dependencias externas
├── templates/
│   └── nginx/                       # Plantilla única Nginx dinámica
│       ├── nodejs.tpl               # HTTP reverse proxy (resuelve cualquier puerto dinámicamente)
│       └── nodejs.stpl              # HTTPS/SSL reverse proxy con WebSockets
├── webapps/
│   └── NodeJS/                      # Módulo Quick Install App para HestiaCP
│       ├── NodeJSSetup.php          # Clase compatible con BaseSetup en HestiaCP v1.10.5
│       └── nodejs.png               # Icono oficial (300x300 px)
├── install.sh                       # Instalador automático con telemetría y ASCII banner
├── uninstall.sh                     # Desinstalador limpio y seguro
├── LICENSE                          # Licencia MIT
└── README.md                        # Documentación oficial
```

---

## 🗑️ Desinstalación Completa

Para remover completamente el módulo y restaurar el panel HestiaCP a su configuración previa:

```bash
curl -fsSL https://raw.githubusercontent.com/PochiiGreen/hestia-nodejs/main/uninstall.sh | sudo bash
```

---

## 👤 Autor

* **Autor:** pochii-dev ([@PochiiGreen](https://github.com/PochiiGreen))
* **Repositorio:** [https://github.com/PochiiGreen/hestia-nodejs](https://github.com/PochiiGreen/hestia-nodejs)
* **Licencia:** MIT
