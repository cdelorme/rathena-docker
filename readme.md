
# [rathena-docker](https://github.com/cdelorme/rathena-docker)

**Using docker to isolate rAthena instances we can demonstrate scalable deployments without incurring the cost of multiple servers!**

In this demonstration we have a modular composition of images, which allow reusable state to reduce the disk space actually required.  It also allows customization, making it an excellent demonstration of how to create reusable containerized projects.


## images

Review the readme in each of these folders for more information:

- [`rathena`](rathena/)


## Pre-emptive FAQ:

- Why would you create a dockerized rAthena?
	- to cheaply demonstrate (or test) the rAthena distributed model.
- Why compile inside the container?
	- to isolate runtime dependencies that may fail if the build happened locally.
- Why not compile only in the containers each uses?
	- laziness, also consistency.  The packetver and prere settings as well as any other desirable modifications would need to be repeated in three independent builds.  I am happy to trade a negligable amount of disk space for the confidence that the binaries are compatible and the ability to test that before I create independent deployable components.
