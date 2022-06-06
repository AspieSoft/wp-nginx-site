#!/bin/bash

# install nodejs
sudo apt -y install curl dirmngr apt-transport-https lsb-release ca-certificates
curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
sudo apt -y install nodejs
sudo apt -y install gcc g++ make

#sudo apt -y install npm
sudo npm install -g npm
