
# rathena

**This is the base image from which all else is constructed.**

The `Dockerfile` describes the initial dependencies as defined by the rAthena github project readme.

It accepts environment variables to override the `packetver` and `prere` settings used when compiling, which can be set as follows (below are the defaults):

	PRERE=no PACKETVER=20151029 docker build -t "rathena:latest" .

_If you fancy support for multiple `packetver` values, you could use that in place of `latest` to make multiple builds available, and run a separate command to add another label for the latest build._

The `add/` folder allows you to install or overwrite literally any customizable files for consistency when distributing.  This can include global configuration (eg. `conf/import/`) updates to code files (eg. `src/`), or any data files (eg. `npc/`, `db/`, etc...).

The only item that exists there for certain is `add/docker/build.sh`, which includes the default logic to build rathena.  You can adjust the defaults, as well as customize the compilation steps here.
