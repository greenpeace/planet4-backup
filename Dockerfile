FROM google/cloud-sdk:alpine

RUN echo "Hello"

RUN gcloud --quiet components update cloud_sql_proxy

RUN apk add --no-cache mysql-client gzip

WORKDIR /app

ENTRYPOINT ["/app/entrypoint.sh"]

CMD ["./go.sh"]

ARG WP_STATELESS_KEY
ARG BACKUP_PROJECT_ID

ENV BACKUP_SERVICE_KEY_FILE="gcloud_service_key.json" \
  BACKUP_BUCKET_LOCATION="us"

COPY . /app
