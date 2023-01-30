PROJECT_ID=ok-devo-data-3102
STORAGE_BUCKET=raw-landing-ok-dk

gcloud storage cp readings.csv gs://$STORAGE_BUCKET \
    --project=$PROJECT_ID