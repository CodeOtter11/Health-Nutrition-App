const mongoose = require("mongoose");

const dietitianSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true
  },
  email: {
    type: String,
    unique: true,
    required: true
  },
  password: {
    type: String,
    required: true
  },

  specialization: String,
  experience: Number,
  bio: String,
  profileImage: String,

  isVerified: {
    type: Boolean,
    default: false
  },

  createdAt: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model("Dietitian", dietitianSchema);