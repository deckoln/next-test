#!bin/bash
ENVIRONMENT=$1

if [ $ENVIRONMENT = "local" ]; then
    echo "Building for development."
    PROJECT_ID="infinitalk-dev"
    SERVICE_NAME="social-tech-list-dialer"
    TAG_NAME="latest"
    ENV_FILE_PATH="development.yaml"
    VPC_CONNECTOR_NAME="vpc-infinitalk-cloud-1"
    REGION="us-central1"
    MEMORY="2Gi"
    CPU="2"
    CONCURRENCY="1"
    MIN_INSTANCES="1"
    SERVICE_ACCOUNT="cloudrun-service@infinitalk-dev.iam.gserviceaccount.com"
elif [ $ENVIRONMENT = "dev" ]; then
    echo "Building for development."
    PROJECT_ID="$PROJECT_ID"
    SERVICE_NAME="social-tech-list-dialer"
    TAG_NAME="latest"
    ENV_FILE_PATH="development.yaml"
    VPC_CONNECTOR_NAME="vpc-infinitalk-cloud-1"
    REGION="us-central1"
    MEMORY="2Gi"
    CPU="2"
    CONCURRENCY="1"
    MIN_INSTANCES="1"
    SERVICE_ACCOUNT="cloudrun-service@infinitalk-dev.iam.gserviceaccount.com"
elif [ $ENVIRONMENT = "prod" ]; then
    echo "Building for production."
else
    echo "Invalid environment. Please use either 'dev' or 'prod'."
    exit 1
fi

## gcloud config
if [ $ENVIRONMENT != "local" ]; then
    echo "$GOOGLE_CREDENTIAL_KEY_DEVELOP" > credentials-key.json
    gcloud auth activate-service-account --key-file credentials-key.json
    gcloud config set project $PROJECT_ID
    gcloud config set compute/region $REGION
fi

## Build and deploy
IMAGE_NAME="gcr.io/$PROJECT_ID/$SERVICE_NAME:$TAG_NAME"

VPC_CONNECTOR="projects/$PROJECT_ID/locations/$REGION/connectors/$VPC_CONNECTOR_NAME"

gcloud builds submit --tag=$IMAGE_NAME .
gcloud run deploy $SERVICE_NAME \
    --execution-environment gen2 \
    --allow-unauthenticated \
    --service-account=$SERVICE_ACCOUNT \
    --image $IMAGE_NAME \
    --region=$REGION \
    --vpc-connector=$VPC_CONNECTOR \
    --memory=$MEMORY \
    --cpu=$CPU \
    --concurrency=$CONCURRENCY \
    --min-instances=$MIN_INSTANCES