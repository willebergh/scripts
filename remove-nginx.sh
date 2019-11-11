#!/bin/bash

while getopts d: option
do
case "${option}"
in
d) DOMAIN=${OPTARG};;
esac
done

sudo find /etc/letsencrypt/live/ -type d -name $DOMAIN\* -exec rm -r {} \;
sudo find /etc/letsencrypt/archive/ -type d -name $DOMAIN\* -exec rm -r {} \;
sudo find /etc/letsencrypt/renewal/ -type d -name $DOMAIN\* -exec rm -r {} \;

sudo rm /etc/nginx/sites-enabled/$DOMAIN
sudo rm /etc/nginx/sites-available/$DOMAIN
