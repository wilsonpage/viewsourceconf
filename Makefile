VERSION := $(shell git describe --tags --exact-match 2>/dev/null || echo latest)
REGISTRY ?= quay.io/
IMAGE_PREFIX ?= mozmar
IMAGE_NAME ?= viewsourceconf
IMAGE := ${REGISTRY}${IMAGE_PREFIX}/${IMAGE_NAME}\:${VERSION}
BUILD_IMAGE_NAME ?= ${IMAGE_NAME}_build
BUILD_IMAGE := ${REGISTRY}${IMAGE_PREFIX}/${BUILD_IMAGE_NAME}\:${VERSION}
WATCH_PORT ?= 8080
SERVE_PORT ?= 8000
MOUNT_DIR ?= $(shell pwd)
APP_DIR ?= /app
DOCKER_RUN_ARGS ?= -v ${MOUNT_DIR}\:${APP_DIR} -w ${APP_DIR}
HOST_IP ?= $(shell docker-machine ip || echo 127.0.0.1)

.PHONY: build watch

build:
	docker run ${DOCKER_RUN_ARGS} ${BUILD_IMAGE} node build

watch:
	docker run ${DOCKER_RUN_ARGS} -p "${WATCH_PORT}:${WATCH_PORT}" ${BUILD_IMAGE} node watch 

build-build-image:
	docker build -f Dockerfile-build -t ${BUILD_IMAGE} .

push-build-image:
	docker push ${BUILD_IMAGE}

build-deploy-image:
	docker build -t ${IMAGE} .

push-deploy-image:
	docker push ${IMAGE}

serve:
	docker run -p "${SERVE_PORT}:80" ${IMAGE}

curl:
	curl -H "X-Forwarded-Proto: https" ${HOST_IP}:${SERVE_PORT}
