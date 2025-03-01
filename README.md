# mongodb-mongoexpress-docker-compose
Below is a **comprehensive guide** to set up **MongoDB** and **MongoDB UI (Mongo Express)** using Docker Compose, with **data persistence**, and integrate it with a **Dev Container in VS Code**. This setup will automatically install required extensions, start the MongoDB server, and allow you to interact with the database using both **VS Code plugins** and **Mongo Express UI**.

---

### **Step 1: Prerequisites**
1. Install **Docker** and **Docker Compose**:
   - [Install Docker](https://docs.docker.com/get-docker/)
   - [Install Docker Compose](https://docs.docker.com/compose/install/)

2. Install **Visual Studio Code (VS Code)**:
   - [Download VS Code](https://code.visualstudio.com/)

3. Install the **Remote - Containers** extension in VS Code:
   - Open VS Code, go to Extensions, and search for "Remote - Containers". Install it.

---

### **Step 2: Set Up the Project Structure**
Create a project folder with the following structure:
```
mongodb-devcontainer/
├── .devcontainer/
│   ├── devcontainer.json
│   ├── Dockerfile
│   └── docker-compose.yml
├── mongo-data/  # Folder for persistent data
└── mongo-init.js  # Optional: Initialization script
```

---

### **Step 3: Create the `docker-compose.yml` File**
In the `.devcontainer` folder, create a `docker-compose.yml` file to define the MongoDB and Mongo Express services:

```yaml
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
      - ../mongo-data:/data/db  # Persist data to the host machine
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
```

---

### **Step 4: Create a Data Directory**
Create a directory named `mongo-data` in the project folder. This directory will store MongoDB's data persistently on your host machine.

```bash
mkdir mongo-data
```

---

### **Step 5: (Optional) Add an Initialization Script**
If you want to initialize the MongoDB database with some data or users, create a `mongo-init.js` file:

```javascript
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
```

Update the `docker-compose.yml` file to use this initialization script:

```yaml
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
      - ../mongo-init.js:/docker-entrypoint-initdb.d/mongo-init.js  # Add initialization script
    networks:
      - mongodb-network
```

---

### **Step 6: Set Up the Dev Container**

#### **1. Create the `Dockerfile`**
In the `.devcontainer` folder, create a `Dockerfile` to define the development environment:

```dockerfile
FROM mongo:latest

# Install additional tools (optional)
RUN apt-get update && apt-get install -y \
    curl \
    vim

# Set the working directory
WORKDIR /workspace

# Copy initialization script (optional)
COPY ../mongo-init.js /docker-entrypoint-initdb.d/mongo-init.js
```

#### **2. Create the `devcontainer.json`**
In the `.devcontainer` folder, create a `devcontainer.json` file to configure the Dev Container:

```json
{
  "name": "MongoDB Dev Container",
  "dockerComposeFile": "docker-compose.yml",
  "service": "mongodb",
  "workspaceFolder": "/workspace",
  "shutdownAction": "stopCompose",
  "extensions": [
    "mongodb.mongodb-vscode",  // MongoDB for VS Code extension
    "ms-vscode.vscode-node-azure-pack"  // Optional: Additional extensions
  ],
  "postCreateCommand": "docker-compose up -d",  // Start MongoDB and Mongo Express
  "forwardPorts": [27017, 8081]  // Forward MongoDB and Mongo Express ports
}
```

---

### **Step 7: Open the Project in VS Code**

1. Open the project folder in VS Code:
   ```bash
   code mongodb-devcontainer
   ```

2. Reopen the project in the Dev Container:
   - Press `Ctrl+Shift+P` and select **"Remote-Containers: Reopen in Container"**.

3. VS Code will:
   - Build the Docker container.
   - Install the required extensions (e.g., MongoDB for VS Code).
   - Start the MongoDB and Mongo Express services.

---

### **Step 8: Access MongoDB and Mongo Express**

#### **1. Access MongoDB via VS Code**
- Open the **MongoDB for VS Code** extension.
- Add a connection to MongoDB:
  - Connection string: `mongodb://root:example@localhost:27017`
- Use the extension to run queries and manage the database.

#### **2. Access Mongo Express UI**
- Open your browser and go to:
  ```
  http://localhost:8081
  ```
- Use the following credentials to log in:
  - **Username**: `root`
  - **Password**: `example`

---

### **Step 9: Play Around with the Database**

#### **1. Using VS Code MongoDB Extension**
- Open the MongoDB extension and connect to the database.
- Run queries in the VS Code terminal or using the extension's UI:
  ```javascript
  use mydatabase;
  db.mycollection.find();
  db.mycollection.insertOne({ name: 'New Data' });
  ```

#### **2. Using Mongo Express UI**
- Navigate to the `mydatabase` database in Mongo Express.
- Add, update, or delete documents using the web interface.

---

### **Step 10: Sample NoSQL Queries**

#### **Insert Data**
```javascript
db.mycollection.insertOne({ name: 'John Doe', age: 30 });
```

#### **Query Data**
```javascript
db.mycollection.find({ age: { $gt: 25 } });
```

#### **Update Data**
```javascript
db.mycollection.updateOne({ name: 'John Doe' }, { $set: { age: 31 } });
```

#### **Delete Data**
```javascript
db.mycollection.deleteOne({ name: 'John Doe' });
```

---

### **Step 11: Clean Up**

To stop and remove the containers (while keeping the data):

```bash
docker-compose down
```

To remove the containers and the persistent data:

```bash
docker-compose down -v
```

---

### **Summary**
- **MongoDB** and **Mongo Express** are set up using Docker Compose.
- Data is persisted using Docker volumes.
- The Dev Container in VS Code automatically installs extensions and starts the services.
- You can interact with the database using both the **VS Code MongoDB extension** and the **Mongo Express UI**.

This setup provides a seamless development environment for working with MongoDB.
