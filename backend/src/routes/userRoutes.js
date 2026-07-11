const express = require("express");
const router = express.Router();

const authMiddleware = require("../middleware/authMiddleware");
const { saveFcmToken } = require("../controllers/userController");

// ✅ SAVE FCM TOKEN
router.put("/fcm-token", authMiddleware, saveFcmToken);

module.exports = router;