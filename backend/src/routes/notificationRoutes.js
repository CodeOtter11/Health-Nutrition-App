const express = require("express");
const router = express.Router();
const admin = require("../firebaseAdmin");

router.post("/send", async (req, res) => {
  try {
    const { title, body, topic } = req.body;

    const message = {
      notification: {
        title,
        body,
      },
      topic: topic,
    };

    await admin.messaging().send(message);

    res.json({
      success: true,
      message: "Notification sent",
    });
  } catch (error) {
    console.error("FCM ERROR:", error);
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

module.exports = router;