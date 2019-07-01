#!/usr/bin/env bash
# shellcheck disable=SC1091
set -euo pipefail

echo "The BACKUP_SERVICE_KEY is ${BACKUP_SERVICE_KEY}"

echo "The BACKUP_PROJECT_ID is ${BACKUP_PROJECT_ID}"

./activate-service-account.sh

./init-gcs.sh
