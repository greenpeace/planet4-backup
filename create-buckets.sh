#!/usr/bin/env bash
set -euo pipefail

if [ -z ${APP_ENVIRONMENT+x} ]; then
  APP_ENVIRONMENT="production"
fi

[[ ${APP_ENVIRONMENT} =~ production ]] || {
  echo "Non-prod environment: skipping database backup"
  exit 0
}

# shellcheck disable=SC1091
. /app/retry.sh

create_image_backup_bucket() {

  IMAGE_BACKUP_BUCKET_NAME=${WP_STATELESS_BUCKET}_images_backup
  gcloud storage ls --project "${GOOGLE_PROJECT_ID}" "gs://${IMAGE_BACKUP_BUCKET_NAME}" >/dev/null && return

  # Make image backup bucket if it doesn't exist

  echo " * gcs: Initialising WP Stateless bucket"
  echo
  echo " * gcs: Project: ${GOOGLE_PROJECT_ID}"
  echo " * gcs: Labels:"
  echo " * gcs:  - NRO:  ${APP_HOSTPATH}"
  echo " * gcs: Bucket:  gs://${IMAGE_BACKUP_BUCKET_NAME}"
  echo " * gcs: Region:  ${BACKUP_BUCKET_LOCATION}"
  echo " * Purpose: Backup of bucket:  gs://${WP_STATELESS_BUCKET}"


  gcloud storage buckets create --project "${GOOGLE_PROJECT_ID}" -l "${BACKUP_BUCKET_LOCATION}" "gs://${IMAGE_BACKUP_BUCKET_NAME}"

  # Apply labels to image backups bucket
  gcloud storage buckets update "gs://${IMAGE_BACKUP_BUCKET_NAME}" \
    --update-labels=app=planet4,environment=production,component=images_backup,nro="${APP_HOSTPATH}"

}


create_db_backup_bucket() {

  DB_BACKUP_BUCKET_NAME=${WP_STATELESS_BUCKET}_db_backup
  gcloud storage ls --project "${GOOGLE_PROJECT_ID}" "gs://${DB_BACKUP_BUCKET_NAME}" >/dev/null && return

  # Make image backup bucket if it doesn't exist
  if [ -z ${APP_ENVIRONMENT+x} ]; then
    APP_ENVIRONMENT="production"
  fi

  echo " * gcs: Initialising WP Stateless bucket"
  echo
  echo " * gcs: Project: ${GOOGLE_PROJECT_ID}"
  echo " * gcs: Labels:"
  echo " * gcs:  - NRO:  ${APP_HOSTPATH}"
  echo " * gcs: Bucket:  gs://${DB_BACKUP_BUCKET_NAME}"
  echo " * gcs: Region:  ${BACKUP_BUCKET_LOCATION}"
  echo " * Purpose: Backup of bucket:  gs://${WP_STATELESS_BUCKET}"


  gcloud storage buckets create --project "${GOOGLE_PROJECT_ID}" -l "${BACKUP_BUCKET_LOCATION}" "gs://${DB_BACKUP_BUCKET_NAME}"

  # Apply labels to image backups bucket
  gcloud storage buckets update "gs://${DB_BACKUP_BUCKET_NAME}" \
    --update-labels=app=planet4,environment=production,component=db_backup,nro="${APP_HOSTPATH}"

  # Allow versioning of database files (use storage versioning to keep multiple copies of the SQL!)
  gcloud storage buckets update "gs://${DB_BACKUP_BUCKET_NAME}" --versioning
  gcloud storage buckets update "gs://${DB_BACKUP_BUCKET_NAME}" --lifecycle-file=/app/lifecycle-db.json
}

# Set the normal images bucket to have versioning so that deleted images get retained
gcloud storage buckets update "gs://${WP_STATELESS_BUCKET}" --versioning

# Retrying here because gcloud is flaky, connection resets often
echo "Create GCS buckets to store backup data ..."
retry create_image_backup_bucket
retry create_db_backup_bucket
