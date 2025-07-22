#!/bin/bash

# ====== CONFIG ======
CONTAINER_NAME=flask-ci-cd
IMAGE_NAME=thepm002/docker_ci-cd_test:$TAG  # TAG is passed from GitHub Actions
# ====================

echo "🔍 Checking for containers using port 80..."
CONTAINER_ON_PORT_80=$(docker ps -q --filter "publish=80")

if [ ! -z "$CONTAINER_ON_PORT_80" ]; then
  echo "⚠️ Port 80 is in use by container: $CONTAINER_ON_PORT_80"
  echo "🛑 Stopping and removing container using port 80..."
  docker stop $CONTAINER_ON_PORT_80
  docker rm $CONTAINER_ON_PORT_80
fi

echo "🛑 Stopping old container (if exists): $CONTAINER_NAME"
docker stop $CONTAINER_NAME || true

echo "🗑️ Removing old container (if exists): $CONTAINER_NAME"
docker rm $CONTAINER_NAME || true

echo "🔐 Logging in to Docker Hub..."
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin

echo "📦 Pulling image: $IMAGE_NAME"
docker pull $IMAGE_NAME

echo "🚀 Running new container: $CONTAINER_NAME"
docker run -d --name $CONTAINER_NAME -p 80:5000 $IMAGE_NAME

echo "✅ Deployment complete!"
