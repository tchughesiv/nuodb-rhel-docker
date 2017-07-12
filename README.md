**DESCRIPTION:**


**DOCKER BUILD:**

 `RELEASE_PACKAGE=##`  - Bamboo release package number
 
 `BUILD=##` - Bamboo build number

 `RELEASE_BUILD=#.#.#` - NuoDB's release number

 `VERSION=nuodb or nuodb-ce` - Community Edition or Full version of NuoDB

example:
```bash
Docker build \
    -t nuodb-2.6.1:latest \
    --build-arg RELEASE_PACKAGE=35 \
    --build-arg BUILD=8 \
    --build-arg BUILD_RELEASE=2.6.1 \
    --build-arg VERSION=nuodb-ce \
    --build-arg RHUSER=redhatAccount@example.com \
    --build-arg RHPASS=RedHatPassword
```
**DOCKER RUN:**

General environment variables:

    ENV_TYPE - Describes the ecosystem you're deploying the docker container in. 
                 The options are:
                     OPENSHIFT 
                     AWSEC2
                     AWSECS
                     AZURE
                     GOOGLE
                     
    AGENT_PORT="48011"
    NODE_PORT="48010"
    BROKER_PORT="48004"
    NODE_TYPE
    
OpenShift specific environment variables 

    OC_ADDRESS  - IP or FQDN of master OpenShift node 
    USERNAME    - OpenShift user account to execute oc commands
    PASSWORD    - OpenShift user's password


example: OpenShift
```bash
oc new-app docker.io/nuodbopenshift/nuodb-ce:latest \
    --name nuodb-deployer \
    -e "ENV_TYPE=OPENSHIFT" \
    -e "OC_ADDRESS=172.31.17.249"  \
    -e "USERNAME=developer"  \
    -e "PASSWORD=developer" 
```

