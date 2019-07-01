#!/usr/bin/env bash
# shellcheck disable=SC1091
set -euo pipefail

. /app/retry.sh

echo "The BACKUP_SERVICE_KEY is ${BACKUP_SERVICE_KEY}"

echo "The BACKUP_PROJECT_ID is ${BACKUP_PROJECT_ID}"

./activate-service-account.sh

./create-buckets.sh

./backup-db.sh


backup_images() {
  echo "here we would do the actual sync. Commented it out for speedness of testing"
  #gsutil rsync -d -r -m gs://"${WP_STATELESS_BUCKET}" gs://"${WP_STATELESS_BUCKET}_images_backup"
}

retry backup_images
