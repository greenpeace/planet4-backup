SHELL := /bin/bash

BUILD_NAMESPACE ?= greenpeaceinternational

SED_MATCH ?= [^a-zA-Z0-9._-]

ifeq ($(CIRCLECI),true)
# Configure build variables based on CircleCI environment vars
BUILD_NUM = $(CIRCLE_BUILD_NUM)
BRANCH_NAME ?= $(shell sed 's/$(SED_MATCH)/-/g' <<< "$(CIRCLE_BRANCH)")
BUILD_TAG ?= $(shell sed 's/$(SED_MATCH)/-/g' <<< "$(CIRCLE_TAG)")
else
# Not in CircleCI environment, try to set sane defaults
BUILD_NUM = local
BRANCH_NAME ?= $(shell git rev-parse --abbrev-ref HEAD | sed 's/$(SED_MATCH)/-/g')
BUILD_TAG ?= local-tag
endif

dev:
	docker build \
				-t $(BUILD_NAMESPACE)/planet4-backup:build-$(BUILD_NUM) \
				.
	docker run --rm \
	  -e BACKUP_BUCKET_NAME=${BACKUP_BUCKET_NAME} \
	  -e GOOGLE_PROJECT_ID=${BACKUP_PROJECT_ID} \
		-e WP_STATELESS_KEY=${BACKUP_SERVICE_KEY} \
		-e WP_STATELESS_BUCKET=planet4-koyansync-stateless-develop \
		-e CLOUDSQL_INSTANCE=p4-develop-k8s \
		-e WP_DB_NAME=planet4-koyansync_wordpress_develop \
		-e WP_DB_USERNAME=${WP_DB_USERNAME} \
		-e WP_DB_PASSWORD=${WP_DB_PASSWORD} \
		-e SQLPROXY_KEY=${SQLPROXY_KEY} \
		-e APP_HOSTPATH=koyansync \
		$(BUILD_NAMESPACE)/planet4-backup:build-local


build-tag:
	docker build \
				-t $(BUILD_NAMESPACE)/planet4-backup:build-$(BUILD_NUM) \
				-t $(BUILD_NAMESPACE)/planet4-backup:$(BUILD_TAG) \
				-t $(BUILD_NAMESPACE)/planet4-backup:latest \
				.

build-branch:
	docker build \
				-t $(BUILD_NAMESPACE)/planet4-backup:build-$(BUILD_NUM) \
				-t $(BUILD_NAMESPACE)/planet4-backup:$(BRANCH_NAME) \
				.

push-tag:
	docker push $(BUILD_NAMESPACE)/planet4-backup:build-$(BUILD_NUM)
	docker push $(BUILD_NAMESPACE)/planet4-backup:$(BUILD_TAG)
	docker push $(BUILD_NAMESPACE)/planet4-backup:latest

push-branch:
	docker push $(BUILD_NAMESPACE)/planet4-backup:build-$(BUILD_NUM)
	docker push $(BUILD_NAMESPACE)/planet4-backup:$(BRANCH_NAME)
