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
