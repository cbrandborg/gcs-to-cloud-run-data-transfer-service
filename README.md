# Cloud Storage to BigQuery table - Cloud Run service demo
### Cloud Run service using a Node JS webserver to handle PubSub messages triggered by pushing an object to a Cloud Storage Bucket

## Setting up Cloud Run

## Prerequisites
1. Authenticate with Google Cloud using 'gcloud auth login'
2. Create project in console
3. Set the following permissions for the user:
- roles/artifactregistry.admin
- roles/resourcemanager.projectIamAdmin
- roles/run.admin
- roles/pubsub.admin
- roles/iam.serviceAccountAdmin
- roles/iam.serviceAccountUser
- roles/serviceusage.serviceUsageAdmin
- roles/storage.admin
- roles/logging.admin

## Fill in the following environment values in prerequisites.sh
- PROJECT_ID - Your project ID in GCP
- STORAGE_BUCKET - The storage bucket name you wish to use
- TOPIC - Name of PubSub Topic to be created
- SUB - Name of PubSub Subscription to be created
- ARTIFACT_REGISTRY - Name the registry you wish to create or use
- SERVICE_NAME - Name of Cloud Run service to be created

## Run prerequisites.sh to create infrastructure contained in service
- `. prerequisites.sh`

## Fill in the following environment values in push_object.sh and run to trigger service
- PROJECT_ID - Your project ID in GCP
- STORAGE_BUCKET - The storage bucket name you wish to use
- Run push_object.sh to trigger service: `. push_object.sh`

## Documentation used to construct this demo:
- [Using PubSub with Cloud Run](https://cloud.google.com/run/docs/tutorials/pubsub#run_pubsub_build-nodejs)
- [Loading data into BigQuery from Cloud Storage](https://cloud.google.com/bigquery/docs/loading-data-cloud-storage-csv)
- [Using PubSub Notifications](https://cloud.google.com/storage/docs/pubsub-notifications)