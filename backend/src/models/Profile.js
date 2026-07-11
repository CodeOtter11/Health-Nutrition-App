const mongoose = require("mongoose");   // ✅ ADD THIS LINE

const ProfileSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true,
    unique: true,
  },

  name: String,
  email: String,
  phone: String,

  age: Number,
  gender: String,
  height: Number,
  weight: Number,
  city: String,

  dietType: String,
  diseases: [String],
  healthDetails: Object,

  activityLevel: String,
  habits: [String],

  goal: String,
  targetWeight: Number,

  referralSource: [String],
}, { timestamps: true });

module.exports = mongoose.model("Profile", ProfileSchema);
