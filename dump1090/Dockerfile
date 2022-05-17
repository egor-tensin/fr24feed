FROM debian:bullseye-slim AS builder

# Variables:
ARG DUMP1090_VERSION=7.2

WORKDIR /tmp

    # dump1090 build dependencies (from README at https://github.com/flightaware/dump1090/blob/v7.2/README.md):
RUN build_deps='build-essential fakeroot debhelper librtlsdr-dev pkg-config libncurses5-dev libbladerf-dev libhackrf-dev liblimesuite-dev' && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
        apt-get install -y --no-install-recommends $build_deps

ADD ["https://github.com/flightaware/dump1090/archive/v${DUMP1090_VERSION}.tar.gz", "./dump1090-${DUMP1090_VERSION}.tar.gz"]

RUN tar xzf "dump1090-$DUMP1090_VERSION.tar.gz" && \
    cd -- "dump1090-$DUMP1090_VERSION" && \
    ./prepare-build.sh bullseye && \
    cd package-bullseye && \
    dpkg-buildpackage -b --no-sign && \
    dump1090_arch="$( dpkg --print-architecture )" && \
    cp -- "../dump1090-fa_${DUMP1090_VERSION}_${dump1090_arch}.deb" /tmp/dump1090-fa.deb

FROM debian:bullseye-slim

LABEL maintainer="Egor Tensin <Egor.Tensin@gmail.com>"

WORKDIR /tmp

COPY --from=builder ["/tmp/dump1090-fa.deb", "./"]

RUN apt-get update && \
    # Supervisor to run both dump1090-fa and lighttpd:
    # lighty-enable-mod depends on Term/ReadLine.pm, which isn't listed as a
    # dependency, which is a bug:
    DEBIAN_FRONTEND=noninteractive \
        apt-get install -y --no-install-recommends supervisor libterm-readline-gnu-perl && \
    DEBIAN_FRONTEND=noninteractive \
        apt-get install -y ./dump1090-fa.deb && \
    rm -- ./dump1090-fa.deb

# Create the /run/dump1090-fa directory, typically created by systemd:
RUN mkdir --mode=0755 /run/dump1090-fa

# Config files:
COPY ["config.js", "/usr/share/dump1090-fa/html/"]
COPY ["supervisord.conf", "/etc/supervisor/conf.d/"]

EXPOSE 80 30001 30002 30003 30004 30005 30104

CMD ["/usr/bin/supervisord", "--configuration=/etc/supervisor/conf.d/supervisord.conf"]
