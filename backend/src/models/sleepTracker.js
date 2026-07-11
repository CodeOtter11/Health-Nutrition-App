const mongoose = require("mongoose");

const sleepSchema = new mongoose.Schema({
  userId: String,
  date: String,
  sleepHours: Number,
}, { timestamps: true });

module.exports =
  mongoose.models.SleepTracker ||
  mongoose.model("SleepTracker", sleepSchema);