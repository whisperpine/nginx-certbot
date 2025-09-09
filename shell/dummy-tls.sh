#!/bin/sh

self_sign_tls() {
  target_path="/etc/nginx/ssl/live/$1"
  if [ -e "$target_path" ]; then
    echo ":: $target_path exists."
  else
    echo ":: $target_path does not exist."
    echo ":: now creating dummy certificates to avoid Nginx startup failure."

    mkdir -p "$target_path"
    cd "$target_path" || exit 1

    openssl genrsa -out privkey.pem 2048
    openssl req -new -key privkey.pem -out csr.pem -subj "/O=dummy"
    openssl x509 -req -days 365 -in csr.pem -signkey privkey.pem -out fullchain.pem
    chmod 644 "*"
  fi
}

# shellcheck disable=SC2153
for domain_name in $DOMAIN_NAMES; do
  self_sign_tls "$domain_name"
done
