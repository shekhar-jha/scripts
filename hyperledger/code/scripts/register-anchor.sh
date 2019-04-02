#!/bin/bash

source ./scripts/setEnv.sh $1 $2 $3

peer channel update -o ${ORDERER_ADDRESS} -c ${CHANNEL_ID} -f ./channel-artifacts/${ORG_ID^}MSPanchors.tx --tls --cafile ${ORDERER_TLS_ROOTCERT_FILE}

