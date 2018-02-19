#!/bin/sh
CURR_DIR="$(dirname $0)";
_=$(stat ./.config/.NFS_SERVER) && FLAG_IS_NFS_ENABLED=1 || FLAG_IS_NFS_ENABLED=0

CLOUDSQL_CREDENTIALS_BASE64=`cat ${CURR_DIR}/.config/.CLOUDSQL_CREDENTIALS.json | base64`;
CLOUDSQL_INSTANCE_CONNECTION_NAME=`cat ${CURR_DIR}/.config/.CLOUDSQL_INSTANCE_CONNECTION_NAME`;
DB_HOST=`cat ${CURR_DIR}/.config/.DB_HOST`;
DB_NAME=`cat ${CURR_DIR}/.config/.DB_NAME`;
DB_USERNAME_BASE64=`cat ${CURR_DIR}/.config/.DB_USERNAME | base64`;
DB_PASSWORD_BASE64=`cat ${CURR_DIR}/.config/.DB_PASSWORD | base64`;
DOMAIN=`cat ${CURR_DIR}/.config/.DOMAIN`;
DOMAIN_ESCAPED="$(printf -- "${DOMAIN}" | sed -e "s|[^a-z0-9]|\-|g")";
if [ ${FLAG_IS_NFS_ENABLED} -eq 1 ]; then
  NFS_SERVER=`cat ${CURR_DIR}/.config/.NFS_SERVER`;
else
  GCE_PERSISTENT_DISK_NAME=`cat ${CURR_DIR}/.config/.GCE_PERSISTENT_DISK_NAME`;
fi;
GCE_PERSISTENT_DISK_SIZE=`cat ${CURR_DIR}/.config/.GCE_PERSISTENT_DISK_SIZE`;
GHOST_PRODUCTION_CONFIG_JSON=`cat ${CURR_DIR}/.config/.GHOST_PRODUCTION_CONFIG.json`;
GHOST_PRODUCTION_CONFIG='';
for LINE in ${GHOST_PRODUCTION_CONFIG_JSON}; do
  GHOST_PRODUCTION_CONFIG="${GHOST_PRODUCTION_CONFIG}${LINE}";
done;
SUBDOMAIN=`cat ${CURR_DIR}/.config/.SUBDOMAIN | sed -e "s|[^a-z0-9\.]|\-|g"`;
SUBDOMAIN_ESCAPED="$(printf -- "${SUBDOMAIN}" | sed -e "s|[^a-z0-9]|\-|g")";
CURRENT_TIMESTAMP=`date +'%Y%m%d-%H%M%S'`;
PATH_TO_DEPLOYMENT="${CURR_DIR}/.deployments/${CURRENT_TIMESTAMP}/";
mkdir -p "${PATH_TO_DEPLOYMENT}";

cat ${CURR_DIR}/config-map.yaml \
  | egrep "^[^\#]" \
  | sed -e "s|\${DB_HOST}|${DB_HOST}|g" \
  | sed -e "s|\${DB_NAME}|${DB_NAME}|g" \
  >> ${PATH_TO_DEPLOYMENT}/config-map.yaml;
cat ${CURR_DIR}/config-map.ghost-config.yaml \
  | egrep "^[^\#]" \
  | sed -e "s|\${GHOST_PRODUCTION_CONFIG}|${GHOST_PRODUCTION_CONFIG}|g" \
  >> ${PATH_TO_DEPLOYMENT}/config-map.ghost-config.yaml;
cat ${CURR_DIR}/deployment.yaml \
  | egrep "^[^\#]" \
  | sed -e "s|\${CLOUDSQL_INSTANCE_CONNECTION_NAME}|${CLOUDSQL_INSTANCE_CONNECTION_NAME}|g" \
  >> ${PATH_TO_DEPLOYMENT}/deployment.yaml;
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
cat ${CURR_DIR}/secret.db.yaml \
  | egrep "^[^\#]" \
  | sed -e "s|\${DB_USERNAME_BASE64}|${DB_USERNAME_BASE64}|g" \
  | sed -e "s|\${DB_PASSWORD_BASE64}|${DB_PASSWORD_BASE64}|g" \
  >> ${PATH_TO_DEPLOYMENT}/secret.db.yaml;
if [ ${FLAG_IS_NFS_ENABLED} -eq 1 ]; then
  cat ${CURR_DIR}/persistent-volume.nfs.yaml \
    | egrep "^[^\#]" \
    | sed -e "s|\${NFS_SERVER}|${NFS_SERVER}|g" \
    | sed -e "s|\${GCE_PERSISTENT_DISK_SIZE}|${GCE_PERSISTENT_DISK_SIZE}|g" \
    >> ${PATH_TO_DEPLOYMENT}/persistent-volume.nfs.yaml;
  cat ${CURR_DIR}/persistent-volume-claim.nfs.yaml \
    | egrep "^[^\#]" \
    | sed -e "s|\${GCE_PERSISTENT_DISK_SIZE}|${GCE_PERSISTENT_DISK_SIZE}|g" \
    >> ${PATH_TO_DEPLOYMENT}/persistent-volume-claim.nfs.yaml;
else
  cat ${CURR_DIR}/persistent-volume.yaml \
    | egrep "^[^\#]" \
    | sed -e "s|\${GCE_PERSISTENT_DISK_NAME}|${GCE_PERSISTENT_DISK_NAME}|g" \
    | sed -e "s|\${GCE_PERSISTENT_DISK_SIZE}|${GCE_PERSISTENT_DISK_SIZE}|g" \
    >> ${PATH_TO_DEPLOYMENT}/persistent-volume.yaml;
  cat ${CURR_DIR}/persistent-volume-claim.yaml \
    | egrep "^[^\#]" \
    | sed -e "s|\${GCE_PERSISTENT_DISK_SIZE}|${GCE_PERSISTENT_DISK_SIZE}|g" \
    >> ${PATH_TO_DEPLOYMENT}/persistent-volume-claim.yaml;
fi;
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