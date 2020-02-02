# Various one-liners which I'm too lazy to remember.
# Basically a collection of really small shell scripts.

MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
.SUFFIXES:

PROJECT = fr24feed
# Use BuildKit, which is required:
export DOCKER_BUILDKIT = 1
# Enable buildx support:
export DOCKER_CLI_EXPERIMENTAL = enabled
# Enable BuildKit in docker-compose (requires 1.25.0 or higher):
export COMPOSE_DOCKER_CLI_BUILD = 1
# Target platforms (used by buildx):
platforms = linux/i386,linux/amd64,linux/armhf
# One of the latest (at the moment) Compose versions that supports BuildKit:
compose_version = 1.25.3
# Docker Hub credentials:
DOCKER_USERNAME = egortensin

all: build

DO:

login:
ifndef DOCKER_PASSWORD
	$(error Please define DOCKER_PASSWORD)
endif
	@echo "$(DOCKER_PASSWORD)" | docker login --username "$(DOCKER_USERNAME)" --password-stdin

# Build natively by default.
build: compose/build

clean:
	docker system prune --all --force --volumes

# Push multi-arch images by default.
push: buildx/push

pull:
	docker-compose pull

up:
	docker-compose up -d

down:
	docker-compose down --volumes

check-build:
ifndef FORCE
	$(warning Going to build natively; consider `docker buildx build` instead)
endif

check-push:
ifndef FORCE
	$(error Please use `docker buildx build --push` instead)
endif

# `docker build` has week support for multiarch repos (you need to use multiple
# Dockerfile's, create a manifest manually, etc.), so it's only here for
# testing purposes, and native builds.
docker/build/%: DO check-build
	docker build -t "$(DOCKER_USERNAME)/$*" "$*/"

docker/build: docker/build/dump1090 docker/build/fr24feed

# `docker push` would replace the multiarch repo with a single image by default
# (you'd have to create a manifest and push it instead), so it's only here for
# testing purposes.
docker/push/%: DO check-push docker/build/%
	docker push "$(DOCKER_USERNAME)/$*"

docker/push: check-push docker/push/dump1090 docker/push/fr24feed

# Quickly install a newer Compose version:
compose/install:
	curl -L "https://github.com/docker/compose/releases/download/$(compose_version)/docker-compose-$$(uname -s)-$$(uname -m)" -o /usr/local/bin/docker-compose
	chmod +x /usr/local/bin/docker-compose

# `docker-compose build` has the same problems as `docker build`.
compose/build: check-build
	docker-compose build

# `docker-compose push` has the same problems as `docker push`.
compose/push: check-push compose/build
	docker-compose push

# The simple way to build multiarch repos is `docker buildx`.

# Re-register binfmt_misc formats with the F flag (required i.e. on Bionic):
fix-binfmt:
	docker run --rm --privileged docker/binfmt:66f9012c56a8316f9244ffd7622d7c21c1f6f28d

buildx/create: fix-binfmt
	docker buildx create --use --name "$(PROJECT)_builder"

buildx/rm:
	docker buildx rm "$(PROJECT)_builder"

buildx/build/%: DO
	docker buildx build -t "$(DOCKER_USERNAME)/$*" --platform "$(platforms)" "$*/"

buildx/build: buildx/build/dump1090 buildx/build/fr24feed

buildx/push/%: DO
	docker buildx build -t "$(DOCKER_USERNAME)/$*" --platform "$(platforms)" --push "$*/"

buildx/push: buildx/push/dump1090 buildx/push/fr24feed

.PHONY: all login build clean push pull up down
.PHONY: check-build check-push
.PHONY: docker/build docker/push
.PHONY: compose/install compose/build compose/push
.PHONY: fix-binfmt buildx/create buildx/rm buildx/build buildx/push
