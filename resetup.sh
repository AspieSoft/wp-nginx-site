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
  unset rDomain
  unset rSub

  unset dbRootPass
  unset dbUserPass
  unset dbUser
  unset dbName
  unset db_name

  unset passExclude
  unset wpPass

  unset themeVersion

  unset -f ynInput
  unset -f installPlugin
}
trap cleanup EXIT


# get user input
source <(curl -s https://raw.githubusercontent.com/AspieSoft/wp-nginx-site/master/bin/input_plugins.sh "$3" "$4" "$5" "$6" "$7")
source <(curl -s https://raw.githubusercontent.com/AspieSoft/wp-nginx-site/master/bin/input.sh "$1" "$2")

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
sudo sed -r -i "s/SUBPART_DOMAIN/$sub/" "$rSub.$rDomain"

sudo ln -s "/etc/nginx/sites-available/$rSub.$rDomain" "/etc/nginx/sites-enabled/$rSub.$rDomain"

sudo service nginx restart


# setup database
passExclude="\'\"\`\$\\\/\!\&"
dbUserPass="$(pwgen -cnys -r \"$passExclude\" 64 1)"
dbUser="$(pwgen -A0B 8 1)"
dbName="$(pwgen -A0B 8 1)"

dbRootPass=$(sudo head -n 1 /var/dp_pass) &>/dev/null

db_name=${dbName}_db_${rSub//\./_}_${rDomain//\./_}
echo -e "use mysql;\nCREATE DATABASE ${db_name};\nGRANT ALL ON ${db_name}.* TO '$dbUser'@'localhost' IDENTIFIED BY '$dbUserPass' WITH GRANT OPTION;\nFLUSH PRIVILEGES;\nexit" | mysql -u root -p$dbRootPass


# install wordpress
cd "/var/$rDomain/$rSub"

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
sudo sed -r -i "s/^\s*define\(\s*'(DB_NAME)',\s*'.*?'\s*\);\s*$/define( '\1', '${db_name}' );/m" wp-config.php
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


# install wordpress plugins
cd wp-content/plugins

function installPlugin() {
  echo "Installing Plugin $1..."
  sudo mkdir "$1" &>/dev/null
  cd "$1"
  sudo wget -r --no-parent "https://plugins.svn.wordpress.org/$1/trunk/" &>/dev/null
  sudo cp -r plugins.svn.wordpress.org/$1/trunk/* . &>/dev/null
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
  installPlugin "wp-stateless"
  installPlugin "progressive-wp"
  installPlugin "menu-icons"
  installPlugin "aspiesoft-auto-embed"
fi

if [[ "$installThemeNeve" == "true" ]]; then
  themeVersion="3.2.5"

  echo "Installing Theme neve..."
  sudo mkdir ../themes/neve &>/dev/null
  cd ../themes/neve
  sudo wget -r --no-parent "https://themes.svn.wordpress.org/neve/$themeVersion/" &>/dev/null
  sudo cp -r themes.svn.wordpress.org/neve/$themeVersion/* . &>/dev/null
  sudo rm -rf themes.svn.wordpress.org &>/dev/null
  cd ../../plugins
  echo "Finished Installing Theme neve"

  echo "Installing Plugin css-modifications-for-neve..."
  sudo mkdir css-modifications-for-neve &>/dev/null
  cd css-modifications-for-neve
  sudo wget https://raw.githubusercontent.com/AspieSoft/wp-css-modifications-for-neve/master/css-modifications-for-neve.zip &>/dev/null
  sudo unzip css-modifications-for-neve.zip &>/dev/null
  sudo rm -f css-modifications-for-neve.zip &>/dev/null
  cd ..
  echo "Finished Installing Plugin css-modifications-for-neve"
fi

sudo chown -R www-data:www-data "/var/$rDomain/$rSub"
sudo chmod -R 755 "/var/$rDomain/$rSub"


# finished msg
cd
echo "All Done!"
echo

if [[ "$subdomain" == "" ]]; then
  echo "Open https://$domain in a browser to get started"
else
  echo "Open https://$subdomain in a browser to get started"
fi
