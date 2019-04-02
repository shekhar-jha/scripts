#!/bin/bash

source ./scripts/setEnv.sh $1 $2 $3

peer channel join -b ${CHANNEL_ID}.block

