#!/bin/bash

source ./scripts/setEnv.sh $1 $2 $3

export CHAINCODE_NAME=${4};
export CHAINCODE_FUNC=${5};
export CHAINCODE_ARGS=${6}

if [[ "${4}" == "" ]];
then
   echo "Please specify the chaincode that needs to be registered. Value is typically name of directory that contains the node js files";
   exit 1;
fi
export CHAINCODE_BASE="/opt/gopath/src/github.com/hyperledger/fabric/peer/code";

if [[ ! -d "${CHAINCODE_BASE}/${CHAINCODE_NAME}" ]];
then
   echo "Please ensure that base directory for chaincode ${CHAINCODE_BASE}/${CHAINCODE_NAME} is valid";
   exit 2;
fi

export CHAINCODE_FUNC_ARGS='{"function":"'"${CHAINCODE_FUNC}"'","Args":'"${CHAINCODE_ARGS}}"
echo $CHAINCODE_FUNC_ARGS
peer chaincode invoke -o ${ORDERER_ADDRESS} -C ${CHANNEL_ID} -n "${CHAINCODE_NAME}" -c "${CHAINCODE_FUNC_ARGS}" --tls --cafile ${ORDERER_TLS_ROOTCERT_FILE}

