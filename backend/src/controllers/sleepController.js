const SleepTracker = require("../models/SleepTracker");

// ================= SAVE SLEEP =================
exports.saveSleep = async (req, res) => {
  try {
    const { userId, sleepHours, date } = req.body;
    console.log("SAVING:", userId, sleepHours, date);

    // 🔥 FIXED DATE FORMAT (IMPORTANT)
    const formattedDate = new Date(date).toISOString().split("T")[0];

    let record = await SleepTracker.findOne({
      userId,
      date: formattedDate,
    });

    if (record) {
      // ✅ Add sleep (you already handled limit)
      record.sleepHours += sleepHours;

      if (record.sleepHours > 24) {
        record.sleepHours = 24;
      }

      await record.save();
    } else {
      record = new SleepTracker({
        userId,
        sleepHours,
        date: formattedDate,
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


// ================= GET TODAY SLEEP =================
exports.getSleep = async (req, res) => {
  try {
    const { userId, date } = req.params;

    // 🔥 FIXED DATE FORMAT
    const formattedDate = new Date(date).toISOString().split("T")[0];

    const record = await SleepTracker.findOne({
      userId,
      date: formattedDate,
    });

    if (!record) {
      return res.json({
        success: true,
        data: {
          sleepHours: 0,
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


// ================= GET WEEKLY SLEEP =================
exports.getWeeklySleep = async (req, res) => {
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

    const days = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"];

    const records = await SleepTracker.find({
      userId: userId.toString()
    });

    console.log("FOUND RECORDS:", records);

    records.forEach(record => {
      if (!record.date) return;

      // 🔥 FIXED DATE PARSING
      const parts = record.date.split("-");
      const date = new Date(parts[0], parts[1] - 1, parts[2]);

      const day = days[date.getDay()];

      if (result[day] !== undefined) {
        result[day] += record.sleepHours;
      }
    });

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