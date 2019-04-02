#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )/";

source ${SCRIPT_DIR}/setEnv.sh

echo "Starting the servers on Contoso..."
docker-compose -f ${HYPERLEDGER_HOME}/config/docker-contoso.yaml up >"${HYPERLEDGER_HOME}/logs/contoso.logs" 2>&1 &

sleep 10
echo "Fetching Channel details to register peers....."
docker exec -it cli peer channel fetch 0 ${CHANNEL_NAME}.block -o orderer.example.com:7050 -c ${CHANNEL_NAME} --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
echo "Fetched !!"
echo ""
echo "Registering Peer0 to channel"
docker exec -it cli  ./scripts/register-peer.sh peer0 contoso ${CHANNEL_NAME}
echo "Registered !!"
echo ""
echo "Registering Peer1 to channel"
docker exec -it cli  ./scripts/register-peer.sh peer1 contoso ${CHANNEL_NAME}
echo "Registered !!"
echo ""
echo "Enabling Peer0 as anchor peer on channel for contoso..."
docker exec -it cli ./scripts/register-anchor.sh peer0 contoso ${CHANNEL_NAME}
echo "Enabled"

