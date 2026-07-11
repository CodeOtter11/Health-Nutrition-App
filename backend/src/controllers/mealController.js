const Meal = require("../models/Meal");
const User = require("../models/User");

// ADD MEAL
exports.addMeal = async (req, res) => {
  try {
   const {
     mealType,
     name,
     calories,
     protein,
     carbs,
     fat,
     fiber,
     sugar,
     saturatedFats,
     quantity,
     unit,
     grams,
   } = req.body;

    const meal = await Meal.create({
      userId: req.user.userId,
      mealType,
      name,
      calories,
      protein,
      carbs,
      fat,
      fiber,
      sugar,
      saturatedFats,
      quantity,
      unit,
      grams,
      date: new Date(),
    });

    res.status(201).json(meal);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Failed to add meal" });
  }
};

// GET MEALS BY DATE
exports.getMealsByDate = async (req, res) => {
  try {
    const { date } = req.query;

    if (!date) {
      return res.status(400).json({ message: "Date is required" });
    }

    const start = new Date(date);
    start.setHours(0, 0, 0, 0);

    const end = new Date(date);
    end.setHours(23, 59, 59, 999);

    const meals = await Meal.find({
      userId: req.user.userId,
      date: { $gte: start, $lte: end },
    });

    res.json(meals);
  } catch (error) {
    res.status(500).json({ message: "Failed to fetch meals" });
  }
};

// DELETE MEAL
exports.deleteMeal = async (req, res) => {
  try {
    await Meal.findOneAndDelete({
      _id: req.params.id,
      userId: req.user.userId,
    });

    res.json({ message: "Meal deleted" });
  } catch (error) {
    res.status(500).json({ message: "Failed to delete meal" });
  }
};

// GET TODAY SUMMARY (FOR PROGRESS PAGE)
exports.getTodaySummary = async (req, res) => {
  try {
    const userId = req.user.userId;

    const now = new Date();
    const start = new Date(now);
    start.setUTCHours(0, 0, 0, 0);

    const end = new Date(now);
    end.setUTCHours(23, 59, 59, 999);

    const meals = await Meal.find({
      userId,
      date: { $gte: start, $lte: end },
    });

    let totalCalories = 0;
    let protein = 0;
    let carbs = 0;
    let fat = 0;
    let fiber = 0;
    let sugar = 0;
    let saturatedFats = 0;

    meals.forEach((meal) => {
      totalCalories += meal.calories || 0;
      protein += meal.protein || 0;
      carbs += meal.carbs || 0;
      fat += meal.fat || 0;

      fiber += meal.fiber || 0;
      sugar += meal.sugar || 0;
      saturatedFats += meal.saturatedFats || 0;
    });

   const user = await User.findById(userId);

   const goalCalories = user.goalCalories || 2000;

    res.status(200).json({
      totalCalories,
      macros: {
        protein,
        carbs,
        fat,
        fiber,
        sugar,
        saturatedFats,
      },
      goalCalories,
      remainingCalories: Math.max(0, goalCalories - totalCalories),
    });

  } catch (error) {
    console.error("Today summary error:", error);
    res.status(500).json({ message: "Failed to fetch today summary" });
  }
};

// GET WEEKLY SUMMARY (FOR PROGRESS PAGE)
exports.getWeeklySummary = async (req, res) => {
  try {
    const userId = req.user.userId;

    const now = new Date();

    // Start of week (Sunday)
    const startOfWeek = new Date(now);
    startOfWeek.setUTCHours(0, 0, 0, 0);
    startOfWeek.setUTCDate(now.getUTCDate() - now.getUTCDay());

    const endOfWeek = new Date(startOfWeek);
    endOfWeek.setUTCDate(startOfWeek.getUTCDate() + 7);

    const meals = await Meal.find({
      userId,
      date: { $gte: startOfWeek, $lt: endOfWeek },
    });

    const result = {
      Sun: 0,
      Mon: 0,
      Tue: 0,
      Wed: 0,
      Thu: 0,
      Fri: 0,
      Sat: 0,
    };

    meals.forEach((meal) => {
      const day = meal.date.getUTCDay(); // 0 = Sun
      const map = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
      result[map[day]] += meal.calories || 0;
    });

    res.status(200).json(result);

  } catch (error) {
    console.error("Weekly summary error:", error);
    res.status(500).json({ message: "Failed to fetch weekly summary" });
  }
};