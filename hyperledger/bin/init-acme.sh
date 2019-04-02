#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )/";

source ${SCRIPT_DIR}/setEnv.sh

echo "Starting the server in ACME ..."

docker-compose -f ${HYPERLEDGER_HOME}/config/docker-acme.yaml up >"${HYPERLEDGER_HOME}/logs/acme.logs" 2>&1 &
RETURN_CODE=$?
if [ $RETURN_CODE -ne 0 ]
then 
   echo "Starting docker setup for Acme failed with error code ${RETURN_CODE}"
   exit 1;
fi

sleep 10
echo "Creating Channel ${CHANNEL_NAME} ....."
docker exec -it cli peer channel create -o orderer.example.com:7050 -c ${CHANNEL_NAME} -f ./channel-artifacts/channel.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
RETURN_CODE=$?
if [ $RETURN_CODE -ne 0 ]
then 
   echo "Channel creation failed with error code ${RETURN_CODE}"
   exit 2;
fi
echo "Created !!"
echo ""
echo "Registering Peer0 to channel..."
docker exec -it cli ./scripts/register-peer.sh peer0 acme ${CHANNEL_NAME}
echo "Registered !!"
echo ""
echo "Registering Peer1 to channel..."
docker exec -it cli ./scripts/register-peer.sh peer1 acme ${CHANNEL_NAME}
echo "Registered !!"
echo ""
echo "Enabling Peer0 as anchor peer in channel for acme..."
docker exec -it cli ./scripts/register-anchor.sh peer0 acme ${CHANNEL_NAME}
echo "Enabled"
