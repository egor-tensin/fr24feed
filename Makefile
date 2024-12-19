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
build: buildx/build

.PHONY: push
push: buildx/push

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
