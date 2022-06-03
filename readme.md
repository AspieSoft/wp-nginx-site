# WordPress NginX Website Setup

[![donation link](https://img.shields.io/badge/buy%20me%20a%20coffee-square-blue)](https://buymeacoffee.aspiesoft.com)

Easily and quick setup for a wordpress website runing with nginx on debian.
Auto sets up lets encrypt.
Optionally auto install some recommended wordpress plugins.

> Note: If using CloudFlare, you may need to go to **SSL/TLS > Edge Certificates** and temporarily disable **Always Use HTTPS**, **Automatic HTTPS Rewrites**, and **Disable Universal SSL** so letsencrypt certbot can detect your domain.

This module will also install a [modified version of wp-migration](https://github.com/d0n601/All-In-One-WP-Migration-With-Import.git) from github

## Installation

```shell script
bash <(curl -s https://raw.githubusercontent.com/AspieSoft/wp-nginx-setup/master/setup.sh)
```
