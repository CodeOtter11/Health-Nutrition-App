const jwt = require("jsonwebtoken");
const config = require("../config");

const authMiddleware = (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return res.status(401).json({
        success: false,
        message: "Authorization token missing"
      });
    }

    const token = authHeader.split(" ")[1];

    let decoded = null;

    // Try health app JWT
    try {
      decoded = jwt.verify(
        token,
        config.JWT_SECRET
      );

      console.log("✅ Health token verified");

    } catch (err1) {
      console.log("Health token failed");

      try {
        decoded = jwt.verify(
          token,
          "super_secret_key_here"
        );

        console.log("✅ Dietitian token verified");

      } catch (err2) {
        console.log("Dietitian token failed");

        return res.status(401).json({
          success: false,
          message: "Invalid or expired token"
        });
      }
    }

    req.user = {
      userId: decoded.userId
    };

    next();

  } catch (error) {
    console.log(error);

    return res.status(500).json({
      success: false,
      message: "Server error"
    });
  }
};

module.exports = authMiddleware;