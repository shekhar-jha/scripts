#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )/";

source ${SCRIPT_DIR}/setEnv.sh

export CHAINCODE=${1:-manageid}
export ORG_NAME=${2:-acme}
export PEER_NAME=${3:-peer0}

registerCode() {
    echo "Installing chain-code ${CHAINCODE} on ${1}(${2})...."
    docker exec -it cli ./scripts/register-chaincode.sh $1 $2 ${CHANNEL_NAME} ${CHAINCODE} 0.1 node
    RETURN_CODE=$?
    if [[ "${RETURN_CODE}" != "0" ]];
    then
      echo "Failed to install chain-code. Error " + ${RETURN_CODE}
      exit 1;
    fi
    echo "Installed !!";
}

registerCode "${PEER_NAME}" "${ORG_NAME}"

