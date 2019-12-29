# Alpine is a bit too extreme (it doesn't have /etc/localtime, no support for
# hostname -I, etc.).

FROM debian:stretch-slim

LABEL maintainer="Egor Tensin <Egor.Tensin@gmail.com>"

# Don't prompt:
ENV DEBIAN_FRONTEND=noninteractive

    # fr24feed dependencies:
RUN runtime_deps='ca-certificates procps' && \
    apt-get update -yq && \
    apt-get install -yq --no-install-recommends $runtime_deps

# Variables:
ARG FR24FEED_VERSION=1.0.24-7
ARG FR24FEED_ARCH=armhf

# Download fr24feed:
WORKDIR /tmp
ADD ["https://repo-feed.flightradar24.com/rpi_binaries/fr24feed_${FR24FEED_VERSION}_${FR24FEED_ARCH}.tgz", "./"]
RUN tar xzf fr24feed_${FR24FEED_VERSION}_${FR24FEED_ARCH}.tgz

# fr24feed config:
COPY ["fr24feed.ini", "/etc/"]

EXPOSE 8754

WORKDIR fr24feed_${FR24FEED_ARCH}
CMD ["./fr24feed"]
