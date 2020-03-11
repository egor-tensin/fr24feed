FROM debian:stretch-slim AS builder

# Don't prompt:
ENV DEBIAN_FRONTEND=noninteractive

# Variables:
ARG DUMP1090_VERSION=3.8.0
ENV DUMP1090_VERSION="${DUMP1090_VERSION}"

WORKDIR /tmp

# Build the dump1090-fa package:
ADD ["https://github.com/flightaware/dump1090/archive/v${DUMP1090_VERSION}.tar.gz", "./dump1090-${DUMP1090_VERSION}.tar.gz"]

    # dump1090 build dependencies (from README at https://github.com/flightaware/dump1090/blob/v3.7.2/README.md):
RUN build_deps='build-essential debhelper librtlsdr-dev pkg-config dh-systemd libncurses5-dev libbladerf-dev' && \
    apt-get update -yq && \
    apt-get install -yq --no-install-recommends $build_deps && \
    tar xzf dump1090-${DUMP1090_VERSION}.tar.gz && \
    cd -- dump1090-${DUMP1090_VERSION} && \
    dpkg-buildpackage -b && \
    cd -- .. && \
    dump1090_arch="$( dpkg --print-architecture )" && \
    mv -- dump1090-fa_${DUMP1090_VERSION}_${dump1090_arch}.deb dump1090-fa.deb

FROM debian:stretch-slim

LABEL maintainer="Egor Tensin <Egor.Tensin@gmail.com>"

# Don't prompt:
ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /tmp

COPY --from=builder ["/tmp/dump1090-fa.deb", "./"]

RUN apt-get update -yq && \
    # Supervisor to run both dump1090-fa and lighttpd:
    # lighty-enable-mod depends on Term/ReadLine.pm, which isn't listed as a
    # dependency, which is a bug:
    apt-get install -yq --no-install-recommends supervisor libterm-readline-gnu-perl && \
    apt-get install -yq ./dump1090-fa.deb && \
    rm -- ./dump1090-fa.deb

# Create the /run/dump1090-fa directory, typically created by systemd:
RUN mkdir --mode=0755 /run/dump1090-fa

# Config files:
COPY ["config.js", "/usr/share/dump1090-fa/html/"]
COPY ["supervisord.conf", "/etc/supervisor/conf.d/"]

EXPOSE 80 30001 30002 30003 30004 30005 30104

CMD ["/usr/bin/supervisord", "--configuration=/etc/supervisor/conf.d/supervisord.conf"]
