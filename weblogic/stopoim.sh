#!/bin/bash

source /home/oimsvc/bin/common.sh
source $DOMAIN_HOME/bin/setDomainEnv.sh >> /dev/null

$JAVA_HOME/bin/java -Dweblogic.security.SSL.enableJSSE=true -Dweblogic.security.SSL.minimumProtocolVersion=TLSv1.2 weblogic.WLST -loadProperties ${SCRIPT_BASE_DIR}/config.properties ${SCRIPT_BASE_DIR}/oimstop.py `hostname`

if [ "${IS_ADMIN_SERVER}" == "TRUE" ];
then
    echo "###################################"
    echo "#### Stopping Admin Server    #####"
    echo "###################################"
    $DOMAIN_HOME/bin/stopWebLogic.sh
fi
