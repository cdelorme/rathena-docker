
# flaws

I wanted to discuss some flaws across the tools in this project:

- docker
- docker-compose
- rAthena

## docker

Because docker images are intended to be immutable there is no way to mount a folder during a build.

_For development this means a full image must be rebuilt per corrected typo._

The baked image takes up 1GB of space on disk, and is cloned per container (_a 5GB test environment_).

By design docker is only supposed to run a single process per container.

_It is possible to use a script to launch several processes instead._

> In an ideal world we would be able to rapidly and automatically rebuild when source files changed, and we would only need a single shared set of source files that was accessible from the host across all containers.


## docker-compose

There is no way to separate builds from services with `docker-compose`.

To work around this we have to shove the build logic into one of the earliest services in the dependency chain.

_This adds risk to modifying the `docker-compose.yml` file._

> In an ideal world we should be able to bake a base rAthena image with only dependencies installed, but we end up with an image that had the source installed and the full build process and database preloaded.

There is a limitation in docker compose where `depends_on` only launches containers in order.

_This means it is theoretically possible for the map server to finish starting up before the character server, leading to an error at startup due to failed connection._

> In an ideal world we would be able to prevent the initialization of a container until its dependent services were actually online and able to take traffic.


## rAthena

There is no resilience built into the startup logic of rAthena.

_If a connection fails at launch the service dies and we have to write behavior to retry starting it._

None of the services expose an accessible means of testing availability (eg. a ready-check or health-check that does not require C level code to access).

_We cannot write logic to automate waiting for the services to come online in order._

There is no distinction as to what files each server binary depends on.

_Every server needs a complete copy of the rAthena project to ensure each service runs without errors._

Communication between servers is not encrypted, making it susceptible to MITM attacks in a real-world distributed configuration where separate servers are used.


# alternatives

I considered various alternatives when trying to figure out a valid approach.

For example I could have created a throw-away "service" that build an image with just the dependencies.

All subsequent services could use that base image and mount the shared source.

_This would break due to conflicts when we tried to compile in parallel._

_We also lack a means of dealing with distributed server configuration, since we cannot point at different configuration files per image._

**This adds sizable complexity since we would probably need a script per service to handle its own unique build and configuration logic to evade the first two problems.**

We are also now stuck with an extra purposefully exited service container that will be created at each launch.


# design

I also wanted to quickly cover distributed game design, since there is some useful information we can glean from a discussion on that as well.


## shards

Game servers by design do not scale like stateless web software and instead use "sharding".

> **The most important factor leading to server shards is the availability of resources in the game world, which is not a technological restriction but rather a game design limitation.**

In the case of Ragnarok Online the players are split across Character Servers, making them the "shards".

This allows the load to be distributed on a predictable criteria.

It also allows a host to put their servers relative to the location of their users which reduces latency, which can improve the users experience.

**It is completely possible to use load balancing and instanced maps exclusively to address the combined resource limitations and load concerns, but this comes at the cost of reducing the value of said resources while also limiting visibility which can negatively impact the social experience of a user.**


## distribution

A properly designed system would be "multi-tenant", which is to say a single cluster of a "type" of servers would be able to equally load balance responsibility.

For example, even with multiple "character servers", in a well designed system it should be possible to have a single cluster of character servers, or even just one, to service all requests.

Similarly, a well designed map server would work the same.

**This is impossible by design with Ragnarok and rAthena.**


### Ragnarok

Starting with the official ragnarok client, because rAthena has the goal of feature parity.

When the client connects to a selected character server it does not send the name or any identifiable information.

_Basically, there is no way for the character server to identify which "Shard" the user is attempting to access, and thus each character server must be its own unique combination of IP address and port._

**This is the first and most fundamental flaw.**

Another two-fold flaw is that it uses TCP sessions for connecting to the login and character servers.

By default this means it uses IP addresses and not DNS, meaning it would be unable to pick a load balancer via DNS.

Additionally, neither of these scenarios require real-time communication, which means basic HTTP/S would have been a far better choice.


### rAthena

There are other factors rAthena has control over that could be modified to varying degrees of effect.

**_I will note that there aren't many private servers that have enough traffic to need true distribution or scalability, so these criticisms are within a microscopic view._**

The first is that the servers in rAthena are by-design "stateful".

That is to say, they rely on individual running instances to carry state.

This is rooted in the TCP session design used to establish and facilitate inter-service communication.

_Even if that method of registration and heartbeat are used, if the status was stored in a database we would be able to resolve at least one measure of distributed scalability._

The map server design for distributed scalability requires fully manual configuration.

This forces us to reboot the map servers after making changes, and is not responsive to actual user traffic.

_For example, if the population on each map server was used we could allow all map servers to handle any map, but choose which map server to send a user to based on the population plus other factors like keeping them on the same map servers as their party members.  We could also make map instances more intelligent by picking assumed maximum populations, allowing the system to automatically create and remove instances on demand._

Finally, each character server requires its own database.

> **_I believe it critical to point out that this is not a flaw.  The database is literally the only part of the system that cannot scale by adding more servers and is thus part of the critical path for performance._**


# conclusions

Again, these are weak criticisms made in hindsight of a project that is otherwise amazingly well built especially when you consider how long it has been in service.
