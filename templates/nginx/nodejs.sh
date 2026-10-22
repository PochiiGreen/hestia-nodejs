#!/bin/bash
#=========================================================================#
# Node.js Template Hook for HestiaCP                                      #
# Author: pochii-dev / PochiiGreen (https://github.com/PochiiGreen)       #
# Args: $1=user $2=domain $3=ip $4=home $5=docroot                       #
#=========================================================================#

user="$1"
domain="$2"
ip="$3"
home="$4"
docroot="$5"

conf_dir="$home/$user/conf/web/$domain"
web_dir="$home/$user/web/$domain"

mkdir -p "$conf_dir" 2>/dev/null || true

# If nodeport.conf does not exist, initialize with default port 3000
if [ ! -f "$conf_dir/nodeport.conf" ]; then
    cat <<EOF > "$conf_dir/nodeport.conf"
# Node.js reverse proxy port mapping for $domain
proxy_pass http://127.0.0.1:3000;
EOF
    chown "$user:$user" "$conf_dir/nodeport.conf" 2>/dev/null || true
    chmod 644 "$conf_dir/nodeport.conf" 2>/dev/null || true
fi

# Ensure web directory is traversable by the Nginx worker process
chmod 751 "$web_dir" 2>/dev/null || true
exit 0
