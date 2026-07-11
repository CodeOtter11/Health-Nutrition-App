const WaterTracker = require("../models/WaterTracker");

// ================= SAVE WATER =================
exports.saveWater = async (req, res) => {
  try {
    const { userId, totalWaterMl, glasses, goalMl, date } = req.body;

    let record = await WaterTracker.findOne({ userId, date });

    if (record) {
      record.totalWaterMl = totalWaterMl;
      record.glasses = glasses;
      record.goalMl = goalMl;
      await record.save();
    } else {
      record = new WaterTracker({
        userId,
        totalWaterMl,
        glasses,
        goalMl,
        date,
      });
      await record.save();
    }

    res.json({
      success: true,
      data: record,
    });

  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
};

// ================= GET TODAY WATER =================
exports.getWater = async (req, res) => {
  try {
    const { userId, date } = req.params;

    const record = await WaterTracker.findOne({ userId, date });

    if (!record) {
      return res.json({
        success: true,
        data: {
          totalWaterMl: 0,
          glasses: 0,
          goalMl: 2000,
        },
      });
    }

    res.json({
      success: true,
      data: record,
    });

  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
};

// ================= GET WEEKLY WATER =================
exports.getWeeklyWater = async (req, res) => {
  try {
    const { userId } = req.params;

    const result = {
      Sun: 0,
      Mon: 0,
      Tue: 0,
      Wed: 0,
      Thu: 0,
      Fri: 0,
      Sat: 0,
    };

    const today = new Date();

    // 🔥 Get last 7 days INCLUDING TODAY
    for (let i = 0; i < 7; i++) {
      const d = new Date();
      d.setDate(today.getDate() - i);

      const dateStr = d.toISOString().split("T")[0];

      const record = await WaterTracker.findOne({
        userId,
        date: dateStr,
      });

      const dayName = d.toLocaleDateString("en-US", {
        weekday: "short",
      });

      if (record) {
        result[dayName] = record.totalWaterMl;
      } else {
        result[dayName] = 0;
      }
    }

    res.json({
      success: true,
      data: result,
    });

  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
};