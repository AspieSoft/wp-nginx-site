#!/bin/bash

# install php 8
sudo apt -y install ca-certificates apt-transport-https software-properties-common wget curl lsb-release
curl -sSL https://packages.sury.org/php/README.txt | sudo bash -x
sudo apt update
sudo apt -y install php8.1 php8.1-fpm

sudo apt -y install php8.1-bcmath php8.1-dba php8.1-dom php8.1-enchant php8.1-fileinfo php8.1-gd php8.1-imap php8.1-intl php8.1-ldap php8.1-mbstring php8.1-mysqli php8.1-mysqlnd php8.1-odbc php8.1-pdo php8.1-pgsql php8.1-phar php8.1-posix php8.1-pspell php8.1-soap php8.1-sockets php8.1-sqlite3 php8.1-sysvmsg php8.1-sysvsem php8.1-sysvshm php8.1-tidy php8.1-xmlreader php8.1-xmlwriter php8.1-xsl php8.1-yaml php8.1-zip php8.1-memcache php8.1-mailparse php8.1-imagick php8.1-igbinary php8.1-redis php8.1-curl php8.1-cli php8.1-common php8.1-opcache


# gen rand passwords
sudo apt -y install pwgen
passExclude="\'\"\`\$\\\/\!\&"
dbUserPass="$(pwgen -cnys -r \"$passExclude\" 64 1)"
dbUser="$(pwgen -A0B 8 1)"
dbName="$(pwgen -A0B 8 1)"

dbRootPass=$(sudo head -n 1 /var/dp_pass) &>/dev/null
if [[ "$dbRootPass" == "" ]]; then
  dbRootPass="$(pwgen -cnys -r \"$passExclude\" 64 1)"
  echo "$dbRootPass" | sudo tee -a /var/dp_pass
  sudo chmod 600 /var/dp_pass
fi

# install database
sudo apt -y install mariadb-server
sudo systemctl enable mariadb.service
echo -e "\ny\ny\n$dbRootPass\n$dbRootPass\ny\ny\ny\ny\n" | sudo mysql_secure_installation
