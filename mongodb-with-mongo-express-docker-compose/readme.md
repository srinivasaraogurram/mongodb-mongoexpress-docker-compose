To create and start **MongoDB** and **MongoDB Express (Mongo Express)** using **Docker Compose**, follow this step-by-step guide. This setup will include:

1. **MongoDB**: The database server.
2. **Mongo Express**: A web-based MongoDB admin interface.
3. **Data Persistence**: Using Docker volumes to persist MongoDB data.
4. **Initialization Script**: Optional script to initialize the database with users and data.

---

### **Step 1: Prerequisites**
1. Install **Docker** and **Docker Compose**:
   - [Install Docker](https://docs.docker.com/get-docker/)
   - [Install Docker Compose](https://docs.docker.com/compose/install/)

2. Verify Docker and Docker Compose are installed:
   ```bash
   docker --version
   docker-compose --version
   ```

---

### **Step 2: Create the Project Structure**
Create a project folder with the following structure:
```
mongodb-docker/
├── docker-compose.yml
├── mongo-data/  # Folder for persistent data
└── mongo-init.js  # Optional: Initialization script
```

---

### **Step 3: Create the `docker-compose.yml` File**
In the `docker-compose.yml` file, define the MongoDB and Mongo Express services.

#### **`docker-compose.yml`**
```yaml
version: '3.8'

services:
  mongodb:
    image: mongo:latest  # Official MongoDB image
    container_name: mongodb
    environment:
      MONGO_INITDB_ROOT_USERNAME: root  # Root username
      MONGO_INITDB_ROOT_PASSWORD: example  # Root password
    ports:
      - "27017:27017"  # Expose MongoDB port
    volumes:
      - ./mongo-data:/data/db  # Persist data to the host machine
    networks:
      - mongodb-network

  mongo-express:
    image: mongo-express:latest  # Official Mongo Express image
    container_name: mongo-express
    environment:
      ME_CONFIG_MONGODB_ADMINUSERNAME: root  # MongoDB admin username
      ME_CONFIG_MONGODB_ADMINPASSWORD: example  # MongoDB admin password
      ME_CONFIG_MONGODB_URL: mongodb://root:example@mongodb:27017/  # MongoDB connection URL
    ports:
      - "8081:8081"  # Expose Mongo Express port
    depends_on:
      - mongodb  # Start after MongoDB
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
If you want to initialize the MongoDB database with users or data, create a `mongo-init.js` file.

#### **`mongo-init.js`**
```javascript
// Create a user and database
db.createUser({
  user: 'admin',
  pwd: 'admin123',
  roles: [
    { role: 'readWrite', db: 'mydatabase' }
  ]
});

// Create a collection and insert data
db = db.getSiblingDB('mydatabase');
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
      - ./mongo-data:/data/db
      - ./mongo-init.js:/docker-entrypoint-initdb.d/mongo-init.js  # Add initialization script
    networks:
      - mongodb-network
```

---

### **Step 6: Start the Services**
Run the following command to start the MongoDB and Mongo Express services:

```bash
docker-compose up -d
```

---

### **Step 7: Access MongoDB and Mongo Express**

#### **1. Access MongoDB**
- Connect to MongoDB using the connection string:
  ```
  mongodb://root:example@localhost:27017
  ```
- You can use a MongoDB client like `mongosh` or MongoDB Compass.

#### **2. Access Mongo Express UI**
- Open your browser and go to:
  ```
  http://localhost:8081
  ```
- Use the following credentials to log in:
  - **Username**: `root`
  - **Password**: `example`

---

### **Step 8: Verify Data Persistence**

1. **Add Data**:
   - Use Mongo Express or a MongoDB client to add some data to the database.

2. **Stop and Restart the Containers**:
   - Stop the containers:
     ```bash
     docker-compose down
     ```
   - Restart the containers:
     ```bash
     docker-compose up -d
     ```

3. **Check Data**:
   - Verify that the data you added earlier is still present in the database.

---

### **Step 9: Clean Up**

To stop and remove the containers (while keeping the data):

```bash
docker-compose down
```

To remove the containers and the persistent data:

```bash
docker-compose down -v
```

---

### **Explanation of Key Components**

1. **Volumes**:
   - The `./mongo-data:/data/db` volume ensures that MongoDB data is stored on the host machine in the `mongo-data` directory. This allows data to persist even when the container is stopped or removed.

2. **Environment Variables**:
   - `MONGO_INITDB_ROOT_USERNAME` and `MONGO_INITDB_ROOT_PASSWORD` are used to set up the root user for MongoDB.

3. **Networks**:
   - A custom Docker network (`mongodb-network`) is created to allow communication between the MongoDB and Mongo Express containers.

4. **Initialization Script**:
   - The `mongo-init.js` script is executed when the MongoDB container starts for the first time. It can be used to create users, databases, and collections.

---

### **Step 10: Example NoSQL Queries**

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

By following these steps, you can create and start **MongoDB** and **Mongo Express** using Docker Compose. This setup provides a persistent development environment for working with MongoDB.