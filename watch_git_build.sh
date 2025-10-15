#!/bin/bash

# --- Configuration ---
PROJECT_DIR="/home/kalihuda/arithmetic_api"
GIT_REPO="https://github.com/houdaZ02/arithmetic-api.git"
DOCKER_IMAGE="hudaz002/arithmetic-api"
CONTAINER_NAME="arithmetic-api-container"
PORT="5000:5000"

# --- Move to project directory ---
cd "$PROJECT_DIR" || { echo "Project directory not found!"; exit 1; }

# --- Function to build & deploy Docker ---
build_and_deploy() {
    echo "Rebuilding Docker image..."
    docker build -t "$DOCKER_IMAGE" .

    # Stop and remove old container if exists
    if [ "$(docker ps -aq -f name=$CONTAINER_NAME)" ]; then
        docker rm -f "$CONTAINER_NAME"
    fi

    # Run new container
    docker run -d --name "$CONTAINER_NAME" -p $PORT "$DOCKER_IMAGE"

    # Push Docker image
    echo "Pushing Docker image to Docker Hub..."
    docker login --username hudaz002
    docker push "$DOCKER_IMAGE"
    echo "Done! Docker image pushed as $DOCKER_IMAGE:latest"
}

# --- Check for Git updates ---
check_git() {
    git fetch origin main
    LOCAL=$(git rev-parse HEAD)
    REMOTE=$(git rev-parse origin/main)

    if [ "$LOCAL" != "$REMOTE" ]; then
        echo "New commit detected on Git. Updating..."
        git reset --hard origin/main
        build_and_deploy
    fi
}

# --- Main loop ---
while true; do
    # Watch for local changes
    inotifywait -e modify,create,delete -r "$PROJECT_DIR"

    # If local changes, rebuild
    echo "Local changes detected."
    build_and_deploy

    # Check Git for new commits
    check_git
done
