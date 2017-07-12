#!/bin/sh
#
#  start the NuoDB processes
#
set -x

env

# setup NUODB vars pointing to standard locations
export NUODB_HOME=/opt/nuodb
. $NUODB_HOME/etc/nuodb_setup.sh

mv /opt/nuodb/etc/default.properties.sample /opt/nuodb/etc/default.properties
sed -i "/#domainPassword =/c\domainPassword = ${DOMAIN_PASSWORD}" /opt/nuodb/etc/default.properties

mkdir -p $NUODB_LOGDIR
mkdir -p $NUODB_VARDIR

NODE_MEM="512m"


ARCHIVE_VOLUME=$NUODB_VARDIR/production-archives
ARCHIVE_LOCATION=$ARCHIVE_VOLUME/$DB_NAME

# set up BROKER vars
BROKER_OPTS="--password ${DOMAIN_PASSWORD} --broker true"
[ -n "$PEER_ADDRESS" ] && BROKER_OPTS="$BROKER_OPTS --peer ${PEER_ADDRESS}"
[ -n "$ALT_ADDRESS" ] && BROKER_OPTS="$BROKER_OPTS --advertise-alt --alt-addr ${ALT_ADDRESS}"

# first start the broker
if [ "${NODE_TYPE}" == "SM" ]; then
   HOST_TAGS="-DhostTags=SM_OK=True"
elif [ "${NODE_TYPE}" == "TE" ]; then
    HOST_TAGS="-DhostTags=TE_OK=True"
fi

$JAVA_HOME/bin/java $HOST_TAGS -jar $NUODB_HOME/jar/nuoagent.jar --port ${AGENT_PORT} $BROKER_OPTS >> $NUODB_LOGDIR/agent.log 2>&1 &

# wait a bit for the broker
sleep 5

# set up engine start-up vars
START_CMD="start process ${NODE_TYPE} host ${PEER_ADDRESS}:${AGENT_PORT} database ${DB_NAME}"
NODE_OPTS="--agent-port ${AGENT_PORT} --node-port ${NODE_PORT} --mem $NODE_MEM"

# add options specific to the engine type
if [ "${NODE_TYPE}" == "SM" ]; then
        START_CMD="$START_CMD archive $ARCHIVE_LOCATION"
        NODE_OPTS="$NODE_OPTS --journal enable"

        # if the archive volume is mounted, but the archive does not exist, then initialize it
        if [ -d "$ARCHIVE_VOLUME" ]; then
                [ -d "$ARCHIVE_LOCATION" ] || NODE_OPTS="$NODE_OPS --initialize"
        else
                # the archive volume is not mounted, so the archive is ephemeral
                echo "No archive volume mounted - running in DEV mode"
                mkdir -p $ARCHIVE_LOCATION
        fi
elif [ "${NODE_TYPE}" == "TE" ]; then
        NODE_OPTS="$NODE_OPTS --dba-user ${DB_USER} --dba-password ${DB_PASSWORD}"
elif [ "${NODE_TYPE}" == "BROKER" ]; then
        echo "Starting BROKER container"
else
        echo "Unimplemented node type: ${NODE_TYPE}"
        exit 1
fi

#disable thp if enabled
/bin/bash /scripts/disable_thp.sh

#NUODBMGR="$NUODB_HOME/bin/nuodbmgr --broker ${PEER_ADDRESS}:${AGENT_PORT} --password ${DOMAIN_PASSWORD} --command"
#START_CMD="$START_CMD options '$NODE_OPTS'"
#$NUODBMGR "$START_CMD"

#start api service
/opt/nuodb/etc/nuorestsvc start

cat $NUODB_LOGDIR/agent.log
tail -f $NUODB_LOGDIR/agent.log
