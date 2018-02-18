#!/bin/sh
## this script creates a new static IP address
read -p "Enter the name of the IP address to create (default): " ADDRESS_NAME;
if [ "${ADDRESS_NAME}" = "" ]; then
  ADDRESS_NAME='default';
fi;
read -p "Enter the region of the IP address to create (global): " REGION;
if [ "${REGION}" = "" ]; then
  REGION='global';
fi;
if [ "${REGION}" = "global" ]; then
  gcloud compute addresses create "${ADDRESS_NAME}" --global;
else
  gcloud compute addresses create "${ADDRESS_NAME}" --region=${REGION};
fi;