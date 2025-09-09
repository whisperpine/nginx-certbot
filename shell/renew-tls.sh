#!/bin/sh

# Run this script to renew tls certs.

# Get env vars.
# shellcheck disable=SC1091
. ./.env
# echo $DOMAIN_NAMES

red_echo() {
  printf "\033[31m%s\033[0m" "$*"
}

# ----------------
# dry-run
# ----------------
if ! sudo docker compose run --rm certbot renew --dry-run; then
  red_echo ":: failed to renew tls certificates"
  exit 1
fi

# ----------------
# renew
# ----------------
if ! sudo docker compose run --rm certbot renew; then
  red_echo ":: failed to renew tls certificates"
  exit 1
fi

# ----------------
# reload nginx
# ----------------
sudo docker compose exec nginx chown -R nginx:nginx /etc/nginx/ssl/
if ! sudo docker compose exec nginx nginx -s reload; then
  red_echo ":: failed to reload nginx"
  exit 1
fi
