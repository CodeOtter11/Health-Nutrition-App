const User = require("../models/User");

// ================= SAVE FCM TOKEN =================
exports.saveFcmToken = async (req, res) => {
  try {
    const { fcmToken } = req.body;

    console.log("USER ID:", req.user.userId);
    console.log("FCM TOKEN:", fcmToken);

    const updatedUser = await User.findByIdAndUpdate(
      req.user.userId,
      { fcmToken },
      { new: true } // 🔥 VERY IMPORTANT
    );

    console.log("UPDATED USER:", updatedUser);

    res.json({
      success: true,
      message: "FCM token saved",
    });

  } catch (err) {
    console.log("ERROR:", err);
    res.status(500).json({
      success: false,
      message: err.message,
    });
  }
};