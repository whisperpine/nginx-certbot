#!/bin/sh

# get env vars.
# shellcheck disable=SC1091
. ./.env
# echo $DOMAIN_NAMES

# Example: 20230527-0146
timestamp=$(date +%Y%m%d-%H%M)

add_conf() {
  domain_name=$1
  target_path="./conf.d/$domain_name.conf"

  if [ -e "$target_path" ]; then
    echo
    echo "backing up the old file:"
    echo "rename $target_path"
    echo "as     $target_path.$timestamp.old"
    cp "$target_path" "$target_path.$timestamp.old"
  fi

  echo
  echo "creating a new file:"
  echo "$target_path"
  cp ./conf.d/.conf.template "$target_path"

  sed -i "s/example.com/$domain_name/g" "$target_path"
}

# shellcheck disable=SC2153
for domain_name in $DOMAIN_NAMES; do
  add_conf "$domain_name"
done
