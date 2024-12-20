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

* Edit dump1090/config.js to set the correct coordinates of the receiver.

      DefaultCenterLat = 66.5;
      DefaultCenterLon = 25.19;
      
      SiteShow    = true;
      SiteLat     = 66.5;
      SiteLon     = 25.19;
      SiteName    = "My receiver";

* Edit dump1090/supervisord.conf to set the correct coordinates of the receiver
in dump1090-fa's arguments (`--lat` and `--lon`).

      command=/usr/bin/dump1090-fa ... --lat 66.5 --lon 25.19 ...

Start the containers using

    docker-compose up -d

You can now access the interactive map at http://127.0.0.1:8080/dump1090-fa/
and the fr24feed web interface at http://127.0.0.1:8754/.

Stop the containers using

    docker-compose down

DVB-T dongles
-------------

They can be bought on eBay and AliExpress for a few dollars.
This is what they look like:

![DVB-T dongle example](doc/dongle.jpeg "DVB-T dongle")

You have to be careful not to buy the wrong one though.
All of them are equipped with tuners, some of which don't support the 1090 MHz
frequency.
I've made the mistake to buy dongles with the FC0012 tuner, which doesn't
support it.
In general, you'll see something like

    [FC0012] no valid PLL combination found for 1090000000 Hz!

in dump1090 container output if your dongle isn't supported.

Development
-----------

### Dependencies

* Docker with BuildKit support (18.09 or higher),

### Multiarch

Build & push multiarch images using

    make buildx/create
    make buildx/push
    make buildx/rm

A guide on how to set up multiarch builds can be found [here].
The goal was to have a single multiarch repo for each container in the
registry.
The approach is to use Docker's new BuildKit builder + the buildx command line
plugin.

Other possibilities are:
* use QEMU + multiarch base images directly ([1][1], [2][2]), and create a
manifest file manually,
* build natively on multiple architectures (not sure how to combine them in a
single manifest then though).

[here]: https://mirailabs.io/blog/multiarch-docker-with-buildx/
[1]: https://lobradov.github.io/Building-docker-multiarch-images/
[2]: https://ownyourbits.com/2018/06/27/running-and-building-arm-docker-containers-in-x86/

Sources
-------

* [dump1090]: ADS-B, Mode S, and Mode 3A/3C demodulator and decoder.
* [fr24feed]: Flightradar24 software to upload decoded data to their network.

[dump1090]: https://github.com/flightaware/dump1090
[fr24feed]: https://www.flightradar24.com/share-your-data
