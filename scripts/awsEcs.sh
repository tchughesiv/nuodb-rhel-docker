#set params
AGENT_PORT="48011"
NODE_PORT="48010"
BROKER_PORT="48004"
CONTAINER="docker.io/nuodbopenshift/nuodb-ce-dev:latest"
AZ="$( curl http://169.254.169.254/latest/meta-data/placement/availability-zone/ )"
REGION="${AZ::-1}"

#the deploy container in AWS ECS is the broker
export NODE_TYPE=BROKER
export AGENT_PORT=$AGENT_PORT
export NODE_PORT=$NODE_PORT
export BROKER_PORT=$BROKER_PORT

#run startNuodb now for broker
. /scripts/startNuodb.sh

#let nuodb start up
sleep 30

#grab broker ip address
PEER_ADDRESS="$(ifconfig eth0 | grep broadcast | awk '{print $2}')"


echo "broker address: $PEER_ADDRESS"

#deploy sm
aws ecs --region $REGION register-task-definition \
  --network-mode bridge \
  --cli-input-json file://./sm.json ####this needs to be inline for PEER_ADDRESS param

aws ecs --region $REGION run-task \
  --cluster ${CLUSTER} \
  --task-definition sm

oc new-app $CONTAINER --name=sm \
    --env="NODE_REGION=aws" \
    --env="NODE_TYPE=SM" \
    --env="AGENT_PORT=$AGENT_PORT" \
    --env="DB_NAME=db1" \
    --env="PEER_ADDRESS=$PEER_ADDRESS:$BROKER_PORT" \
    --env="NODE_PORT=$NODE_PORT" \
    --allow-missing-images=false \
    --grant-install-rights=true \
    --loglevel=10

oc status

#deploy te
oc new-app $CONTAINER --name=te \
    --env="NODE_REGION=aws" \
    --env="NODE_TYPE=TE" \
    --env="AGENT_PORT=$AGENT_PORT" \
    --env="DB_NAME=db1" \
    --env="PEER_ADDRESS=$PEER_ADDRESS:$BROKER_PORT" \
    --env="NODE_PORT=$NODE_PORT" \
    --allow-missing-images=false \
    --grant-install-rights=true \
    --loglevel=10

oc status

#remove deployer from oc
oc delete all -l 'app=nuodb-deployer'
