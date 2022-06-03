#/bin/bash

set -e

SCRIPT_PATH=$(dirname "$0")

. "${SCRIPT_PATH}"/../.ssync/ssync.conf

if [ ! -f ${LOCAL_PATH}/${VERSION} ]
then
    mkdir -p `dirname ${LOCAL_PATH}/${VERSION}`
    echo 0 > ${LOCAL_PATH}/${VERSION}
fi


if [ ! -f ${LOCAL_PATH}/${EXCLUDE} ]
then
    mkdir -p `dirname ${LOCAL_PATH}/${VERSION}`
    touch ${LOCAL_PATH}/${EXCLUDE}
fi

if [ -z "${LOG_FILE}" ]
then
    echo "Variable for log file is empty"
    exit 0
fi

echo "------------------------ Start ------------------------" >> ${LOG_FILE}

local_state_version=`cat ${LOCAL_PATH}/${VERSION}`
rm -f /tmp/ssync_version.state
rsync -e "ssh -p ${SSH_PORT}" --log-file=${LOG_FILE} ${SERVER_PATH}/${VERSION} /tmp/ssync_version.state >/dev/null 2>&1
if [ ! -f /tmp/ssync_version.state ]
then
    server_state_version=0
else
    server_state_version=`cat /tmp/ssync_version.state`
fi

if (( $local_state_version >= $server_state_version ))
then
    echo "LOCAL =========> SERVER" | tee -a ${LOG_FILE}
    echo $(date +%s) > ${LOCAL_PATH}/${VERSION}
    rsync -e "ssh -p ${SSH_PORT}" -au --delete --exclude-from=${LOCAL_PATH}/${EXCLUDE} --log-file=${LOG_FILE} ${LOCAL_PATH}/ ${SERVER_PATH}
else
    echo "SERVER =========> LOCAL" | tee -a ${LOG_FILE}
    echo ${server_state_version} > ${LOCAL_PATH}/${VERSION}
    rsync -e "ssh -p ${SSH_PORT}" -au --delete --exclude-from=${LOCAL_PATH}/${EXCLUDE} --log-file=${LOG_FILE} ${SERVER_PATH}/ ${LOCAL_PATH}
fi
echo "------------------------  END  ------------------------" >> ${LOG_FILE}
