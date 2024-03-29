include prelude.mk

.PHONY: DO
DO:

PROJECT := fr24feed
# Target platforms (used by buildx):
PLATFORMS := i386,amd64,arm64
# Docker Hub credentials:
DOCKER_USERNAME := egortensin
# This is still required with older Compose versions to use TARGETARCH:
export DOCKER_BUILDKIT := 1

ifdef DOCKER_PASSWORD
$(eval $(call noexpand,DOCKER_PASSWORD))
endif

.PHONY: all
all: build

.PHONY: login
login:
ifndef DOCKER_PASSWORD
	$(error Please define DOCKER_PASSWORD)
endif
	@echo '$(call escape,$(DOCKER_PASSWORD))' \
		| docker login --username '$(call escape,$(DOCKER_USERNAME))' --password-stdin

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

.PHONY: compose/build
# `docker-compose build` has week support for multiarch repos (you need to use
# multiple Dockerfile's, create a manifest manually, etc.), so it's only here
# for testing purposes, and native builds.
compose/build: check-build
	docker-compose build --progress plain

.PHONY: compose/push
# `docker-compose push` would replace the multiarch repo with a single image by
# default (you'd have to create a manifest and push it instead), so it's only
# here for testing purposes.
compose/push: check-push compose/build
	docker-compose push

.PHONY: buildx/create
buildx/create:
	docker buildx create --use --name '$(call escape,$(PROJECT))_builder'

.PHONY: buildx/rm
buildx/rm:
	docker buildx rm '$(call escape,$(PROJECT))_builder'

buildx/build/%: DO
	docker buildx build \
		-t '$(call escape,$(DOCKER_USERNAME))/$*' \
		--platform '$(call escape,$(PLATFORMS))' \
		--progress plain \
		'$*/'

.PHONY: buildx/build
buildx/build: buildx/build/dump1090 buildx/build/fr24feed

buildx/push/%: DO
	docker buildx build \
		-t '$(call escape,$(DOCKER_USERNAME))/$*' \
		--platform '$(call escape,$(PLATFORMS))' \
		--progress plain \
		--push \
		'$*/'

.PHONY: buildx/push
buildx/push: buildx/push/dump1090 buildx/push/fr24feed
