SHELL := /bin/bash

dev:
	docker build -t backuptest1 .
	docker run --rm \
	  -e BACKUP_BUCKET_NAME=${BACKUP_BUCKET_NAME} \
	  -e BACKUP_PROJECT_ID=${BACKUP_PROJECT_ID} \
		-e BACKUP_SERVICE_KEY=${BACKUP_SERVICE_KEY} \
		-e WP_STATELESS_BUCKET=planet4-koyansync-stateless-develop \
		-e CLOUDSQL_INSTANCE=p4-develop-k8s \
		-e WP_DB_NAME=planet4-koyansync_wordpress_develop \
		-e WP_DB_USERNAME=${WP_DB_USERNAME} \
		-e WP_DB_PASSWORD=${WP_DB_PASSWORD} \
		-e SQLPROXY_KEY=${SQLPROXY_KEY} \
		-e APP_HOSTPATH=koyansync \
		backuptest1
