const express = require("express");
const router = express.Router();
const { saveBMI, getBMIHistory } = require("../controllers/bmiController");
const auth = require("../middleware/auth"); // your JWT middleware

router.post("/bmi", auth, saveBMI);
router.get("/bmi", auth, getBMIHistory);

module.exports = router;