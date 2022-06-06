#!/bin/bash

function cleanup() {
  unset email
  unset domain
  unset subdomain
  unset sub
  unset rDomain
  unset rSub
  unset port
}
trap cleanup EXIT


# get user input
source <(curl -s https://raw.githubusercontent.com/AspieSoft/wp-nginx-site/master/bin/input.sh "$1" "$2")

port = "$3"

if [[ "$port" == "" ]]; then
  echo 'Enter Port Number For Node.js Server (This will sit under a proxy)'
  read -p "port: " port
fi


# install basics
source <(curl -s https://raw.githubusercontent.com/AspieSoft/wp-nginx-site/master/bin/install_basics.sh)


if [[ "$subdomain" == "" ]]; then
  sudo certbot certonly --nginx -m "$email" -d "$domain" -n --agree-tos
else
  sudo certbot certonly --nginx -m "$email" -d "$domain" -d "$subdomain" -n --agree-tos
fi
sudo certbot renew --dry-run


# config nginx
cd /etc/nginx/sites-available
sudo wget -O default https://raw.githubusercontent.com/AspieSoft/wp-nginx-site/master/nginx-wp-config

if [[ "$subdomain" == "" ]]; then
  sudo sed -r -i "s/LIST_DOMAINS/$domain/" default
else
  sudo sed -r -i "s/LIST_DOMAINS/$domain $subdomain/" default
fi
sudo sed -r -i "s/BASIC_DOMAIN/$domain/" default
sudo sed -r -i "s/SUB_DOMAIN/$subdomain/" default
sudo sed -r -i "s/NODE_PORT/$port/" default

sudo service nginx restart


# install node
source <(curl -s https://raw.githubusercontent.com/AspieSoft/wp-nginx-site/master/bin/install_node.sh)


# finished msg
cd
echo "All Done!"
echo

echo "To get started, run: 'gcloud init & gcloud compute scp --recurse ~/Local/Path/To/Node/Server vm-name:~/app'"
echo

if [[ "$subdomain" == "" ]]; then
  echo "https://$domain"
else
  echo "https://$subdomain"
fi
