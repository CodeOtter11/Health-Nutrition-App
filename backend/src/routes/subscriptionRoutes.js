const express = require("express");
const router = express.Router();

const authMiddleware = require("../middleware/authMiddleware");
const subscriptionController = require("../controllers/subscriptionController");

router.post(
  "/activate-pro",
  authMiddleware,
  subscriptionController.activatePro
);

module.exports = router;