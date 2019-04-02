#!/bin/bash

source ./scripts/setEnv.sh $1 $2 $3

export CHAINCODE_NAME=${4};
export CHAINCODE_VERSION=${5:-0.1}
export CHAINCODE_LANGUAGE=${6:-node}
export CHAINCODE_ARGS=${7}

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

peer chaincode install -n "${CHAINCODE_NAME}"  -v ${CHAINCODE_VERSION} -p "${CHAINCODE_BASE}/${CHAINCODE_NAME}" -l "${CHAINCODE_LANGUAGE}"

