UID ?= $(shell id -u)
GID ?= $(shell id -g)

IMAGE_NAME ?= helix-appimage:latest

.PHONY: build

build:
	docker build --build-arg UUID=$(UID) --build-arg UGID=$(GID) -t $(IMAGE_NAME) .
