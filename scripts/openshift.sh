#set params
AGENT_PORT="48011"
NODE_PORT="48010"
BROKER_PORT="48004"
CONTAINER="docker.io/nuodb/nuodb-ce-2.6.1:latest"

#login into oc
oc login ${OC_ADDRESS}:8443 -u ${USERNAME} -p ${PASSWORD} --insecure-skip-tls-verify=true


#deploy broker first
oc new-app $CONTAINER --name=broker \
      --env="NODE_REGION=aws" \
      --env="NODE_TYPE=BROKER" \
      --env="AGENT_PORT=$BROKER_PORT" \
      --allow-missing-images=false \
      --grant-install-rights=true \
      --loglevel=10

oc status

#grab broker ip address
function getPeer()
{
    PEER_ADDRESS="$(oc describe pod broker-1 | grep IP: | awk '{print $2}')"
}

while [ -z "$PEER_ADDRESS" ]
do
    sleep 60 # give broker a second to start
    getPeer
done

echo "broker address: $PEER_ADDRESS"

#deploy sm
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
