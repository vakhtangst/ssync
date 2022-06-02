#/bin/bash

set -e

SCRIPT_PATH=$(dirname "$0")

. "${SCRIPT_PATH}"/../.ssync/ssync.conf

if [ ! -f ${LOCAL_PATH}/${TIME_STATE_FILE} ]
then
    mkdir -p `dirname ${LOCAL_PATH}/${TIME_STATE_FILE}`
    echo 0 > ${LOCAL_PATH}/${TIME_STATE_FILE}
fi

if [ ! -f ${LOCAL_PATH}/${SYNC_STATE_FILE} ]
then
    mkdir -p `dirname ${LOCAL_PATH}/${SYNC_STATE_FILE}`
    touch ${LOCAL_PATH}/${SYNC_STATE_FILE}
fi

if [ ! -f ${LOCAL_PATH}/${EXCLUDE} ]
then
    mkdir -p `dirname ${LOCAL_PATH}/${TIME_STATE_FILE}`
    touch ${LOCAL_PATH}/${EXCLUDE}
fi

if [ -z "${LOG_FILE}" ]
then
    echo "Variable for log file is empty"
    exit 0
fi

echo "------------------------ Start ------------------------" >> ${LOG_FILE}

local_state_version=`cat ${LOCAL_PATH}/${TIME_STATE_FILE}`

rm -f ${LOCAL_PATH}/${SYNC_STATE_FILE}
rsync -e "ssh -p ${SSH_PORT}" --log-file=${LOG_FILE} ${SERVER_PATH}/.ssync/*.state ${LOCAL_PATH}/.ssync/ >/dev/null 2>&1

if [[ -f "${LOCAL_PATH}/${SYNC_STATE_FILE}" && `cat ${LOCAL_PATH}/${SYNC_STATE_FILE}` != "done" ]]
then
    echo "Synced not comlited"
    exit 0
fi

echo "progress" > ${LOCAL_PATH}/${SYNC_STATE_FILE}

if [ ! -f ${LOCAL_PATH}/${TIME_STATE_FILE} ] || (( `cat ${LOCAL_PATH}/${TIME_STATE_FILE}` <= $local_state_version ))
then
    echo "LOCAL =========> SERVER" | tee -a ${LOG_FILE}
    echo $(date +%s) > ${LOCAL_PATH}/${TIME_STATE_FILE}    
    rsync -e "ssh -p ${SSH_PORT}" -au --relative --delete --log-file=${LOG_FILE} ${LOCAL_PATH}/./${SYNC_STATE_FILE} ${SERVER_PATH}/

    rsync -e "ssh -p ${SSH_PORT}" -au --delete --exclude-from=${LOCAL_PATH}/${EXCLUDE} --log-file=${LOG_FILE} ${LOCAL_PATH}/ ${SERVER_PATH}
    
    echo "done" > ${LOCAL_PATH}/${SYNC_STATE_FILE}
    rsync -e "ssh -p ${SSH_PORT}" -au --relative --delete --log-file=${LOG_FILE} ${LOCAL_PATH}/./${SYNC_STATE_FILE} ${SERVER_PATH}/
else
    echo "SERVER =========> LOCAL" | tee -a ${LOG_FILE}
    rsync -e "ssh -p ${SSH_PORT}" -au --delete --exclude-from=${LOCAL_PATH}/${EXCLUDE} --log-file=${LOG_FILE} ${SERVER_PATH}/ ${LOCAL_PATH}
fi

echo "------------------------  END  ------------------------" >> ${LOG_FILE}
