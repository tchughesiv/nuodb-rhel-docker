Example setup to build a Docker image for containing a single TE or SM. The
NuoDB Agent in this model runs outside the containers on the host OS. Note
that this setup requires NuoDB version 2.2 or later which has a flag to tell
database processes to report a PID other than the one from inside a container.

#### Building the docker image
  * change into the directory with this readme file
  * `sudo docker build .`
  * `sudo docker tag IMAGEID nuodb:tenant`
  Alternately, you can update the wrapper script with your image's identifier.

#### Setting up the host NuoDB environment
  * Install nuodb as usual
  * `sudo cp nuodb_wrapper.sh /opt/nuodb/bin/nuodb`
  * `sudo chmod +x /opt/nuodb/bin/nuodb`
  * note the comments in the wrapper script about granting nuodb sudo privs
  * make sure that [Transparent Huge Pages are disabled](http://doc.nuodb.com/display/doc/Linux+Installation?src=search#LinuxInstallation-NoteaboutTransparentHugePages%28THP%29) on the *host*

You can now use all of the normal management tools available to start database
processes. The processes, however, will each be run in their own container.
