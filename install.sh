#!/bin/bash
#===================================================================================#
#        HestiaCP Node.js, PNPM & PM2 Full Integration Installer                    #
#        Author: pochii-dev / PochiiGreen (https://github.com/PochiiGreen)          #
#        Compatible with Hestia Control Panel v1.10.x & v1.10.5+                    #
#===================================================================================#

set -e

# Default Configurations
NODE_VERSION="${NODE_VERSION:-20}"
REPO_URL="${REPO_URL:-https://github.com/PochiiGreen/hestia-nodejs.git}"
BRANCH="${BRANCH:-main}"
AUTHOR="PochiiGreen"

# Terminal Colors & Styles
C_RESET='\033[0m'
C_BOLD='\033[1m'
C_DIM='\033[2m'
C_GREEN='\033[38;5;48m'
C_BRIGHT_GREEN='\033[38;5;82m'
C_CYAN='\033[38;5;51m'
C_BLUE='\033[38;5;39m'
C_YELLOW='\033[38;5;220m'
C_RED='\033[38;5;196m'
C_MAGENTA='\033[38;5;201m'
C_GRAY='\033[38;5;244m'
C_WHITE='\033[38;5;255m'

clear 2>/dev/null || true

# ASCII Art Banner
echo -e "${C_BRIGHT_GREEN}"
cat << "EOF"
 ██╗  ██╗███████╗███████╗████████╗██╗ █████╗  ██████╗██████╗ 
 ██║  ██║██╔════╝██╔════╝╚══██╔══╝██║██╔══██╗██╔════╝██╔══██╗
 ███████║█████╗  ███████╗   ██║   ██║███████║██║     ██████╔╝
 ██╔══██║██╔══╝  ╚════██║   ██║   ██║██╔══██║██║     ██╔═══╝ 
 ██║  ██║███████╗███████║   ██║   ██║██║  ██║╚██████╗██║     
 ╚═╝  ╚═╝╚══════╝╚══════╝   ╚═╝   ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝     
EOF
echo -e "${C_CYAN}${C_BOLD}     ⚡ NODE.JS, PNPM & PM2 INTEGRATION FOR HESTIACP v1.10+ ⚡${C_RESET}"
echo -e "${C_GRAY}                Desarrollado con ❤️ por ${C_WHITE}${C_BOLD}pochii-dev${C_RESET}"
echo -e "${C_GRAY}          https://github.com/PochiiGreen/hestia-nodejs${C_RESET}"
echo ""

# 1. Root Check
if [ "$EUID" -ne 0 ]; then
    echo -e "${C_RED}[✖ ERROR] Este instalador debe ejecutarse como root (sudo).${C_RESET}"
    exit 1
fi

# 2. Check HestiaCP Installation
if [ ! -d "/usr/local/hestia" ]; then
    echo -e "${C_RED}[✖ ERROR] Hestia Control Panel no está instalado en este servidor (/usr/local/hestia no existe).${C_RESET}"
    echo -e "${C_YELLOW}Por favor instale HestiaCP primero: https://hestiacp.com${C_RESET}"
    exit 1
fi

# System Telemetry
echo -e "${C_BLUE}${C_BOLD}┌──────────────────────────────────────────────────────────────────┐${C_RESET}"
echo -e "${C_BLUE}${C_BOLD}│               📊 INFORMACIÓN DEL SISTEMA DETECTADA               │${C_RESET}"
echo -e "${C_BLUE}${C_BOLD}└──────────────────────────────────────────────────────────────────┘${C_RESET}"

OS_PRETTY="Linux Desconocido"
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_PRETTY="$NAME $VERSION"
fi
KERNEL_VER=$(uname -r)
ARCH=$(uname -m)

CPU_MODEL=$(grep -m1 "model name" /proc/cpuinfo 2>/dev/null | cut -d: -f2 | sed 's/^[ \t]*//' || echo "CPU Genérica")
CPU_CORES=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || echo "1")
MEM_TOTAL=$(free -m 2>/dev/null | awk '/^Mem:/{print $2}')
MEM_AVAIL=$(free -m 2>/dev/null | awk '/^Mem:/{print $7}')
[ -z "$MEM_AVAIL" ] && MEM_AVAIL=$(free -m 2>/dev/null | awk '/^Mem:/{print $4}')

HESTIA_VER="1.x"
if [ -f /usr/local/hestia/conf/hestia.conf ]; then
    HESTIA_VER=$(grep "VERSION=" /usr/local/hestia/conf/hestia.conf 2>/dev/null | cut -d"'" -f2 || echo "1.x")
    WEB_SYSTEM=$(grep "WEB_SYSTEM=" /usr/local/hestia/conf/hestia.conf 2>/dev/null | cut -d"'" -f2 || echo "nginx")
    WEB_BACKEND=$(grep "WEB_BACKEND=" /usr/local/hestia/conf/hestia.conf 2>/dev/null | cut -d"'" -f2 || echo "php-fpm")
fi

echo -e "  ${C_CYAN}• Sistema Operativo:${C_RESET}  ${C_WHITE}${OS_PRETTY} (${ARCH})${C_RESET}"
echo -e "  ${C_CYAN}• Núcleo Kernel:${C_RESET}      ${C_WHITE}${KERNEL_VER}${C_RESET}"
echo -e "  ${C_CYAN}• Procesador:${C_RESET}        ${C_WHITE}${CPU_MODEL} (${CPU_CORES} Cores)${C_RESET}"
echo -e "  ${C_CYAN}• Memoria RAM:${C_RESET}       ${C_WHITE}${MEM_AVAIL} MB disponibles de ${MEM_TOTAL} MB${C_RESET}"
echo -e "  ${C_CYAN}• Versión HestiaCP:${C_RESET}  ${C_WHITE}v${HESTIA_VER} (${WEB_SYSTEM} + ${WEB_BACKEND})${C_RESET}"
echo -e "  ${C_CYAN}• Versión Node.js:${C_RESET}   ${C_BRIGHT_GREEN}v${NODE_VERSION}.x LTS (NodeSource Repo)${C_RESET}"
echo ""

# Handle Source Directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"
TEMP_DIR=""

if [ ! -f "$SCRIPT_DIR/webapps/NodeJS/NodeJSSetup.php" ]; then
    echo -e "${C_MAGENTA}⚡ [MODO REMOTO] Descargando componentes desde GitHub (@${AUTHOR})...${C_RESET}"
    TEMP_DIR=$(mktemp -d)
    if command -v git >/dev/null 2>&1; then
        git clone --depth 1 -b "$BRANCH" "$REPO_URL" "$TEMP_DIR" >/dev/null 2>&1 || {
            echo -e "${C_YELLOW}[!] Git clone falló, descargando archivo tarball...${C_RESET}"
            curl -sSL "https://github.com/PochiiGreen/hestia-nodejs/archive/refs/heads/${BRANCH}.tar.gz" | tar -xz -C "$TEMP_DIR" --strip-components=1
        }
    else
        apt-get update -qq && apt-get install -y -qq git curl ca-certificates >/dev/null 2>&1
        git clone --depth 1 -b "$BRANCH" "$REPO_URL" "$TEMP_DIR"
    fi
    SOURCE_DIR="$TEMP_DIR"
else
    SOURCE_DIR="$SCRIPT_DIR"
fi

cleanup() {
    if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
}
trap cleanup EXIT

echo -e "${C_BLUE}${C_BOLD}┌──────────────────────────────────────────────────────────────────┐${C_RESET}"
echo -e "${C_BLUE}${C_BOLD}│                    🚀 EJECUTANDO INSTALACIÓN                     │${C_RESET}"
echo -e "${C_BLUE}${C_BOLD}└──────────────────────────────────────────────────────────────────┘${C_RESET}"

# 1. Install Node.js
echo -ne "  ${C_YELLOW}⟳${C_RESET} [1/7] Configurando Node.js v${NODE_VERSION}.x..."
apt-get update -qq >/dev/null 2>&1
apt-get install -y -qq curl ca-certificates gnupg build-essential >/dev/null 2>&1

CURRENT_NODE_VER=""
if command -v node >/dev/null 2>&1; then
    CURRENT_NODE_VER=$(node -v | cut -d'.' -f1 | tr -d 'v')
fi

if [ "$CURRENT_NODE_VER" != "$NODE_VERSION" ]; then
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor --yes -o /etc/apt/keyrings/nodesource.gpg >/dev/null 2>&1
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_VERSION}.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list >/dev/null
    apt-get update -qq >/dev/null 2>&1
    apt-get install -y -qq nodejs >/dev/null 2>&1
fi
echo -e "\r  ${C_GREEN}✔${C_RESET} [1/7] Node.js instalado: ${C_BRIGHT_GREEN}$(node -v)${C_RESET} (NPM ${C_CYAN}v$(npm -v)${C_RESET})"

# 2. Install PNPM, PM2 & Yarn
echo -ne "  ${C_YELLOW}⟳${C_RESET} [2/7] Instalando PNPM, PM2 y Yarn globalmente..."
npm install -g pm2 pnpm yarn --loglevel=error >/dev/null 2>&1

# Symlinks in /usr/bin
[ -f /usr/local/bin/pm2 ] && [ ! -f /usr/bin/pm2 ] && ln -s /usr/local/bin/pm2 /usr/bin/pm2 2>/dev/null || true
[ -f /usr/local/bin/pnpm ] && [ ! -f /usr/bin/pnpm ] && ln -s /usr/local/bin/pnpm /usr/bin/pnpm 2>/dev/null || true
[ -f /usr/local/bin/yarn ] && [ ! -f /usr/bin/yarn ] && ln -s /usr/local/bin/yarn /usr/bin/yarn 2>/dev/null || true

pm2 install pm2-logrotate >/dev/null 2>&1 || true
pm2 set pm2-logrotate:max_size 10M >/dev/null 2>&1 || true
pm2 set pm2-logrotate:retain 7 >/dev/null 2>&1 || true
echo -e "\r  ${C_GREEN}✔${C_RESET} [2/7] PM2 (${C_BRIGHT_GREEN}v$(pm2 -v 2>/dev/null || echo 'OK')${C_RESET}) y PNPM (${C_CYAN}v$(pnpm -v 2>/dev/null || echo 'OK')${C_RESET}) listos."

# 3. Configure Nginx WebSockets
echo -ne "  ${C_YELLOW}⟳${C_RESET} [3/7] Configurando soporte WebSocket en Nginx..."
mkdir -p /etc/nginx/conf.d
if [ -f "$SOURCE_DIR/templates/conf.d/websocket_upgrade.conf" ]; then
    cp "$SOURCE_DIR/templates/conf.d/websocket_upgrade.conf" /etc/nginx/conf.d/websocket_upgrade.conf
else
    cat <<'EOF' > /etc/nginx/conf.d/websocket_upgrade.conf
map $http_upgrade $connection_upgrade {
    default upgrade;
    '' close;
}
EOF
fi
chmod 644 /etc/nginx/conf.d/websocket_upgrade.conf
echo -e "\r  ${C_GREEN}✔${C_RESET} [3/7] Soporte para WebSockets ($connection_upgrade) registrado en Nginx."

# 4. Install Nginx Templates
echo -ne "  ${C_YELLOW}⟳${C_RESET} [4/7] Instalando plantillas Nginx (puertos dinámicos)..."
if [ -d "/usr/local/hestia/data/templates/web/nginx" ]; then
    cp "$SOURCE_DIR"/templates/nginx/*.tpl /usr/local/hestia/data/templates/web/nginx/ 2>/dev/null || true
    cp "$SOURCE_DIR"/templates/nginx/*.stpl /usr/local/hestia/data/templates/web/nginx/ 2>/dev/null || true
    chmod 644 /usr/local/hestia/data/templates/web/nginx/nodejs* 2>/dev/null || true
fi

if [ -d "/usr/local/hestia/data/templates/web/nginx/php-fpm" ]; then
    cp "$SOURCE_DIR"/templates/nginx/*.tpl /usr/local/hestia/data/templates/web/nginx/php-fpm/ 2>/dev/null || true
    cp "$SOURCE_DIR"/templates/nginx/*.stpl /usr/local/hestia/data/templates/web/nginx/php-fpm/ 2>/dev/null || true
    chmod 644 /usr/local/hestia/data/templates/web/nginx/php-fpm/nodejs* 2>/dev/null || true
fi
echo -e "\r  ${C_GREEN}✔${C_RESET} [4/7] Plantillas Nginx HTTP/HTTPS instaladas (soporte para cualquier puerto ej: 3041)."

# 5. Install Starter Boilerplates
echo -ne "  ${C_YELLOW}⟳${C_RESET} [5/7] Copiando plantillas de inicio (Express, Fastify, Nativo)..."
STARTERS_DIR="/usr/local/hestia/data/templates/starters/nodejs"
mkdir -p "$STARTERS_DIR"
cp -r "$SOURCE_DIR"/starters/* "$STARTERS_DIR/"
chown -R root:root "$STARTERS_DIR"
chmod -R 755 "$STARTERS_DIR"
echo -e "\r  ${C_GREEN}✔${C_RESET} [5/7] Plantillas iniciales provisionadas en $STARTERS_DIR."

# 6. Install Quick Install App (Compatible with HestiaCP v1.10.x & v1.10.5+)
echo -ne "  ${C_YELLOW}⟳${C_RESET} [6/7] Registrando Quick Install App para HestiaCP v1.10+..."
WEBAPP_DIR="/usr/local/hestia/web/src/app/WebApp/Installers/NodeJS"
mkdir -p "$WEBAPP_DIR"
cp "$SOURCE_DIR/webapps/NodeJS/NodeJSSetup.php" "$WEBAPP_DIR/NodeJSSetup.php"
cp "$SOURCE_DIR/webapps/NodeJS/nodejs.png" "$WEBAPP_DIR/nodejs.png"
chown -R root:root "$WEBAPP_DIR"
chmod 644 "$WEBAPP_DIR/NodeJSSetup.php" "$WEBAPP_DIR/nodejs.png"
echo -e "\r  ${C_GREEN}✔${C_RESET} [6/7] Quick Install App integrado (100% compatible con HestiaCP v1.10.5)."

# 7. Install CLI Commands
echo -ne "  ${C_YELLOW}⟳${C_RESET} [7/7] Habilitando comandos nativos de consola (/usr/local/hestia/bin)..."
cp "$SOURCE_DIR"/bin/v-*-nodejs /usr/local/hestia/bin/
chown root:root /usr/local/hestia/bin/v-*-nodejs
chmod 755 /usr/local/hestia/bin/v-*-nodejs

for cmd in /usr/local/hestia/bin/v-*-nodejs; do
    base=$(basename "$cmd")
    [ ! -e "/usr/bin/$base" ] && ln -s "$cmd" "/usr/bin/$base" 2>/dev/null || true
done

# Patch v-run-cli-cmd whitelist to allow node, npm, pnpm, pm2, yarn, npx
V_RUN_CMD="/usr/local/hestia/bin/v-run-cli-cmd"
if [ -f "$V_RUN_CMD" ]; then
    if ! grep -q "pnpm" "$V_RUN_CMD"; then
        sed -i 's/composer|wp|/composer|wp|node|npm|pnpm|pm2|yarn|npx|/g' "$V_RUN_CMD" 2>/dev/null || true
    fi
fi

# Reload Nginx
if nginx -t >/dev/null 2>&1; then
    systemctl reload nginx
fi
echo -e "\r  ${C_GREEN}✔${C_RESET} [7/7] Comandos CLI instalados y Nginx recargado correctamente."
echo ""

# ASCII Summary Card
echo -e "${C_GREEN}${C_BOLD}"
cat << "EOF"
 ╔════════════════════════════════════════════════════════════════════╗
 ║           🎉  ¡INSTALACIÓN COMPLETADA EXITOSAMENTE!  🎉           ║
 ║                                                                    ║
 ║  Autor: pochii-dev          Repo: github.com/PochiiGreen/hestia-nodejs ║
 ╚════════════════════════════════════════════════════════════════════╝
EOF
echo -e "${C_RESET}"

echo -e "${C_WHITE}${C_BOLD}📌 Resumen de Novedades y Uso en HestiaCP v1.10.5:${C_RESET}"
echo ""
echo -e "  ${C_CYAN}1. Soporte Nativo para PNPM, NPM y YARN:${C_RESET}"
echo -e "     Puedes elegir ${C_BRIGHT_GREEN}pnpm${C_RESET} para instalar dependencias ultrarrápidas y ahorrar espacio en disco."
echo ""
echo -e "  ${C_CYAN}2. Soporte de Cualquier Puerto (ej: 3041):${C_RESET}"
echo -e "     Asigna ${C_BRIGHT_GREEN}cualquier puerto${C_RESET} (ej: ${C_YELLOW}3041${C_RESET}, 4000, 5000, 8080). Nginx lo resuelve dinámicamente."
echo ""
echo -e "  ${C_CYAN}3. Ecosystem Automático y Ejecución Inmediata:${C_RESET}"
echo -e "     Genera ${C_WHITE}ecosystem.config.js${C_RESET} y ${C_WHITE}ecosystem.config.cjs${C_RESET} y pone la app a correr con PM2 al instante."
echo ""
echo -e "  ${C_CYAN}4. Comandos de Consola (CLI):${C_RESET}"
echo -e "     ${C_YELLOW}v-add-web-domain-nodejs${C_RESET} admin midominio.com 3041 mi-app app.js pnpm express production 1 yes"
echo -e "     ${C_YELLOW}v-restart-web-domain-nodejs${C_RESET} admin midominio.com"
echo -e "     ${C_YELLOW}v-list-web-domain-nodejs${C_RESET}"
echo ""
echo -e "${C_GRAY}──────────────────────────────────────────────────────────────────────${C_RESET}"
echo -e "${C_BRIGHT_GREEN}${C_BOLD}🚀 ¡HestiaCP v1.10.5 y Node.js listos para producción!${C_RESET}"
echo ""
exit 0
