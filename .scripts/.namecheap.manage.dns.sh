#!/bin/sh
CURR_DIR="$(dirname $0)";
DOMAIN=`cat ${CURR_DIR}/../.config/domain`;
open "https://ap.www.namecheap.com/domains/domaincontrolpanel/${DOMAIN}/advanceddns";
exit 0;