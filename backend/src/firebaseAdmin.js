const admin = require("firebase-admin");

const serviceAccount = require("./serviceAccountKey.json");

// ✅ FIX: Initialize only if not already initialized
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
}

module.exports = admin;