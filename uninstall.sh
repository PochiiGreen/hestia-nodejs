#!/bin/bash
#=========================================================================#
# HestiaCP Node.js & PM2 Uninstaller                                      #
# Author: pochii-dev / PochiiGreen (https://github.com/PochiiGreen)       #
# Cleans up WebApp installer, CLI commands, templates, and starters       #
#=========================================================================#

set -e

if [ "$EUID" -ne 0 ]; then
    echo "Error: Este script debe ejecutarse como root (sudo)."
    exit 1
fi

echo "====================================================================="
echo "       Desinstalando integración de Node.js & PM2 en HestiaCP        "
echo "====================================================================="

# 1. Remove WebApp installer module (solves 500 error in Quick Install UI)
if [ -d "/usr/local/hestia/web/src/app/WebApp/Installers/NodeJS" ]; then
    rm -rf /usr/local/hestia/web/src/app/WebApp/Installers/NodeJS
    echo "✔ Módulo WebApp NodeJS eliminado de /usr/local/hestia/web/src/app/WebApp/Installers/NodeJS"
fi

# 2. Remove corrupted or legacy websocket upgrade file if present
rm -f /etc/nginx/conf.d/websocket_upgrade.conf* 2>/dev/null || true
echo "✔ Verificada limpieza de /etc/nginx/conf.d"

# 3. Remove CLI commands
rm -f /usr/local/hestia/bin/v-*-nodejs
rm -f /usr/bin/v-*-nodejs
echo "✔ Comandos CLI eliminados"

# 4. Remove starters
rm -rf /usr/local/hestia/data/templates/starters/nodejs
echo "✔ Plantillas iniciales eliminadas"

# 5. Remove Nginx & Web templates
rm -f /usr/local/hestia/data/templates/web/nginx/nodejs.*
rm -f /usr/local/hestia/data/templates/web/nginx/php-fpm/nodejs.*
rm -f /usr/local/hestia/data/templates/web/apache2/nodejs.* 2>/dev/null || true
echo "✔ Plantillas Nginx eliminadas"

# 6. Reload Nginx
if command -v nginx >/dev/null 2>&1; then
    if nginx -t >/dev/null 2>&1; then
        systemctl reload nginx 2>/dev/null || true
        echo "✔ Nginx verificado y recargado con éxito"
    else
        echo "⚠ Revise la sintaxis de Nginx: nginx -t"
    fi
fi

echo ""
echo "✔ Desinstalación completada con éxito. El panel HestiaCP vuelve a su estado original."
exit 0
