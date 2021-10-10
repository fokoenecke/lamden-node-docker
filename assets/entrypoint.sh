#!/usr/bin/env bash

# create crontab entries from env vars
echo 'MAILTO=""' > /etc/cron.d/lamden_cron
env | sort | awk -F= '/^CRONTAB_ENTRY_/ {print $2}' >> /etc/cron.d/lamden_cron

for script in /entrypoint.d/*
do
  echo "running custom script: ${script}"
  ${script}
done

exec "$@"
