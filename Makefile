# Various one-liners which I'm too lazy to remember.
# Basically a collection of really small shell scripts.

MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
.SUFFIXES:

PROJECT := fr24feed
# Use BuildKit, which is required:
export DOCKER_BUILDKIT := 1
# Enable buildx support:
export DOCKER_CLI_EXPERIMENTAL := enabled
# Enable BuildKit in docker-compose (requires 1.25.0 or higher):
export COMPOSE_DOCKER_CLI_BUILD := 1
# Target platforms (used by buildx):
PLATFORMS := linux/i386,linux/amd64,linux/armhf
# One of the latest (at the moment) Compose versions that supports BuildKit:
COMPOSE_VERSION := 1.25.3
# In case buildx isn't installed (e.g. on Ubuntu):
BUILDX_VERSION := v0.4.2
# Docker Hub credentials:
DOCKER_USERNAME := egortensin

curl := curl --silent --show-error --location --dump-header - --connect-timeout 20

.PHONY: all
all: build

.PHONY: DO
DO:

.PHONY: login
login:
ifndef DOCKER_PASSWORD
	$(error Please define DOCKER_PASSWORD)
endif
	@echo "$(DOCKER_PASSWORD)" | docker login --username "$(DOCKER_USERNAME)" --password-stdin

.PHONY: build
# Build natively by default.
build: compose/build

.PHONY: clean
clean:
	docker system prune --all --force --volumes

.PHONY: push
# Push multi-arch images by default.
push: buildx/push

.PHONY: pull
pull:
	docker-compose pull

.PHONY: up
up:
	docker-compose up -d

.PHONY: down
down:
	docker-compose down --volumes

.PHONY: check-build
check-build:
ifndef FORCE
	$(warning Going to build natively; consider `docker buildx build` instead)
endif

.PHONY: check-push
check-push:
ifndef FORCE
	$(error Please use `docker buildx build --push` instead)
endif

# `docker build` has week support for multiarch repos (you need to use multiple
# Dockerfile's, create a manifest manually, etc.), so it's only here for
# testing purposes, and native builds.
docker/build/%: DO check-build
	docker build -t "$(DOCKER_USERNAME)/$*" "$*/"

.PHONY: docker/build
docker/build: docker/build/dump1090 docker/build/fr24feed

# `docker push` would replace the multiarch repo with a single image by default
# (you'd have to create a manifest and push it instead), so it's only here for
# testing purposes.
docker/push/%: DO check-push docker/build/%
	docker push "$(DOCKER_USERNAME)/$*"

.PHONY: docker/push
docker/push: check-push docker/push/dump1090 docker/push/fr24feed

.PHONY: compose/install
# Quickly install a newer Compose version:
compose/install:
	$(curl) --output /usr/local/bin/docker-compose -- "https://github.com/docker/compose/releases/download/$(COMPOSE_VERSION)/docker-compose-$$(uname -s)-$$(uname -m)"
	chmod +x -- /usr/local/bin/docker-compose

.PHONY: compose/build
# `docker-compose build` has the same problems as `docker build`.
compose/build: check-build
	docker-compose build

.PHONY: compose/push
# `docker-compose push` has the same problems as `docker push`.
compose/push: check-push compose/build
	docker-compose push

# The simple way to build multiarch repos is `docker buildx`.

.PHONY: fix-binfmt
# Re-register binfmt_misc formats with the F flag (required e.g. on Bionic):
fix-binfmt:
	docker run --rm --privileged docker/binfmt:66f9012c56a8316f9244ffd7622d7c21c1f6f28d

.PHONY: buildx/install
buildx/install:
	mkdir -p -- ~/.docker/cli-plugins/
	$(curl) --output ~/.docker/cli-plugins/docker-buildx -- 'https://github.com/docker/buildx/releases/download/$(BUILDX_VERSION)/buildx-$(BUILDX_VERSION).linux-amd64'
	chmod +x -- ~/.docker/cli-plugins/docker-buildx

.PHONY: buildx/create
buildx/create: fix-binfmt
	docker buildx create --use --name "$(PROJECT)_builder"

.PHONY: buildx/rm
buildx/rm:
	docker buildx rm "$(PROJECT)_builder"

buildx/build/%: DO
	docker buildx build -t "$(DOCKER_USERNAME)/$*" --platform "$(PLATFORMS)" "$*/"

.PHONY: buildx/build
buildx/build: buildx/build/dump1090 buildx/build/fr24feed

buildx/push/%: DO
	docker buildx build -t "$(DOCKER_USERNAME)/$*" --platform "$(PLATFORMS)" --push "$*/"

.PHONY: buildx/push
buildx/push: buildx/push/dump1090 buildx/push/fr24feed
