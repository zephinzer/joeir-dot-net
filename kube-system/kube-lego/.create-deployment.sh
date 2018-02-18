#!/bin/sh
CURR_DIR="$(dirname $0)";
KUBE_LEGO_EMAIL=`cat ${CURR_DIR}/.config/.KUBE_LEGO_EMAIL`;
CURRENT_TIMESTAMP=`date +'%Y%m%d-%H%M%S'`;
PATH_TO_DEPLOYMENT="${CURR_DIR}/.deployments/${CURRENT_TIMESTAMP}/";
mkdir -p "${PATH_TO_DEPLOYMENT}";

cat ${CURR_DIR}/config-map.yaml \
  | egrep "^[^\#]" \
  | sed -e "s|\${KUBE_LEGO_EMAIL}|${KUBE_LEGO_EMAIL}|g" \
  >> ${PATH_TO_DEPLOYMENT}/config-map.yaml;
cat ${CURR_DIR}/deployment.yaml \
  | egrep "^[^\#]" \
  >> ${PATH_TO_DEPLOYMENT}/deployment.yaml;

stat "${PATH_TO_DEPLOYMENT}/warnings.info" &>/dev/null;
if [ "$?" = "0" ]; then
  printf -- "\e[31mWARNINGS WERE FOUND:\e[0m\n";
  cat "${PATH_TO_DEPLOYMENT}/warnings.info";
  exit 1;
fi;

printf -- "\nDeployment saved to:\n  ${PATH_TO_DEPLOYMENT}\n";
exit 0;