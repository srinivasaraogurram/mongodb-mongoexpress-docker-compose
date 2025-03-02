#!/bin/bash

# Set project directory
PROJECT_DIR="mongodb-app"

# Create Project Directory if not exists
mkdir -p $PROJECT_DIR && cd $PROJECT_DIR

# Create Required Folders
mkdir -p .devcontainer src

# Function to install MongoDB Shell
install_mongosh() {
    echo "🔍 Checking if mongosh is installed..."
    if ! mongosh --version &> /dev/null; then
        echo "🚀 Installing MongoDB Shell (mongosh)..."
        curl -fsSL https://pgp.mongodb.com/server-6.0.asc | sudo gpg --dearmor -o /usr/share/keyrings/mongodb-server-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/mongodb-server-keyring.gpg] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
        sudo apt update
        sudo apt install -y mongodb-mongosh
        echo "✅ MongoDB Shell (mongosh) installed successfully!"
    else
        echo "✅ mongosh is already installed."
    fi
}

# Function to start Docker Compose
start_docker_compose() {
    echo "📁 Creating or updating Docker Compose file..."
    cat <<EOF > docker-compose.yml
version: '3.8'

services:
  mongodb:
    image: mongo:latest
    container_name: mongodb
    restart: always
    command: ["mongod", "--bind_ip", "0.0.0.0"]
    volumes:
      - mongodb_data:/data/db
    ports:
      - "27017:27017"

  mongo-express:
    image: mongo-express:latest
    container_name: mongo-express
    restart: always
    environment:
      ME_CONFIG_MONGODB_URL: mongodb://mongodb:27017/
      ME_CONFIG_BASICAUTH: "false"
    ports:
      - "8081:8081"
    depends_on:
      - mongodb

volumes:
  mongodb_data:
    driver: local
EOF

    echo "🚀 Starting Docker Compose..."
    docker-compose up -d
    echo "✅ MongoDB and Mongo Express started successfully!"
    echo "🔗 Mongo Express: http://localhost:8081"
    echo "💻 Connect via Mongo Shell: mongosh 'mongodb://localhost:27017/'"
}

# Function to stop Docker Compose
stop_docker_compose() {
    echo "🛑 Stopping MongoDB and Mongo Express..."
    docker-compose down
    echo "✅ Services stopped successfully."
}

# Main Menu
while true; do
    echo ""
    echo "=================================="
    echo "   MongoDB Setup Script Menu"
    echo "=================================="
    echo "1️⃣  Install MongoDB Shell (mongosh)"
    echo "2️⃣  Start MongoDB & Mongo Express"
    echo "3️⃣  Stop MongoDB & Mongo Express"
    echo "4️⃣  Exit"
    echo "----------------------------------"
    read -p "🔹 Select an option (1-4) and press ENTER: " CHOICE

    case $CHOICE in
        1)
            install_mongosh
            ;;
        2)
            start_docker_compose
            ;;
        3)
            stop_docker_compose
            ;;
        4)
            echo "🚀 Exiting script. Have a great day!"
            exit 0
            ;;
        *)
            echo "❌ Invalid option. Please enter 1, 2, 3, or 4."
            ;;
    esac
done
