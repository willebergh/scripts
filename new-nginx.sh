#!/bin/bash

while getopts d:p: option
do
case "${option}"
in
d) DOMAIN=${OPTARG};;
p) PORT=${OPTARG};;
esac
done

echo Server name: $DOMAIN;
echo Service port: $PORT;

# Get new ssl certificate
sudo certbot --nginx certonly -d $DOMAIN

NGINX_CONFIG="server { listen 80; listen [::]:80; server_name "$DOMAIN"; return 301 https://"$DOMAIN"$"request_uri"; } server { listen 443 ssl; listen [::]:443 ssl; server_name "$DOMAIN"; location / { proxy_pass http://0.0.0.0:"$PORT"; } ssl_certificate /etc/letsencrypt/live/"$DOMAIN"/fullchain.pem;ssl_certificate_key /etc/letsencrypt/live/"$DOMAIN"/privkey.pem; include /etc/letsencrypt/options-ssl-nginx.conf; ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; }"

# Create nginx template for the new app
sudo echo $NGINX_CONFIG > /etc/nginx/sites-available/$DOMAIN

# Create symbolic link
sudo ln -s /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/$DOMAIN

# Test new config
sudo nginx -t

# Restart nginx
sudo systemctl restart nginx
