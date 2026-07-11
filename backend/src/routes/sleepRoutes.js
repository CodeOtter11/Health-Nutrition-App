const express = require("express");
const router = express.Router();

const sleepController = require("../controllers/sleepController");

router.post("/sleep", sleepController.saveSleep);
router.get("/sleep/:userId/:date", sleepController.getSleep);
router.get("/sleep/weekly/:userId", sleepController.getWeeklySleep);

module.exports = router;