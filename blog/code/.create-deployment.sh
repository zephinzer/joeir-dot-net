#!/bin/sh
CURR_DIR="$(dirname $0)";
DB_HOST=`cat ${CURR_DIR}/.config/.DB_HOST`;
DB_NAME=`cat ${CURR_DIR}/.config/.DB_NAME`;
DB_USERNAME_BASE64=`cat ${CURR_DIR}/.config/.DB_USERNAME | base64`;
DB_PASSWORD_BASE64=`cat ${CURR_DIR}/.config/.DB_PASSWORD | base64`;
DOMAIN=`cat ${CURR_DIR}/.config/.DOMAIN`;
DOMAIN_ESCAPED="$(printf -- "${DOMAIN}" | sed -e "s|[^a-z0-9]|\-|g")";
SUBDOMAIN=`cat ${CURR_DIR}/.config/.SUBDOMAIN | sed -e "s|[^a-z0-9\.]|\-|g"`;
SUBDOMAIN_ESCAPED="$(printf -- "${SUBDOMAIN}" | sed -e "s|[^a-z0-9]|\-|g")";
CLOUDSQL_CREDENTIALS_BASE64=`cat ${CURR_DIR}/.config/.CLOUDSQL_CREDENTIALS.json | base64`;
CLOUDSQL_INSTANCE_CONNECTION_NAME=`cat ${CURR_DIR}/.config/.CLOUDSQL_INSTANCE_CONNECTION_NAME`;
CURRENT_TIMESTAMP=`date +'%Y%m%d-%H%M%S'`;
PATH_TO_DEPLOYMENT="${CURR_DIR}/.deployments/${CURRENT_TIMESTAMP}/";
mkdir -p "${PATH_TO_DEPLOYMENT}";

cat ${CURR_DIR}/config-map.yaml \
  | egrep "^[^\#]" \
  | sed -e "s|\${DB_HOST}|${DB_HOST}|g" \
  | sed -e "s|\${DB_NAME}|${DB_NAME}|g" \
  >> ${PATH_TO_DEPLOYMENT}/config-map.yaml;
cat ${CURR_DIR}/secret.db.yaml \
  | egrep "^[^\#]" \
  | sed -e "s|\${DB_USERNAME_BASE64}|${DB_USERNAME_BASE64}|g" \
  | sed -e "s|\${DB_PASSWORD_BASE64}|${DB_PASSWORD_BASE64}|g" \
  >> ${PATH_TO_DEPLOYMENT}/secret.db.yaml;
cat ${CURR_DIR}/ingress.yaml \
  | egrep "^[^\#]" \
  | sed -e "s|\${DOMAIN}|${DOMAIN}|g" \
  | sed -e "s|\${DOMAIN_ESCAPED}|${DOMAIN_ESCAPED}|g" \
  | sed -e "s|\${SUBDOMAIN}|${SUBDOMAIN}|g" \
  | sed -e "s|\${SUBDOMAIN_ESCAPED}|${SUBDOMAIN_ESCAPED}|g" \
  >> ${PATH_TO_DEPLOYMENT}/ingress.yaml;
cat ${CURR_DIR}/secret.cloudsql.yaml \
  | egrep "^[^\#]" \
  | sed -e "s|\${CLOUDSQL_CREDENTIALS_BASE64}|${CLOUDSQL_CREDENTIALS_BASE64}|g" \
  >> ${PATH_TO_DEPLOYMENT}/secret.cloudsql.yaml;
cat ${CURR_DIR}/deployment.yaml \
  | egrep "^[^\#]" \
  | sed -e "s|\${CLOUDSQL_INSTANCE_CONNECTION_NAME}|${CLOUDSQL_INSTANCE_CONNECTION_NAME}|g" \
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