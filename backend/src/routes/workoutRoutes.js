const express = require("express");
const router = express.Router();

const {
  saveWorkout,
  getWorkouts,
} = require("../controllers/workoutController");

const authMiddleware = require("../middleware/authMiddleware");

// POST workout
router.post("/workout", authMiddleware, saveWorkout);

// GET last 7 workouts
router.get("/workout", authMiddleware, getWorkouts);

module.exports = router;