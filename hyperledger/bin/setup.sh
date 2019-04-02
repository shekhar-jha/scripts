#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )/";

source ${SCRIPT_DIR}/setEnv.sh

if [[ "${HYPERLEDGER_BASE}" == "" ]] ;
then
    echo "Please set 'HYPERLEDGER_BASE' to base directly of first-samples that contains binaries";
    exit 1;
fi

if [[ (! -f ${HYPERLEDGER_BASE}/bin/cryptogen) ||  (! -f ${HYPERLEDGER_BASE}/bin/configtxgen) ]];
then
   echo "HYPERLEDGER_BASE '${HYPERLEDGER_BASE}' does not contain either cryptogen or configtxgen in bin directory";
   exit 2;
fi

echo "Generating keys and certificates..."
CRYPTO_CONFIG_FILE=${HYPERLEDGER_HOME}/config/crypto-config.yaml

if [[ ! -f ${CRYPTO_CONFIG_FILE} ]];
then
   echo "Please provide configuration file as '${CRYPTO_CONFIG_FILE}'";
   exit 3;
fi
rm -rf "${HYPERLEDGER_HOME}/data/crypto-config"

${HYPERLEDGER_BASE}/bin/cryptogen generate --config=${CRYPTO_CONFIG_FILE} --output="${HYPERLEDGER_HOME}/data/crypto-config"

echo "Generated !!"
echo ""
echo "Generating Genesis block....."
rm -rf "${HYPERLEDGER_HOME}/data/channel-def" ; mkdir "${HYPERLEDGER_HOME}/data/channel-def"
ln -sf "${HYPERLEDGER_HOME}/data/crypto-config" "${HYPERLEDGER_HOME}/config/crypto-config"
cp ${HYPERLEDGER_HOME}/config/configtx-genesis.yaml ${HYPERLEDGER_HOME}/config/configtx.yaml
${HYPERLEDGER_BASE}/bin/configtxgen -profile Genesis --configPath="${HYPERLEDGER_HOME}/config" -outputBlock="${HYPERLEDGER_HOME}/data/channel-def/genesis.block"
GENESIS_RETURN_CODE=$?
if [ $GENESIS_RETURN_CODE -ne 0 ]
then
   echo "Genesis block generation failed with error code ${GENESIS_RETURN_CODE}"
   rm  "${HYPERLEDGER_HOME}/config/configtx.yaml"
   rm "${HYPERLEDGER_HOME}/config/crypto-config"
   exit 4;
fi
echo "Generated !!"
echo ""
echo "Creating channel ${CHANNEL_NAME}"
cp ${HYPERLEDGER_HOME}/config/configtx-channel.yaml ${HYPERLEDGER_HOME}/config/configtx.yaml
${HYPERLEDGER_BASE}/bin/configtxgen -profile Channel -configPath="${HYPERLEDGER_HOME}/config" -outputCreateChannelTx "${HYPERLEDGER_HOME}/data/channel-def/channel.tx" -channelID $CHANNEL_NAME;
CHANNEL_RETURN_CODE=$?
if [ $CHANNEL_RETURN_CODE -ne 0 ]
then
   echo "Channel block generation failed with error code ${CHANNEL_RETURN_CODE}"
   rm  "${HYPERLEDGER_HOME}/config/configtx.yaml"
   rm "${HYPERLEDGER_HOME}/config/crypto-config"
   exit 5;
fi
echo "Created !!"
echo ""
echo "Enabling anchor peer for Acme"
${HYPERLEDGER_BASE}/bin/configtxgen -profile Channel -configPath="${HYPERLEDGER_HOME}/config" -outputAnchorPeersUpdate "${HYPERLEDGER_HOME}/data/channel-def/AcmeMSPanchors.tx" -channelID $CHANNEL_NAME -asOrg AcmeMSP
RETURN_CODE=$?
if [ $RETURN_CODE -ne 0 ]
then
   echo "Anchoring peer for acme failed with error code ${RETURN_CODE}"
   rm  "${HYPERLEDGER_HOME}/config/configtx.yaml"
   rm "${HYPERLEDGER_HOME}/config/crypto-config"
   exit 6;
fi
echo "Enabled !!"
echo ""
echo "Enabling anchor peer for Contoso"
${HYPERLEDGER_BASE}/bin/configtxgen -profile Channel -configPath="${HYPERLEDGER_HOME}/config" -outputAnchorPeersUpdate "${HYPERLEDGER_HOME}/data/channel-def/ContosoMSPanchors.tx" -channelID $CHANNEL_NAME -asOrg ContosoMSP
RETURN_CODE=$?
if [ $RETURN_CODE -ne 0 ]
then 
   echo "Anchoring peer for contoso failed with error code ${RETURN_CODE}"
   rm  "${HYPERLEDGER_HOME}/config/configtx.yaml"
   rm "${HYPERLEDGER_HOME}/config/crypto-config"
   exit 7;
fi
echo "Enabled !!"

rm  "${HYPERLEDGER_HOME}/config/configtx.yaml"
unlink  ${HYPERLEDGER_HOME}/config/crypto-config
