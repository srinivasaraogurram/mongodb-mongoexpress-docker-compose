#!/bin/bash

echo "🚀 Setting up MongoDB Dev Container in the root directory..."

# Ensure we are in the root workspace
ROOT_DIR="$(pwd)"
DEVCONTAINER_DIR="$ROOT_DIR/.devcontainer"
SRC_DIR="$ROOT_DIR/src"
SCRIPTS_DIR="$ROOT_DIR/scripts"

# Create Required Folders
mkdir -p "$DEVCONTAINER_DIR" "$SRC_DIR" "$SCRIPTS_DIR"

echo "📁 Creating Dev Container configuration..."
cat <<EOF > "$DEVCONTAINER_DIR/devcontainer.json"
{
  "name": "MongoDB Dev Container",
  "dockerComposeFile": "docker-compose.yml",
  "service": "mongodb",
  "workspaceFolder": "/workspace",
  "extensions": [
    "mongodb.mongodb-vscode"
  ],
  "settings": {
    "terminal.integrated.shell.linux": "/bin/bash"
  },
  "postCreateCommand": "bash /workspace/scripts/startup.sh"
}
EOF

echo "📁 Creating Docker Compose file..."
cat <<EOF > "$ROOT_DIR/docker-compose.yml"
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

echo "📁 Creating MongoDB Startup Script..."
cat <<EOF > "$SCRIPTS_DIR/startup.sh"
#!/bin/bash

echo "🚀 Ensuring MongoDB is running..."
docker-compose up -d

echo "🔗 Mongo Express is available at: http://localhost:8081"
echo "💻 Connect via Mongo Shell: mongosh 'mongodb://localhost:27017/'"
EOF

# Make startup script executable
chmod +x "$SCRIPTS_DIR/startup.sh"

echo "📁 Creating MongoDB Shutdown Script..."
cat <<EOF > "$SCRIPTS_DIR/shutdown.sh"
#!/bin/bash

echo "🛑 Stopping MongoDB and Mongo Express..."
docker-compose down
echo "✅ Services stopped successfully."
EOF

# Make shutdown script executable
chmod +x "$SCRIPTS_DIR/shutdown.sh"

echo "📁 Creating VS Code Workspace file..."
cat <<EOF > "$ROOT_DIR/mongodb-app.code-workspace"
{
  "folders": [
    {
      "path": "."
    }
  ],
  "settings": {}
}
EOF

echo "🚀 Running Startup Script..."
bash "$SCRIPTS_DIR/startup.sh"

echo "🛠️ Setting up GitHub Codespaces Port Forwarding..."
gh codespace ports visibility 27017:public
gh codespace ports visibility 8081:public

echo "✅ Setup complete! Open this repository in a **Dev Container**."
