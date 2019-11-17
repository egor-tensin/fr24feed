fr24feed in Docker
==================

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

    docker-compose pull && docker-compose up -d

You can now access the interactive map at http://0.0.0.0:8080/dump1090-fa/ and
the fr24feed web interface at http://0.0.0.0:8754/.

Stop the containers using

    docker-compose down -v

Development
-----------

Build the images using

    docker-compose build --force-rm
