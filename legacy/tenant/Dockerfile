
# Example Dockerfile for building an image useful for running single-tenant,
# isolated processes. This does not setup services, install java, etc. You
# should change the $nuodb_package value to whichever .tgz package you are
# are using for this image.

FROM ubuntu:vivid
ENV nuodb_package nuodb-2.2.0.linux.x86_64.tar.gz

# add the package and setup so it's in the usual location
ADD $nuodb_package /tmp/
RUN /bin/mv /tmp/nuo* /opt/nuodb
RUN /bin/chown -R root:root /opt/nuodb

# set the default entrypoint so it can be called by the provided wrapper script
CMD /opt/nuodb/bin/nuodb --connect-key $key --agent-port $port --report-pid-as $pid
