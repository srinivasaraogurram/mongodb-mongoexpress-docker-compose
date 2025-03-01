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
