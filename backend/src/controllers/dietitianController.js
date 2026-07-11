const mongoose = require("mongoose");
const DietitianRequest = require("../models/DietitianRequest");

// your existing models
const Profile = require("../models/Profile");
const Meal = require("../models/Meal");
const Weight = require("../models/WeightLog");
const Water = require("../models/waterTracker");
const Workout = require("../models/workoutLog");
const Sleep = require("../models/sleepTracker");


// ✅ 1. Send Request (FIXED)
exports.sendRequest = async (req, res) => {
  try {
    const { userId, dietitianId, message } = req.body;

    // 🔥 prevent duplicate request
    const existing = await DietitianRequest.findOne({
      userId,
      dietitianId,
    });

    if (existing) {
      return res.status(400).json({
        message: "Request already sent",
      });
    }

    const request = new DietitianRequest({
      userId: new mongoose.Types.ObjectId(userId),
      dietitianId: new mongoose.Types.ObjectId(dietitianId),
      message,
      status: "pending", // 🔥 IMPORTANT FIX
    });

    await request.save();

    res.json({ message: "Request sent successfully" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};


// ✅ 2. Get Requests
exports.getRequests = async (req, res) => {
  try {
    const dietitianId = new mongoose.Types.ObjectId(req.params.dietitianId);

    const requests = await DietitianRequest.find({ dietitianId })
      .populate("userId", "name email")
      .sort({ createdAt: -1 }); // 🔥 latest first

    res.json(requests);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};


// ✅ 3. Accept Request (FIX SAFE)
exports.acceptRequest = async (req, res) => {
  try {
    const { requestId } = req.params;

    console.log("ACCEPTING ID:", requestId); // 🔥 DEBUG

    const updatedRequest = await DietitianRequest.findByIdAndUpdate(
      requestId,
      { status: "accepted" },
      { new: true }
    );

    if (!updatedRequest) {
      return res.status(404).json({ message: "Request not found" });
    }

    res.status(200).json({
      success: true,
      request: updatedRequest,
    });

  } catch (err) {
    console.error("ACCEPT ERROR:", err);
    res.status(500).json({ error: err.message });
  }
};

// ✅ 4. Reject Request (FIX SAFE)
exports.rejectRequest = async (req, res) => {
  try {
    const { requestId } = req.params;

    const updatedRequest = await DietitianRequest.findByIdAndUpdate(
      requestId,
      { status: "rejected" },
      { new: true }
    );

    if (!updatedRequest) {
      return res.status(404).json({ message: "Request not found" });
    }

    res.status(200).json({
      success: true,
      request: updatedRequest,
    });

  } catch (err) {
    console.error("REJECT ERROR:", err);
    res.status(500).json({ error: err.message });
  }
};

// ✅ 5. Dashboard Stats
exports.getDashboardStats = async (req, res) => {
  try {
    const mongoose = require("mongoose");
    const dietitianId = new mongoose.Types.ObjectId(req.params.dietitianId);

    // ✅ Active Clients
    const activeClients = await DietitianRequest.countDocuments({
      dietitianId,
      status: "accepted",
    });

    // ✅ Total Requests (can act as messages for now)
    const messages = await DietitianRequest.countDocuments({
      dietitianId,
    });

    // ✅ Diet Plans (dummy logic for now = accepted clients)
    const dietPlans = activeClients;

    // ✅ Appointments (dummy logic)
    const appointments = activeClients;

    res.json({
      activeClients,
      messages,
      dietPlans,
      appointments,
    });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};


// ✅ 6. Get FULL USER DATA
exports.getUserFullData = async (req, res) => {
  try {
    const { userId, dietitianId } = req.params;

    const mongoose = require("mongoose");

    // 🔥 convert string → ObjectId
    const objectUserId = new mongoose.Types.ObjectId(userId);
    const objectDietitianId = new mongoose.Types.ObjectId(dietitianId);

    // 🔐 check access
    const request = await DietitianRequest.findOne({
      userId: objectUserId,
      dietitianId: objectDietitianId,
      status: "accepted",
    });

    if (!request) {
      return res.status(403).json({ message: "Access denied" });
    }

    // 🔥 fetch all data correctly
    const userData = {
      profile: await Profile.findOne({ userId: objectUserId }),
      meals: await Meal.find({ userId: objectUserId }),
      weights: await Weight.find({ userId: objectUserId }),
      water: await Water.find({ userId: objectUserId }),
      workouts: await Workout.find({ userId: objectUserId }),
      sleep: await Sleep.find({ userId: objectUserId }),
    };

    console.log("USER DATA:", userData); // 🔥 debug

    res.json(userData);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
const Dietitian = require("../models/Dietitian");

// ✅ DIETITIAN SIGNUP
exports.signupDietitian = async (req, res) => {
  try {
    const { name, email, password } = req.body;

    const existing = await Dietitian.findOne({ email });

    if (existing) {
      return res.status(400).json({ message: "Dietitian already exists" });
    }

    const newDietitian = new Dietitian({
      name,
      email,
      password,
    });

    await newDietitian.save();

    res.json({
      message: "Signup successful",
      dietitian: newDietitian,
    });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// ✅ DIETITIAN LOGIN
exports.loginDietitian = async (req, res) => {
  try {
    const { email, password } = req.body;

    const dietitian = await Dietitian.findOne({ email });

    if (!dietitian) {
      return res.status(404).json({ message: "Dietitian not found" });
    }

    if (dietitian.password !== password) {
      return res.status(400).json({ message: "Invalid password" });
    }

    res.json({
      message: "Login successful",
      dietitianId: dietitian._id,
      dietitian: dietitian,
    });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

module.exports = {
  sendRequest: exports.sendRequest,
  getRequests: exports.getRequests,
  acceptRequest: exports.acceptRequest,
  rejectRequest: exports.rejectRequest,
  getUserFullData: exports.getUserFullData,
  getDashboardStats: exports.getDashboardStats,
  signupDietitian: exports.signupDietitian,
  loginDietitian: exports.loginDietitian,
};