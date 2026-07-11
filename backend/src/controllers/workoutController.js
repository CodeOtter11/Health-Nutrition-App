const Workout = require("../models/workoutLog");

// ================= SAVE WORKOUT =================
exports.saveWorkout = async (req, res) => {
  try {
    const {
      workoutType,
      exercises,
      durationMinutes,
      caloriesBurned,
    } = req.body;

    const workout = await Workout.create({
      userId: req.user.userId,
      workoutType,
      exercises,
      durationMinutes,
      caloriesBurned,
    });

    res.json({ success: true, data: workout });

  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// ================= GET LAST 7 DAYS =================
exports.getWorkouts = async (req, res) => {
  try {
    const workouts = await Workout.find({
      userId: req.user.userId,
    })
      .sort({ date: -1 })
      .limit(7);

    res.json({ success: true, data: workouts });

  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};