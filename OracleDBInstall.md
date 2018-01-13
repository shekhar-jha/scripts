Database details
----------------

1. Global Database Name & SID: OIAM
2. Server parameter file: /opt/oracle/db/product/11.2.0/dbhome_1/dbs/spfileOIAM.ora
3. TNS Listener : 1521
4. ORACLE_HOME=/opt/oracle/db/product/11.2.0/dbhome_1/
5. password: demo1234

Start/stop
----------

1. login as oracle
2. `. setuporadb.sh`
3. `dbstart $ORACLE_HOME` - to start server
4. `dbshut $ORACLE_HOME` - to stop server.

Database control URL: https://<hostname>:1158/em

Notes
------

Oracle 12.2.0.1 (12.2.0.1.171017)

1. RCU
    1. **Authentication Level** - DB 12.2 and later version support higher authentication mechanism which is not compatible with RCU's level due to which authentication fails with unsupported authentication protocol. Keeping that in mind need to add `SQLNET.ALLOWED_LOGON_VERSION_SERVER=8` and `SQLNET.ALLOWED_LOGON_VERSION_CLIENT=8` to $ORACLE_HOME//network/admin/sqlnet.ora (create an empty file if not already present) and restart the DB. Also, reset the password for sys & system using `alter user system identified by <password>` to ensure that new authentication protocol is active.
     2. **MDS Schema creation failure** - DB Security in 12.2 disables some features which triggers error while creating MDS Schema. Execute `ALTER SYSTEM SET "_allow_insert_with_update_check"=TRUE scope=spfile` and restart database.


Database Installation
--------------------
In case of OEL, you can use `oracle-rdbms-server-12cR1-preinstall` or `oracle-rdbms-server-11gR2-preinstall` to ensure appropriate prerequisites are met.

1. set the following <br>
```mkdir /opt/oracle/tmp```<br>
```export TMP=/opt/oracle/tmp```<br>
```export TMPDIR=/opt/oracle/tmp```<br>
2. Start installation<br>
`cd /opt/oracle/installers/db/database/`<br>
`./runInstaller`<br>
3. Security Updates - Uncheck
4. Install database software only
5. Grid Option - Single Instance
6. Product Language - English
7. Database Edition - Enterprise
8. Installation Location - Base - `/opt/oracle/db`
9. Ora Inventory - /opt/oracle/oraInventory, Group name: oinstall
10. OSDBA group : dba; OSOPER group : oinstall
11. Ignore pre-requisite errors (ensure all packages are installed as i686 & swap space is 8GB)
12. Run the scripts
/opt/oracle/oraInventory/orainstRoot.sh
/opt/oracle/db/product/11.2.0/dbhome_1/root.sh

Network configuration
---------------------

1. logout and then login as oracle
2. ensure that ORACLE_HOME & ORACLE_SID are set and PATH contains $ORACLE_HOME/bin
3. `netca`
4. Listener Configuration
5. Add
6. LISTENER
7. TCP
8. 1521
9. Next and finish.
This will configure and start the LISTENER on 1521

Database configuration
----------------------

1. 1&2 as above
2. dbca
2. (Version 12.2) Click on Advanced Configuration
3. Create a database
4. General Purpose or Transaction Processing
5. Global Database Name : OIAM, SID: OIAM
6. (Version 12.2) Database Identification: Uncheck Container Database
6. Management:
a. Enterprise Manager : uncheck enterprise manager
b. Configure Database control for local management
c. Automatic maintainance tasks checked
7. Use same password : demo1234
8. Storage Type: File, Use Database file location from template
9. Specify flash recovery checked, default values
10. (Version 12.2) Select default listener already selected.
11. (Version 12.2) Configure Data Vault and Oracle Label Security - unchecked.
10. Nothin on sample schema
11. Use Automatic Memory management : checked; Memory Size: 3072
12. Sizing > User Processes : 500
13. Character sets: AL32UTF8
13. (Version 12.2) National Character set: UTF8
14. open_cursors: 800
15. Create the database
16. Enable Database in /etc/oratab to allow easy start of server using dbstart tool<br>
`OIAM:/opt/oracle/db/product/11.2.0/dbhome_1:Y`
17. Updated the tmpfs line in /etc/fstab to allow oracle database to start on server<br>
`tmpfs                   /dev/shm                tmpfs  size=3g        0 0`

Profile setup
------------

To simplify the oracle environment setup, a file `"~oracle/setuporadb.sh"` was created with following content
```
export ORACLE_BASE=/opt/oracle/db
export DB_HOME=$ORACLE_BASE/product/11.2.0/dbhome_1
export ORACLE_HOME=$DB_HOME
export ORACLE_SID=OIAM
export ORACLE_TERM=xterm
export JAVA_HOME=/opt/oracle/java/
export BASE_PATH=/usr/sbin:$PATH
export PATH=$JAVA_HOME/bin/:$ORACLE_HOME/bin/:$BASE_PATH
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib
export ORACLE_HOME_LISTNER=$ORACLE_HOME
```

PATCH Installation
------------------
Sample patch 8545377

1. Setup environment and shutdown server<br>
`. ~oracle/setuporadb.sh`<br>
`dbshut $ORACLE_HOME`<br>
2. Check the correct Oracle HOME<br>
`opatch lsinventory -invPtrLoc /opt/oracle/oraInventory/oraInst.loc`
3. Apply patch
`unzip p8545377_112010_Linux-x86-64.zip; cd 8545377; opatch apply -invPtrLoc /opt/oracle/oraInventory/oraInst.loc`
4. Restart the server


Database details
----------------

1. Global Database Name & SID: OIAM
2. Server parameter file: `/opt/oracle/db/product/11.2.0/dbhome_1/dbs/spfileOIAM.ora`
3. Database control URL: `https://<hostname>:1158/em`
