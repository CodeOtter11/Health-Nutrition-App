const express = require("express");
const router = express.Router();

const authController = require("../controllers/authController");

const {
  register,
  login,
  googleAuth,
} = authController;

const authMiddleware = require("../middleware/authMiddleware");

// 🔐 Manual auth
router.post("/register", register);
router.post("/login", login);

// 🔥 Google auth
router.post("/google", googleAuth);

// 👤 Profile APIs
router.get("/user/profile", authMiddleware, authController.getProfile);
router.put("/user/profile", authMiddleware, authController.updateProfile);
router.put("/change-password", authMiddleware, authController.changePassword);
router.post("/assign", authMiddleware, authController.assignProfessional);
router.get("/user/experts", authMiddleware, authController.getAssignedExperts);

module.exports = router;