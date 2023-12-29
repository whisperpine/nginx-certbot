#!/usr/bin/sh

# Helper script for quick setup.

APPLY_CONFIG_FILE="template/example-com-apply.conf"
RENEW_CONFIG_FILE="template/example-com-renew.conf"

# Example: 20230527-0146
TIMESTAMP=$(date +%Y%m%d-%H%M)

help_msg() {
    echo
    echo "Usage:"
    echo " sh $0 [OPTIONS] DOMAIN"
    echo
    echo "Exmaples:"
    echo " sh $0 -a create -d www.exmaple.com"
    echo " sh $0 -c -a create -d www.exmaple.com"
    echo " sh $0 -a https -d www.exmaple.com"
    echo
    echo "Helper script for quick setup."
    echo
    echo "Options:"
    echo " -h, --help        display this help"
    echo " -a [ACTION]       optional values: create, https"
    echo " -d [DOMAIN]       set domain name (never ignore this option)"
    echo " -c                use 'docker-compose' instead of 'docker compose'"
    echo
}

action() {
    while getopts ":a::d:ch" opt; do
        case ${opt} in
        a)
            ACTION=${OPTARG}
            ;;
        c)
            FLAG_C="C"
            ;;
        h)
            help_msg
            exit 0
            ;;
        d)
            DOMAIN_NAME=${OPTARG}
            ;;
        \?)
            echo "Invalid option: -${OPTARG}."
            exit 1
            ;;
        :)
            echo "error: please provide a domain name." >&2
            ;;
        esac
    done

    echo
    echo "specified domain:"
    echo $DOMAIN_NAME

    if [ -e "conf.d/$DOMAIN_NAME.conf" ]; then
        echo
        echo "backing up the old file:"
        echo "rename conf.d/$DOMAIN_NAME.conf"
        echo "as     conf.d/$DOMAIN_NAME.conf.$TIMESTAMP.old"
        cp conf.d/$DOMAIN_NAME.conf conf.d/$DOMAIN_NAME.conf.$TIMESTAMP.old
    fi

    echo
    echo "creating a new file:"
    echo "conf.d/$DOMAIN_NAME.conf"

    if [ $ACTION = "create" ]; then
        cp $APPLY_CONFIG_FILE conf.d/$DOMAIN_NAME.conf
    elif [ $ACTION = "https" ]; then
        cp $RENEW_CONFIG_FILE conf.d/$DOMAIN_NAME.conf
    else
        echo "-a optional values: create, https" >&2
        exit 1
    fi

    sed -i "s/example.com/$DOMAIN_NAME/g" conf.d/$DOMAIN_NAME.conf

    echo
    echo "restarting docker compose..."
    if [ -z ${FLAG_C} ]; then
        sudo docker compose down
        sudo docker compose up -d
    else
        sudo docker-compose down
        sudo docker-compose up -d
    fi

    echo
    echo "please check the following link:"
    if [ $ACTION = "create" ]; then
        echo "http://$DOMAIN_NAME"
    elif [ $ACTION = "https" ]; then
        echo "https://$DOMAIN_NAME"
    fi
    echo
}

case $1 in
"help")
    help_msg
    ;;
"--help")
    help_msg
    ;;
"")
    help_msg
    ;;
*)
    action $@
    ;;
esac
