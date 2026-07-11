const BmiLog = require("../models/BmiLog");

// ================= SAVE BMI =================
exports.saveBMI = async (req, res) => {
  try {
    const { bmi, height, weight} = req.body;

    const userId = req.user.userId; // from auth middleware

    const newEntry = new BmiLog({
      userId,
      bmi,
      height,
      weight,
      date: new Date().toISOString(),
    });

    await newEntry.save();

    res.status(201).json({
      success: true,
      message: "BMI saved successfully",
      data: newEntry,
    });

  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: "Server Error",
    });
  }
};

exports.getBMIHistory = async (req, res) => {
  try {
    const userId = req.user.userId;

    const history = await BmiLog.find({ userId })
      .sort({ createdAt: -1 });

    res.status(200).json({
      success: true,
      data: history,
    });

  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: "Server Error",
    });
  }
};