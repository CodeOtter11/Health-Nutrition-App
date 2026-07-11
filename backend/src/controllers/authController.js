const User = require("../models/User");
const Profile = require("../models/Profile");
const jwt = require("jsonwebtoken");
const bcrypt = require("bcrypt");
const admin = require("../config/firebaseAdmin");
const config = require("../config");


// ================= REGISTER =================
exports.register = async (req, res) => {
  try {
    const { name, email, phone, password } = req.body;

    if (!name || !email || !phone || !password) {
      return res.status(400).json({ message: "All fields are required" });
    }

    // Check existing user
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ message: "User already exists" });
    }

    // Create user
    const hashedPassword = await bcrypt.hash(password, 10);

    const user = await User.create({
      name,
      email,
      phone,
      password: hashedPassword,
      authProvider: "local",
    });

    // 🔥 CREATE TOKEN (IMPORTANT)
    const token = jwt.sign(
                    { userId: user._id },
                    config.JWT_SECRET,
                    { expiresIn: "1h" }
                  );


    // ✅ SEND TOKEN IN RESPONSE
    res.status(201).json({
      message: "User registered successfully",
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        phone: user.phone,
      },
    });
  } catch (error) {
    console.error("Register error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

// ================= LOGIN =================
exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;

    // 1️⃣ Validate input
    if (!email || !password) {
      return res.status(400).json({
        message: "Email and password required",
      });
    }

    // 2️⃣ Find user
    const user = await User.findOne({ email });

    if (!user) {
      return res.status(401).json({
        message: "Invalid credentials",
      });
    }

    // 3️⃣ Prevent Google users from password login
    if (user.authProvider === "google") {
      return res.status(400).json({
        message: "Please login using Google",
      });
    }

    const isPasswordValid = await bcrypt.compare(password, user.password);

    if (!isPasswordValid) {
      return res.status(401).json({
        message: "Invalid credentials",
      });
    }

    // 5️⃣ Create JWT token
    const token = jwt.sign(
      { userId: user._id },
      config.JWT_SECRET,
      { expiresIn: "1h" }
    );


    // 6️⃣ Success response
    res.status(200).json({
      message: "Login successful",
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        phone: user.phone || "",
        isProUser: user.isProUser,
        subscriptionPlan: user.subscriptionPlan,
        subscriptionExpiryDate: user.subscriptionExpiryDate
      },
    });
  } catch (error) {
    console.error("Login error:", error);
    res.status(500).json({
      message: "Server error",
    });
  }
};

// ================= GOOGLE AUTH =================
exports.googleAuth = async (req, res) => {
  try {
    const { idToken } = req.body;

    if (!idToken) {
      return res.status(400).json({ message: "ID token required" });
    }

    const decodedToken = await admin.auth().verifyIdToken(idToken);

    const { uid, email } = decodedToken;
    const name = decodedToken.name || "Google User";

    if (!email) {
      return res.status(400).json({ message: "Email not found in Google account" });
    }

    let user = await User.findOne({ email });

    // 🚫 Prevent conflict
    if (user && user.authProvider === "local") {
      return res.status(400).json({
        message: "Email already registered with password login",
      });
    }

    if (!user) {
      user = await User.create({
        name,
        email,
        authProvider: "google",
        googleUid: uid,
      });
    }

    const token = jwt.sign(
      { userId: user._id },
      config.JWT_SECRET,
      { expiresIn: "1h" }
    );

    res.status(200).json({
      message: "Google login successful",
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        phone: user.phone || "",
        isProUser: user.isProUser,
        subscriptionPlan: user.subscriptionPlan,
        subscriptionExpiryDate: user.subscriptionExpiryDate
      },
    });
  } catch (error) {
    console.error("Google auth error:", error);
    res.status(401).json({ message: "Invalid Google token" });
  }
};

// ================= GET PROFILE =================
exports.getProfile = async (req, res) => {
  try {

    const user = await User.findById(req.user.userId).select("-password");
    const profile = await Profile.findOne({ userId: req.user.userId });

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    res.status(200).json({
      name: user.name,
      email: user.email,
      phone: user.phone || "",
      city: profile?.city || "",
      authProvider: user.authProvider,
      // PRO DATA
      isProUser: user.isProUser,
      subscriptionPlan: user.subscriptionPlan,
      subscriptionStartDate: user.subscriptionStartDate,
      subscriptionExpiryDate: user.subscriptionExpiryDate,
      consultations: user.consultations
    });

  } catch (error) {
    console.error("Get profile error:", error);
    res.status(500).json({ message: "Server error" });
  }
};


// ================= UPDATE PROFILE =================
exports.updateProfile = async (req, res) => {
  try {
    const { name, email, phone, city } = req.body;

    const user = await User.findById(req.user.userId);

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    // Update USER
    user.name = name || user.name;
    user.phone = phone || user.phone;

    if (user.authProvider !== "google") {
      user.email = email || user.email;
    }

    await user.save();

    // Update PROFILE (with upsert)
    await Profile.findOneAndUpdate(
      { userId: req.user.userId },
      { $set: { city: city } },
      { new: true, upsert: true }
    );

    res.status(200).json({
      message: "Profile updated successfully"
    });

  } catch (error) {
    console.error("Update profile error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

// ================= CHANGE PASSWORD =================
exports.changePassword = async (req, res) => {
  try {
    const { oldPassword, newPassword } = req.body;

    const user = await User.findById(req.user.userId);

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    // Prevent Google users
    if (user.authProvider === "google") {
      return res.status(400).json({
        message: "Google users cannot change password",
      });
    }

    // Check old password
    const isMatch = await bcrypt.compare(oldPassword, user.password);

    if (!isMatch) {
      return res.status(400).json({
        message: "Old password is incorrect",
      });
    }

    // Hash new password
    const hashedPassword = await bcrypt.hash(newPassword, 10);

    user.password = hashedPassword;

    await user.save();

    res.status(200).json({
      message: "Password updated successfully",
    });

  } catch (error) {
    console.error("Change password error:", error);
    res.status(500).json({
      message: "Server error",
    });
  }
};

// ================= ASSIGN PROFESSIONAL =================
const axios = require("axios");

exports.assignProfessional = async (req, res) => {
  try {
    const { role, slot } = req.body;
    const customerId = req.user.userId;

    const token = req.headers.authorization;

    console.log("Incoming Token:", token);

    // First check if already assigned
    const user = await User.findById(customerId);

    const existingConsultation = user.consultations.find(
      (c) => c.role === role && c.slot === slot
    );

    if (existingConsultation) {
      return res.status(200).json({
        message: `${role} already assigned`,
        professionalId: existingConsultation.userId
      });
    }

    // Call dietitian backend only if not assigned
    const response = await axios.post(
      "http://192.168.1.6:5001/api/auth/assign",
      {
        role,
        slot,
        customerId: customerId   // FIX HERE
      },
      {
        headers: {
          Authorization: token
        }
      }
    );

    const professional = response.data.professional;

    // Save only once
    await User.findByIdAndUpdate(customerId, {
      $push: {
        consultations: {
          userId: professional.id,
          role: role,
          slot: slot
        }
      }
    });

    res.status(200).json({
      message: `${role} assigned successfully`,
      professional
    });

  } catch (error) {
    console.log(
      "Assignment Error:",
      error.response?.data || error.message
    );

    res.status(500).json({
      message: "Assignment failed"
    });
  }
};

// ================= GET ASSIGNED EXPERTS =================
exports.getAssignedExperts = async (req, res) => {
  try {
    console.log("GET EXPERTS API HIT");

    const user = await User.findById(req.user.userId);

    if (!user) {
      return res.status(404).json({
        message: "User not found"
      });
    }

    const consultationsWithDetails = [];

    for (const consultation of user.consultations) {
      try {
        const response = await axios.get(
          `http://192.168.1.6:5001/api/auth/professional/${consultation.userId}`
        );

        consultationsWithDetails.push({
          role: consultation.role,
          slot: consultation.slot,
          userId: response.data.professional
        });

      } catch (err) {
        console.log(
          "Professional fetch failed:",
          consultation.userId
        );
      }
    }

    console.log(
      "FINAL CONSULTATIONS:",
      consultationsWithDetails
    );

    res.status(200).json({
      consultations: consultationsWithDetails
    });

  } catch (error) {
    console.log("Get Experts Error:", error);

    res.status(500).json({
      message: "Server error"
    });
  }
};