MAKEFLAGS += --no-builtin-rules --no-builtin-variables --warn-undefined-variables
unexport MAKEFLAGS
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c

escape = $(subst ','\'',$(1))

define noexpand
ifeq ($$(origin $(1)),environment)
    $(1) := $$(value $(1))
endif
ifeq ($$(origin $(1)),environment override)
    $(1) := $$(value $(1))
endif
ifeq ($$(origin $(1)),command line)
    override $(1) := $$(value $(1))
endif
endef

.PHONY: DO
DO:

PROJECT := fr24feed
# Target platforms (used by buildx):
PLATFORMS := linux/i386,linux/amd64,linux/armhf
# Docker Hub credentials:
DOCKER_USERNAME := egortensin
# Use BuildKit, which is required (i.e. for using variables in FROM):
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
	@echo '$(call escape,$(DOCKER_PASSWORD))' | docker login --username '$(call escape,$(DOCKER_USERNAME))' --password-stdin

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
	docker-compose build

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
	docker buildx build -t '$(call escape,$(DOCKER_USERNAME))/$*' --platform '$(call escape,$(PLATFORMS))' '$*/'

.PHONY: buildx/build
buildx/build: buildx/build/dump1090 buildx/build/fr24feed

buildx/push/%: DO
	docker buildx build -t '$(call escape,$(DOCKER_USERNAME))/$*' --platform '$(call escape,$(PLATFORMS))' --push '$*/'

.PHONY: buildx/push
buildx/push: buildx/push/dump1090 buildx/push/fr24feed
