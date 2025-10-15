#!/bin/bash
IMAGE_NAME="arithmetic-api"
CONTAINER_NAME="arithmetic-api-container"

while true; do
    inotifywait -e modify,create,delete -r .
    echo "Changes detected. Rebuilding Docker image..."
    
    docker build -t $IMAGE_NAME .
    
    if [ "$(docker ps -q -f name=$CONTAINER_NAME)" ]; then
        docker stop $CONTAINER_NAME
        docker rm $CONTAINER_NAME
    fi
    
    docker run -d -p 5000:5000 --name $CONTAINER_NAME $IMAGE_NAME
done
