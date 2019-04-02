#!/bin/bash

CONTAINER_IDS=$(docker ps -a | awk '($2 ~ /(fabric|acme|contoso)/) {print $1}')
if [ -z "$CONTAINER_IDS" -o "$CONTAINER_IDS" == " " ]; then
  echo "---- No containers available for deletion ----"
else
  echo "Deleting containers..."
  docker rm -f $CONTAINER_IDS
fi

echo "Deleting Network..."
docker network rm hyperledger-base_acme

VOLUMES=$(docker volume ls | awk '($2 ~ /(acme|contoso)/) {print $2}')
if [ -z "$VOLUMES" -o "$VOLUMES" == " " ];
then
   echo "---- No Volumes  available for deletion ----"
else
   echo "Deleting Volumes..."
   docker volume rm $VOLUMES
fi

CHAINCODE_IMAGES=$(docker images | awk '($1 ~ /(acme|contoso)/) {print $3}')
if [ -z "$CHAINCODE_IMAGES" -o "$CHAINCODE_IMAGES" == " " ];
then
   echo "---- No chaincode images  available for deletion ----"
else
   echo "Deleting chaincode images..."
   docker rmi $CHAINCODE_IMAGES
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )/";

rm -rf ${SCRIPT_DIR}/../data/*

for logFileName in ${SCRIPT_DIR}/../logs/*;
do
   echo "" > ${logFileName};
done
