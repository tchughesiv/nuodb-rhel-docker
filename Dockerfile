FROM registry.access.redhat.com/rhel7

ARG RELEASE_PACKAGE=35
ARG BUILD=8
ARG RELEASE_BUILD=2.6.1
ARG VERSION=nuodb
ARG RHUSER
ARG RHPASS

LABEL "name"="$VERSION" \
      "vendor"="NuoDB LTD" \
      "version"="$RELEASE_BUILD" \
      "release"="$BUILD"

RUN subscription-manager register --username=$RHUSER --password=$RHPASS \
    && subscription-manager attach --pool=8a85f9815b58a400015b58e392315383 \
    && subscription-manager repos --disable="*" \
    && subscription-manager repos --enable="rhel-7-server-rpms" --enable="rhel-7-server-ose-3.5-rpms"

RUN yum -y install --disablerepo "*" --enablerepo rhel-7-server-rpms,rhel-7-server-ose-3.5-rpms \
      --setopt=tsflags=nodocs net-tools java unzip atomic-openshift-clients \
    && yum clean all

RUN curl -SL https://s3.amazonaws.com/aws-cli/awscli-bundle.zip -o /tmp/awscli-bundle.zip \
    && unzip /tmp/awscli-bundle.zip -d /tmp/ && /tmp/awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws \
    && rm -rf /tmp/awscli*

RUN curl -SL http://bamboo.bo2.nuodb.com/bamboo/artifact/RELEASE-PACKAGE$RELEASE_PACKAGE/shared/build-$BUILD/Linux-.tar.gz/$VERSION-$RELEASE_BUILD.$BUILD.linux.x86_64.tar.gz -o /tmp/nuodb.tgz \
    && mkdir -p /opt/nuodb \
    && tar xvf /tmp/nuodb.tgz -C /opt/nuodb --strip-components 1 \
    && rm -rf /tmp/nuodb.tgz

#set ownership of nuodb home
RUN chown -R nobody:nobody /opt/nuodb

ADD scripts /scripts
COPY help.1 /

USER 99
CMD ["bash", "/scripts/entrypoint.sh"]
