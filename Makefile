ROOT:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

IMAGE_NAME:=jenkins4eval/slave
IMAGE_NAME_AGENT:=jenkins4eval/agent

.PHONY: build
build: build-alpine build-debian build-jdk11

build-alpine:
	docker build -t ${IMAGE_NAME}:alpine -t ${IMAGE_NAME_AGENT}:alpine --file Dockerfile-alpine .

build-debian:
	docker build -t ${IMAGE_NAME}:test -t ${IMAGE_NAME_AGENT}:test --file Dockerfile .

build-jdk11:
	docker build -t ${IMAGE_NAME}:jdk11  -t ${IMAGE_NAME_AGENT}:jdk11 --file Dockerfile-jdk11 .


bats:
# The lastest version is v1.1.0
	@if [ ! -d bats-core ]; then git clone https://github.com/bats-core/bats-core.git; fi
	@git -C bats-core reset --hard c706d1470dd1376687776bbe985ac22d09780327

.PHONY: test
test: test-alpine test-debian test-jdk11

.PHONY: test-alpine
test-alpine: bats
	@FLAVOR=alpine bats-core/bin/bats tests/tests.bats

.PHONY: test-debian
test-debian: bats
	@bats-core/bin/bats tests/tests.bats

.PHONY: test-jdk11
test-jdk11: bats
	@FLAVOR=jdk11 bats-core/bin/bats tests/tests.bats
