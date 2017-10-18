#!/bin/bash

source /home/oimsvc/bin/common.sh
source $DOMAIN_HOME/bin/setDomainEnv.sh >> /dev/null

$JAVA_HOME/bin/java -Dweblogic.security.SSL.enableJSSE=true -Dweblogic.security.SSL.minimumProtocolVersion=TLSv1.2 weblogic.WLST -loadProperties ${SCRIPT_BASE_DIR}/config.properties ${SCRIPT_BASE_DIR}/oimstatus.py `hostname` |grep "^Server "

