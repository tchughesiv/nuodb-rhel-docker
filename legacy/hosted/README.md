Example setup to build a Docker image that contains a complete NuoDB
environment. See the `Dockerfile` for details on two different methods for
injecting properties, and as a starting-point for defining your own
specific customizations. The setup will work with NuoDB 2.1 or later. See
the `Dockerfile` for the expected `.deb` install file name, or to update
to use a different installer and packaging system.

#### Building the docker image
  * change into the directory with this readme file
  * `sudo docker build .`

#### Running one or more containers
  * `sudo docker run run -P --net=host [OPTIONS] IMAGEID`
  * `IMAGEID` is shown on the last line of a successful docker build
  * `OPTIONS` must include a definition for DOMAIN_PASSWORD and may include AGENT_PORT and AGENT_PEER
  * Options are specified via the `-e` flag, for instance `-e DOMAIN_PASSWORD=bird -e AGENT_PORT=48010`
  * make sure that [Transparent Huge Pages are disabled](http://doc.nuodb.com/display/doc/Linux+Installation?src=search#LinuxInstallation-NoteaboutTransparentHugePages%28THP%29) on the *host* before running

