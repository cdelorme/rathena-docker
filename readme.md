
# [rathena-docker](https://github.com/cdelorme/rathena-docker)

**Using docker to isolate rAthena instances we can demonstrate scalable deployments without incurring the cost of multiple servers!**

In this demonstration we have a modular composition of images, which allow reusable state to reduce the disk space actually required.  It also allows customization, making it an excellent demonstration of how to create reusable containerized projects.


## images

Review the readme in each of these folders for more information:

- [`rathena`](rathena/)
- [`db`](db/)
- [`full`](full/)


## Pre-emptive FAQ:

- Why would you create a dockerized rAthena?
	- to cheaply demonstrate (or test) the rAthena distributed model.
- Why compile inside the container?
	- to isolate runtime dependencies that may fail if the build happened locally.
- Why add a scripts instead of using the Dockerfile?
	- it becomes significantly easier to override complex build steps when they can be uploaded in a script instead of executed by a Dockerfile where syntax may be more limited.
- Why not compile only in the containers each uses?
	- laziness, also consistency.  The packetver and prere settings as well as any other desirable modifications would need to be repeated in three independent builds.  I am happy to trade a negligable amount of disk space for the confidence that the binaries are compatible and the ability to test that before I create independent deployable components.
- Why use mysql?
	- it's the only database supported by rAthena currently, and it allows you to distribute load by separating the database instance.
- Why use the base image for the db instances?
	- laziness, and consistency.  Considering rAthena is a relatively active project, you can't ensure that separated DB builds cloning it would always get the same data, unless you also want to track and checkout a specific git commit hash or tagged version.
- Why load all schema into the same db image?
	- laziness, and consistency.  Loading it all at once reduces the number of containers we need to keep track of at the cost of a negligable amount of disk space.  _We can also use this as the base image for a complete deployment that can be tested before we bother with distributed components._
- Why allow overrides in both the main image as well as each component?
	- a consistent initial state supercedes per-instance settings, and a majority of global configuration is still applied via txt files and not mysql; it is entirely optional whether you use it.


## notes

If you run `docker images` it will list each image, the label, id, and size.  The base `debian:jessie` has a size of 125MB.  The size with rAthena dependencies and the compiled project is 532MB (at time of testing).  The system only tracks the diff of those sizes, so a fully compiled rAthena image only takes 407MB on disk.  Subsequently, the database instance is 693.5MB, meaning it only takes 161.5MB on disk.  So, while it is wasteful to create "universal" images, it is not as bad as you'd think.  _If the data and each server were broken into separate components, it would be much easier to make a clean dockerized solution._
