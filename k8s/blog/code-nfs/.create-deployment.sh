#!/bin/sh
CURR_DIR="$(dirname $0)";
GCE_PERSISTENT_DISK_NAME=`cat ${CURR_DIR}/.config/.GCE_PERSISTENT_DISK_NAME`;
GCE_PERSISTENT_DISK_SIZE=`cat ${CURR_DIR}/.config/.GCE_PERSISTENT_DISK_SIZE`;

CURRENT_TIMESTAMP=`date +'%Y%m%d-%H%M%S'`;
PATH_TO_DEPLOYMENT="${CURR_DIR}/.deployments/${CURRENT_TIMESTAMP}/";
mkdir -p "${PATH_TO_DEPLOYMENT}";

cat ${CURR_DIR}/deployment.yaml \
  | egrep "^[^\#]" \
  >> ${PATH_TO_DEPLOYMENT}/deployment.yaml;
cat ${CURR_DIR}/persistent-volume.yaml \
  | egrep "^[^\#]" \
  | sed -e "s|\${GCE_PERSISTENT_DISK_NAME}|${GCE_PERSISTENT_DISK_NAME}|g" \
  | sed -e "s|\${GCE_PERSISTENT_DISK_SIZE}|${GCE_PERSISTENT_DISK_SIZE}|g" \
  >> ${PATH_TO_DEPLOYMENT}/persistent-volume.yaml;
cat ${CURR_DIR}/persistent-volume-claim.yaml \
  | egrep "^[^\#]" \
  | sed -e "s|\${GCE_PERSISTENT_DISK_SIZE}|${GCE_PERSISTENT_DISK_SIZE}|g" \
  >> ${PATH_TO_DEPLOYMENT}/persistent-volume-claim.yaml;
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