import time
sleep=time.sleep
print "#####################################"
print "# Waiting for Admin Server to Start #"
print "#####################################"
while True:
   try: connect(url="t3://localhost:7101",adminServerName="AdminServer"); break
   except: sleep(60)

print "##############################"
print "# Admin Server has come up #"
print "##############################"

print "##########################"
print "# Starting SOA Server 1 #"
print "##########################"

start(name="WLS_SOA1", block="true")
print "##########################"
print "# Starting OIM Server 1 #"
print "##########################"

start(name="WLS_OIM1", block="true")

print "##################################"
print "# Starting BI Publisher Server 1 #"
print "##################################"

start(name="WLS_BIP1", block="true")

exit()
