#!/bin/sh

# Wrapper script called on entry to the image that updates the agent's
# default.properties file in-place before passing-on control to supervisor.

AGENT_PORT=${AGENT_PORT:-48004}
PORT_RANGE=$((AGENT_PORT+1))
AGENT_PEER=${AGENT_PEER:-''}

/bin/sed -ie "s/#domainPassword =/domainPassword = $DOMAIN_PASSWORD/" /opt/nuodb/etc/default.properties
/bin/sed -ie "s/#port = 48004/port = $AGENT_PORT/" /opt/nuodb/etc/default.properties
/bin/sed -ie "s/portRange = 48005/portRange = $PORT_RANGE/" /opt/nuodb/etc/default.properties
/bin/sed -ie "s/#peer =/peer = $AGENT_PEER/" /opt/nuodb/etc/default.properties

/usr/bin/supervisord
