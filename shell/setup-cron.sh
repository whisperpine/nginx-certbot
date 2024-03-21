#!/bin/sh

sudo tee /etc/cron.d/minio-compose <<EOF
# renew every 2 months (on the first day of the month).
0 0 1 */2 * cd $(pwd) && sh helper.sh renew
EOF
