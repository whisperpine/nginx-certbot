#!/bin/sh

# Run this script to apply free tls certs.

# Get env vars.
# shellcheck disable=SC1091
. ./.env
# echo $DOMAIN_NAMES
# echo $LETSENCRYPT_EMAIL

red_echo() {
  printf "\033[31m%s\033[0m" "$*"
}
green_echo() {
  printf "\033[32m%s\033[0m" "$*"
}

# ----------------
# dry-run
# ----------------
apply_tls_dry_run() {
  if ! sudo docker compose run --rm \
    certbot certonly --webroot \
    --webroot-path /var/www/certbot/ \
    --agree-tos \
    --no-eff-email \
    -m "$LETSENCRYPT_EMAIL" \
    -d "$1" \
    --dry-run; then
    red_echo "failed to apply tls certificates for:"
    red_echo "$1"
    exit 1
  fi
}
# shellcheck disable=SC2153
for domain_name in $DOMAIN_NAMES; do
  apply_tls_dry_run "$domain_name"
done

# ----------------
# rm dummy files
# ----------------
sudo docker compose exec nginx rm -r /etc/nginx/ssl/live
green_echo "dummy tls certifates have been deleted"

# ----------------
# apply
# ----------------
apply_tls() {
  if ! sudo docker compose run --rm \
    certbot certonly --webroot \
    --webroot-path /var/www/certbot/ \
    --agree-tos \
    --no-eff-email \
    -m "$LETSENCRYPT_EMAIL" \
    -d "$1"; then
    red_echo "failed to apply tls certificates for:"
    red_echo "$1"
    exit 1
  fi
}
for domain_name in $DOMAIN_NAMES; do
  apply_tls "$domain_name"
done

# ----------------
# reload nginx
# ----------------
sudo docker compose exec nginx chown -R nginx:nginx /etc/nginx/ssl/
if ! sudo docker compose exec nginx nginx -s reload; then
  red_echo ":: failed to reload nginx"
  exit 1
fi
