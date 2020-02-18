Simple scripts for various SSL operations using OpenSSL and Java keystores

# OpenSSL

## CSR Generation

```
if [ $# -eq 0 ]
then
   echo "Please provide fully qualified server name"
   exit
fi
echo "Processing $1 "
splitValues=(${1//./ })
if [ ${#splitValues[@]} -lt 2 ]
then
   echo "Please ensure that server name is fully qualified"
   exit
fi
if [[ "`getent hosts $1`" == '' ]]
then
   echo "The given server name $1 could not be resolved. Please ensure that server name is correct"
   read -p "Proceed (y/n)? " -n 1 -r
   echo
   if [[ $REPLY =~ ^[Yy]$ ]]
   then
     echo "Moving ahead with process"
   else
     exit
   fi
fi
processHostName=${splitValues[0]}
mkdir -p $processHostName
cd $processHostName
openssl genrsa -out ./$processHostName.key 2048
openssl req -new -key ./$processHostName.key -out ./$processHostName.csr -subj "/C=IN/ST=MH/L=WHATEVER/O=ACMEINC/CN=$1"
```
## Generate and sign certificates

### Create CA
```
OPENSSL_CMD="/usr/local/Cellar/openssl/1.0.2t/bin/openssl"
mkdir -p ca
openssl genrsa -out ca/ca.key 2048
$OPENSSL_CMD req -new -x509 -key ca/ca.key -sha256 -days 328500 -out ca/ca.crt -config ./certs-v3-ca.conf
```

### Create Cert
```
#!/bin/bash

usage () {
  echo $0' <directory name> <domain name> [<domain name>]*'
  exit 1
}

if [[ "$1" == "" ]]; then
  echo "Please provide certificate directory";
  usage
fi
if [[ ! -d "$1" ]]; then
  echo "Please provide valid certificate directory";
  usage
fi
if [[ ! -d "$1/items" ]]; then
  mkdir "$1/items"
fi
if [[ "$2" == "" ]]; then
  echo "Please provide the name of server for which certificate needs to be generated";
  usage
fi
CERT_DIR=$1
DOMAIN_NAME=$2
SAN="DNS.1 = $2"
COUNTER=2
for sanName in "${@:3}"
do
   SAN="$SAN"$'\n'"DNS.$COUNTER = $sanName"
   let COUNTER=COUNTER+1
done
echo "SAN List: $SAN"

OPENSSL_CMD="/mingw64/bin/openssl"

    $OPENSSL_CMD genrsa -out $CERT_DIR/items/$DOMAIN_NAME.key 2048;
    cp ./certs-v3.conf ./certs-v3.conf.temp
    echo "$SAN" >> ./certs-v3.conf.temp

    $OPENSSL_CMD req -new -key $CERT_DIR/items/$DOMAIN_NAME.key -out $CERT_DIR/items/$DOMAIN_NAME.csr \
        -subj "//C=US\ST=MH\L=WHATEVER\O=ACMEINC\OU=IT\CN=$DOMAIN_NAME" \
        -reqexts v3_req \
        -extensions v3_req -config ./certs-v3.conf.temp

    $OPENSSL_CMD x509 -req -in $CERT_DIR/items/$DOMAIN_NAME.csr -CA ./ca/ca.crt -CAkey ./ca/ca.key -CAcreateserial -out $CERT_DIR/items/$DOMAIN_NAME.crt -days 328499 -sha256 -extensions v3_req -extfile ./certs-v3.conf.temp;
    rm ./certs-v3.conf.temp
    $OPENSSL_CMD pkcs12 -export -out $CERT_DIR/$DOMAIN_NAME.pfx -inkey $CERT_DIR/items/$DOMAIN_NAME.key -in $CERT_DIR/items/$DOMAIN_NAME.crt -certfile ./ca/ca.crt;
```
#### certs-v3.conf
The file should contain the following 
```
[ v3_req ] # this section should contain the following
# Extensions to add to a certificate request

basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

....

[alt_names]
# This should be last line in file

```

## Create PKCS12 file and JKS File

```
JAVA_HOME="${JAVA_HOME:-/opt/oracle/java/jdk1.7.0_80}"
if [ $# -eq 0 ]
then
   echo "Please provide fully qualified server name"
   exit
fi
echo "Processing $1 "
splitValues=(${1//./ })
if [ ${#splitValues[@]} -lt 1 ]
then
   echo "Please ensure that server name is provided"
   exit
fi
processHostName=${splitValues[0]}

if [ ! -d "$processHostName" ];
then
  echo "Looks like no SSL initialization has not yet been performed. Please generate CSR and get signed certificate before running this script"
  exit
fi
if [ ! -f "$processHostName/$processHostName.key" ]
then
  echo "Failed to locate private key. Please ensure that SSL initialization was performed correctly."
  exit
fi
if [ ! -f "$processHostName/$processHostName.cert" ]
then
  echo "Looks like CSR was created but signed certificate is not available. Please ensure that signed certificate is stored in $processHostName.cert file"
  exit
fi
cd $processHostName
read -s -p "Keystore password?" keystorePassword
echo
read -s -p "Private key password?" privateKeyPassword
echo
rm -f $processHostName.p12
openssl pkcs12 -export -in $processHostName.cert -inkey $processHostName.key -out $processHostName.p12 -password pass:$privateKeyPassword -name $processHostName
rm -f $processHostName.jks
$JAVA_HOME/bin/keytool -importkeystore -srckeystore $processHostName.p12 -srcstoretype PKCS12 -destkeystore $processHostName.jks -deststoretype JKS -srcstorepass $privateKeyPassword -destkeypass $privateKeyPassword -deststorepass $keystorePassword -alias $processHostName
cd ..
for cert in `ls *.crt`;
do
  $JAVA_HOME/bin/keytool -import -file $cert -alias $cert -trustcacerts -keystore $processHostName/$processHostName.jks -storepass $keystorePassword -noprompt
done

```

# JKS

## Create JKS from PKCS12
```
$JAVA_HOME/bin/keytool -importkeystore -srckeystore $processHostName.p12 -srcstoretype PKCS12 -destkeystore $processHostName.jks -deststoretype JKS -srcstorepass $privateKeyPassword -destkeypass $privateKeyPassword -deststorepass $keystorePassword -alias $processHostName
```

# NSS
Mozilla NSS uses internal certificate database. On Suse Linux 11, mod-apache_nss is recommended method to support TLSv1.2 on apache 2.2. The following steps can be used to create certificate database.

## Create database
```
certutil -N -d conf/certs.nss/ --empty-password
```

## Add certificates
```
certutil -A -n "intermediate" -t "C,," -d conf/certs.nss/ -i conf/certs/intermediate.cer
```
## Add PKCS12
```
pk12util -i "${p12FileName}" -d conf/certs.nss/ -W "${p12FilePassword}"
```

## Setup Apache with NSS
Add the following lines in httpd.conf to enable SSL using NSS module
```
LoadModule nss_module               /usr/lib64/apache2/mod_nss.so
<IfModule nss_module>
#
# NSSEngine: Whether SSL is enabled.
#
  NSSEngine on

#
# ServerName: Hostname and port that the server uses to identify itself
#
  ServerName @@fully-qualified-server-name@@:@@port@@

#
# NSSCertificateDatabase: Location of NSS Database that contains server
# and other intermediate and CA certificates.
#
# Use 'certutil' to create and manage this database.
# Use 'pk12util' to import new server's certificate
#
  NSSCertificateDatabase @@site-location@@/@@site-name@@/conf/certs.nss

#
# NSSNickName: Alias used to identify server certificate
#
# Use 'certutil -L -d <location of certificate database>' to identify
# the server certificate
#
  NSSNickName @@server_cert_name@@

  NSSRandomSeed startup builtin
#
# NSSProtocol: Specific SSL Protocol that server should support.
#
# Based on security recommendation, this has been set to latest
# TLS protocol.
#
  NSSProtocol TLSv1.2

#
# NSSCipherSuite: Cipher suite that can be used by client to connect
# to Server.
#
# Based on security recommendation, this has been set to NOT support
# DES, 3DES, RC4
#
  NSSCipherSuite ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:RSA+AESGCM:RSA+AES:!aNULL:!MD5:!DSS
  NSSPassPhraseHelper /usr/sbin/nss_pcache

</IfModule>

```

# Oracle Wallet

Oracle wallet management tools are available as part of Weblogic Proxy plugin and need Java to run.

## Create wallet
```
/opt/apache/plugin/18603703/bin/orapki wallet create -wallet ../../../oracle-wallet/wallet-base/ -auto_login_only
```

## Add certificate 
Add a trusted certificate to wallet to allow proxy plugin to connect to weblogic servers
```
/opt/apache/plugin/18603703/bin/orapki wallet add -wallet ../../../oracle-wallet/wallet-base -cert ../../../oracle-wallet/root.crt -trusted_cert -auto_login_only
```


# Weblogic
In order to secure SSL on weblogic, the following changes are needed. These changes ensure that

1. Strong TLS Protocol (i.e. version 1.2) is supported and request to connect using weak protocol is not supported.
2. Strong Ciphers are used.

## Disable weak cipher

### Weblogic Server and Node Manager
Use the latest Java. This implies using JDK version older than 1.7.0_80 which is available through oracle support. Understand licensing implication of using latest version.

Also, change the following line in /opt/oracle/java/java7/jre/lib/security/java.security
```
jdk.tls.disabledAlgorithms=SSLv3, MD5withRSA, DH keySize < 768, \
    EC keySize < 224 
```
to the following to disable weak RC4, DES and 3DES protocols
```
jdk.tls.disabledAlgorithms=SSLv3, MD5withRSA, DH keySize < 768, \
    EC keySize < 224 \
        RC4_128, RC4_40, DES_CBC, DES40_CBC, \
        3DES_EDE_CBC
```
### Default JKS Keystore
The Default JKS Keystore contains a certificate which contains a key/certificate with weak signature algorithm. This is used by SOA server to authenticate and invoke OIM Webservices.
#### JKS
Create new keystore with self-signed certificate
```
keytool -genkeypair -keystore ./default-keystore.jks -keyalg RSA -sigalg SHA256withRSA -alias xell -dname "CN=<env>-gidm,O=ACME, L=City, S=State, C=Country" -keysize 2048 -validity 3650
Enter keystore password:
Re-enter new password:
Enter key password for <xell>
```
Export and import new certificate
```
keytool -exportcert -keystore ./default-keystore.jks -v -alias xell -rfc -file ./gidm.cer
keytool -importcert -keystore ./default-keystore.jks -alias xeltrusted -file ./gidm.cer -noprompt
```
Replace old key present in `$DOMAIN_HOME/config/fmwconfig/default-keystore.jks`

#### Keystore password update
Update the new Password in `oim` Credential map available on Oracle EM console (or through wlst command).

## Enable strong SSL Protocol

### Weblogic Server

Add the following line ${DOMAIN_HOME}/bin/setDomainEnv.sh. 
```
export JAVA_OPTIONS="${JAVA_OPTIONS} -Dweblogic.security.SSL.minimumProtocolVersion=TLSv1.2"
```

### Node Manager
Add the following in JAVA_OPTIONS definition in ${MIDDLEWARE_HOME}/wlserver_10.3/server/bin/startNodeManager.sh
```
-Dweblogic.security.SSL.minimumProtocolVersion=TLSv1.2
```
