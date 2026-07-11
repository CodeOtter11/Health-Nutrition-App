const mongoose = require("mongoose");

const waterTrackerSchema = new mongoose.Schema({

  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true
  },

  date: {
    type: String,   // YYYY-MM-DD
    required: true
  },

  totalWaterMl: {
    type: Number,
    default: 0
  },

  glasses: {
    type: Number,
    default: 0
  },

  goalMl: {
    type: Number,
    default: 2000
  }

}, { timestamps: true });

module.exports =
  mongoose.models.WaterTracker ||
  mongoose.model("WaterTracker", waterTrackerSchema);