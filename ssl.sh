#!/bin/bash

function cleanup() {
  unset email
  unset domain
  unset subdomain
  unset sub
}
trap cleanup EXIT


# get user input
cd

email="$(cat wp-site-ssl-info.txt | grep 'email: ')"
email="${email//email: /}"

domain="$(cat wp-site-ssl-info.txt | grep 'domain: ')"
domain="${domain//domain: /}"

if [[ "$email" == "" ]]; then
  echo 'Enter Admin Email'
  read -p "Email: " email
  echo
fi

if [[ "$email" != "" ]]; then
  echo "email: $email" >> wp-site-ssl-info.txt
fi

if [[ "$domain" == "" ]]; then
  echo 'Enter Domain (Do Not include "www" unless using a different subdomain)'
  read -p "Domain: " domain
fi

if [[ "$domain" != "" ]]; then
  echo "domain: $domain" >> wp-site-ssl-info.txt
fi

if [[ "$domain" =~ ^[\w_-]+\.[\w_-]+$ ]]; then
  subdomain="www.$domain"
  sub="www"
else
  sub=${domain%%.*}
fi


# fix nginx (disable ssl)
cd /etc/nginx/sites-available
sudo sed -r -i "s/(listen\s*443)/#\1/" default
sudo sed -r -i "s/(ssl_certificate)/#\1/" default
sudo sed -r -i "s|(include\s*/etc/letsencrypt)|#\1|" default
sudo service nginx restart


# install certbot
if [[ "$subdomain" == "" ]]; then
  sudo certbot certonly --nginx -m "$email" -d "$domain" -n --agree-tos
else
  sudo certbot certonly --nginx -m "$email" -d "$domain" -d "$subdomain" -n --agree-tos
fi
sudo certbot renew --dry-run

# config nginx
cd /etc/nginx/sites-available
sudo wget -O default https://raw.githubusercontent.com/AspieSoft/wp-nginx-site/master/nginx-wp-config

sudo sed -r -i "s/DOMAIN/$domain/" default
sudo sed -r -i "s/SUB/$sub/" default

sudo service nginx restart


# finished msg
cd
echo "All Done!"
echo

if [[ "$subdomain" == "" ]]; then
  echo "Open https://$domain in a browser to get started"
else
  echo "Open https://$subdomain in a browser to get started"
fi
