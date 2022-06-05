#!/bin/bash

function cleanup() {
  unset installPluginEssentials
  unset installPluginDeveloper
  unset installPluginBeaverBuilder
  unset installPluginOther
  unset installThemeNeve

  unset email
  unset domain
  unset subdomain
  unset sub

  unset dbRootPass
  unset dbUserPass
  unset dbUser
  unset dbName

  unset passExclude
  unset wpPass

  unset themeVersion

  unset -f ynInput
  unset -f installPlugin
}
trap cleanup EXIT


function ynInput() {

  local optY="y"
  local optN="n"

  if [ "$2" = "y" -o "$2" = "Y" ] ; then
    optY="Y"
  elif [ "$2" = "n" -o "$2" = "N" ] ; then
    optN="N"
  fi

  local input=""
  read -n1 -p "$1 ($optY/$optN)? " input ; echo >&2

  if [ "$input" = "y" -o "$input" = "Y" ] ; then
    echo "true"
  elif [ "$input" = "n" -o "$input" = "N" ] ; then
    echo "false"
  else
    if [ "$2" = "y" -o "$2" = "Y" ] ; then
      echo "true"
    elif [ "$2" = "n" -o "$2" = "N" ] ; then
      echo "false"
    else
      echo ynInput "$1" "$2"
    fi
  fi

  unset input
  unset optY
  unset optN
}

cd

email="$(cat wp-site-ssl-info.txt | grep 'email: ')"
email="${email//email: /}"

domain="$(cat wp-site-ssl-info.txt | grep 'domain: ')"
domain="${domain//domain: /}"

port="$(cat wp-site-ssl-info.txt | grep 'domain: ')"
port="${port//port: /}"

echo "" > wp-site-ssl-info.txt

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

if [[ "$port" == "" ]]; then
  echo 'Enter Port Number For Node.js Server (This will sit under a proxy)'
  read -p "port: " port
fi

if [[ "$port" != "" ]]; then
  echo "port: $port" >> wp-site-ssl-info.txt
fi


# update
sudo apt update
sudo apt -y upgrade

# install zip
sudo apt -y install zip unzip gzip

# install git
sudo apt -y install git wget curl

# install nginx
sudo apt -y install nginx


# install certbot
sudo apt -y install snapd
sudo snap install core; sudo snap refresh core
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot

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
sudo sed -r -i "s/SUB_DOMAIN/$sub/" default
sudo sed -r -i "s/NODE_PORT/$port/" default

sudo service nginx restart


# install nodejs
sudo apt -y install curl dirmngr apt-transport-https lsb-release ca-certificates
curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
sudo apt -y install nodejs
sudo apt -y install gcc g++ make

#sudo apt -y install npm
sudo npm install -g npm


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
