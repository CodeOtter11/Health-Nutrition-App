const mongoose = require("mongoose");

const dietitianRequestSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
  },
  dietitianId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Dietitian",
  },
  message: String,

  // 🔥 ADD THIS (VERY IMPORTANT)
  status: {
    type: String,
    enum: ["pending", "accepted", "rejected"],
    default: "pending", // ✅ THIS FIXES YOUR ISSUE
  },
}, { timestamps: true });

module.exports = mongoose.model(
  "DietitianRequest",
  dietitianRequestSchema
);