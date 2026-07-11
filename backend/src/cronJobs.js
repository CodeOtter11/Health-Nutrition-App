const cron = require("node-cron");
const admin = require("./firebaseAdmin");

// 🍳 Breakfast - 9 AM
cron.schedule("0 9 * * *", async () => {
  console.log("🍳 Breakfast reminder triggered");

  await admin.messaging().send({
    notification: {
      title: "Breakfast Time 🍳",
      body: "Start your day with healthy food!",
    },
    topic: "all_users",
    android: { priority: "high" },
  });
});

// 🍛 Lunch - 1 PM
cron.schedule("0 13 * * *", async () => {
  console.log("🍛 Lunch reminder triggered");

  await admin.messaging().send({
    notification: {
      title: "Lunch Time 🍛",
      body: "Fuel your body properly!",
    },
    topic: "all_users",
    android: { priority: "high" },
  });
});

// 🍽 Dinner - 8 PM
cron.schedule("0 20 * * *", async () => {
  console.log("🍽 Dinner reminder triggered");

  await admin.messaging().send({
    notification: {
      title: "Dinner Time 🍽",
      body: "Eat light & stay healthy!",
    },
    topic: "all_users",
    android: { priority: "high" },
  });
});

// 💧 Water every 2 hours
cron.schedule("0 */2 * * *", async () => {
  console.log("💧 Water reminder triggered");

  await admin.messaging().send({
    notification: {
      title: "Stay Hydrated 💧",
      body: "Drink water now!",
    },
    topic: "all_users",
    android: { priority: "high" },
  });
});