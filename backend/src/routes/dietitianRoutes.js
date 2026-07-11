const express = require("express");
const router = express.Router();

console.log("🔥 DIETITIAN ROUTES LOADED"); // 👈 ADD HERE

const controller = require("../controllers/dietitianController");

// User App
router.post("/request", controller.sendRequest);

// Dietitian App
router.get("/requests/:dietitianId", controller.getRequests);
router.put("/accept/:requestId", controller.acceptRequest);
router.put("/reject/:requestId", controller.rejectRequest);


// Access user data
router.get("/user-data/:userId/:dietitianId", controller.getUserFullData);

// ✅ FIXED LINE
router.get("/stats/:dietitianId", controller.getDashboardStats);
// ✅ NEW AUTH ROUTES (ADD THIS)


module.exports = router;