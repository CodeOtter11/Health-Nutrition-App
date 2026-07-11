const mongoose = require("mongoose");

const workoutSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },

    workoutType: String,
    exercises: [String],

    durationMinutes: Number,
    caloriesBurned: Number,

    date: {
      type: Date,
      default: Date.now,
    },

    notes: String,
  },
  { timestamps: true }
);

module.exports = mongoose.model("WorkoutLog", workoutSchema);