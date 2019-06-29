SHELL := /bin/bash

dev:
	docker build -t backuptest1 .
	docker run --rm \
	  -e BUCKET_NAME=${BUCKET_NAME} \
	  -e BACKUP_PROJECT_ID=${BACKUP_PROJECT_ID} \
		-e BACKUP_SERVICE_KEY=${BACKUP_SERVICE_KEY} \
		backuptest1
