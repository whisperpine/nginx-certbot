#!/bin/sh

# run this script to renew tls certs.

# get env vars.
. ./.env
# echo $DOMAIN_NAMES

######### dry-run #########>
sudo $DOCKER_COMPOSE run --rm certbot renew --dry-run

if [ $? -ne 0 ]; then
  red_echo ":: failed to renew tls certificates"
  exit 1
fi
######### dry-run #########<

######### renew #########>
sudo $DOCKER_COMPOSE run --rm certbot renew

if [ $? -ne 0 ]; then
  red_echo ":: failed to renew tls certificates"
  exit 1
fi
######### renew #########<

######### reload nginx #########<
sudo $DOCKER_COMPOSE exec nginx chown -R nginx:nginx /etc/nginx/ssl/
sudo $DOCKER_COMPOSE exec nginx nginx -s reload

if [ $? -ne 0 ]; then
  red_echo ":: failed to reload nginx"
  exit 1
fi
######### reload nginx #########<
