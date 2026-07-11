const express = require("express");
const router = express.Router();

const waterController = require("../controllers/waterController");

// ✅ POST
router.post("/water", waterController.saveWater);

// 🔥 WEEKLY FIRST
router.get("/water/weekly/:userId", waterController.getWeeklyWater);

// 🔥 THEN DAILY
router.get("/water/:userId/:date", waterController.getWater);

// TEST
router.get("/test", (req, res) => {
  res.send("Water route working ✅");
});

console.log("🔥 WATER ROUTES LOADED");

module.exports = router;