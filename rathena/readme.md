
# rathena

**This is the base image from which all else is constructed.**  _Realize that in spite of all resources being in a single shared image, the efficiency gained by separating would be in negligable amounts of disk space, but you are welcome to endeavor to achieve such a state._

The `Dockerfile` describes the base debian jessie system, installs dependent packages, clones the rAthena repository from github, and runs `build.sh` within.  _It accepts and forwards two environment variables, one for `packetver` and one for `prere`, which are settings supplied to `./configure` when `build.sh` is executed._

The `build.sh` file is copied onto the container by the `Dockerfile`, and allows you to pre-emptively override any behaviors, including custom steps such as applying a patcher, installing other packages, or applying additional settings to `./configure`.

**example execution with overrides (set to defaults):**

	PRERE=no PACKETVER=20151029 docker build -t "rathena:latest" .

_If you fancy support for multiple `packetver` values, you could use that in place of `latest` to make multiple builds available, and run a separate command to add another label for the latest build._
