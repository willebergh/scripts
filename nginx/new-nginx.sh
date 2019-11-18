#!/bin/bash

while getopts a:d:h:p: option
 do
  case "${option}" in
    a) ACCESS=${OPTARG};;
    d) DOMAIN=${OPTARG};;
    h) HOST=${OPTARG};;
    p) PORT=${OPTARG};;
  esac
done

function generate () {
ACCESS=$1
DOMAIN=$2
HOST=$3
PORT=$4
SSL_FULLCHAIN=$5
SSL_PRIVKEY=$6

cat << EOF
# Auto Nignx Script

# Access: $ACCESS
# Domain: $DOMAIN
# Host: $HOST
# Port: $PORT

server {
        listen 80;
        listen [::]:80;
        server_name $DOMAIN;
        return 301 https://$DOMAIN\$request_uri;
}

server {
        listen 443 ssl;
        listen [::]:443 ssl;
        server_name $DOMAIN;

        location / {
                auth_request /auth;
                proxy_pass http://$HOST:$PORT;
                proxy_pass_request_headers on;
        }

        location /auth {
                internal;
                proxy_pass http://0.0.0.0:8083/check/$ACCESS;
        }

        error_page 401 = @error401;
        location @error401 {
                return 302 https://auth.dampgang.com/login?redirect=https%3A%2F%2F$DOMAIN\$request_uri;
        }

        ssl_certificate $SSL_FULLCHAIN;
        ssl_certificate_key $SSL_PRIVKEY;
        include /etc/letsencrypt/options-ssl-nginx.conf;
        ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
}
EOF
}

if [ $UID != 0 ]
 then echo You need to run this script with sudo"!"
 exit 1
fi

if [ "$1" == "debug" ]
 then
  echo Running "in" debug mode"!"
  generate DEBUG DEBUG DEBUG DEBUG DEBUG > debug
  exit;
fi

if [ -n ! $ACCESS ]
 then ACCESS=public
fi

echo
echo -e "Access: \t $ACCESS"
echo -e "Domain: \t $DOMAIN"
echo -e "Host:   \t $HOST"
echo -e "Port:   \t $PORT"
echo

SSL_FULLCHAIN=/etc/letsencrypt/live/"$DOMAIN"/fullchain.pem
SSL_PRIVKEY=/etc/letsencrypt/live/"$DOMAIN"/privkey.pem

# Get new ssl certificate
if [ ! -e $SSL_FULLCHAIN ] || [ ! -e $SSL_PRIVKEY ]
 then
  echo -n Generating new ssl certificates...
  if sudo certbot --nginx certonly -d $DOMAIN >& certbot.tmp
   then echo -e "\t\tdone"
   else echo -e "\nFailed to create new ssl certificates; certbot log:\n\n$(cat certbot.tmp)"; exit;
 fi
 else
  echo Using existing certificates for $DOMAIN
fi

SSL_FULLCHAIN=$(cat certbot.tmp | awk '/\/etc\/letsencrypt\/live\//{print $1}' | awk '/fullchain.pem$/')
SSL_PRIVKEY=$(cat certbot.tmp | awk '/\/etc\/letsencrypt\/live\//{print $1}' | awk '/privkey.pem$/')

NGINX_CONFIG_PATH=/etc/nginx/sites-available/$DOMAIN
NGINX_CONFIG_LINK=/etc/nginx/sites-enabled/$DOMAIN

# Create nginx template for the new app
echo -n Creating config file...
generate $ACCESS $DOMAIN $HOST $PORT $SSL_FULLCHAIN $SSL_PRIVKEY > $DOMAIN
sudo mv $DOMAIN $NGINX_CONFIG_PATH
echo -e "\t\t\t\tdone"

# Create symbolic link
if [ ! -L $NGINX_CONFIG_LINK ]
 then
  echo -n Crating symbolic link...
  sudo ln -s $NGINX_CONFIG_PATH $NGINX_CONFIG_LINK
  echo -e "\t\t\tdone"
 else
  echo Skipping symbolic link: Site already enabled
fi

# Test new config
if sudo nginx -t >& /dev/null
 then
  # Restart nginx
  echo -n Restarting nginx...
  sudo systemctl restart nginx
  echo -e "\t\t\tdone"
 else
  echo Nginx test failed"!"
fi

rm certbot.tmp
echo
