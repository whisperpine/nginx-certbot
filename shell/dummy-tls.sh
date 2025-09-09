#!/bin/sh

self_sign_tls() {
  TARGET_PATH="/etc/nginx/ssl/live/$1"
  if [ -e $TARGET_PATH ]; then
    echo ":: $TARGET_PATH exists."
  else
    echo ":: $TARGET_PATH does not exist."
    echo ":: now creating dummy certificates to avoid Nginx startup failure."

    mkdir -p $TARGET_PATH
    cd $TARGET_PATH

    openssl genrsa -out privkey.pem 2048
    openssl req -new -key privkey.pem -out csr.pem -subj "/O=dummy"
    openssl x509 -req -days 365 -in csr.pem -signkey privkey.pem -out fullchain.pem
    chmod 644 *
  fi
}

for DOMAIN_NAME in $DOMAIN_NAMES; do
  self_sign_tls $DOMAIN_NAME
done
