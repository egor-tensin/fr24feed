fr24feed in Docker
==================

[![CI](https://github.com/egor-tensin/fr24feed/actions/workflows/ci.yml/badge.svg)](https://github.com/egor-tensin/fr24feed/actions/workflows/ci.yml)

I'm tired of keeping track of all the hacks I needed to introduce to my Arch
Linux installation on my Raspberry Pi to get fr24feed running, so here's a
Docker configuration.

Usage
-----

* Type in your sharing key in fr24feed/fr24feed.ini.

      fr24key="0123456789abcdef"

* Optionally, edit dump1090/config.js to set the correct coordinates of the
receiver.

      DefaultCenterLat = 66.5;
      DefaultCenterLon = 25.19;
      
      SiteShow    = true;
      SiteLat     = 66.5;
      SiteLon     = 25.19;
      SiteName    = "My receiver";

* Optionally, edit dump1090/supervisord.conf to set the correct coordinates of
the receiver in dump1090-fa's arguments (`--lat` and `--lon`).

      command=/usr/bin/dump1090-fa ... --lat 66.5 --lon 25.19 ...

Start the containers using

    make pull && make up

You can now access the interactive map at http://127.0.0.1:8080/dump1090-fa/
and the fr24feed web interface at http://127.0.0.1:8754/.

Stop the containers using

    make down

Development
-----------

TL;DR: build the native images using

    make compose/build

Or, if you have Compose version 1.24.x or below,

    make docker/build

### Dependencies

* Docker with BuildKit support (18.09 or higher),
* Compose with BuildKit support for `compose/build` (1.25.0 or higher).

### CI

I used a guide to set up multiarch builds ([1][1]).
I don't understand it completely at the moment, but whatever.

The goal is to have a single multiarch repo on Docker Hub for each of the
services.
The approach is to use Docker's new BuildKit builder + the buildx command line
plugin.

Other possibilities are:
* use QEMU + multiarch base images directly ([2][2], [3][3]), and create a
manifest file manually,
* build natively on multiple architectures (not sure how to combine them in a
single manifest then though).

The disadvantages of the approach taken are:
* newer Docker version is required,
* docker-compose doesn't seem to support that method natively.

[1]: https://mirailabs.io/blog/multiarch-docker-with-buildx/
[2]: https://lobradov.github.io/Building-docker-multiarch-images/
[3]: https://ownyourbits.com/2018/06/27/running-and-building-arm-docker-containers-in-x86/

Sources
-------

* [dump1090]: ADS-B, Mode S, and Mode 3A/3C demodulator and decoder.
* [fr24feed]: Flightradar24 software to upload decoded data to their network.

[dump1090]: https://github.com/flightaware/dump1090
[fr24feed]: https://www.flightradar24.com/share-your-data
