const Weight = require("../models/WeightLog");

// ================= SAVE GOAL =================
exports.saveGoal = async (req, res) => {
  try {
    const { startWeight, goalWeight, goalType } = req.body;

    const data = await Weight.findOneAndUpdate(
      { userId: req.user.userId },
      {
        startWeight,
        goalWeight,
        goalType,
      },
      { new: true, upsert: true }
    );

    res.json({ success: true, data });

  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// ================= ADD WEIGHT =================
exports.addWeight = async (req, res) => {
  try {
    const { weight } = req.body;

    const data = await Weight.findOneAndUpdate(
      { userId: req.user.userId },
      {
        $push: {
          history: {
            weight,
            date: new Date(),
          },
        },
      },
      { new: true, upsert: true }
    );

    res.json({ success: true, data });

  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// ================= GET FULL DATA =================
exports.getWeightData = async (req, res) => {
  try {
    const data = await Weight.findOne({
      userId: req.user.userId,
    });

    res.json({ success: true, data });

  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};