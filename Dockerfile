FROM google/cloud-sdk:alpine

RUN echo "Hello"

WORKDIR /app

ENTRYPOINT ["/app/entrypoint.sh"]

CMD ["./go.sh"]

ARG BUCKET_NAME
ARG BACKUP_SERVICE_KEY
ARG BACKUP_PROJECT_ID
ARG BUCKET_NAME
ARG BUCKET_NAME

ENV BACKUP_SERVICE_KEY_FILE="gcloud_service_key.json"

COPY . /app
