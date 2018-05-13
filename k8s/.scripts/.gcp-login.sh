#!/bin/sh
CURR_DIR="$(dirname $0)";
gcloud auth login "$(cat ${CURR_DIR}/../.config/gcloud_account)";
gcloud config set project "$(cat ${CURR_DIR}/../.config/gcloud_project_id)";
gcloud config set compute/zone "$(cat ${CURR_DIR}/../.config/gcloud_zone)";