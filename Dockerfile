FROM google/cloud-sdk:alpine

RUN echo "Hello"

WORKDIR /app

ENTRYPOINT ["/app/entrypoint.sh"]

CMD ["./go.sh"]

ARG BACKUP_SERVICE_KEY
ARG BACKUP_PROJECT_ID

ENV BACKUP_SERVICE_KEY_FILE="gcloud_service_key.json" \
  BACKUP_BUCKET_LOCATION="us"

COPY . /app
