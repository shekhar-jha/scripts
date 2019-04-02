#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )/";

source ${SCRIPT_DIR}/setEnv.sh

docker-compose -f ${HYPERLEDGER_HOME}/config/docker-acme.yaml stop 

