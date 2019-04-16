# set key and authenticate gcloud
echo $MYANDELA_GCLOUD_SERVICE_KEY | base64 --decode > ${HOME}/gcloud-service-key.json
sudo /opt/google-cloud-sdk/bin/gcloud auth activate-service-account --key-file ${HOME}/gcloud-service-key.json

# configure gcloud
sudo /opt/google-cloud-sdk/bin/gcloud --quiet config set project $MYANDELA_PROJECT_NAME
sudo /opt/google-cloud-sdk/bin/gcloud --quiet config set container/cluster $MYANDELA_CLUSTER_NAME
sudo /opt/google-cloud-sdk/bin/gcloud --quiet config set compute/zone ${MYANDELA_CLOUDSDK_COMPUTE_ZONE}
sudo /opt/google-cloud-sdk/bin/gcloud --quiet container clusters get-credentials $MYANDELA_CLUSTER_NAME

sudo apt-get install -y python-pip

# delete targetEnvironment values and generate cron.yaml file
sed '/targetEnvironment/d' template.cron.yaml > cron.yaml

mkdir lib
pip install -t lib -r requirements.txt
gcloud app --quiet deploy --version=1 cron.yaml app.yaml
