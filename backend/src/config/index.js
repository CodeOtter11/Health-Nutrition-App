/**
 * Centralized environment configuration
 * This file loads .env and exports all env variables
 */

require("dotenv").config();

module.exports = {
  // Server
  PORT: process.env.PORT || 5000,

  // Database
  MONGO_URI: process.env.MONGO_URI,

  // Auth
  JWT_SECRET: process.env.JWT_SECRET,

  // Environment (optional but useful)
  NODE_ENV: process.env.NODE_ENV || "development",
};
