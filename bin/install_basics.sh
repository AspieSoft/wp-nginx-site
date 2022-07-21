#!/bin/bash

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
