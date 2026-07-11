const mongoose = require("mongoose");

const userSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: false,
    },

    email: {
      type: String,
      required: true,
      unique: true,
    },

    phone: {
      type: String,
      required: false,
    },

    password: {
      type: String,
      required: false,
    },

    authProvider: {
      type: String,
      enum: ["local", "google"],
      default: "local",
    },

    googleUid: {
      type: String,
      default: null,
    },

    fcmToken: {
      type: String,
      default: null,
    },

    // ✅ ADD consultations INSIDE schema object
    consultations: [
      {
        userId: {
          type: mongoose.Schema.Types.ObjectId,
          ref: "User",
        },
        role: String,
        slot: String
      }
    ],

    // PRO SUBSCRIPTION
    isProUser: {
      type: Boolean,
      default: false
    },

    subscriptionPlan: {
      type: String,
      default: null
    },

    subscriptionStartDate: {
      type: Date,
      default: null
    },

    subscriptionExpiryDate: {
      type: Date,
      default: null
    }
  },

  {
    timestamps: true
  }
);

module.exports = mongoose.model("User", userSchema);