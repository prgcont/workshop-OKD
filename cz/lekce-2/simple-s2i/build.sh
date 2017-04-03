#!/bin/bash

DOCKER_REGISTRY=$(oc get svc/docker-registry -n default -o yaml | grep clusterIP: | awk '{print $2}')
PROJECT_NAME=$(for a in `pwd | tr "/" " "`; do echo $a; done | tail -n 1)

docker build -t ${PROJECT_NAME}:latest .
echo "Nazev projektu: $PROJECT_NAME"
echo "Docker registry: $DOCKER_REGISTRY"


if [[ !  -z $DOCKER_REGISTRY ]]; then

TOKEN=$(oc whoami -t)
docker login --username=miloslav.vlach -p $TOKEN --email=miloslav.vlach@rohlik.cz $DOCKER_REGISTRY:5000 
docker tag ${PROJECT_NAME}:latest $DOCKER_REGISTRY:5000/openshift/${PROJECT_NAME}:latest
docker push $DOCKER_REGISTRY:5000/openshift/${PROJECT_NAME}:latest
oc tag $DOCKER_REGISTRY:5000/openshift/${PROJECT_NAME}:latest ${PROJECT_NAME}:latest --insecure=true

fi
