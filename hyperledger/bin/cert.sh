#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )/";

source ${SCRIPT_DIR}/setEnv.sh

if [[ "$1" == "" ]];
then
   echo "Please specify organization name e.g. acme, contoso";
   exit 1;
fi
CERTIFICATE_LOC=${SCRIPT_DIR}/../data/crypto-config/peerOrganizations/${1}.example.com
case "$2" in
   ca) 
       CERTIFICATE_LOC=${CERTIFICATE_LOC}/ca/ca.${1}.example.com-cert.pem
       ;;
   peer)
       if [[ "$3" == "" ]];
       then
           echo "Please specify peer id e.g. peer0, peer1";
           exit 3;
       fi
       CERTIFICATE_LOC=${CERTIFICATE_LOC}/peers/${3}.${1}.example.com/msp/signcerts/${3}.${1}.example.com-cert.pem
       ;;
   user)
       if [[ "$3" == "" ]];
       then
           echo "Please specify user id e.g. Admin, User1";
           exit 4;
       fi
       CERTIFICATE_LOC=${CERTIFICATE_LOC}/users/${3}@${1}.example.com/msp/signcerts/${3}@${1}.example.com-cert.pem
       ;;
   *)
       echo "Please specify type of certification e.g. ca, peer, user";
       exit 2;
esac

openssl x509 -in ${CERTIFICATE_LOC} -noout -fingerprint -sha1 |cut -d '=' -f 2
