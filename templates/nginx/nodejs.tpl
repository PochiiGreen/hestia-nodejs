#=========================================================================#
# Hestia Control Panel - Node.js HTTP Reverse Proxy Template              #
# Author: pochii-dev / PochiiGreen (https://github.com/PochiiGreen)       #
# Application directory: %home%/%user%/web/%domain%/private/nodeapp       #
# Static assets:         %docroot% (%home%/%user%/web/%domain%/public_html)#
# Dynamic reverse proxy to Node.js / PM2 on $node_port with WebSockets    #
#=========================================================================#

server {
    listen      %ip%:%web_port%;
    server_name %domain_idn% %alias_idn%;
    root        %docroot%;
    index       index.html index.htm;
    access_log  /var/log/%web_system%/domains/%domain%.log combined;
    access_log  /var/log/%web_system%/domains/%domain%.bytes bytes;
    error_log   /var/log/%web_system%/domains/%domain%.error.log error;

    # Node.js dynamic port mapping (default 3000, set per domain in nodeport.conf)
    set $node_port 3000;
    include %home%/%user%/conf/web/%domain%/nodeport.conf*;

    # Deny access to hidden files/directories (except .well-known for ACME/SSL)
    location ~ /\.(?!well-known\/|file) {
        deny all;
        return 404;
    }

    # Static assets direct caching - served by Nginx if file exists in %docroot%
    location ~* ^.+\.(jpg|jpeg|gif|png|ico|svg|css|zip|tgz|gz|rar|bz2|doc|xls|exe|pdf|ppt|txt|tar|mid|midi|wav|bmp|rtf|js|flv|swf|woff|woff2|ttf|eot|webp)$ {
        root %docroot%;
        access_log off;
        expires 30d;
        add_header Cache-Control "public, no-transform";
        try_files $uri @nodejs_app;
    }

    # Main application routing: reverse proxy directly to Node.js backend
    location / {
        proxy_pass         http://127.0.0.1:$node_port;
        proxy_http_version 1.1;

        # WebSocket support
        proxy_set_header   Upgrade $http_upgrade;
        proxy_set_header   Connection "upgrade";

        # Proxy Headers
        proxy_set_header   Host $host;
        proxy_set_header   X-Real-IP $remote_addr;
        proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto $scheme;
        proxy_set_header   X-Forwarded-Port $server_port;
        proxy_set_header   X-Forwarded-Host $host;

        # Production buffer & timeout configurations
        proxy_connect_timeout 60s;
        proxy_send_timeout    300s;
        proxy_read_timeout    300s;
        proxy_cache_bypass    $http_upgrade;
        proxy_buffering       off;
    }

    # Fallback location for static asset misses
    location @nodejs_app {
        proxy_pass         http://127.0.0.1:$node_port;
        proxy_http_version 1.1;

        # WebSocket support
        proxy_set_header   Upgrade $http_upgrade;
        proxy_set_header   Connection "upgrade";

        # Proxy Headers
        proxy_set_header   Host $host;
        proxy_set_header   X-Real-IP $remote_addr;
        proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto $scheme;
        proxy_set_header   X-Forwarded-Port $server_port;
        proxy_set_header   X-Forwarded-Host $host;

        # Production buffer & timeout configurations
        proxy_connect_timeout 60s;
        proxy_send_timeout    300s;
        proxy_read_timeout    300s;
        proxy_cache_bypass    $http_upgrade;
        proxy_buffering       off;
    }

    location /error/ {
        alias %home%/%user%/web/%domain%/document_errors/;
    }

    include %home%/%user%/conf/web/%domain%/nginx.conf_*;
}
