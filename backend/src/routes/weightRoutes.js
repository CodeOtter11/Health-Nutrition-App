const express = require("express");
const router = express.Router();

const {
  saveGoal,
  addWeight,
  getWeightData,
} = require("../controllers/weightController");

const authMiddleware = require("../middleware/authMiddleware");

router.post("/weight/goal", authMiddleware, saveGoal);
router.post("/weight", authMiddleware, addWeight);
router.get("/weight", authMiddleware, getWeightData);

module.exports = router;