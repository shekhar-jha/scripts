export PEER_ID=${PEER_ID:-$1}
export ORG_ID=${ORG_ID:-$2}
export CHANNEL_ID=${CHANNEL_ID:-$3}

if [[ "${PEER_ID}" == "" ]];
then
   echo "Please specify the peer that needs to be registered. Value is typically peer0, peer1, etc.";
   exit 1;
fi
if [[ "${ORG_ID}" == "" ]];
then
   echo "Please specify the organization for which peer needs to be registered. Value is typically acme, contoso, etc.";
   exit 2;
fi

if [[ "${CHANNEL_ID}" == "" ]];
then
   echo "Please specify the channel to which peer should register to";
   exit 3;
fi
export ORDERER_ADDRESS=orderer.example.com:7050
export ORDERER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
export CORE_PEER_ADDRESS=${PEER_ID}.${ORG_ID}.example.com:7051
export CORE_PEER_LOCALMSPID=${ORG_ID^}MSP
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/${ORG_ID}.example.com/peers/${PEER_ID}.${ORG_ID}.example.com/tls/server.crt
export CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/${ORG_ID}.example.com/peers/${PEER_ID}.${ORG_ID}.example.com/tls/server.key
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/${ORG_ID}.example.com/peers/${PEER_ID}.${ORG_ID}.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/${ORG_ID}.example.com/users/Admin@${ORG_ID}.example.com/msp

