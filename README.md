
# 🚀 Flask CI/CD App Deployed to DigitalOcean via GitHub Actions

This project demonstrates a fully automated CI/CD pipeline for deploying a Dockerized Flask web application to a **DigitalOcean Droplet**, using **GitHub Actions** for automation and **Docker Hub** for image storage.


## 📦 Features

- ✅ Simple Flask web app
- ✅ Dockerized and pushed to Docker Hub
- ✅ GitHub Actions CI/CD pipeline:
  - Auto build + image tagging
  - Auto push to Docker Hub
  - Auto SSH deployment to DigitalOcean
- ✅ Auto-redeploys on every push to `main`
- ✅ Logs and test output viewable in GitHub Actions
- ✅ `/about` route added for testing deployment changes


## 🛠 Tech Stack

| Tool             | Purpose                                |
|------------------|----------------------------------------|
| Flask            | Web application framework              |
| Docker           | Containerization                       |
| Docker Hub       | Image registry                         |
| GitHub Actions   | CI/CD automation                       |
| DigitalOcean     | Deployment target (Ubuntu Droplet)     |
| Appleboy SSH     | Remote SSH-based deployment (GitHub)   |

---

## 🌐 Live App

> Visit the app via the public IP of your DigitalOcean Droplet:

```bash
http://<your-droplet-ip>/
http://<your-droplet-ip>/about
```


## 📁 Project Structure

```bash
.
├── .github/workflows/
│   └── ci-cd.yml         # GitHub Actions workflow
├── app.py                # Flask app with two routes
├── Dockerfile            # Container build definition
├── deploy.sh             # Bash script run via SSH to deploy app
└── README.md             # This documentation
```


## 🔄 CI/CD Pipeline Overview

### ➕ On Push to `main`:
1. **GitHub Actions** triggers the pipeline.
2. Docker image is built and tagged with:
   - `latest`
   - Timestamp (e.g. `20250722-225025`)
3. Image is pushed to **Docker Hub**.
4. Then SSHs into **DigitalOcean Droplet** to:
   - Stop & remove old container
   - Pull new image
   - Run updated container on port 80


## 🔐 Secrets Used in GitHub Actions

Store these securely under **Settings → Secrets and variables → Actions**:

| Secret Name          | Purpose                               |
|----------------------|----------------------------------------|
| `DOCKER_USERNAME`    | Your Docker Hub username               |
| `DOCKER_PASSWORD`    | Docker Hub access token                |
| `DROPLET_IP`         | Public IP address of your droplet      |
| `DROPLET_SSH_KEY`    | Private SSH key (Base64 or raw value)  |


## 🔧 `deploy.sh` Script

```bash
#!/bin/bash

CONTAINER_NAME=flask-app
IMAGE_NAME=thepm002/docker_ci-cd_test:$(date +%Y-%m-%d)

docker stop $CONTAINER_NAME || true
docker rm $CONTAINER_NAME || true

echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin

docker pull $IMAGE_NAME
docker run -d --name $CONTAINER_NAME -p 80:5000 $IMAGE_NAME
```

This script is called automatically via the GitHub Actions workflow using `appleboy/ssh-action`.


## 📋 Sample GitHub Actions Workflow (`ci-cd.yml`)

```yaml
name: CI/CD Pipeline

on:
  push:
    branches:
      - main

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    outputs:
      image_tag: ${{ steps.get_tag.outputs.tag }}
    steps:
      - name: 📥 Checkout code
        uses: actions/checkout@v4

      - name: 🧪 Run dummy test
        run: echo "Dummy test passed!"

      - name: 🐳 Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: 🔐 Log in to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}

      - name: 🕒 Generate dynamic tag
        id: get_tag
        run: echo "tag=$(date +'%Y%m%d-%H%M%S')" >> $GITHUB_OUTPUT

      - name: 🏗️ Build and push Docker image
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: |
            thepm002/docker_ci-cd_test:latest
            thepm002/docker_ci-cd_test:${{ steps.get_tag.outputs.tag }}

  deploy:
    needs: build-and-push
    runs-on: ubuntu-latest
    steps:
      - name: 📥 Checkout code
        uses: actions/checkout@v4

      - name: 📡 Deploy to Droplet via SSH
        uses: appleboy/ssh-action@v1.0.3
        with:
          host: ${{ secrets.DROPLET_IP }}
          username: root
          key: ${{ secrets.DROPLET_SSH_KEY }}
          script: |
            docker stop flask-app || true
            docker rm flask-app || true
            docker pull thepm002/docker_ci-cd_test:${{ needs.build-and-push.outputs.image_tag }}
            docker run -d --name flask-app -p 80:5000 thepm002/docker_ci-cd_test:${{ needs.build-and-push.outputs.image_tag }}
```


## ✅ How to Trigger Deployment

1. Make a change to `app.py` (e.g., add new route or update message).
2. Push to `main`:

```bash
git add .
git commit -m " Trigger redeployment with changes"
git push origin main
```

3. Wait for GitHub Actions to finish, then visit your droplet IP.


## 💣 Droplet Cleanup (Optional)

When you're done testing, you can safely destroy the droplet to avoid incurring charges:

```bash
doctl compute droplet delete <droplet-id>  # Or via the dashboard
```


## 📌 Final Notes

This project is a great DevOps portfolio example covering:

- CI/CD fundamentals
- Docker image tagging
- Remote deployment automation
- Secrets management
- Infrastructure cleanup planning


> Made with ❤️ by [OSSAI CHIBUZOR MALACHI]