
# [rathena-docker](https://github.com/cdelorme/rathena-docker)

**Dockerized rAthena for _local_ testing.**

The project consists of two main components:

- a [`Dockerfile`](Dockerfile) to create a single self-contained and fully configured image
- a [`deploy.sh`](deploy.sh) script to help automate building and deployment for testing

_Testing in isolated containers is a sure-fire way to avoid the "it works on my system" problem, and without the overhead of full virtualization._


## dependencies

This project requires `docker`, a host with `bash`, and the `debian:jessie` image from the public docker registry.


## configuration

All configuration is handled via inputs through `deploy.sh`.  **For automation support do not modify existing defaults within [`rathena/conf/import/`](rathena/conf/import/)**, though you are welcome to add to them.

The only configurable settings are the prere, packetver, and repo versions.  _While I would like to add more, the complexity it adds and time to finish would be significant, and the original goal of this project has failed due to limitations of the technology._


## usage

Simply run [`./deploy.sh`](deploy.sh) and follow the interactive prompts.  _You can pre-emptively set environment variables to answer the questions, for details [view the source](deploy.sh)._


## preemptive faq

- why dockerize rathena?
	- primarily to make it easy to isolate a predictable build environment so newcomers can easily get rathena up and running, and so developers have a quick play-test instance to work with.
- why a single image with mysql preloaded?
	- docker limitations with regard to post-runtime configuration forced my hand, but reducing complexity and subsequently human error are the positives.
- can I distribute the container?
	- I think anyone would be ill-advised to use docker for production deployments, and this image does not produce an efficient server instance.


## notes

I spent roughly three weeks tinkering, and concluded that any attempts to use `docker exec` and `docker run` to modify the instance prior to starting up `rathena` components, such as would be required to tailor the system for distributed computing, were simply not supported.

Attempts to do this led to zombied processes and a whole lot of reading on how docker enforces single-processes.  This seems to be fine using `CMD` to startup the database and server using `docker create`, but it has zero flexibility once the image has been built.
