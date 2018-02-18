#!/bin/sh
CURR_DIR="$(dirname $0)";
LOAD_BALANCER_IP=`cat ${CURR_DIR}/.config/.LOAD_BALANCER_IP`;
CURRENT_TIMESTAMP=`date +'%Y%m%d-%H%M%S'`;
PATH_TO_DEPLOYMENT="${CURR_DIR}/.deployments/${CURRENT_TIMESTAMP}/";
mkdir -p "${PATH_TO_DEPLOYMENT}";

cat ${CURR_DIR}/namespace.yaml \
  | egrep "^[^\#]" \
  >> ${PATH_TO_DEPLOYMENT}/namespace.yaml;
cat ${CURR_DIR}/config-map.yaml \
  | egrep "^[^\#]" \
  >> ${PATH_TO_DEPLOYMENT}/config-map.yaml;
cat ${CURR_DIR}/config-map.tcp.yaml \
  | egrep "^[^\#]" \
  >> ${PATH_TO_DEPLOYMENT}/config-map.tcp.yaml;
cat ${CURR_DIR}/config-map.udp.yaml \
  | egrep "^[^\#]" \
  >> ${PATH_TO_DEPLOYMENT}/config-map.udp.yaml;
cat ${CURR_DIR}/deployment.yaml \
  | egrep "^[^\#]" \
  >> ${PATH_TO_DEPLOYMENT}/deployment.yaml;
cat ${CURR_DIR}/service.yaml \
  | egrep "^[^\#]" \
  | sed -e "s|\${LOAD_BALANCER_IP}|${LOAD_BALANCER_IP}|g" \
  >> ${PATH_TO_DEPLOYMENT}/service.yaml;

stat "${PATH_TO_DEPLOYMENT}/warnings.info" &>/dev/null;
if [ "$?" = "0" ]; then
  printf -- "\e[31mWARNINGS WERE FOUND:\e[0m\n";
  cat "${PATH_TO_DEPLOYMENT}/warnings.info";
  exit 1;
fi;

printf -- "\nDeployment saved to:\n  ${PATH_TO_DEPLOYMENT}\n";
exit 0;