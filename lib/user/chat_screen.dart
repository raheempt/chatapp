

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  final String currentUser;
  final String otherUser;
  final String otherName;

  const ChatScreen({
    super.key,
    required this.currentUser,
    required this.otherUser,
    required this.otherName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageController = TextEditingController();

  String getChatId() {
    return widget.currentUser.compareTo(widget.otherUser) > 0
        ? "${widget.currentUser}_${widget.otherUser}"
        : "${widget.otherUser}_${widget.currentUser}";
  }

  Future<void> sendMessage() async {
    if (messageController.text.trim().isEmpty) return;

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(getChatId())
        .collection('messages')
        .add({
      'text': messageController.text.trim(),
      'sender': widget.currentUser,
      'timestamp': Timestamp.now(),
    });

    messageController.clear();
  }

  String formatTime(Timestamp? ts) {
    if (ts == null) return "";
    final dt = ts.toDate();
    return "${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final chatId = getChatId();

    return Scaffold(
      /// 🔝 APPBAR
      appBar: AppBar(
        backgroundColor: const Color(0xFF075E54),
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.green),
            ),
            const SizedBox(width: 10),
            Text(widget.otherName),
          ],
        ),
      ),

      /// 📱 BODY
      body: Column(
        children: [
          /// 💬 MESSAGES
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe =
                        msg['sender'] == widget.currentUser;

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        constraints: BoxConstraints(
                          maxWidth:
                              MediaQuery.of(context).size.width * 0.7,
                        ),
                        decoration: BoxDecoration(
                          color: isMe
                              ? const Color(0xFFDCF8C6) // WhatsApp green
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              msg['text'],
                              style: const TextStyle(fontSize: 15),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formatTime(msg['timestamp']),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          /// ✍️ INPUT AREA
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            color: Colors.grey[100],
            child: Row(
              children: [
                /// TEXT FIELD
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: messageController,
                      decoration: const InputDecoration(
                        hintText: "Type a message",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                /// SEND BUTTON
                CircleAvatar(
                  backgroundColor: const Color(0xFF25D366),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}