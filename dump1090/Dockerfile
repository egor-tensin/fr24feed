FROM debian:stretch

LABEL maintainer="Egor Tensin <Egor.Tensin@gmail.com>"

# Don't prompt:
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -yq && apt-get dist-upgrade -yq

# Install dependencies (from README at https://github.com/flightaware/dump1090):
RUN apt-get install -yq build-essential debhelper librtlsdr-dev pkg-config dh-systemd libncurses5-dev libbladerf-dev

# Install Supervisor to run both lighttpd and dump1090:
RUN apt-get install -yq supervisor

# Build and install the dump1090-fa package:
WORKDIR /tmp

# Variables:
ARG DUMP1090_VERSION=3.7.2
ARG DUMP1090_ARCH=armhf

ADD ["https://github.com/flightaware/dump1090/archive/v${DUMP1090_VERSION}.tar.gz", "./dump1090-${DUMP1090_VERSION}.tar.gz"]

RUN tar xzf dump1090-${DUMP1090_VERSION}.tar.gz && \
    cd dump1090-${DUMP1090_VERSION} && \
    dpkg-buildpackage -b && \
    dpkg-buildpackage -Tclean && \
    apt-get install -yq ../dump1090-fa_${DUMP1090_VERSION}_${DUMP1090_ARCH}.deb

# Create the /run/dump1090-fa directory, typically created by systemd:
RUN mkdir --mode=0755 /run/dump1090-fa

# Config files:
COPY ["config.js", "/usr/share/dump1090-fa/html/"]
COPY ["supervisord.conf", "/etc/supervisor/conf.d/"]

EXPOSE 80 30001 30002 30003 30004 30005 30104

CMD ["/usr/bin/supervisord", "--configuration=/etc/supervisor/conf.d/supervisord.conf"]
