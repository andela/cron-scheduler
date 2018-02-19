
if [ "$CIRCLE_BRANCH" == 'master' ] || [ "$CIRCLE_BRANCH" == 'v2-master' ] || ! [ -z "$CIRCLE_TAG" ]; then
  DEPLOYMENT_ENVIRONMENT="production"
  GCLOUD_SERVICE_KEY=$GCLOUD_SERVICE_KEY_PROD
  PROJECT_NAME=$PROJECT_NAME_PROD
  CLUSTER_NAME=$CLUSTER_NAME_PROD
  CLOUDSDK_COMPUTE_ZONE=$CLOUDSDK_COMPUTE_ZONE_PROD
  DEPLOYMENT_CHANNEL="#deploy-prod"
fi

# set key and authenticate gcloud
echo $GCLOUD_SERVICE_KEY | base64 --decode > ${HOME}/gcloud-service-key.json
sudo /opt/google-cloud-sdk/bin/gcloud auth activate-service-account --key-file ${HOME}/gcloud-service-key.json

# configure gcloud
sudo /opt/google-cloud-sdk/bin/gcloud --quiet config set project $PROJECT_NAME
sudo /opt/google-cloud-sdk/bin/gcloud --quiet config set container/cluster $CLUSTER_NAME
sudo /opt/google-cloud-sdk/bin/gcloud --quiet config set compute/zone ${CLOUDSDK_COMPUTE_ZONE}
sudo /opt/google-cloud-sdk/bin/gcloud --quiet container clusters get-credentials $CLUSTER_NAME

gcloud app --quiet deploy cron.yaml app.yaml