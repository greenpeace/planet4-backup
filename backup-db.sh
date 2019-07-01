#!/usr/bin/env bash
set -euo pipefail

function finish {
  # Stop background jobs
  kill "$(jobs -p)"
}

echo $SQLPROXY_KEY | base64 -d > /app/key.json

WP_DB_USERNAME_DC=$(echo "${WP_DB_USERNAME}" | base64 -d)
WP_DB_PASSWORD_DC=$(echo "${WP_DB_PASSWORD}" | base64 -d)
BUCKET_DESTINATION=gs://${WP_STATELESS_BUCKET}_db_backup
export GOOGLE_APPLICATION_CREDENTIALS="/app/key.json"

echo ""
echo "We will try to get connected to: ${BACKUP_PROJECT_ID}:us-central1:${CLOUDSQL_INSTANCE}"
echo ""

trap finish EXIT
cloud_sql_proxy \
  -instances="${BACKUP_PROJECT_ID}:us-central1:${CLOUDSQL_INSTANCE}=tcp:3306" &

mkdir -p content

sleep 2

echo ""
echo "mysqldump ${WP_DB_NAME} > content/${WP_DB_NAME}-db-backup.sql ..."
echo ""
mysqldump -v \
  -u "$WP_DB_USERNAME_DC" \
  -p"$WP_DB_PASSWORD_DC" \
  -h 127.0.0.1 \
  "${WP_DB_NAME}" > "content/${WP_DB_NAME}-db-backup.sql"

echo ""
echo "gzip ..."
echo ""
gzip "content/${WP_DB_NAME}-db-backup.sql"
gzip --test "content/${WP_DB_NAME}-db-backup.sql.gz"


echo ""
echo "uploading to ${BUCKET_DESTINATION}/..."
echo ""
gsutil cp "content/${WP_DB_NAME}-db-backup.sql.gz" "${BUCKET_DESTINATION}/"

gsutil ls "${BUCKET_DESTINATION}/"
