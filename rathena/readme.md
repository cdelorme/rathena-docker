
# rathena

**This is the base image from which all else is constructed.**


## dependencies

This image depends on the `debian:jessie` base image from the public docker register.


## configuration

By default the following environment variables can be supplied to override `packetver` and `prere` settings when building rathena:

- `PRERE`
- `PACKETVER`

_See the `Dockerfile` for defaults._

More detailed customization can be added by modifying the `Dockerfile` or `add/docker/build.sh`, which executes the build steps, allowing you to force override the environment variables or set additional settings.

If you wish to add global configuration or modify rathena repository files prior to building, you can add them to `add/` using the same relative paths (_eg. `src/`, `conf/import/`, `npc/`, and `db/`_).


## execution

**The distributed components depend on a proper label of `rathena:latest`, which can be built via:**

	docker build -t "rathena:latest" .
