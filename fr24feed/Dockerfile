# Alpine is a bit too extreme (it doesn't have /etc/localtime, no support for
# hostname -I, etc.).

FROM debian:stretch-slim AS base

# Those are weird hacks, but the alternative (using the apt repository) was
# unsuitable (no systemctl, etc.).

FROM base as base-386
ENV fr24feed_directory=linux_x86_binaries
ENV fr24feed_version=1.0.24-5
ENV fr24feed_archive_suffix=i386

FROM base AS base-amd64
ENV fr24feed_directory=linux_x86_64_binaries
ENV fr24feed_version=1.0.24-5
ENV fr24feed_archive_suffix=amd64

FROM base AS base-arm
ENV fr24feed_directory=rpi_binaries
ENV fr24feed_version=1.0.24-7
ENV fr24feed_archive_suffix=armhf

ARG TARGETARCH
FROM base-$TARGETARCH

LABEL maintainer="Egor Tensin <Egor.Tensin@gmail.com>"

ENV fr24feed_archive_name="fr24feed_${fr24feed_version}_${fr24feed_archive_suffix}.tgz"

# Don't prompt:
ENV DEBIAN_FRONTEND=noninteractive

    # fr24feed dependencies:
RUN runtime_deps='ca-certificates procps' && \
    apt-get update -yq && \
    apt-get install -yq --no-install-recommends $runtime_deps

WORKDIR /tmp
ADD ["https://repo-feed.flightradar24.com/$fr24feed_directory/$fr24feed_archive_name", "./"]
RUN tar xzf "$fr24feed_archive_name"

COPY ["fr24feed.ini", "/etc/"]

EXPOSE 8754

WORKDIR "fr24feed_${fr24feed_archive_suffix}"
CMD ["./fr24feed"]
