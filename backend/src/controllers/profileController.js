const Profile = require("../models/Profile");

/**
 * GET MY PROFILE
 * Auto-creates profile if missing
 */
exports.getMyProfile = async (req, res) => {
  try {
    const userId = req.user.userId;

    let profile = await Profile.findOne({ userId });

    // 🔥 AUTO-CREATE PROFILE
    if (!profile) {
      profile = await Profile.create({ userId });
    }

    res.status(200).json({
      success: true,
      profile,
    });
  } catch (error) {
    console.error("Get profile error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to fetch profile",
    });
  }
};

/**
 * CREATE OR UPDATE PROFILE
 * Used for onboarding + edit profile
 */
exports.updateMyProfile = async (req, res) => {
  try {
    const userId = req.user.userId;

    const profile = await Profile.findOneAndUpdate(
      { userId },
      { $set: req.body },
      {
        new: true,
        upsert: true, // 🔥 create if missing
      }
    );

    res.status(200).json({
      success: true,
      message: "Profile updated successfully",
      profile,
    });
  } catch (error) {
    console.error("Update profile error:", error);
    res.status(500).json({
      success: false,
      message: "Failed to update profile",
    });
  }
};
