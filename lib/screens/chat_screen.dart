import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatScreen extends StatefulWidget {
  final String expertId;

  const ChatScreen({
    super.key,
    required this.expertId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController controller = TextEditingController();

  List<dynamic> messages = [];
  String? myId;
  IO.Socket? socket;

  String baseUrl = "http://192.168.1.6:5000";

  @override
  void initState() {
    super.initState();
    initializeChat();
  }

  Future<void> initializeChat() async {
    await loadMyId();
    await loadMessages();
    connectSocket();
  }

  Future<void> loadMyId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    myId = prefs.getString("userId");
  }

  void connectSocket() {
    socket = IO.io(
      baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .enableAutoConnect()
          .build(),
    );

    socket!.connect();

    socket!.onConnect((_) {
      final roomId = [myId, widget.expertId]..sort();
      final finalRoom = roomId.join("_");
      socket!.emit("joinChat", finalRoom);
    });

    socket!.on("receiveMessage", (data) {
      final alreadyExists =
      messages.any((msg) => msg["_id"] == data["_id"]);

      if (!alreadyExists) {
        setState(() {
          messages.add(data);
        });
      }
    });
  }

  Future<void> loadMessages() async {
    try {
      SharedPreferences prefs =
      await SharedPreferences.getInstance();

      String? token = prefs.getString("auth_token");

      final response = await http.get(
        Uri.parse("$baseUrl/api/chat/${widget.expertId}"),
        headers: {"Authorization": "Bearer $token"},
      );

      final data = jsonDecode(response.body);

      setState(() {
        messages = data;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> sendMessage() async {
    if (controller.text.trim().isEmpty) return;

    final messageText = controller.text.trim();

    try {
      SharedPreferences prefs =
      await SharedPreferences.getInstance();

      String? token = prefs.getString("auth_token");

      final response = await http.post(
        Uri.parse("$baseUrl/api/chat/send"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "receiverId": widget.expertId,
          "message": messageText,
        }),
      );

      if (response.statusCode == 200) {
        controller.clear();
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: isDark
            ? const Color(0xFF2E7D32)
            : const Color(0xFFA5D6A7),
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: theme.cardColor,
              child: const Icon(Icons.person, color: Colors.green),
            ),
            const SizedBox(width: 10),
            const Text("Chat"),
          ],
        ),
      ),

      body: Column(
        children: [

          // 🔹 MESSAGES
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMe = msg["senderId"] == myId;

                return Align(
                  alignment: isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    constraints:
                    const BoxConstraints(maxWidth: 260),
                    decoration: BoxDecoration(
                      color: isMe
                          ? const Color(0xff4CAF50)
                          : theme.cardColor,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft:
                        Radius.circular(isMe ? 16 : 0),
                        bottomRight:
                        Radius.circular(isMe ? 0 : 16),
                      ),
                    ),
                    child: Text(
                      msg["message"],
                      style: TextStyle(
                        color: isMe
                            ? Colors.white
                            : theme.textTheme.bodyMedium!.color,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 🔹 INPUT
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.cardColor,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.black26
                          : const Color(0xffF1F3F2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: "Type message...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xff4CAF50),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send,
                        color: Colors.white),
                    onPressed: sendMessage,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    socket?.disconnect();
    socket?.dispose();
    controller.dispose();
    super.dispose();
  }
}