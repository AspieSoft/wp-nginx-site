#!/bin/bash

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
installPluginEssentials="$1"
installPluginEssentials="$2"
installPluginEssentials="$3"
installPluginEssentials="$4"
installPluginEssentials="$5"

if [[ "$installPluginEssentials" == "y" ]]; then
  installPluginEssentials = "true"
elif [[ "$installPluginEssentials" == "n" ]]; then
  installPluginEssentials = "false"
else
  installPluginEssentials=$(ynInput "Install Essential Plugins" "y")
fi

if [[ "$installPluginDeveloper" == "y" ]]; then
  installPluginDeveloper = "true"
elif [[ "$installPluginDeveloper" == "n" ]]; then
  installPluginDeveloper = "false"
else
  installPluginDeveloper=$(ynInput "Install Developer Plugins" "y")
fi

if [[ "$installPluginBeaverBuilder" == "y" ]]; then
  installPluginBeaverBuilder = "true"
elif [[ "$installPluginBeaverBuilder" == "n" ]]; then
  installPluginBeaverBuilder = "false"
else
  installPluginBeaverBuilder=$(ynInput "Install Beaver Builder Plugin" "y")
fi

if [[ "$installPluginOther" == "y" ]]; then
  installPluginOther = "true"
elif [[ "$installPluginOther" == "n" ]]; then
  installPluginOther = "false"
else
  installPluginOther=$(ynInput "Install Other Plugins" "y")
fi

if [[ "$installThemeNeve" == "y" ]]; then
  installThemeNeve = "true"
elif [[ "$installThemeNeve" == "n" ]]; then
  installThemeNeve = "false"
else
  installThemeNeve=$(ynInput "Install Neve Theme" "y")
fi
