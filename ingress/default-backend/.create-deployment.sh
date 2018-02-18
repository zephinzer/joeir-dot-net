#!/bin/sh
CURR_DIR="$(dirname $0)";

DOMAIN=`cat ${CURR_DIR}/.config/.DOMAIN`;
SUBDOMAIN=`cat ${CURR_DIR}/.config/.SUBDOMAIN | sed -e "s|[^a-z0-9\.]|\-|g"`;
SUBDOMAIN_DASH_CASE="$(printf -- "${SUBDOMAIN}" | sed -e "s|[^a-z0-9]|\-|g")";

CURRENT_TIMESTAMP=`date +'%Y%m%d-%H%M%S'`;
PATH_TO_DEPLOYMENT="${CURR_DIR}/.deployments/${CURRENT_TIMESTAMP}/";
mkdir -p "${PATH_TO_DEPLOYMENT}";

gcloud compute addresses list | grep "${STATIC_IP_NAME}" &>/dev/null
[ "$?" = "0" ] && STATIC_IP_NAME_EXISTS=1 || STATIC_IP_NAME_EXISTS=0;
if [ ${STATIC_IP_NAME_EXISTS} -eq 0 ]; then
  printf -- "configured static ip name '${STATIC_IP_NAME}' does not exist in the currently configured account.\n" \
    >> ${PATH_TO_DEPLOYMENT}/warnings.info;
fi;

cat ${CURR_DIR}/ingress.yaml \
  | egrep "^[^\#]" \
  | sed -e "s|\${SUBDOMAIN}|${SUBDOMAIN}|g" \
  | sed -e "s|\${SUBDOMAIN_DASH_CASE}|${SUBDOMAIN_DASH_CASE}|g" \
  | sed -e "s|\${DOMAIN}|${DOMAIN}|g" \
  >> ${PATH_TO_DEPLOYMENT}/ingress.yaml;
cat ${CURR_DIR}/deployment.yaml \
  | egrep "^[^\#]" \
  >> ${PATH_TO_DEPLOYMENT}/deployment.yaml;
cat ${CURR_DIR}/service.yaml \
  | egrep "^[^\#]" \
  >> ${PATH_TO_DEPLOYMENT}/service.yaml;

stat "${PATH_TO_DEPLOYMENT}/warnings.info" &>/dev/null;
if [ "$?" = "0" ]; then
  printf -- "\e[31mWARNINGS WERE FOUND:\e[0m\n";
  cat "${PATH_TO_DEPLOYMENT}/warnings.info";
  exit 1;
fi;

printf -- "\nDeployment saved to:\n  ${PATH_TO_DEPLOYMENT}\n";
exit 0;