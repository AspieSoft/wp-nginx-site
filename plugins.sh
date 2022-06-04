#!/bin/bash

function cleanup() {
  unset installPluginEssentials
  unset installPluginDeveloper
  unset installPluginBeaverBuilder
  unset installPluginOther
  unset installThemeNeve

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


# install wordpress plugins
cd /var/www/html/wp-content/plugins

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

  # echo "Installing Plugin wp-stateless..."
  # sudo mkdir wp-stateless &>/dev/null
  # cd wp-stateless
  # sudo wget https://raw.githubusercontent.com/AspieSoft/wp-nginx-site/master/wp-stateless.zip &>/dev/null
  # sudo unzip wp-stateless.zip &>/dev/null
  # sudo rm -f wp-stateless.zip &>/dev/null
  # cd ..
  # echo "Finished Installing Plugin wp-stateless"
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

sudo chown -R www-data:www-data /var/www/html
sudo chmod -R 755 /var/www/html


# finished msg
cd
echo "All Done!"
