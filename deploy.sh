
if [ "$CIRCLE_BRANCH" == 'master' ] || [ "$CIRCLE_BRANCH" == 'v2-master' ] || ! [ -z "$CIRCLE_TAG" ]; then
  DEPLOYMENT_ENVIRONMENT=$DEPLOYMENT_ENVIRONMENT
  GCLOUD_SERVICE_KEY=$GCLOUD_SERVICE_KEY
  PROJECT_NAME=$PROJECT_NAME
  CLUSTER_NAME=$CLUSTER_NAME
  CLOUDSDK_COMPUTE_ZONE=$CLOUDSDK_COMPUTE_ZONE
  DEPLOYMENT_CHANNEL="#deploy-staging"
fi

# set key and authenticate gcloud
echo $GCLOUD_SERVICE_KEY | base64 --decode > ${HOME}/gcloud-service-key.json
sudo /opt/google-cloud-sdk/bin/gcloud auth activate-service-account --key-file ${HOME}/gcloud-service-key.json

# configure gcloud
sudo /opt/google-cloud-sdk/bin/gcloud --quiet config set project $PROJECT_NAME
sudo /opt/google-cloud-sdk/bin/gcloud --quiet config set container/cluster $CLUSTER_NAME
sudo /opt/google-cloud-sdk/bin/gcloud --quiet config set compute/zone ${CLOUDSDK_COMPUTE_ZONE}
sudo /opt/google-cloud-sdk/bin/gcloud --quiet container clusters get-credentials $CLUSTER_NAME

sudo apt-get install -y python-pip

mkdir lib
pip install -t lib -r requirements.txt
gcloud app --quiet deploy --version=1 cron.yaml app.yaml

