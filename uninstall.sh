#!/bin/bash
#=========================================================================#
# HestiaCP Node.js & PM2 Uninstaller                                      #
# Author: pochii-dev (https://github.com/pochii-dev)                      #
# Cleans up Nginx templates, QuickInstall WebApp and CLI commands         #
#=========================================================================#

set -e

if [ "$EUID" -ne 0 ]; then
    echo "Error: Este script debe ejecutarse como root."
    exit 1
fi

echo "Desinstalando integración de Node.js en HestiaCP (pochii-dev)..."

# Remove WebApp
rm -rf /usr/local/hestia/web/src/app/WebApp/Installers/NodeJS

# Remove CLI commands
rm -f /usr/local/hestia/bin/v-*-nodejs
rm -f /usr/bin/v-*-nodejs

# Remove starters
rm -rf /usr/local/hestia/data/templates/starters/nodejs

# Remove templates
rm -f /usr/local/hestia/data/templates/web/nginx/nodejs*
rm -f /usr/local/hestia/data/templates/web/nginx/php-fpm/nodejs*

# Reload Nginx
if nginx -t >/dev/null 2>&1; then
    systemctl reload nginx
fi

echo "Desinstalación completada con éxito."
exit 0
