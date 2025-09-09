#!/bin/sh

# Helper script for quick setup.

case $1 in
init)
  sh ./shell/template-conf.sh
  ;;
apply)
  sh ./shell/apply-tls.sh
  ;;
renew)
  sh ./shell/renew-tls.sh
  ;;
cron)
  sh ./shell/setup-cron.sh
  ;;
*)
  echo "Usage: sh helper.sh [init|apply|renew|cron]"
  ;;
esac
