# Use BuildKit, which is required:
export DOCKER_BUILDKIT = 1
# Enable buildx support:
export DOCKER_CLI_EXPERIMENTAL = enabled
# Enable BuildKit in docker-compose (requires 1.25.0 or higher):
export COMPOSE_DOCKER_CLI_BUILD = 1
# Target platforms (used by buildx):
platforms = linux/i386,linux/amd64,linux/armhf
# One of the latest (at the moment Compose versions) that supports BuildKit:
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

# Three kinds of builds:
# * docker build (for testing only),
# * docker-compose build (for testing only, Compose doesn't support buildx
# yet),
# * docker buildx (the right way for multiarch repos).
docker-build/%:
	docker build -t "$(DOCKER_USERNAME)/$*" "$*/"

docker-build: docker-build/dump1090 docker-build/fr24feed

compose-build:
	docker-compose build

buildx/%:
	docker buildx build -t "$(DOCKER_USERNAME)/$*" --platform "$(platforms)" "$*/"

buildx: buildx/dump1090 buildx/fr24feed

# buildx is used by default.
build: buildx

# Three kinds of pushes:
# * docker push (for testing only),
# * docker-compose push (for testing only, Compose doesn't support buildx and
# multiarch repos yet),
# * docker buildx --push (the right way for multiarch repos).
docker-push/%: docker-build/%
	docker push "$(DOCKER_USERNAME)/$*"

docker-push: docker-push/dump1090 docker-push/fr24feed

compose-push: compose-build
	docker-compose push

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

.PHONY: all login install-compose compose docker-build compose-build buildx build docker-push compose-push buildx-push push up down pull clean
