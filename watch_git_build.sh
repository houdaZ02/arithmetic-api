#!/bin/bash

# --- Configuration ---
PROJECT_DIR="/home/kalihuda/arithmetic_api"
GIT_REPO="https://github.com/houdaZ02/arithmetic-api.git"
DOCKER_IMAGE="hudaZ002/arithmetic-api"
CONTAINER_NAME="arithmetic-api-container"
PORT="5000:5000"

# --- Move to project directory ---
cd "$PROJECT_DIR" || { echo "Project directory not found!"; exit 1; }

# --- Fetch latest changes from Git ---
git fetch origin main
LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/main)

if [ "$LOCAL" != "$REMOTE" ]; then
    echo "New commit detected. Rebuilding Docker image..."
    git reset --hard origin/main

    # --- Build Docker image ---
    docker build -t "$DOCKER_IMAGE" .

    # --- Stop and remove old container if exists ---
    if [ "$(docker ps -aq -f name=$CONTAINER_NAME)" ]; then
        docker rm -f "$CONTAINER_NAME"
    fi

    # --- Run new container ---
    docker run -d --name "$CONTAINER_NAME" -p $PORT "$DOCKER_IMAGE"

    # --- Push to Docker Hub ---
    echo "Pushing Docker image to Docker Hub..."
    docker login --username hudaZ002
    docker push "$DOCKER_IMAGE"

    echo "Done! Docker image pushed to Docker Hub as $DOCKER_IMAGE:latest"
else
    echo "No new commits. Nothing to do."
fi
