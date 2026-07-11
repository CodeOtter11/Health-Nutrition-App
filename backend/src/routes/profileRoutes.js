const express = require("express");
const router = express.Router();

const authMiddleware = require("../middleware/authMiddleware");
const {
  getMyProfile,
  updateMyProfile,
} = require("../controllers/profileController");

// 🔐 GET profile (auto-create if missing)
router.get("/me", authMiddleware, getMyProfile);

// 🔐 CREATE / UPDATE profile
router.put("/me", authMiddleware, updateMyProfile);

module.exports = router;
