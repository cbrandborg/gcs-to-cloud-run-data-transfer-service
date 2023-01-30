PROJECT_ID=ok-devo-data-3102
PROJECT_NUM=$(gcloud projects describe ${PROJECT_ID} --format "value(projectNumber)")
CURRENT_USER=$(gcloud auth list --filter=status:ACTIVE --format="value(account)")
LOCATION=us-central1

gcloud config set project $PROJECT_ID

STORAGE_BUCKET=raw-landing-ok-dk
TOPIC=top-bkt-obj-readings
SUB=sub-bkt-obj-readings
ARTIFACT_REGISTRY=cloud-run-readings-transfers-demo
SERVICE_NAME=ok-readings-transfers-demo

RELEVANT_APIS=(artifactregistry.googleapis.com storage-component.googleapis.com pubsub.googleapis.com)

# Enabling APIs

for API in ${RELEVANT_APIS[@]}; do 
    gcloud services enable $API \
        --project=$PROJECT_ID

done

# Creating storage bucket
#gcloud storage buckets create gs://$STORAGE_BUCKET --location=$LOCATION

# Creating PubSub Topic
gcloud pubsub topics create $TOPIC \
    --project=$PROJECT_ID

# Delete current notifications
gcloud storage buckets notifications delete gs://raw-landing-ok-dk

# Create object finalize notifications
gcloud storage buckets notifications create gs://$STORAGE_BUCKET \
    --event-types=OBJECT_FINALIZE \
    --project=$PROJECT_ID \
    --topic=$TOPIC
    
# Create artifact registry
gcloud artifacts repositories create $ARTIFACT_REGISTRY \
    --repository-format=docker \
    --project=$PROJECT_ID \
    --location=$LOCATION \
    --description="Repository used Cloud Run data transfers from Cloud Storage bucket demo"

# Build docker image

cd nodejs-implementation

#cd c#-implementation/Run.Samples.Pubsub.MinimalApi

gcloud auth configure-docker us-central1-docker.pkg.dev

docker build . --tag $LOCATION-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REGISTRY/$SERVICE_NAME:latest

docker push $LOCATION-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REGISTRY/$SERVICE_NAME:latest

cd ..

# Deploy Cloud Run
gcloud run deploy cloudrun-${SERVICE_NAME} \
    --image $LOCATION-docker.pkg.dev/$PROJECT_ID/$ARTIFACT_REGISTRY/$SERVICE_NAME:latest \
    --project $PROJECT_ID \
    --region $LOCATION \
    --allow-unauthenticated

gcloud iam service-accounts create sa-ok-cr-pbs-invoker \
    --display-name "OK Cloud Run PubSub Invoker Service Account" \
    --project=$PROJECT_ID

gcloud run services add-iam-policy-binding cloudrun-${SERVICE_NAME} \
    --member=serviceAccount:sa-ok-cr-pbs-invoker@${PROJECT_ID}.iam.gserviceaccount.com \
    --role=roles/run.invoker \
    --region=$LOCATION

SERVICE_URL=$(gcloud run services describe cloudrun-${SERVICE_NAME} --region=${LOCATION} --format='value(status.address.url)')
echo $SERVICE_URL

# Create PubSub Subscription
gcloud pubsub subscriptions create $SUB --topic $TOPIC \
    --project=$PROJECT_ID \
    --ack-deadline=600 \
    --push-endpoint=$SERVICE_URL/ \
    --push-auth-service-account=sa-ok-cr-pbs-invoker@${PROJECT_ID}.iam.gserviceaccount.com
