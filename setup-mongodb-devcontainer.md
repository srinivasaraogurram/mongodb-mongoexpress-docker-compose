Below is a **bash script** to create the folder structure and files for the `mongodb-devcontainer` project as per your requirements. This script will create the necessary folders, files, and populate them with the required content.

---

### **Bash Script**

```bash
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
```

---

### **How to Use the Script**

1. Save the script to a file, e.g., `setup-mongodb-devcontainer.sh`.
2. Make the script executable:
   ```bash
   chmod +x setup-mongodb-devcontainer.sh
   ```
3. Run the script:
   ```bash
   ./setup-mongodb-devcontainer.sh
   ```

---

### **What the Script Does**

1. Creates the following folder structure:
   ```
   mongodb-devcontainer/
   ├── .devcontainer/
   │   ├── devcontainer.json
   │   ├── Dockerfile
   │   └── docker-compose.yml
   ├── mongo-data/
   └── mongo-init.js
   ```

2. Populates the files with the required content:
   - `devcontainer.json`: Configures the Dev Container for VS Code.
   - `Dockerfile`: Defines the Docker image for the Dev Container.
   - `docker-compose.yml`: Defines the MongoDB and Mongo Express services.
   - `mongo-init.js`: Initializes the MongoDB database with a user and sample data.

3. Makes the script executable for future use.

---

### **Next Steps**

1. Open the project in VS Code:
   ```bash
   code mongodb-devcontainer
   ```

2. Reopen the project in the Dev Container:
   - Press `Ctrl+Shift+P` and select **"Remote-Containers: Reopen in Container"**.

3. The MongoDB and Mongo Express services will start automatically. You can access:
   - MongoDB: `mongodb://root:example@localhost:27017`
   - Mongo Express: `http://localhost:8081`

4. Use the **MongoDB for VS Code** extension or the **Mongo Express UI** to interact with the database.

---

This script automates the setup of your MongoDB Dev Container project, making it easy to get started with MongoDB and Mongo Express in a development environment.