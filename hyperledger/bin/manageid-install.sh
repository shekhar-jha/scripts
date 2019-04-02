#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )/";

source ${SCRIPT_DIR}/setEnv.sh

echo "Installing manageid...."
${SCRIPT_DIR}/install-code.sh manageid acme peer0
${SCRIPT_DIR}/install-code.sh manageid contoso peer1

ORG_NAME=acme
PEER_NAME=peer0
echo "-----------------------------------------------------------"
ACME_ORG_DID=$(cat /proc/sys/kernel/random/uuid);
echo "Acme DID             : ${ACME_ORG_DID}"
ACME_ADMIN_DID=$(cat /proc/sys/kernel/random/uuid);
echo "Acme Admin DID       : ${ACME_ADMIN_DID}"

CONTOSO_ORG_DID=$(cat /proc/sys/kernel/random/uuid);
echo "CONTOSO DID          : ${CONTOSO_ORG_DID}"
CONTOSO_ADMIN_DID=$(cat /proc/sys/kernel/random/uuid);
echo "Contoso Admin DID    : ${CONTOSO_ADMIN_DID}"
echo "-----------------------------------------------------------"
echo "Instantiating...."
${SCRIPT_DIR}/instantiate-code.sh manageid ${ORG_NAME} ${PEER_NAME} "${ACME_ORG_DID}" "$(${SCRIPT_DIR}/cert.sh acme ca)" "Steward" "00000000-0000-0000-0000-000000000000" "${ACME_ADMIN_DID}" "$(${SCRIPT_DIR}/cert.sh acme user Admin)" "OnBehalfOf" "${ACME_ORG_DID}"
sleep 10

echo "Registering entities...."
${SCRIPT_DIR}/invoke-code.sh manageid registerEntity ${ORG_NAME} ${PEER_NAME} - "$(cat /proc/sys/kernel/random/uuid)" "$(${SCRIPT_DIR}/cert.sh acme peer peer0)" "OnBehalfOf" "${ACME_ADMIN_DID}"
${SCRIPT_DIR}/invoke-code.sh manageid registerEntity ${ORG_NAME} ${PEER_NAME} - "$(cat /proc/sys/kernel/random/uuid)" "$(${SCRIPT_DIR}/cert.sh acme peer peer1)" "OnBehalfOf" "${ACME_ADMIN_DID}"
${SCRIPT_DIR}/invoke-code.sh manageid registerEntity ${ORG_NAME} ${PEER_NAME} - "${CONTOSO_ORG_DID}" "$(${SCRIPT_DIR}/cert.sh contoso ca)" "Trust Agent" "${ACME_ADMIN_DID}"
${SCRIPT_DIR}/invoke-code.sh manageid registerEntity ${ORG_NAME} ${PEER_NAME} - "${CONTOSO_ADMIN_DID}" "$(${SCRIPT_DIR}/cert.sh contoso user Admin)" "OnBehalfOf" "${ACME_ADMIN_DID}"
sleep 5
${SCRIPT_DIR}/invoke-code.sh manageid registerEntity contoso peer1 - "$(cat /proc/sys/kernel/random/uuid)" "$(${SCRIPT_DIR}/cert.sh contoso peer peer0)" "OnBehalfOf" "${CONTOSO_ADMIN_DID}"
${SCRIPT_DIR}/invoke-code.sh manageid registerEntity contoso peer1 - "$(cat /proc/sys/kernel/random/uuid)" "$(${SCRIPT_DIR}/cert.sh contoso peer peer1)" "OnBehalfOf" "${CONTOSO_ADMIN_DID}"
