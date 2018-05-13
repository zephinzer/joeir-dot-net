#!/bin/sh
## this creates a new user for an existing CloudSQL instance
## run this from the directory of any deployment
## the CloudSQL instance ID will be read from ./.config/cloud_sql_instance_id

set -e;

GCLOUD_SQL_INSTANCE_ID="$(cat ${PWD}/.config/cloud_sql_instance_id)";
if [ "$?" != "0" ] || [ "${GCLOUD_SQL_INSTANCE_ID}" = "" ]; then
  read -p "Enter CloudSQL instance ID: " GCLOUD_SQL_INSTANCE_ID;
  if [ "${GCLOUD_SQL_INSTANCE_ID}" = "" ]; then
    printf -- "\e[1m\e[31mERROR\e[0m\e[31m - invalid instance ID";
    exit 1;
  fi;
fi;
printf -- "GCLOUD_SQL_INSTANCE_ID: ${GCLOUD_SQL_INSTANCE_ID}\n";
read -p "Enter username for proxy user: " INPUT_USERNAME;
printf -- "USERNAME: ${INPUT_USERNAME}\n";
read -p "Confirm DELETE user '${INPUT_USERNAME}' (y/N)? " CONFIRMATION;

if [ "${CONFIRMATION}" = "y" ] || [ "${CONFIRMATION}" = "Y" ]; then
  printf -- 'Deleting user...\n';
  gcloud sql users delete "${INPUT_USERNAME}" cloudsqlproxy~% \
    --instance="${GCLOUD_SQL_INSTANCE_ID}";
  printf -- '\nDONE.\n';
else
  printf -- "Aborted proxy user deletion with exit code 1.\n";
  exit 1;
fi;
