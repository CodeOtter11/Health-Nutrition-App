const mongoose = require("mongoose");

const weightSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
      unique: true,
    },

    // ✅ GOAL DATA
    startWeight: Number,
    goalWeight: Number,
    goalType: {
      type: String,
      enum: ["lose", "gain", "maintain"],
    },

    // ✅ HISTORY ARRAY
    history: [
      {
        weight: Number,
        date: {
          type: Date,
          default: Date.now,
        },
      },
    ],
  },
  { timestamps: true }
);

module.exports = mongoose.model("Weight", weightSchema);