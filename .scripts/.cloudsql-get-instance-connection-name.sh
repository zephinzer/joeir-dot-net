#!/bin/sh
## this retrieves the connection name of a CloudSQL instance
## the CloudSQL instance ID will be read from ./.config/cloud_sql_instance_id

GCLOUD_SQL_INSTANCE_ID="$(cat ${PWD}/.config/cloud_sql_instance_id)";
INSTANCE_CONNECTION_NAME="$(gcloud sql instances describe "${GCLOUD_SQL_INSTANCE_ID}" | grep "connectionName" | cut -f 2 -d ' ')";
printf -- "INSTANCE_CONNECTION_NAME: ${INSTANCE_CONNECTION_NAME}\n";