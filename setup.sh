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


# get user input
installPluginEssentials=$(ynInput "Install Essential Plugins" "y")
installPluginDeveloper=$(ynInput "Install Developer Plugins" "y")
installPluginBeaverBuilder=$(ynInput "Install Beaver Builder Plugin" "y")
installPluginOther=$(ynInput "Install Other Plugins" "y")
installThemeNeve=$(ynInput "Install Neve Theme" "y")

echo 'Enter Admin Email'
read -p "Email: " email

echo

echo 'Enter Domain (Do Not include "www" unless using a different subdomain)'
read -p "Domain: " domain

if [[ "$domain" =~ ^[\w_-]+\.[\w_-]+$ ]]; then
  subdomain="www.$domain"
  sub="www"
else
  sub=${domain%%.*}
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
  sudo certbot certonly --nginx -m "$email" -d "$domain $subdomain" -n --agree-tos
fi
sudo certbot renew --dry-run


# config nginx
cd /etc/nginx/sites-available
sudo wget -O default https://raw.githubusercontent.com/AspieSoft/wp-nginx-site/master/nginx-wp-config

sudo sed -r -i "s/DOMAIN/$domain/" default
sudo sed -r -i "s/SUB/$sub/" default

sudo service nginx restart


# install php 8
sudo apt -y install ca-certificates apt-transport-https software-properties-common wget curl lsb-release
curl -sSL https://packages.sury.org/php/README.txt | sudo bash -x
sudo apt update
sudo apt -y install php8.1 php8.1-fpm

sudo apt -y install php8.1-bcmath php8.1-dba php8.1-dom php8.1-enchant php8.1-fileinfo php8.1-gd php8.1-imap php8.1-intl php8.1-ldap php8.1-mbstring php8.1-mysqli php8.1-mysqlnd php8.1-odbc php8.1-pdo php8.1-pgsql php8.1-phar php8.1-posix php8.1-pspell php8.1-soap php8.1-sockets php8.1-sqlite3 php8.1-sysvmsg php8.1-sysvsem php8.1-sysvshm php8.1-tidy php8.1-xmlreader php8.1-xmlwriter php8.1-xsl php8.1-yaml php8.1-zip php8.1-memcache php8.1-mailparse php8.1-imagick php8.1-igbinary php8.1-redis php8.1-curl php8.1-cli php8.1-common php8.1-opcache


# gen rand passwords
sudo apt -y install pwgen
passExclude="\'\"\`\$\\\/\!\&"
dbRootPass="$(pwgen -cnys -r \"$passExclude\" 256 1)"
dbUserPass="$(pwgen -cnys -r \"$passExclude\" 64 1)"
dbUser="$(pwgen -A0B 8 1)"
dbName="$(pwgen -A0B 8 1)"


# install database
sudo apt -y install mariadb-server
sudo systemctl enable mariadb.service
echo -e "\ny\ny\n$dbRootPass\n$dbRootPass\ny\ny\ny\ny\n" | sudo mysql_secure_installation

echo -e "use mysql;\nCREATE DATABASE ${dbName}_db;\nGRANT ALL ON wordpress_db.* TO '$dbUser'@'localhost' IDENTIFIED BY '$dbUserPass' WITH GRANT OPTION;\nFLUSH PRIVILEGES;\nexit" | mysql -u root -p$dbRootPass


# install wordpress
cd /var/www/html
sudo rm -f index.nginx-debian.html
sudo wget https://wordpress.org/latest.zip
sudo unzip latest.zip
sudo cp -r wordpress/* .
sudo rm -rf wordpress
sudo rm -f latest.zip

sudo chown -R www-data:www-data *
sudo chmod -R 755 *

# setup database
sudo cp wp-config-sample.php wp-config.php

# setup db
sudo sed -r -i "s/^\s*define\(\s*'(DB_NAME)',\s*'.*?'\s*\);\s*$/define( '\1', '${dbName}_db' );/m" wp-config.php
sudo sed -r -i "s/^\s*define\(\s*'(DB_USER)',\s*'.*?'\s*\);\s*$/define( '\1', '${dbUser}' );/m" wp-config.php
sudo sed -r -i "s/^\s*define\(\s*'(DB_PASSWORD)',\s*'.*?'\s*\);\s*$/define( '\1', '${dbUserPass}' );/m" wp-config.php

sudo sed -r -i "s/^\s*define\(\s*'(DB_HOST)',\s*'.*?'\s*\);\s*$/define( '\1', 'localhost' );/m" wp-config.php

# setup auth keys
wpPass="$(pwgen -cnys -r \"$passExclude\" 64 1)"
sudo sed -r -i "s/^\s*define\(\s*'(AUTH_KEY)',\s*'.*?'\s*\);\s*$/define( '\1', '$wpPass' );/m" wp-config.php
wpPass="$(pwgen -cnys -r \"$passExclude\" 64 1)"
sudo sed -r -i "s/^\s*define\(\s*'(SECURE_AUTH_KEY)',\s*'.*?'\s*\);\s*$/define( '\1', '$wpPass' );/m" wp-config.php
wpPass="$(pwgen -cnys -r \"$passExclude\" 64 1)"
sudo sed -r -i "s/^\s*define\(\s*'(LOGGED_IN_KEY)',\s*'.*?'\s*\);\s*$/define( '\1', '$wpPass' );/m" wp-config.php
wpPass="$(pwgen -cnys -r \"$passExclude\" 64 1)"
sudo sed -r -i "s/^\s*define\(\s*'(NONCE_KEY)',\s*'.*?'\s*\);\s*$/define( '\1', '$wpPass' );/m" wp-config.php
wpPass="$(pwgen -cnys -r \"$passExclude\" 64 1)"
sudo sed -r -i "s/^\s*define\(\s*'(AUTH_SALT)',\s*'.*?'\s*\);\s*$/define( '\1', '$wpPass' );/m" wp-config.php
wpPass="$(pwgen -cnys -r \"$passExclude\" 64 1)"
sudo sed -r -i "s/^\s*define\(\s*'(SECURE_AUTH_SALT)',\s*'.*?'\s*\);\s*$/define( '\1', '$wpPass' );/m" wp-config.php
wpPass="$(pwgen -cnys -r \"$passExclude\" 64 1)"
sudo sed -r -i "s/^\s*define\(\s*'(LOGGED_IN_SALT)',\s*'.*?'\s*\);\s*$/define( '\1', '$wpPass' );/m" wp-config.php
wpPass="$(pwgen -cnys -r \"$passExclude\" 64 1)"
sudo sed -r -i "s/^\s*define\(\s*'(NONCE_SALT)',\s*'.*?'\s*\);\s*$/define( '\1', '$wpPass' );/m" wp-config.php
unset wpPass


cd wp-content/plugins

function installPlugin() {
  echo "Installing Plugin $1..."
  sudo mkdir "$1" &>/dev/null
  cd "$1"
  sudo wget -r --no-parent "https://plugins.svn.wordpress.org/$1/trunk/" &>/dev/null
  sudo cp -r "plugins.svn.wordpress.org/$1/trunk/*" . &>/dev/null
  sudo rm -rf plugins.svn.wordpress.org &>/dev/null
  cd ..
  echo "Finished Installing Plugin $1"
}

sudo git clone https://github.com/d0n601/All-In-One-WP-Migration-With-Import.git

if [[ "$installPluginEssentials" == "true" ]]; then
  installPlugin "wordfence"
  installPlugin "aryo-activity-log"
  installPlugin "seo-by-rank-math"
  installPlugin "hummingbird-performance"
  installPlugin "companion-auto-update"
fi

if [[ "$installPluginDeveloper" == "true" ]]; then
  installPlugin "classic-editor"
  installPlugin "contact-form-7"
  installPlugin "duplicate-page"
  installPlugin "dont-muck-my-markup"
  installPlugin "html-editor-syntax-highlighter"
  installPlugin "google-apps-login"
  installPlugin "aspiesoft-wp-plugin-icons"
  installPlugin "admin-page-spider"
  installPlugin "wp-rollback"
fi

if [[ "$installPluginBeaverBuilder" == "true" ]]; then
  installPlugin "beaver-builder-lite-version"
  installPlugin "ninja-beaver-lite-addons-for-beaver-builder"
fi

if [[ "$installPluginOther" == "true" ]]; then
  installPlugin "font-awesome"
  installPlugin "rocket-lazy-load"
  installPlugin "login-security-recaptcha"
  installPlugin "menu-icons"
  installPlugin "progressive-wp"
  installPlugin "aspiesoft-auto-embed"

  echo "Installing Plugin wp-stateless..."
  sudo wget https://raw.githubusercontent.com/AspieSoft/wp-nginx-site/master/wp-stateless.zip &>/dev/null
  sudo unzip wp-stateless.zip &>/dev/null
  sudo rm -f wp-stateless.zip &>/dev/null
  echo "Finished Installing Plugin wp-stateless"
fi

if [[ "$installThemeNeve" == "true" ]]; then
  themeVersion="3.2.5"

  echo "Installing Theme neve..."
  sudo mkdir ../themes/neve &>/dev/null
  cd ../themes/neve
  sudo wget -r --no-parent "https://themes.svn.wordpress.org/neve/$themeVersion/" &>/dev/null
  sudo cp -r "themes.svn.wordpress.org/neve/$themeVersion/*" . &>/dev/null
  sudo rm -rf themes.svn.wordpress.org &>/dev/null
  cd ../../plugins
  echo "Finished Installing Theme neve"

  echo "Installing Plugin css-modifications-for-neve..."
  sudo wget https://raw.githubusercontent.com/AspieSoft/wp-css-modifications-for-neve/master/css-modifications-for-neve.zip &>/dev/null
  sudo unzip css-modifications-for-neve.zip &>/dev/null
  sudo rm -f css-modifications-for-neve.zip &>/dev/null
  echo "Finished Installing Plugin css-modifications-for-neve"
fi
