#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )/";

source ${SCRIPT_DIR}/setEnv.sh

export CHAINCODE=${1:-manageid}

let ARGS_FROM=0;
let TOTAL_ARGS=$#
CHAINCODE_FUNC=$( getValue 2 "${2}" "invoke" $TOTAL_ARGS $ARGS_FROM)
ARGS_FROM=$?
ORG_NAME=$(getValue 3 "${3}" "acme" $TOTAL_ARGS $ARGS_FROM)
ARGS_FROM=$?
PEER_NAME=$(getValue 4 "${4}" "peer0" $TOTAL_ARGS $ARGS_FROM)
ARGS_FROM=$?
if [[ $ARGS_FROM == 0 ]];
then
   ARGS_FROM=6;
fi

if [[ $# -ge ${ARGS_FROM} ]];
then
   CHAINCODE_ARGS='[';
   COUNTER=${ARGS_FROM};
   while [[ $COUNTER -le $# ]];
   do
      CURRENT_VALUE=${!COUNTER};
      if [[ -f ${CURRENT_VALUE} ]];
      then
         CURRENT_VALUE=$(cat ${CURRENT_VALUE} |tr -d '\n');
      fi
      CHAINCODE_ARGS="${CHAINCODE_ARGS}"'"'${CURRENT_VALUE}'"'
      COUNTER=$((COUNTER + 1));
      if [[ $COUNTER -le $# ]];
      then
        CHAINCODE_ARGS="${CHAINCODE_ARGS},";
      fi
   done
   CHAINCODE_ARGS="${CHAINCODE_ARGS}]";
else
  export CHAINCODE_ARGS='[]'
fi

#echo "ARGS: ${CHAINCODE_ARGS}"

invokeCode() {
    echo "Invoking chain-code ${CHAINCODE}...."
    docker exec -it cli ./scripts/invoke-chaincode.sh $1 $2 ${CHANNEL_NAME} ${CHAINCODE} "${CHAINCODE_FUNC}" "${CHAINCODE_ARGS}"
    RETURN_CODE=$?
    if [[ "${RETURN_CODE}" != "0" ]];
    then
      echo "Failed to invoke chain-code. Error " + ${RETURN_CODE}
      exit 1;
    fi
    echo "Invoked !!";
}

invokeCode "${PEER_NAME}" "${ORG_NAME}"

