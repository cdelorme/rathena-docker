
# [rathena-docker](https://github.com/cdelorme/rathena-docker)

**Dockerized rAthena for _local_ testing and demonstrating distributed installations.**

The project consists of two main components:

- a [`Dockerfile`](Dockerfile) to create a single self-contained and fully configured image
- a [`deploy.sh`](deploy.sh) script to help automate building and deployment for testing

_Testing in isolated containers is a sure-fire way to avoid the "it works on my system" problem, and without the overhead of full virtualization._


## dependencies

This project requires `docker`, a host with `bash`, and the `debian:jessie` image from the public docker registry.


## configuration

Sane defaults are provided inside [`rathena/`](rathena/).  **For automation do not modify the existing defaults**, but feel free to append more configuration settings.  _Files added here will override or replace the files in the cloned `rathena`, which means source code can also be added with matching paths._

If you want more fine-tuned control feel free to modify [`deploy.sh`](deploy.sh) or the commands in the [`Dockerfile`](Dockerfile).


## usage

Simply run [`./deploy.sh`](deploy.sh) and follow the interactive prompts.  _You can pre-emptively set environment variables to answer the questions, for details [view the source](deploy.sh)._


## Pre-emptive FAQ:

- why dockerize rathena?
	- primarily to cheaply test distributed deployments, but also to allow the easy creation of distributable rathena images, and the option to build without installing any specific dependencies on your host machine.  Isolation assures that the commands run are valid and not influence by your systems state.
- why a single image with mysql preloaded?
	- to reduce complexity and subsequently human error; to provide a consistent and compatible state when testing distributed deployments; to ensure code versions are compatible; to ensure compilation settings are compatible; to ensure both database data and text file data are compatible (_while a database may be used, many systems still load from text files at launch_)
- can I use these in production?
	- _This system is not for producing efficient, independent, deployable production components, but rather for locally testing and demonstrating only._  The rathena project is monolithically structured, and to efficiently build and deploy all the parts independently would be an especially sizable undertaking to automate.
