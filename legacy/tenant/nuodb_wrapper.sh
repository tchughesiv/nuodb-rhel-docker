#!/bin/sh
#
# Wrapper script for running NuoDB database processes inside of their own
# Docker containers. This provides resource management but still requires the
# network interfaces to be open on the host. To run this, the user 'nuodb'
# will require permisison to run Docker commands via 'sudo'. Typically this
# is done by adding a line like
#
#   nuodb   ALL=(ALL)       NOPASSWD:/usr/bin/docker
#
# to the /etc/sudoers file. You must also disable requiring a TTY if that is
# set by default. 

# set the default agent port
PORT=48004

# the agent will pass at most two arguments directly on the command-line to
# get the local process connected back into the managament tier, so look for
# these to pass into the container as environment variables
while [ $# -gt 1 ]
do
	key="$1"
	case $key in
		(--connect-key)
			shift
			CKEY=$1
			;;
		(--agent-port)
			shift
			PORT=$1
			;;
	esac
	shift
done

# invoke docker via sudo, providing this script's PID as the identifier that
# the new process should report back .. if you want to use a different image
# you can specify a different tag or image identifier here
sudo /usr/bin/docker run -P --net=host -e port=$PORT -e key=$CKEY -e pid=$$ nuodb:tenant 
