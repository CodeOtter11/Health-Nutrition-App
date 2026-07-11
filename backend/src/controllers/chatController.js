const Chat = require("../models/Chat");
const User = require("../models/User");
const admin = require("../config/firebaseAdmin");

exports.sendMessage = async (req, res) => {
  try {
    const { receiverId, message } = req.body;

    const chat = await Chat.create({
      senderId: req.user.userId,
      receiverId,
      message
    });

    const roomId = [req.user.userId, receiverId]
        .sort()
        .join("_");

    console.log("ROOM ID:", roomId);

    // realtime socket message
    global.io.to(roomId).emit(
      "receiveMessage",
      chat
    );

    console.log("🔥 Message emitted to:", roomId);

    // =========================
    // FCM PUSH NOTIFICATION
    // =========================
    const receiver = await User.findById(receiverId);

    if (receiver?.fcmToken) {
      await admin.messaging().send({
        token: receiver.fcmToken,
        notification: {
          title: "New Message",
          body: message
        },
        data: {
           type: "chat",
           senderId: req.user.userId,
           receiverId: receiverId
        }
      });

      console.log("✅ Push notification sent to dietitian");
    } else {
      console.log("❌ Receiver FCM token not found");
    }

    res.status(200).json(chat);

  } catch (error) {
    console.log("CHAT ERROR:", error);

    res.status(500).json({
      message: "Message sending failed"
    });
  }
};

exports.getMessages = async (req, res) => {
  try {
    const { receiverId } = req.params;

    const chats = await Chat.find({
      $or: [
        {
          senderId: req.user.userId,
          receiverId
        },
        {
          senderId: receiverId,
          receiverId: req.user.userId
        }
      ]
    }).sort({ createdAt: 1 });

    res.status(200).json(chats);

  } catch (error) {
    res.status(500).json({
      message: "Failed to fetch chats"
    });
  }
};