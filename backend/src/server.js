const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const http = require("http");
const { Server } = require("socket.io");

const config = require("./config");

const app = express();
const server = http.createServer(app); // NEW

// =======================
// SOCKET.IO
// =======================
const io = new Server(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  }
});

// make io globally accessible
global.io = io;

io.on("connection", (socket) => {
  console.log("🔥 User connected:", socket.id);

  socket.on("joinChat", (roomId) => {
    socket.join(roomId);
    console.log("Joined room:", roomId);
  });

  socket.on("disconnect", () => {
    console.log("User disconnected");
  });
});

// =======================
// MIDDLEWARES
// =======================
app.use(cors({
  origin: "*",
  methods: ["GET", "POST", "PUT", "DELETE"],
  allowedHeaders: ["Content-Type", "Authorization"]
}));

app.use(express.json());

// =======================
// ROUTES
// =======================

const authRoutes = require("./routes/authRoutes");
app.use("/api/auth", authRoutes);

const profileRoutes = require("./routes/profileRoutes");
app.use("/api/profile", profileRoutes);

const mealRoutes = require("./routes/mealRoutes");
app.use("/api/meals", mealRoutes);

const waterRoutes = require("./routes/waterRoutes");
app.use("/api/tracker", waterRoutes);

const sleepRoutes = require("./routes/sleepRoutes");
app.use("/api/tracker", sleepRoutes);

const bmiRoutes = require("./routes/bmiRoutes");
app.use("/api/tracker", bmiRoutes);

const weightRoutes = require("./routes/weightRoutes");
app.use("/api/tracker", weightRoutes);

const workoutRoutes = require("./routes/workoutRoutes");
app.use("/api/tracker", workoutRoutes);

const userRoutes = require("./routes/userRoutes");
app.use("/api/user", userRoutes);

const dietitianRoutes = require("./routes/dietitianRoutes");
app.use("/api/dietitian", dietitianRoutes);

const chatRoutes = require("./routes/chatRoutes");
app.use("/api/chat", chatRoutes);

const subscriptionRoutes = require("./routes/subscriptionRoutes");
app.use("/api/subscription", subscriptionRoutes);

app.use("/api/notifications", require("./routes/notificationRoutes"));

require("./cronJobs");

const errorHandler = require("./middleware/errorHandler");
app.use(errorHandler);

// =======================
// TEST ROUTE
// =======================
app.get("/", (req, res) => {
  res.send("Meal Plan API is running 🚀");
});

// =======================
// MONGODB CONNECTION
// =======================
mongoose.connect(config.MONGO_URI)
  .then(() => {
    console.log("✅ MongoDB connected");
  })
  .catch((err) => {
    console.error("❌ MongoDB connection error:", err);
  });

// =======================
// START SERVER
// =======================
server.listen(5000, "0.0.0.0", () => {
  console.log("🚀 Server running with Socket.IO on port 5000");
});