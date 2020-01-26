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

login:
ifndef DOCKER_PASSWORD
	$(error Please define DOCKER_PASSWORD)
endif
	@echo "$(DOCKER_PASSWORD)" | docker login --username "$(DOCKER_USERNAME)" --password-stdin

# Quickly install a newer Compose version:
install-compose:
	curl -L "https://github.com/docker/compose/releases/download/$(compose_version)/docker-compose-$$(uname -s)-$$(uname -m)" -o /usr/local/bin/docker-compose
	chmod +x /usr/local/bin/docker-compose

compose: install-compose

# Re-register binfmt_misc formats with the F flag (required i.e. on Bionic):
fix-binfmt:
	docker run --rm --privileged docker/binfmt:66f9012c56a8316f9244ffd7622d7c21c1f6f28d

binfmt: fix-binfmt

# `docker build` has week support for multiarch repos (you need to use multiple
# Dockerfile's, create a manifest manually, etc.), so it's only here for
# testing purposes, and native builds.
docker-build/%:
	docker build -t "$(DOCKER_USERNAME)/$*" "$*/"

docker-build: docker-build/dump1090 docker-build/fr24feed

# `docker-compose build` has the same problems as `docker build`.
compose-build:
	docker-compose build

# The simple way to build multiarch repos.
builder/create: fix-binfmt
	docker buildx create --use --name "$(PROJECT)_builder"

builder/rm:
	docker buildx rm "$(PROJECT)_builder"

buildx/%:
	docker buildx build -t "$(DOCKER_USERNAME)/$*" --platform "$(platforms)" "$*/"

buildx: buildx/dump1090 buildx/fr24feed

# buildx is used by default.
build: buildx

# `docker push` would replace the multiarch repo with a single image by default
# (you'd have to create a manifest and push it instead), so it's only here for
# testing purposes.
docker-push/%: docker-build/%
	docker push "$(DOCKER_USERNAME)/$*"

docker-push: docker-push/dump1090 docker-push/fr24feed

# `docker-compose push` has the same problems as `docker push`.
compose-push: compose-build
	docker-compose push

# The simple way to push multiarch repos.
buildx-push/%:
	docker buildx build -t "$(DOCKER_USERNAME)/$*" --platform "$(platforms)" --push "$*/"

buildx-push: buildx-push/dump1090 buildx-push/fr24feed

# buildx is used by default.
push: buildx-push

up:
	docker-compose up -d

down:
	docker-compose down --volumes

pull:
	docker-compose pull

clean:
	docker system prune --all --force --volumes

.PHONY: all login install-compose compose fix-binfmt binfmt docker-build compose-build builder/create builder/rm buildx build docker-push compose-push buildx-push push up down pull clean
