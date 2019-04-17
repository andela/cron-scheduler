# set key and authenticate gcloud
echo $CRON_PROJECT_GCLOUD_SERVICE_KEY | base64 --decode > ${HOME}/gcloud-service-key.json
sudo /opt/google-cloud-sdk/bin/gcloud auth activate-service-account --key-file ${HOME}/gcloud-service-key.json

# configure gcloud
sudo /opt/google-cloud-sdk/bin/gcloud --quiet config set project $CRON_PROJECT_NAME

sudo apt-get install -y python-pip

mkdir lib
pip install -t lib -r requirements.txt
pip install PyYAML
python -m pip install tornado
chmod +x pre_deploy.py
# delete targetEnvironment values and generate cron.yaml file
./pre_deploy.py
gcloud app --quiet deploy --version=$CIRCLE_BUILD_NUM cron.yaml app.yaml
