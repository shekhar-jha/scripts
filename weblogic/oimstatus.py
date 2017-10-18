oimEnvironmentIdentifier=eval(sys.argv[1])
oimDomainName=eval(oimEnvironmentIdentifier + "_DOMAIN_NAME")
machineHost=eval(oimEnvironmentIdentifier + "_MACHINE_HOST_NAME")
adminHost=eval(oimEnvironmentIdentifier + "_ADMIN_SERVER")
localServers=eval(oimEnvironmentIdentifier + "_SERVERS").split(",")

def printServerDetails(serverName, serverStatus):
    if serverStatus == "RUNNING":
        print "Server " + serverName +" : \033[1;32m" + serverStatus + "\033[0m"
    elif serverStatus == "STARTING":
        print "Server " + serverName +" : \033[1;33m" + serverStatus + "\033[0m"
    elif serverStatus == "UNKNOWN":
        print "Server " + serverName +" : \033[1;34m" + serverStatus + "\033[0m"
    else:
        print "Server " + serverName +" : \033[1;31m" + serverStatus + "\033[0m"

try:
    connect(url="t3://" + adminHost + ":7001",adminServerName="AdminServer")
    serverNames = cmo.getServers();
    domainRuntime()
    for name in serverNames:
        cd("/ServerLifeCycleRuntimes/" + name.getName())
        serverState = cmo.getState()
        printServerDetails(name.getName(), serverState)
    disconnect()
    exit()
except :
    try:
        nmConnect(userConfigFile='/apps/oracle/oimps3/domains/' + oimDomainName + '/userConfigFile', userKeyFile='/apps/oracle/oimps3/domains/' + oimDomainName + '/userKeyFile', host=machineHost, port='7003', domainName=oimDomainName, domainDir='/apps/oracle/oimps3/domains/' + oimDomainName, nmType='SSL')
        for name in localServers:
            try:
                serverState=nmServerStatus(name)
                printServerDetails(name, serverState)
            except:
                printServerDetails(name, "UNKNOWN")
        exit()
    except :
        printServerDetails("NodeManager", "UNKNOWN")
        printServerDetails("AdminServer", "UNKNOWN")
        exit()
