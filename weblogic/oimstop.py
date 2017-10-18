oimEnvironmentIdentifier=eval(sys.argv[1])
oimDomainName=eval(oimEnvironmentIdentifier + "_DOMAIN_NAME")
machineHost=eval(oimEnvironmentIdentifier + "_MACHINE_HOST_NAME")
adminHost=eval(oimEnvironmentIdentifier + "_ADMIN_SERVER")
localServers=eval(oimEnvironmentIdentifier + "_SERVERS_STOP").split(",")

try:
    connect(url="t3://" + adminHost + ":7001",adminServerName="AdminServer")
    domainRuntime()
    for localServerName in localServers:
        print "################################################"
        print "####    Stopping server " + localServerName + "        ####"
        print "################################################"
        cd("/ServerLifeCycleRuntimes/" + localServerName)
        try: shutdown(localServerName, force='true', block='true'); print("Server " +localServerName +" stopped")
        except:
            print "Server " + localServerName + " already stopped or it could not be stopped"
    disconnect()
except:
    print "Stopping server using node manager"
    try:
        nmConnect(userConfigFile='/apps/oracle/oimps3/domains/' + oimDomainName  + '/userConfigFile', userKeyFile='/apps/oracle/oimps3/domains/' + oimDomainName + '/userKeyFile', host=machineHost, port='7003', domainName=oimDomainName, domainDir='/apps/oracle/oimps3/domains/' + oimDomainName, nmType='SSL')
        for localServerName in localServers:
            print "################################################"
            print "####    Stopping server " + localServerName + "        ####"
            print "################################################"
            try:
                nmKill(localServerName)
                print("Server " +localServerName +" stopped")
            except:
                print "Server " + localServerName + " already stopped or it could not be stopped"
        nmDisconnect()
    except:
        print("Failed to connect to node manager")

