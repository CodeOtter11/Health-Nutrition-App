const express = require("express");
const router = express.Router();
const authMiddleware = require("../middleware/authMiddleware");
const chatController = require("../controllers/chatController");

router.post("/send", authMiddleware, chatController.sendMessage);
router.get("/:receiverId", authMiddleware, chatController.getMessages);

module.exports = router;