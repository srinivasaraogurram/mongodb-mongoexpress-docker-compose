#!/bin/bash

# Create the project directory structure
mkdir -p mongodb-devcontainer/.devcontainer
mkdir -p mongodb-devcontainer/mongo-data

# Create the .devcontainer files
cat <<EOL > mongodb-devcontainer/.devcontainer/devcontainer.json
{
  "name": "MongoDB Dev Container",
  "dockerComposeFile": "docker-compose.yml",
  "service": "mongodb",
  "workspaceFolder": "/workspace",
  "shutdownAction": "stopCompose",
  "extensions": [
    "mongodb.mongodb-vscode",
    "ms-vscode.vscode-node-azure-pack"
  ],
  "postCreateCommand": "docker-compose up -d",
  "forwardPorts": [27017, 8081]
}
EOL

cat <<EOL > mongodb-devcontainer/.devcontainer/Dockerfile
FROM mongo:latest

# Install additional tools (optional)
RUN apt-get update && apt-get install -y \\
    curl \\
    vim

# Set the working directory
WORKDIR /workspace

# Copy initialization script (optional)
COPY ../mongo-init.js /docker-entrypoint-initdb.d/mongo-init.js
EOL

cat <<EOL > mongodb-devcontainer/.devcontainer/docker-compose.yml
version: '3.8'

services:
  mongodb:
    image: mongo:latest
    container_name: mongodb
    environment:
      MONGO_INITDB_ROOT_USERNAME: root
      MONGO_INITDB_ROOT_PASSWORD: example
    ports:
      - "27017:27017"
    volumes:
      - ../mongo-data:/data/db
    networks:
      - mongodb-network

  mongo-express:
    image: mongo-express:latest
    container_name: mongo-express
    environment:
      ME_CONFIG_MONGODB_ADMINUSERNAME: root
      ME_CONFIG_MONGODB_ADMINPASSWORD: example
      ME_CONFIG_MONGODB_URL: mongodb://root:example@mongodb:27017/
    ports:
      - "8081:8081"
    depends_on:
      - mongodb
    networks:
      - mongodb-network

networks:
  mongodb-network:
    driver: bridge
EOL

# Create the mongo-init.js file
cat <<EOL > mongodb-devcontainer/mongo-init.js
// mongo-init.js
db.createUser({
  user: 'admin',
  pwd: 'admin123',
  roles: [
    { role: 'readWrite', db: 'mydatabase' }
  ]
});

db.createCollection('mycollection');
db.mycollection.insertOne({ name: 'Initial Data' });
EOL

# Make the script executable
chmod +x setup-mongodb-devcontainer.sh

echo "Project structure and files created successfully!"