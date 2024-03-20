#!/bin/sh

# Helper script for quick setup.

# get env vars.
. ./.env
# echo $DOMAIN_NAMES

# Example: 20230527-0146
TIMESTAMP=$(date +%Y%m%d-%H%M)

add_conf() {
    DOMAIN_NAME=$1
    TARGET_PATH="./conf.d/$DOMAIN_NAME.conf"

    if [ -e "$TARGET_PATH" ]; then
        echo
        echo "backing up the old file:"
        echo "rename $TARGET_PATH"
        echo "as     $TARGET_PATH.$TIMESTAMP.old"
        cp $TARGET_PATH $TARGET_PATH.$TIMESTAMP.old
    fi

    echo
    echo "creating a new file:"
    echo $TARGET_PATH
    cp ./conf.d/.conf.template $TARGET_PATH

    sed -i "s/example.com/$DOMAIN_NAME/g" $TARGET_PATH
}

for DOMAIN_NAME in $DOMAIN_NAMES; do
    add_conf $DOMAIN_NAME
done
