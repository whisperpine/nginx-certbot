#!/usr/bin/sh

# Helper script for easy startup.

APPLY_CONFIG_FILE="template/example-com-apply.conf"
RENEW_CONFIG_FILE="template/example-com-renew.conf"

help_msg() {
    echo
    echo "Helper script for easy startup."
    echo
    echo "Suported arguments:"
    echo "  create  [DOMAIN]    create nginx conf for given domain"
    echo "  https   [DOMAIN]    enable https for given domain"
    echo "  help                print help message"
    echo
}

https() {
    if [ -z $1 ]; then
        echo "error: please provide a domain name."
        exit 1
    fi

    echo
    echo "specified domain:"
    echo $1

    if [ -e "conf.d/$1-apply.conf" ]; then
        echo
        echo "deleting the old file:"
        echo "conf.d/$1-apply.conf"
        rm conf.d/$1-apply.conf
    fi

    echo
    echo "creating a new file:"
    echo "conf.d/$1.conf"
    cp $RENEW_CONFIG_FILE conf.d/$1.conf
    sed -i "s/example.com/$1/g" conf.d/$1.conf
    echo
    echo "restarting docker compose..."
    sudo docker compose down
    sudo docker compose up -d
    echo
    echo "please check the following link:"
    echo "https://$1"
    echo
}

create() {
    if [ -z $1 ]; then
        echo "error: please provide a domain name."
        exit 1
    fi

    if [ -e "conf.d/$1-apply.conf" ]; then
        echo "error: conf.d/$1-apply.conf file exists."
        echo "help: if you want to overide, please delete the old file manually."
        exit 1
    fi

    echo
    echo "specified domain:"
    echo $1
    echo
    echo "creating a new file:"
    echo "conf.d/$1-apply.conf"
    cp $APPLY_CONFIG_FILE conf.d/$1-apply.conf
    sed -i "s/example.com/$1/g" conf.d/$1-apply.conf
    echo
    echo "restarting docker compose..."
    sudo docker compose down
    sudo docker compose up -d
    echo
    echo "please check the following link:"
    echo "http://$1"
    echo
}

if [ "$1" = "help" ]; then
    help_msg
elif [ "$1" = "create" ]; then
    create $2
elif [ "$1" = "https" ]; then
    https $2
elif [ "$1" = "--help" ]; then
    help_msg
elif [ "$1" = "" ]; then
    help_msg
else
    echo "Unsupported arguments."
fi
