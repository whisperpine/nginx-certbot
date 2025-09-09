#!/bin/sh

# run this script to apply free tls certs.

# get env vars.
. ./.env
# echo $DOMAIN_NAMES
# echo $LETSENCRYPT_EMAIL

red_echo() {
  echo -e "\033[31m$@\033[0m"
}
green_echo() {
  echo -e "\033[32m$@\033[0m"
}

######### dry-run #########>
apply_tls_dry_run() {
  sudo $DOCKER_COMPOSE run --rm \
    certbot certonly --webroot \
    --webroot-path /var/www/certbot/ \
    --agree-tos \
    --no-eff-email \
    -m $LETSENCRYPT_EMAIL \
    -d $1 \
    --dry-run
  if [ $? -ne 0 ]; then
    red_echo "failed to apply tls certificates for:"
    red_echo "$1"
    exit 1
  fi
}

for DOMAIN_NAME in $DOMAIN_NAMES; do
  apply_tls_dry_run $DOMAIN_NAME
done
######### dry-run #########<

######### rm dummy files #########>
sudo $DOCKER_COMPOSE exec nginx rm -r /etc/nginx/ssl/live
green_echo "dummy tls certifates have been deleted"
######### rm dummy files #########<

######### apply #########>
apply_tls() {
  sudo $DOCKER_COMPOSE run --rm \
    certbot certonly --webroot \
    --webroot-path /var/www/certbot/ \
    --agree-tos \
    --no-eff-email \
    -m $LETSENCRYPT_EMAIL \
    -d $1
  if [ $? -ne 0 ]; then
    red_echo "failed to apply tls certificates for:"
    red_echo "$1"
    exit 1
  fi
}

for DOMAIN_NAME in $DOMAIN_NAMES; do
  apply_tls $DOMAIN_NAME
done
######### apply #########<

######### reload nginx #########<
sudo $DOCKER_COMPOSE exec nginx chown -R nginx:nginx /etc/nginx/ssl/
sudo $DOCKER_COMPOSE exec nginx nginx -s reload

if [ $? -ne 0 ]; then
  red_echo ":: failed to reload nginx"
  exit 1
fi
######### reload nginx #########<
