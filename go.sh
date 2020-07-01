#!/usr/bin/env bash
# shellcheck disable=SC1091
set -euo pipefail

. /app/retry.sh

# echo "The WP_STATELESS_KEY is ${WP_STATELESS_KEY}"

echo "The GOOGLE_PROJECT_ID is ${GOOGLE_PROJECT_ID}"

./activate-service-account.sh

./create-buckets.sh

./backup-db.sh


backup_images() {
  echo "Here we will do actual sync from ${WP_STATELESS_BUCKET} to ${WP_STATELESS_BUCKET}_images_backup"
  # If you work locally and you want to speed your testing comment the following line
  gsutil -m rsync -d -r gs://"${WP_STATELESS_BUCKET}" gs://"${WP_STATELESS_BUCKET}_images_backup"
}

retry backup_images
