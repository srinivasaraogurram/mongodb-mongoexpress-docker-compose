#!/bin/bash

echo "🚀 Ensuring MongoDB is running..."
docker-compose up -d

echo "🔗 Mongo Express is available at: http://localhost:8081"
echo "💻 Connect via Mongo Shell: mongosh 'mongodb://localhost:27017/'"
