SHELL := /bin/bash

dev:
	docker build -t backuptest1 .
	docker run --rm \
	  -e BACKUP_BUCKET_NAME=${BACKUP_BUCKET_NAME} \
	  -e BACKUP_PROJECT_ID=${BACKUP_PROJECT_ID} \
		-e BACKUP_SERVICE_KEY=${BACKUP_SERVICE_KEY} \
		-e WP_STATELESS_BUCKET=planet4-koyansync-stateless-develop \
		-e APP_HOSTPATH=koyansync \
		backuptest1
