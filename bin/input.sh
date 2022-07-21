#!/bin/bash

# get user input
email="$1"
domain="$2"


if [[ "$email" == "" ]]; then
  echo 'Enter Admin Email'
  read -p "Email: " email
  echo
fi

if [[ "$domain" == "" ]]; then
  echo 'Enter Domain (Do Not include "www" unless using a different subdomain)'
  read -p "Domain: " domain
fi

if [[ "$domain" =~ ^[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$ ]]; then
  subdomain="www.$domain"
  sub="www"
  rDomain=$(echo "$subdomain" | sed -r 's/^[A-Za-z0-9._-]+\.([A-Za-z0-9]+\.[A-Za-z0-9]+)$/\1/g')
  rSub=$(echo "$subdomain" | sed -r 's/^([A-Za-z0-9._-]+)\.[A-Za-z0-9]+\.[A-Za-z0-9]+$/\1/g')
else
  subdomain="$domain"
  sub=${domain%%.*}
  rDomain=$(echo "$domain" | sed -r 's/^[A-Za-z0-9._-]+\.([A-Za-z0-9]+\.[A-Za-z0-9]+)$/\1/g')
  rSub=$(echo "$domain" | sed -r 's/^([A-Za-z0-9._-]+)\.[A-Za-z0-9]+\.[A-Za-z0-9]+$/\1/g')
fi
