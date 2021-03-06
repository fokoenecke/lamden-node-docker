#!/usr/bin/env bash

# create crontab entries from env vars
echo 'MAILTO=""' > /etc/cron.d/lamden_cron
env | sort | awk -F= '/^CRONTAB_ENTRY_/ {print $2}' >> /etc/cron.d/lamden_cron

if [ -n "$(ls -A /entrypoint.d/ 2>/dev/null)" ]
then
  for script in /entrypoint.d/*
  do
    echo "running custom script: ${script}"
    ${script}
  done
else
  echo "no custom scripts to run"
fi

# run webserver only on masternodes
if [[ "$LAMDEN_RUN_PARAMS" = *masternode* ]]
then
    export START_WEBSERVER="true"
else
    export START_WEBSERVER="false"
fi

exec "$@"
