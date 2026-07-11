const User = require("../models/User");

exports.activatePro = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { plan } = req.body;

    const startDate = new Date();
    let expiryDate = new Date();

    if (plan == "monthly") {
      expiryDate.setMonth(expiryDate.getMonth() + 1);
    } else if (plan == "yearly") {
      expiryDate.setFullYear(expiryDate.getFullYear() + 1);
    } else {
      return res.status(400).json({
        message: "Invalid plan"
      });
    }

    const updatedUser = await User.findByIdAndUpdate(
      userId,
      {
        isProUser: true,
        subscriptionPlan: plan,
        subscriptionStartDate: startDate,
        subscriptionExpiryDate: expiryDate
      },
      { new: true }
    );

    res.status(200).json({
      message: "Pro activated successfully",
      user: updatedUser
    });

  } catch (error) {
    console.log(error);

    res.status(500).json({
      message: "Subscription activation failed"
    });
  }
};