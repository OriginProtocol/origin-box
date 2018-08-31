#!/bin/bash

set -e

if [ "$TRAVIS_BRANCH" == "master" ]; then
    NAMESPACE = "development"
elif [ "$TRAVIS_BRANCH" == "stable" ]; then
    NAMESPACE = "staging"
fi

docker build -t gcr.io/${PROJECT_NAME}/${NAMESPACE}/${DOCKER_IMAGE_NAME}:$TRAVIS_COMMIT .

echo $GCLOUD_SERVICE_KEYG | base64 --decode -i > ${HOME}/gcloud-service-key.json
gcloud auth activate-service-account --key-file ${HOME}/gcloud-service-key.json

gcloud --quiet config set project $PROJECT_NAME
gcloud --quiet config set container/cluster $CLUSTER_NAME
gcloud --quiet config set compute/zone ${CLOUDSDK_COMPUTE_ZONE}
gcloud --quiet container clusters get-credentials $CLUSTER_NAME

gcloud docker push gcr.io/${PROJECT_NAME}/${NAMESPACE}/${DOCKER_IMAGE_NAME}

yes | gcloud beta container images add-tag gcr.io/${PROJECT_NAME}/${NAMESPACE}/${DOCKER_IMAGE_NAME}:$TRAVIS_COMMIT gcr.io/${PROJECT_NAME}/${NAMESPACE}/${DOCKER_IMAGE_NAME}:latest

kubectl config view
kubectl config current-context

kubectl set image deployment/${KUBE_DEPLOYMENT_NAME} ${KUBE_DEPLOYMENT_CONTAINER_NAME}=gcr.io/${PROJECT_NAME}/${NAMESPACE}/${DOCKER_IMAGE_NAME}:$TRAVIS_COMMIT --namespace=${NAMESPACE}

kubectl rollout status deployment/${KUBE_DEPLOYMENT_NAME}

# Discord webhook

# Deployed a new container for ${KUBE_DEPLOYMENT_NAME} (${TRAVIS_COMMIT_HASH}) to the ${NAMESPACE} environment
