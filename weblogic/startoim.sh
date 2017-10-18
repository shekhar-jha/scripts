#!/bin/bash

source /home/oimsvc/bin/common.sh
cd ${SCRIPT_TEMP_DIR}

echo "###################################"
echo "#### Starting Node Manager    #####"
echo "###################################"
nohup $MW_HOME/wlserver_10.3/server/bin/startNodeManager.sh >node.log &

source $DOMAIN_HOME/bin/setDomainEnv.sh >> /dev/null

if [ "${IS_ADMIN_SERVER}" == "TRUE" ];
then
    echo "###################################"
    echo "#### Starting Admin Server    #####"
    echo "###################################"
    nohup $DOMAIN_HOME/bin/startWebLogic.sh > ${DOMAIN_HOME}/servers/AdminServer/logs/AdminServer.out &
    $JAVA_HOME/bin/java -Dweblogic.security.SSL.enableJSSE=true -Dweblogic.security.SSL.minimumProtocolVersion=TLSv1.2 weblogic.WLST  -loadProperties ${SCRIPT_BASE_DIR}/config.properties ${SCRIPT_BASE_DIR}/oimstart.py `hostname`
else
    $JAVA_HOME/bin/java -Dweblogic.security.SSL.enableJSSE=true -Dweblogic.security.SSL.minimumProtocolVersion=TLSv1.2 weblogic.WLST  -loadProperties ${SCRIPT_BASE_DIR}/config.properties ${SCRIPT_BASE_DIR}/oimstart-nm.py `hostname`
fi
