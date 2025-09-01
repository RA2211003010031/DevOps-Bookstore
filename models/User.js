const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
  email: { type: String, required: true, unique: true },
  password: { type: String },  // For authentication if needed
  name: { type: String }
  // Add other fields as required
});

module.exports = mongoose.model("User", UserSchema);