#!/bin/sh
set -euo pipefail

file=${1:-/app/${BACKUP_SERVICE_KEY_FILE}}

[ -n "$WP_STATELESS_KEY" ] && {
  # BACKUP is set in environment variable
  echo "${WP_STATELESS_KEY}" | base64 -d > "$file"
}

pwd
ls -l /app/

[ ! -e "$file" ] && {
  # BACKUP gcloud service account key file not found
  >&2 echo "ERROR: $file not found"
  exit 1
}

# The working project id may different to the key project_id
if [ -z "${BACKUP_PROJECT_ID:-}" ]
then
  # Default to projectID defined in service account json
  >&2 echo "WARNING: BACKUP_PROJECT_ID not set, reading from file"
  BACKUP_PROJECT_ID=$(jq -r .project_id "$file")
fi

# Authenticate
gcloud auth activate-service-account --key-file "$file"

# Set working project
gcloud config set project "${BACKUP_PROJECT_ID}"
