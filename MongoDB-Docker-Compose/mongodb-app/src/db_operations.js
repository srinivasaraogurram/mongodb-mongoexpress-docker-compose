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
