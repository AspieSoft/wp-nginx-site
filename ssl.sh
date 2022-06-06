#!/bin/bash

function cleanup() {
  unset email
  unset domain
  unset subdomain
  unset sub
  unset rDomain
  unset rSub
}
trap cleanup EXIT


# get user input
source <(curl -s https://raw.githubusercontent.com/AspieSoft/wp-nginx-site/master/bin/input.sh "$1" "$2")


# fix nginx (disable ssl)
cd /etc/nginx/sites-available
sudo sed -r -i "s/(listen\s*443)/#\1/" "$rSub.$rDomain"
sudo sed -r -i "s/(ssl_certificate)/#\1/" "$rSub.$rDomain"
sudo sed -r -i "s|(include\s*/etc/letsencrypt)|#\1|" "$rSub.$rDomain"
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
sudo wget -O "$rSub.$rDomain" https://raw.githubusercontent.com/AspieSoft/wp-nginx-site/master/nginx-wp-config

if [[ "$subdomain" == "" ]]; then
  sudo sed -r -i "s/LIST_DOMAINS/$domain/" "$rSub.$rDomain"
else
  sudo sed -r -i "s/LIST_DOMAINS/$domain $subdomain/" "$rSub.$rDomain"
fi
sudo sed -r -i "s/BASIC_DOMAIN/$domain/" "$rSub.$rDomain"
sudo sed -r -i "s/SUB_DOMAIN/$subdomain/" "$rSub.$rDomain"

sudo ln -s "/etc/nginx/sites-available/$rSub.$rDomain" "/etc/nginx/sites-enabled/$rSub.$rDomain"

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
