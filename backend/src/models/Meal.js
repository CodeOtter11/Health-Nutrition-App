const mongoose = require("mongoose");

const mealSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },

    mealType: {
      type: String,
      enum: ["Breakfast", "Lunch", "Snacks", "Beverages", "Dinner"],
      required: true,
    },

    name: {
      type: String,
      required: true,
      trim: true,
    },

    calories: {
      type: Number,
      default: 0,
    },

    protein: { type: Number, default: 0 },
    carbs: { type: Number, default: 0 },
    fat: { type: Number, default: 0 },


    quantity: {
      type: Number,
      default: 1,
    },

    unit: {
      type: String,
      required: true,
    },

    grams: {
      type: Number,
      default: 0,
    },

    date: {
      type: Date,
      default: Date.now,
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model("Meal", mealSchema);