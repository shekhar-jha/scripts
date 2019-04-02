#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )/";

source ${SCRIPT_DIR}/setEnv.sh

export CHAINCODE=${1:-manageid}
export ORG_NAME=${2:-acme}
export PEER_NAME=${3:-peer0}

ARGS_FROM=3
if [[ $# -gt $ARGS_FROM ]];
then
   CHAINCODE_ARGS='[';
   COUNTER=$(($ARGS_FROM + 1));
   while [[ $COUNTER -le $# ]];
   do
      CURRENT_VALUE=$COUNTER;
      CHAINCODE_ARGS="${CHAINCODE_ARGS}"'"'${!CURRENT_VALUE}'"'
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

echo "${CHAINCODE_ARGS}"

registerCode() {
    echo "Instantiating chain-code ${CHAINCODE}...."
    docker exec -it cli ./scripts/instantiate-chaincode.sh $1 $2 ${CHANNEL_NAME} ${CHAINCODE} 0.1 node "${CHAINCODE_ARGS}"
    RETURN_CODE=$?
    if [[ "${RETURN_CODE}" != "0" ]];
    then
      echo "Failed to instantiate chain-code. Error " + ${RETURN_CODE}
      exit 1;
    fi
    echo "Instantiated !!";
}

registerCode "${PEER_NAME}" "${ORG_NAME}"

