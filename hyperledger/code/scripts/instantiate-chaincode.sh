#!/bin/bash

source ./scripts/setEnv.sh $1 $2 $3

export CHAINCODE_NAME=${4};
export CHAINCODE_VERSION=${5:-0.1}
export CHAINCODE_LANGUAGE=${6:-node}
export CHAINCODE_ARGS=${7}

if [[ "${4}" == "" ]];
then
   echo "Please specify the chaincode that needs to be instantiated. Value is typically name of directory that contains the node js files";
   exit 1;
fi
if [[ "${CHAINCODE_ARGS}" == "" ]];
then
   echo "Please provide the arguments to instantiate the chaincode.";
   exit 2;
fi

export CHAINCODE_FUNC_ARGS='{"function":"init","Args":'"${CHAINCODE_ARGS}}"
echo ${CHAINCODE_FUNC_ARGS}
peer chaincode instantiate -o ${ORDERER_ADDRESS} -C ${CHANNEL_ID} -n "${CHAINCODE_NAME}" -l "${CHAINCODE_LANGUAGE}" -v ${CHAINCODE_VERSION} -c "${CHAINCODE_FUNC_ARGS}" -P "OR ('AcmeMSP.member','ContosoMSP.member')" --tls --cafile ${ORDERER_TLS_ROOTCERT_FILE}

