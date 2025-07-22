#!/bin/bash

CONTAINER_NAME=flask-ci-cd
IMAGE_NAME=thepm002/docker_ci-cd_test:$(date +%Y-%m-%d)

# Stop and remove old container if it exists
docker stop $CONTAINER_NAME && docker rm $CONTAINER_NAME || true

# Log in to Docker Hub (use secrets in GitHub later)
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin

# Pull new image
docker pull $IMAGE_NAME

# Run container
docker run -d --name $CONTAINER_NAME -p 80:5000 $IMAGE_NAME
