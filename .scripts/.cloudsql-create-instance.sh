#!/bin/sh
## this opens up the page in GCP to create a new database instance
set -e;

GCLOUD_PROJECT_ID="$(gcloud config get-value project)";
echo "GCLOUD_PROJECT_ID: ${GCLOUD_PROJECT_ID}";
open "https://console.cloud.google.com/sql/choose-instance-engine?project=${GCLOUD_PROJECT_ID}";
exit 0;