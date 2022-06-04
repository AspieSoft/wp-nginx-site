# get user input
if [[ "$email" == "" ]]; then
  echo 'Enter Admin Email'
  read -p "Email: " email
fi

if [[ "$email" == "" && "$domain" == "" ]]; then
  echo
fi

if [[ "$domain" == "" ]]; then
  echo 'Enter Domain (Do Not include "www" unless using a different subdomain)'
  read -p "Domain: " domain
fi

if [[ "$domain" =~ ^[\w_-]+\.[\w_-]+$ ]]; then
  subdomain="www.$domain"
  sub="www"
else
  sub=${domain%%.*}
fi


# install certbot
if [[ "$subdomain" == "" ]]; then
  sudo certbot certonly --nginx -m "$email" -d "$domain" -n --agree-tos
else
  sudo certbot certonly --nginx -m "$email" -d "$domain" -d "$subdomain" -n --agree-tos
fi
sudo certbot renew --dry-run

# config nginx
cd /etc/nginx/sites-available
sudo wget -O default https://raw.githubusercontent.com/AspieSoft/wp-nginx-site/master/nginx-wp-config

sudo sed -r -i "s/DOMAIN/$domain/" default
sudo sed -r -i "s/SUB/$sub/" default

sudo service nginx restart


# finished msg
cd

echo "All Done!"
echo

if [[ "$subdomain" == "" ]]; then
  echo "Open https://$domain in a browser to get started"
else
  echo "Open https://$subdomain in a browser to get started"
fi
