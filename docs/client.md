
# client

**This document will describe how to setup a client for this project.**

Unfortunately for private servers establishing a client is still a mess.

While numerous custom clients are in the works none have been truly adopted.

_This is likely due to rAthena wanting to ensure compatibility with the official client and remain in parity._

As such we still use the hexed official client with translations.


## requirements

Let's begin by describing the components we need:

- [Translations Courtesy of zackdreaver](https://github.com/zackdreaver)
- [NEMO Client Hexer](https://gitlab.com/4144/Nemo)

Next let's review each of these and verify any restrictions.

If we look at the translations, the [latest officially supported client version is `20180621A`](https://github.com/zackdreaver/ROenglishRE/blob/master/Doc/Compatibility%20list.md).

There are [loads of issues](https://gitlab.com/4144/Nemo/issues?state=opened) for hexing the 2019 client, but only one for the 2018 client, meaning the 2018 version is by far more compatible.

**Conclusions:**

While the linked discussions recommend the 2018 client, they provide no clarification as to why.

Many forum threads will also suggest that the latest rAthena supported version is `2018-06-21A`.

_Doing this simple research step helps explain a lot._


## setup

**I will document setting up RE, as I have never setup non-RE before.**

Download the [latest kRO](https://rathena.org/board/topic/106413-kro-full-client-2019-02-25-includes-bgm-rsu/).

_This contains the official files to patch and run the game._

Extract the contents then run the appropriate patcher (`rsu-kro-renewal-lite.exe` or for pre-re `rsu-kro-rag-lite.exe`).

Download the [translations](https://github.com/zackdreaver/ROenglishRE) and copy into the kRO game folder.

Modify `data/sclientinfo.xml` by setting `<langtype>1</langtype>` and `<address>172.16.24.4</address>`.

Download a [compatible `RagexeRE.exe` client](http://nemo.herc.ws/downloads/2018-06-21aRagexe/).

Download [NEMO](https://gitlab.com/4144/Nemo.git).

Launch `NEMO.exe`, load the client, and click "Select Recommended".

You can ignore the error regarding `CallKoreaClientInfo()` failing to apply; this is a known non-critical bug.

**When prompted, enter `itemInfo_true_V5.lua` so that the client uses the correct translation file, and read the data folder first will ensure it uses the updated grf files for the interface UI (eg. buttons etc).**

This is my recommended set of patches:

- 9 Disable 1rag1 type parameters (Recommended)
- 10 Disable 4 Letter Character Name Limit
- 11 Disable 4 Letter User Name Limit
- 12 Disable 4 Letter Password Limit
- 13 Disable Ragexe Filename Check (Recommended)
- 16 Disable Swear Filter
- 20 Extend Chat Box
- 22 Extend PM Box
- 23 Enable /who command (Recommended)
- 24 Fix Camera Angles (Recommended)
- 32 Increase Zoom Out Max
- 290 Hide build info in client (Recommended)
- 34 Enable /showname (Recommended)
- 291 Hide packets from peek (Recommended)
- 35 Read Data Folder First
- 36 Read msgstringtable.txt (Recommended)
- 38 Remove Gravity Ads (Recommended)
- 39 Remove Gravity Logo (Recommended)
- 40 Restore Login Window (Recommended)
- 41 Disable Nagle Algorithm (Recommended)
- 44 Translate Client (Recommended)
- 46 Use Normal Guild Brackets (Recommended)
- 47 Use Ragnarok Icon
- 48 Use Plain Text Descriptions (Recommended)
- 49 Enable Multiple GRFs (Recommended)
- 53 Use Ascii on All LangTypes (Recommended)
- 64 @ Bug Fix (Recommended)
- 65 Load Custom lua file instead of iteminfo*.lub (Recommended)
- 67 Disable Quake skill effect
- 73 Remove Hourly Announce (Recommended)
- 84 Remove Serial Display (Recommended)
- 90 Enable DNS Support (Recommended)
- 91 Disconnect to Login Window
- 97 Cancel to Login Window (Recommended)
- 207 Resize Font
- 213 Disable Help Message on Login (Recommended)
- 215 Increase Map Quality

Click "Apply Patches" and it will produce a new executable.

Copy the patched executable into the game folder.

**If all went according to plan, you should now have a working client!**

> In a real world build scenario you would want to take the data folder contents and create a new grf using the [GRF Editor](https://rathena.org/board/files/file/2766-grf-editor/).  Then you can add your new file to the top of `DATA.ini`, eliminating the need for the `Read Data Folder First` setting.  _It is also possible to encrypt the file to mitigate tampering._


### configuration

The default settings for Ragnarok Online may not be optimal, and if you run `Setup.exe` you may notice it's unreadable.

Fortunately, [RO OpenSetup](http://nn.ai4rei.net/dev/opensetup/) exists to provide a readable confiuration tool.

_Sadly I did not have good luck with this tool as it only offered 16 bit depth for graphical settings._


### wine

Since I use linux I have the pleasure of another layer of complexity when I run windows applications.

**Fortunately, the latest versions of wine and a default 64 bit prefix work out of the box.**


### robrowser

If you are dealing with a pre-renewal setup you might be able to use robrowser instead of hexing a client.

Someday I hope to document that process, and maybe even add it to the docker compose setup.


## notes

I found a few things of interest that might help explain some previous bugs.

In Zach's Q&A one of the questions mentions the ciatura academy maps are black and unwalkable, which as it turns out I encountered way back in 2015.  Apparently rAthena had been using the old long-deleted maps, which he provided a Mega download link to, but it would be better if rAthena had an update to use the newer maps instead.


# references

- [kRO](https://rathena.org/board/topic/106413-kro-full-client-2019-02-25-includes-bgm-rsu/)
- [Clients](http://nemo.herc.ws/clients/)
- [NEMO](https://gitlab.com/4144/Nemo.git)
- [zackdreaver RO translations](https://github.com/zackdreaver)
- [RO OpenSetup](http://nn.ai4rei.net/dev/opensetup/)
- [Download Link](https://drive.google.com/file/d/16VhFbvirHAmiQbiUde7oLE1XPcu1DSsi/view)
- [Download Link](https://mega.nz/#!Zcdk2C4L!z9SkS36VGhJWAaxD9cRf1sVhgC9I6gMm0k6Cld-lYOQ)
- [Download Discussion](https://rathena.org/board/topic/117168-packetver-20180620-client-release-2018-06-20eragexere/)
- [2019 client discussion](https://rathena.org/board/topic/120601-how-creating-client/)
- [2018 client guide](https://rathena.org/board/topic/114177-tutorial-how-to-create-server-client-2018-step-by-step-debian-linux/)
- [Officially Supported Client Versions](https://rathena.org/board/topic/86650-officially-supported-client-versions/)
- [roBrowser for Pre-RE](https://github.com/vthibault/roBrowser/)
- [GRF Editor](https://rathena.org/board/files/file/2766-grf-editor/)
