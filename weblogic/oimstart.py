import time
sleep=time.sleep

oimEnvironmentIdentifier=eval(sys.argv[1])
oimDomainName=eval(oimEnvironmentIdentifier + "_DOMAIN_NAME")
machineHost=eval(oimEnvironmentIdentifier + "_MACHINE_HOST_NAME")
adminHost=eval(oimEnvironmentIdentifier + "_ADMIN_SERVER")
localServers=eval(oimEnvironmentIdentifier + "_SERVERS_START").split(",")

print "#####################################"
print "# Waiting for Admin Server to Start #"
print "#####################################"
while True:
   try: connect(url="t3://" + adminHost + ":7001",adminServerName="AdminServer"); break
   except: sleep(60)

print "##############################"
print "# Admin Server has come up #"
print "##############################"

for serverName in localServers:
    try:
        print "##########################"
        print "# Starting " + serverName  +"  #"
        print "##########################"
        start(name=serverName, block="true")
    except:
        print "Server " + serverName +" startup failed"

exit()
