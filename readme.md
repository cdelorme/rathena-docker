
# [rathena-docker](https://github.com/cdelorme/rathena-docker)

This is a wrapper I created because I wanted to quickly startup a local copy of rathena I can toy around with and not a heavyweight production deployment.

_This means that instead of standing up each server as an independent container we just have two; one for the database and one for `athena-start` (which runs all 4 servers)._

Tweak the `configs/` to your preference.

_Avoid editing the sections under the `// required` heading without being aware of what that will do._

Run `docker-compose up`.

If you want to wipe the server just run `docker-compose down`.

_If you need to edit the build you can modify the `Dockerfile` or `docker-compose.yml` as needed._


## notes

I am aware of `tools/docker/` in [rathena](https://github.com/rathena/rathena).  While a container per server is the "correct" way to implement a production server environment, the dependency management is lacking.  The services crash before the database is online and loaded.  It still loads the entire sql directory rather than just `main.sql`, `logs.sql`, and `web.sql`.  The builder needs to finish or the binaries won't exist, and if they were build by the host then it may not be compatible if the container image differs.  Overall it's rather finicky and my goal was not a distributed production setup but a rudimentary isolated abstraction.

There does not appear to be a way to "health check" the rathena servers, or at the very least I am unaware of such behavior and cannot find it in the wiki.  This means container health management and subsequently dependency chain control isn't possible.  Since the order each server is launched in matters, as they each connect to another, and all of them connect to the database, you'd need a checklist like this:

- Is the database online?
	- Load the main.sql, logs.sql, and web.sql
- Is the database loaded?
	- launch the map-server
	- launch the web-server
- Is the map-server online?
	- launch the char-server
- Is the char-server online?
	- launch the login-server

_While you can still specify `depends_on`, without a `healthcheck`, it only knows whether the parent process id is running and not whether a system is loaded or ready to receive traffic._

Finally, `docker-compose` does not provide a way to preemptively build a base image and then reuse that multiple times.

This means you need a queer abstraction layer to build the image and either be discarded (eg. `builder`) or that runs one of the servers, and the others then use the same image or share mounted source.

_While it may be possible to overcome these problems with heavy scripting and some sort of tcp-connectivity-test, it would not be simple or clean._

Finally, to create four separate containers means each has a copy of an entire operating systems worth of files, and an additional network layer, all of which adds complexity and overhead.

_While that overhead and complexity may better reflect a proper production deployment, it is entirely unnecessary for local development and tinkering._

For these reasons I chose to just run all services using the `athena-start` script inside a single container.

_Currently a full build in isolation with an alpine linux container takes about 5 minutes._


## network

Docker containers have their own private network layer which makes it exceedingly complex to support both inter-service communication, as well as expose a functional public facing address.

This is why the `configs/` have a mixture of `127.0.0.1` and the container names (eg. `db` and `rathena`).

While then host system may map traffic to an exposed port off `127.0.0.1`, the container's network does not share those same rules and may need some private address.

Inside the container these names will resolve to those private addresses, but they can't be used by the host.

_This has an extra layer of abstraction when working on a windows of mac operating system, which run docker inside of a virtual machine, meaning two layers of abstracted networking._

So, unless you are familiar with the networking behavior it would be best not to modify the addresses defined in the configuration files.


### database

As a result of poor design choices, mysql/mariadb do not behave with docker networking.

The problem:

> I want to connect to mariadb using a client from the host, and the port mapping should work from localhost, but using localhost causes the client to try to connect to the literal host machines socket, and using 127.0.0.1 simply fails.

The solution is to get the container IP address like this:

	docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' <id>

This behavior is not like most other modern databases and seems to stem from poor design choices layered across time, but something like postgres will map to localhost no problem.  _Maybe someday we can hope for a postgres option with rathena?_

**For this reason I have chosen not to port map the database from docker-compose, which means the database is effectively "private".**

An alternative method of accessing the database without exposing the port is to connect to the container first:

	docker-compose exec db bash
	mysql $MARIADB_DATABASE -u$MARIADB_USER -p$MARIADB_PASSWORD


## client

The client side is pretty whimsical for a number of reasons.

The download process is often unclear.

Older clients can fail due to compatibility issues with the latest map files.

_A from the rathena forum user Akkarin that shares zipped downloads from both 2021 and 2022 mentioned the compatibility issue for older clients with the 2022 files, but it was not clear whether that problem would still occur if they ran the rsu patcher in the 2021 zip, which one would assume replaces/updates the files._

Additionally the rsu patcher at some point became a single binary rather than one for renewal and one for pre-renewal.

Finally, Nemo was abandoned, and later forked to gitlab.

The `http://nemo.herc.ws` site provides client downloads and references the gitlab fork, but is sketchy as it doesn't have https support.

An alternative fork called Warp was launched and seems to be more actively maintained.

Finally, I ran into my own set of problems as a result of being a linux-only user, which means using wine to launch the game.

While this had worked for me in the past, both with a 2015 client and a 2018 client, the latest was crashing.  In the end I got it working using lutris by adding a game manually a version of proton-ge.  This could be a wine issue or a dxvk issue, but it's hard to tell because I tried setting the prefix and using different versions of lutris wine by modifying my `PATH` environment variable, but the same issue kept happening.  It also happened after reaching and interacting with the game with a character, which suggested it wasn't a render issue, but turns out the wine logs had some memory error.

Anyways, I'm probably not qualified to share any guide or documentation as an authoritative source, but I'll give it a shot regardless.

I downloaded all of these:

- [Latest official kRO installer](http://rofull.gnjoy.com/RAG_SETUP_220120.exe)
- [OpenSetup](https://nn.ai4rei.net/dev/opensetup/)
- [rsu patcher](https://nn.ai4rei.net/dev/rsu/)
- [llchrisll's ROenglishRE files](https://github.com/llchrisll/ROenglishRE)
- [Nemo's python script to grab the 2021-11-03_Ragexe_1635926200 client](http://nemo.herc.ws/downloads/2021-11-03_Ragexe_1635926200/)
- [Warp](https://github.com/Neo-Mind/WARP)


Start by running the official installer to install the game.

Next download `opensetup` and the rsu patcher and add them to the game folder.

Run the rsu patcher.

Run opensetup to configure the window dimensions and any other visual and audio settings.

Next you can download the translation files from llchrisll's repository, and merge/overwrite the `data/` and `System/` directories.

Finally, download the client from the `nemo.herc.ws` website.

_As I understand it, based on conversations in discord, there are no differences between RagexeRE and Ragexe anymore._

_I have included a container in this project that downloads the 2021-11-03 client by running the python2 (which is no longer supported and thus not included in some operating system package managers) in isolation, which is also the current default packetver in rathena, and thus can be safely considered as "compatible"._

The client needs to be hexed, so we download Warp and run it.

I have included a [profile.log](profile.log) that you can load, but here is a summary of the changes if you want to try them manually:

- Apply Recommended
- Override the lua/lub file names to match what was in the translation `System/` directory
- Read from the data folder direct, to ensure the translations are used
- A variety of quality-of-life changes

Finally, add the patched exe into the game directory.

**_If you are running windows, from here you can just run the game._**

> For linux I launched lutris, downloaded a recent version of lutris-wine-proton-ge, and added a game manually, giving it a wine prefix path to isolate it, and setting the executable and launch directory.  I had some additional issues with multiple monitors where my preferred display wouldn't render updates (eg. looked like a frozen screen but I could still interact with it and hear BGM & sounds).  To resolve that I set a virtual desktop and changed the client to run in fullscreen.


## bugs

- Lots of conflicting documentation on using SQL, I tried with `use_sql_db: yes` but got infinite yml errors
	- Turns out the modern approach is to use the yml files rather than the sql, and I set `use_sql_db: no` and only loaded `main.sql`, `logs.sql`, and `web.sql` and no more issues!
- The `web-server` runs but returns a 404 when accessed from `http://localhost:8888`
	- According to what little documentation I could find this is mostly used to deliver animated guild emblems and isn't a management server, so this may not be a bug but "working as intended"
- I tried half a dozen clients with both Nemo and Warp which worked up until logging in with a character and even interacting with the map before crashing after a few seconds
	- Unsure of why this is but maybe a system library is broken since I managed to resolve this by using lutris to create a bottle with a proton-ge version


## future

I could add a directory that gets rsync'd or diff'd over the rathena source, which would allow the inclusion of custom files or patches to replace the source.

I may add more detailed steps regarding Warp, but for now I think a brief overview and a profile that can be loaded would suffice.

I may switch from merging llchrisll's directories to using a grf editor to wrap things up.  _This seems like it would be more helpful if adding custom resources, but comes at the cost of needing to repackage anytime you change the rathena address._


# references

Useful downloads:

- [OpenSetup](https://nn.ai4rei.net/dev/opensetup/)
- [rsu patcher](https://nn.ai4rei.net/dev/rsu/)
- [Latest official kRO installer](http://rofull.gnjoy.com/RAG_SETUP_220120.exe)
- [llchrisll's ROenglishRE files](https://github.com/llchrisll/ROenglishRE)
- [Unsecured Nemo Host](http://nemo.herc.ws/)
- [Warp](https://github.com/Neo-Mind/WARP)

Helpful documentation and alternative downloads:

- [Akkarin shared pre-packaged kRO 2021 & 2022 zips](https://rathena.org/board/topic/106413-kro-full-client-2022-07-21-includes-bgm-rsu/)
- [[Tutorial] Creating an Open-source Ragnarok Online Server with kRO & OpenKore Support](https://rathena.org/board/topic/130574-tutorial-creating-an-open-source-ragnarok-online-server-with-kro-openkore-support/#comment-408059)
- [[ Guide ] Setting Up 2020 Client & Adding Customs Items!](https://rathena.org/board/topic/126859-guide-setting-up-2020-client-adding-customs-items/)
