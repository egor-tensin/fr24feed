FROM debian:stretch-slim

LABEL maintainer="Egor Tensin <Egor.Tensin@gmail.com>"

WORKDIR /tmp

# Variables:
ARG DUMP1090_VERSION=3.7.2
ARG DUMP1090_ARCH=armhf

# Don't prompt:
ENV DEBIAN_FRONTEND=noninteractive

# Build and install the dump1090-fa package:
ADD ["https://github.com/flightaware/dump1090/archive/v${DUMP1090_VERSION}.tar.gz", "./dump1090-${DUMP1090_VERSION}.tar.gz"]

    # dump1090 dependencies (from README at https://github.com/flightaware/dump1090):
RUN build_deps='build-essential debhelper librtlsdr-dev pkg-config dh-systemd libncurses5-dev libbladerf-dev' && \
    # dump1090-fa runtime dependencies:
    runtime_deps='librtlsdr0 libncurses5 libbladerf1' && \
    # Supervisor to run both dump1090-fa and lighttpd:
    supervisor='supervisor' && \
    apt-get update -yq && \
    apt-get install -yq --no-install-recommends $build_deps $runtime_deps $supervisor && \
    tar xzf dump1090-${DUMP1090_VERSION}.tar.gz && \
    cd -- dump1090-${DUMP1090_VERSION} && \
    dpkg-buildpackage -b && \
    dpkg-buildpackage -Tclean && \
    cd -- .. && \
    apt-get install -yq ./dump1090-fa_${DUMP1090_VERSION}_${DUMP1090_ARCH}.deb && \
    rm -rf -- dump1090-${DUMP1090_VERSION}.tar.gz dump1090-${DUMP1090_VERSION}/ && \
    find . -mindepth 1 -maxdepth 1 -type f -\( -name '*.buildinfo' -o -name '*.changes' -o -name '*.deb' -\) -delete && \
    apt-get purge -yq --auto-remove -o APT::AutoRemove::RecommendsImportant=false $build_deps

# Create the /run/dump1090-fa directory, typically created by systemd:
RUN mkdir --mode=0755 /run/dump1090-fa

# Config files:
COPY ["config.js", "/usr/share/dump1090-fa/html/"]
COPY ["supervisord.conf", "/etc/supervisor/conf.d/"]

EXPOSE 80 30001 30002 30003 30004 30005 30104

CMD ["/usr/bin/supervisord", "--configuration=/etc/supervisor/conf.d/supervisord.conf"]
