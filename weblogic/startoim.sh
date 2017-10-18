#/opt/fmw/oud/oim/OUD/bin/start-ds
export MW_HOME=/opt/fmw/Middleware
export DOMAIN_HOME=/opt/fmw/oim/domains/oim/

cd /opt/fmw/tmp
nohup $MW_HOME/wlserver_10.3/server/bin/startNodeManager.sh &

nohup $DOMAIN_HOME/bin/startWebLogic.sh &
. $DOMAIN_HOME/bin/setDomainEnv.sh
java weblogic.WLST /opt/fmw/oim/oimstart.py
