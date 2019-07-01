#!/usr/bin/env bash
set -euo pipefail

# shellcheck disable=SC1091
. /app/retry.sh

create_backup_bucket() {
  # Make bucket if it doesn't exist
  BACKUP_BUCKET_NAME=${WP_STATELESS_BUCKET}_backup
  gsutil ls -p "${BACKUP_PROJECT_ID}" "gs://${BACKUP_BUCKET_NAME}" >/dev/null && return

  echo " * gcs: Initialising WP Stateless bucket"
  echo
  echo " * gcs: Project: ${BACKUP_PROJECT_ID}"
  echo " * gcs: Labels:"
  echo " * gcs:  - NRO:  ${APP_HOSTPATH}"
  echo " * gcs: Bucket:  gs://${BACKUP_BUCKET_NAME}"
  echo " * gcs: Region:  ${BACKUP_BUCKET_LOCATION}"
  echo " * Purpose: Backup of bucket:  gs://${WP_STATELESS_BUCKET}"


  gsutil mb -l "${BACKUP_BUCKET_LOCATION}" -p "${BACKUP_PROJECT_ID}" "gs://${BACKUP_BUCKET_NAME}"

  # Apply labels
  gsutil label ch \
    -l "app:planet4" \
    -l "app_environment:production" \
    -l "component:backup" \
    "gs://${BACKUP_BUCKET_NAME}"
}

# Retrying here because gsutil is flaky, connection resets often
echo "Create GCS bucket to store backup data ..."
retry create_backup_bucket
