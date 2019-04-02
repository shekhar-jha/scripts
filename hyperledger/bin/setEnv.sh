
export HYPERLEDGER_BASE=${HYPERLEDGER_BASE:-/opt/hyperledger/fabric-samples/}
export HYPERLEDGER_HOME=${HYPERLEDGER_HOME:-$SCRIPT_DIR/../}
export CHANNEL_NAME=${CHANNEL_NAME:-userconsentstatus}
export IMAGE_TAG="latest"
export COMPOSE_PROJECT_NAME=hyperledger-base

# Parameters
# $1 Parameter number being processed. 1,2,3
# $2 Value of parameter being processed
# $3 Default value if parameter not set
# $4 Total number of parameters available
# $5 Location at which arguments are available (i.e. after -)
function getValue() {
#  echo "getValue($1, $2, $3)"
  if [[ $4 -ge $1 ]];
  then
      if [[ $5 -eq 0 ]];
      then
        if [[ "${2}" = "-" ]];
        then
          echo "${3}"
          return $(( $1 + 1 ));
        else
          echo "${2}"
          return $5;
        fi
      else
        echo "${3}"
        return $5;
      fi
  else
     echo "${3}" # Default value
     return $5;
  fi
}
