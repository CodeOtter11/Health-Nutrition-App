const express = require("express");
const router = express.Router();
const auth = require("../middleware/auth");
const mealController = require("../controllers/mealController");

router.get("/summary/today", auth, mealController.getTodaySummary);
router.get("/weekly-summary", auth, mealController.getWeeklySummary);

router.post("/", auth, mealController.addMeal);
router.get("/", auth, mealController.getMealsByDate);

// ✅ ADD THIS LINE
router.delete("/:id", auth, mealController.deleteMeal);

module.exports = router;