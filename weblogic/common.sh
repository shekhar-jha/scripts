export MW_HOME=/opt/oracle/middleware
export SCRIPT_BASE_DIR=/home/oimsvc/bin
export JAVA_HOME=/opt/oracle/java/java7

function prop {
    grep "^${1}" ${SCRIPT_BASE_DIR}/config.properties|cut -d'=' -f2
}

OIM_MACHINE_HOST=`hostname`
SERVER_ID=$(prop "${OIM_MACHINE_HOST}")
IS_ADMIN_SERVER=$(prop "${SERVER_ID}_ISADMIN")
DOMAIN_NAME=$(prop "${SERVER_ID}_DOMAIN_NAME")
export DOMAIN_HOME="/apps/oracle/oimps3/domains/${DOMAIN_NAME}"
export SCRIPT_TEMP_DIR=$(prop "${SERVER_ID}_TEMP_DIR")
