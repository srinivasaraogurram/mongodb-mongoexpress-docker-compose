Here’s a shell script that will **automatically generate** the required **folder structure**, **files**, and **content**, then start the MongoDB server using Docker Compose.

---

### **📌 Shell Script: `setup-mongodb.sh`**
```sh
#!/bin/bash

# Create Project Directory
PROJECT_DIR="mongodb-app"
mkdir -p $PROJECT_DIR && cd $PROJECT_DIR

# Create Required Folders
mkdir -p .devcontainer

# Create Docker Compose File
cat <<EOF > docker-compose.yml
version: '3.8'

services:
  mongodb:
    image: mongo:latest
    container_name: mongodb
    restart: always
    environment:
      MONGO_INITDB_ROOT_USERNAME: admin
      MONGO_INITDB_ROOT_PASSWORD: password
    volumes:
      - mongodb_data:/data/db
    ports:
      - "27017:27017"

  mongo-express:
    image: mongo-express:latest
    container_name: mongo-express
    restart: always
    environment:
      ME_CONFIG_MONGODB_ADMINUSERNAME: admin
      ME_CONFIG_MONGODB_ADMINPASSWORD: password
      ME_CONFIG_MONGODB_URL: mongodb://admin:password@mongodb:27017/
    ports:
      - "8081:8081"
    depends_on:
      - mongodb

volumes:
  mongodb_data:
    driver: local
EOF

# Create DevContainer Configuration
cat <<EOF > .devcontainer/devcontainer.json
{
  "name": "MongoDB Dev Container",
  "dockerComposeFile": "docker-compose.yml",
  "service": "mongodb",
  "workspaceFolder": "/workspace",
  "extensions": [
    "ms-vscode.vscode-typescript-next",
    "mongodb.mongodb-vscode"
  ],
  "settings": {
    "terminal.integrated.shell.linux": "/bin/bash"
  }
}
EOF

# Create User Schema File
mkdir -p src
cat <<EOF > src/userSchema.js
const mongoose = require('mongoose');
const bcrypt = require('bcrypt');

const UserSchema = new mongoose.Schema({
  username: { type: String, required: true, unique: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  roles: { type: [String], enum: ['user', 'admin'], default: ['user'] }
});

// Hash password before saving
UserSchema.pre('save', async function (next) {
  if (!this.isModified('password')) return next();
  this.password = await bcrypt.hash(this.password, 10);
  next();
});

module.exports = mongoose.model('User', UserSchema);
EOF

# Create Seed Data File
cat <<EOF > src/seed.js
const mongoose = require('mongoose');
const User = require('./userSchema');

mongoose.connect('mongodb://admin:password@localhost:27017/', {
  dbName: 'userdb',
  useNewUrlParser: true,
  useUnifiedTopology: true,
}).then(async () => {
  console.log('Connected to MongoDB');
  
  const users = [
    { username: 'admin', email: 'admin@example.com', password: 'admin123', roles: ['admin'] },
    { username: 'user1', email: 'user1@example.com', password: 'user123', roles: ['user'] }
  ];

  for (let user of users) {
    const exists = await User.findOne({ email: user.email });
    if (!exists) await new User(user).save();
  }

  console.log('Seed data inserted');
  mongoose.disconnect();
}).catch(err => console.error('Error:', err));
EOF

# Create Database Operations File
cat <<EOF > src/db_operations.js
const mongoose = require('mongoose');
const User = require('./userSchema');

mongoose.connect('mongodb://admin:password@localhost:27017/', {
  dbName: 'userdb',
  useNewUrlParser: true,
  useUnifiedTopology: true,
}).then(() => console.log('Connected to MongoDB'))
  .catch(err => console.error('Connection error:', err));

// Fetch all users
const getUsers = async () => {
  const users = await User.find();
  console.log(users);
};

// Authenticate user
const authenticateUser = async (email, password) => {
  const user = await User.findOne({ email });
  if (!user) return console.log('User not found');
  console.log(user);
};

// Run script
getUsers();
EOF

# Create Red Hat DevSpaces Config
cat <<EOF > .devfile.yaml
schemaVersion: 2.1.0
metadata:
  name: mongodb-devspace
components:
  - name: tools
    container:
      image: quay.io/devspaces/ubi8
      memoryLimit: 512Mi
      mountSources: true
  - name: mongodb
    container:
      image: mongo:latest
      memoryLimit: 512Mi
      env:
        - name: MONGO_INITDB_ROOT_USERNAME
          value: admin
        - name: MONGO_INITDB_ROOT_PASSWORD
          value: password
      endpoints:
        - name: mongo
          targetPort: 27017
  - name: mongo-express
    container:
      image: mongo-express:latest
      memoryLimit: 512Mi
      env:
        - name: ME_CONFIG_MONGODB_ADMINUSERNAME
          value: admin
        - name: ME_CONFIG_MONGODB_ADMINPASSWORD
          value: password
        - name: ME_CONFIG_MONGODB_URL
          value: mongodb://admin:password@mongodb:27017/
      endpoints:
        - name: mongo-express
          targetPort: 8081
EOF

# Provide Instructions to the User
echo "✅ MongoDB App Setup Complete!"
echo "📁 Project Directory: $PROJECT_DIR"
echo "🚀 Starting Docker Containers..."
docker-compose up -d

echo "🔗 Mongo Express: http://localhost:8081 (Username: admin, Password: password)"
echo "💻 Connect via Mongo CLI:"
echo "    mongo --host localhost --port 27017 -u admin -p password --authenticationDatabase admin"
echo "💡 To run the seed script: cd src && node seed.js"
```

---

### **📌 How to Use**
1. **Save the script** as `setup-mongodb.sh`
2. **Make it executable**:
   ```sh
   chmod +x setup-mongodb.sh
   ```
3. **Run the script**:
   ```sh
   ./setup-mongodb.sh
   ```

---

### **🚀 What This Script Does**
- Creates all necessary files and folders.
- Sets up **Docker Compose** for MongoDB & Mongo Express.
- Generates **user schema** and **seed data**.
- Provides **Mongo Express UI & Mongo CLI connection details**.
- Starts the **MongoDB server and UI** automatically.

---

### **🔗 Web-Based Code Servers Supporting Dev Containers**
1. **GitHub Codespaces** → [https://github.com/features/codespaces](https://github.com/features/codespaces)
2. **GitPod** → [https://www.gitpod.io/](https://www.gitpod.io/)
3. **Red Hat DevSpaces** → [https://developers.redhat.com/products/devspaces](https://developers.redhat.com/products/devspaces)

---

Now, you can start developing instantly with **VS Code Dev Containers, Red Hat DevSpaces, or GitHub Codespaces!** 🚀