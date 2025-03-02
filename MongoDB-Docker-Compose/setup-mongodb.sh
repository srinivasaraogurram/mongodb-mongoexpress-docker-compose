#!/bin/bash

# Set project directory
PROJECT_DIR="mongodb-app"

# Create Project Directory if not exists
mkdir -p $PROJECT_DIR && cd $PROJECT_DIR

# Create Required Folders
mkdir -p .devcontainer src

echo "📁 Creating or updating Docker Compose file..."
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

echo "📁 Creating or updating Dev Container configuration..."
cat <<EOF > .devcontainer/devcontainer.json
{
  "name": "MongoDB Dev Container",
  "dockerComposeFile": "docker-compose.yml",
  "service": "mongodb",
  "workspaceFolder": "/workspace",
  "portsAttributes": {
    "27017": { "label": "MongoDB", "onAutoForward": "openBrowser" },
    "8081": { "label": "Mongo Express", "onAutoForward": "openBrowser" }
  },
  "extensions": [
    "mongodb.mongodb-vscode"
  ],
  "settings": {
    "terminal.integrated.shell.linux": "/bin/bash"
  }
}
EOF

echo "📁 Creating or updating User Schema..."
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

echo "📁 Creating or updating Seed Data script..."
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

echo "📁 Creating or updating Database Operations script..."
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

echo "📁 Creating or updating Red Hat DevSpaces config..."
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

echo "🛠️ Setting up GitHub Codespaces port forwarding..."
gh codespace ports visibility 27017:public
gh codespace ports visibility 8081:public

echo "🚀 Restarting MongoDB and Mongo Express..."
docker-compose down && docker-compose up -d

echo "✅ MongoDB App Setup Completed!"
echo "🔗 Mongo Express: http://localhost:8081 (Username: admin, Password: password)"
echo "💻 Connect via Mongo CLI:"
echo "    mongo --host 127.0.0.1 --port 27017 -u admin -p password --authenticationDatabase admin"
echo "💡 To run the seed script: cd src && node seed.js"
