#!/bin/bash

# Create the project directory structure
mkdir -p mongodb-docker/mongo-data

# Create the docker-compose.yml file
cat <<EOL > mongodb-docker/docker-compose.yml
version: '3.8'

services:
  mongodb:
    image: mongo:latest
    container_name: mongodb
    environment:
      MONGO_INITDB_ROOT_USERNAME: root
      MONGO_INITDB_ROOT_PASSWORD: ${MONGO_INITDB_ROOT_PASSWORD}
    ports:
      - "27017:27017"
    volumes:
      - ./mongo-data:/data/db
      - ./mongo-init.js:/docker-entrypoint-initdb.d/mongo-init.js
    networks:
      - mongodb-network

  mongo-express:
    image: mongo-express:latest
    container_name: mongo-express
    environment:
      ME_CONFIG_MONGODB_ADMINUSERNAME: root
      ME_CONFIG_MONGODB_ADMINPASSWORD: example
      ME_CONFIG_MONGODB_URL: mongodb://root:${MONGO_INITDB_ROOT_PASSWORD}@mongodb:27017/
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
cat <<EOL > mongodb-docker/mongo-init.js
// mongo-init.js
db.createUser({
  user: 'admin',
  pwd: 'admin123',
  roles: [
    { role: 'readWrite', db: 'mydatabase' }
  ]
});

db = db.getSiblingDB('mydatabase');
db.createCollection('mycollection');
db.mycollection.insertOne({ name: 'Initial Data' });
EOL

# Make the script executable
chmod +x create-mongodb-docker.sh

echo "MongoDB Docker project created successfully!"
echo "Project structure:"
tree mongodb-docker