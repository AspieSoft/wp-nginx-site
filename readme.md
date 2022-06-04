# WordPress NginX Website Setup

[![donation link](https://img.shields.io/badge/buy%20me%20a%20coffee-square-blue)](https://buymeacoffee.aspiesoft.com)

Easy and quick setup for a wordpress website runing with nginx on debian.
Auto sets up lets encrypt.
Optionally auto install some recommended wordpress plugins.

This module will also install a [modified version of wp-migration](https://github.com/d0n601/All-In-One-WP-Migration-With-Import.git) from github.

> Note: If Using CloudFlare, You May Need To Do The Following
>
> - Under **SSL/TLS > Origin Server**
>   - Enable **Authenticated Origin Pulls**
> - Under **SSL/TLS > Edge Certificates**
>   - Disable **Always Use HTTPS**
>   - If the ssl certificate still fails after trying the above
>     - Disable **Automatic HTTPS Rewrites**
>     - Click **Disable Universal SSL**

## Installation

```shell script
bash <(curl -s https://raw.githubusercontent.com/AspieSoft/wp-nginx-site/master/setup.sh)
```

## Retry SSL Certificate Install

If the ssl certificate failed to install, you can run the below command to try again, without rerunning the initial setup.

```shell script
bash <(curl -s https://raw.githubusercontent.com/AspieSoft/wp-nginx-site/master/ssl.sh)
```

## Redo Plugin Install

You can easily install the reccommended plugins any time you want.

```shell script
bash <(curl -s https://raw.githubusercontent.com/AspieSoft/wp-nginx-site/master/plugins.sh)
```
