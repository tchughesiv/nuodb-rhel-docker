
# Example Dockerfile for building an image with a complete NuoDB install that
# has an agent and can host one or more databases. The image supports injecting
# configuration changes via environment variables. NuoDB supports this model
# in a few ways. By default the image will use command-line Java properties but
# an alternate model is provided using a bootstrap script. See below for how
# to build using one or the other model.

FROM ubuntu:14.04
ENV nuodb_package nuodb_2.1.1.10_amd64.deb

# update the distro and install the JRE and supervisor
RUN /usr/bin/apt-get update
RUN /usr/bin/apt-get -y install default-jre-headless supervisor

# add the nuodb package to the image and run the install
ADD $nuodb_package /tmp/
RUN /usr/bin/dpkg -i /tmp/$nuodb_package

# copy the supervisor conf file into the image
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Below this line are the two options for injecting properties. By default the
# uncommented block uses JVM properties. Comment-out this section and
# un-comment the other block to do an overwrite of the default.properties
# file. In either model the command-line for running docker is the same.

# START STEPS FOR USING JVM PROPERTIES
# setup the agent JVM options to pull in key properties & start supervisor
ADD jvm-options /etc/nuodb/
RUN /bin/sed -ie 's/#domainPassword =/domainPassword = /' /opt/nuodb/etc/default.properties
CMD /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
# END JVM PROPERTIES STEPS

# START STEPS FOR OVERWRITING DEFAULT.PROPERTIES
# add a wrapper that will stage all properties and use it on entry
#ADD setup.sh /tmp/
#RUN /bin/chmod +x /tmp/setup.sh
#CMD /tmp/setup.sh
# END OVERWRITE STEPS
