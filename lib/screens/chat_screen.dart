import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  String selectedSupportType = 'AI Bot';

  String get _currentCollectionName =>
      selectedSupportType == 'AI Bot' ? 'ai_support_chats' : 'agent_support_chats';

  void _sendBotReply(String userMessage) async {
    String reply = "";
    String lowerMsg = userMessage.toLowerCase();

    if (lowerMsg.contains("hello") ||
        lowerMsg.contains("hi") ||
        lowerMsg.contains("hey")) {
      reply =
          "Hello! Welcome to MSB Store Bot. How can I assist you today?";
    } else if (lowerMsg.contains("price") ||
        lowerMsg.contains("cost") ||
        lowerMsg.contains("product")) {
      reply =
          "You can browse all our products and prices directly from the Shop section in the app!";
    } else if (lowerMsg.contains("delivery") ||
        lowerMsg.contains("shipping")) {
      reply =
          "We offer secure island-wide delivery services for all customer orders.";
    } else if (lowerMsg.contains("payment") ||
        lowerMsg.contains("card")) {
      reply =
          "We support both online card payments and Cash on Delivery options.";
    } else {
      reply =
          "I'm a bot! If you need human assistance, please select 'Live Agent' from the menu.";
    }

    await FirebaseFirestore.instance.collection('ai_support_chats').add({
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'message': reply,
      'sender': 'bot',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Please login first to send messages!'),
            backgroundColor: Colors.red),
      );
      Navigator.push(
              context, MaterialPageRoute(builder: (context) => LoginScreen()))
          .then((_) => setState(() {}));
      return;
    }

    String messageText = _messageController.text.trim();
    _messageController.clear();

    try {
      await FirebaseFirestore.instance.collection(_currentCollectionName).add({
        'userId': user.uid,
        'userEmail': user.email ?? 'Unknown',
        'message': messageText,
        'sender': 'user',
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (selectedSupportType == 'AI Bot') {
        Future.delayed(Duration(seconds: 1), () {
          _sendBotReply(messageText);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error sending message: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  void _showSupportSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFF1E222B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Select Chat Support",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                "Choose who you want to talk with:",
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              SizedBox(height: 15),
              ListTile(
                leading: Icon(Icons.smart_toy, color: Colors.amber),
                title: Text("AI Bot",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Text("Instant automatic replies",
                    style: TextStyle(color: Colors.white54, fontSize: 12)),
                trailing: selectedSupportType == 'AI Bot'
                    ? Icon(Icons.check_circle, color: Colors.amber)
                    : null,
                onTap: () {
                  setState(() {
                    selectedSupportType = 'AI Bot';
                  });
                  Navigator.pop(context);
                },
              ),
              Divider(color: Colors.white24),
              ListTile(
                leading: Icon(Icons.support_agent, color: Colors.blueAccent),
                title: Text("Live Agent",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Text("Talk with a real human support member",
                    style: TextStyle(color: Colors.white54, fontSize: 12)),
                trailing: selectedSupportType == 'Live Agent'
                    ? Icon(Icons.check_circle, color: Colors.blueAccent)
                    : null,
                onTap: () {
                  setState(() {
                    selectedSupportType = 'Live Agent';
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;
    bool isBotActive = (selectedSupportType == 'AI Bot');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1E222B),
        title: Text('Customer Support',
            style: TextStyle(color: Colors.white, fontSize: 18)),
        actions: [
          if (currentUser != null)
            Padding(
              padding: EdgeInsets.only(right: 12.0),
              child: Center(
                child: InkWell(
                  onTap: _showSupportSelector,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isBotActive
                              ? Icons.smart_toy
                              : Icons.support_agent,
                          size: 16,
                          color: Colors.amber,
                        ),
                        SizedBox(width: 6),
                        Text(
                          "Chat with: $selectedSupportType",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down,
                            size: 16, color: Colors.white70),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: currentUser == null
          ? Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.support_agent,
                        size: 70, color: Colors.amber[800]),
                    SizedBox(height: 16),
                    Text('Login Required',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text(
                      'Please login to chat with our support team or bot.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.grey[600], fontSize: 14),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber[800],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginScreen()),
                        ).then((_) => setState(() {}));
                      },
                      child: Text('Login Now',
                          style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                Container(
                  color: isBotActive ? Colors.amber[50] : Colors.blue[50],
                  padding:
                      EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                  child: Row(
                    children: [
                      Icon(
                        isBotActive
                            ? Icons.smart_toy
                            : Icons.support_agent,
                        size: 18,
                        color: isBotActive
                            ? Colors.amber[800]
                            : Colors.blue[800],
                      ),
                      SizedBox(width: 8),
                      Text(
                        isBotActive
                            ? "AI Chat Bot is active. Type a message for instant replies."
                            : "Live Agent mode active. Our support team will respond soon.",
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection(_currentCollectionName)
                        .where('userId', isEqualTo: currentUser.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(
                            child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData ||
                          snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Text(
                            isBotActive
                                ? 'No messages with AI Bot yet. Say hello!'
                                : 'No messages with Live Agent yet. Send a message to start.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }

                      var messages = snapshot.data!.docs;

                      messages.sort((a, b) {
                        var aData = a.data() as Map<String, dynamic>;
                        var bData = b.data() as Map<String, dynamic>;
                        var aTime = aData['timestamp'] ?? Timestamp.now();
                        var bTime = bData['timestamp'] ?? Timestamp.now();
                        return bTime.compareTo(aTime);
                      });

                      return ListView.builder(
                        reverse: true,
                        padding: EdgeInsets.all(16),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          var msgData = messages[index].data()
                              as Map<String, dynamic>;
                          String message = msgData['message'] ?? '';
                          String sender = msgData['sender'] ?? 'user';
                          bool isUser = sender == 'user';
                          bool isBot = sender == 'bot';
                          bool isAgent =
                              (sender == 'agent' || sender == 'admin');

                          return Align(
                            alignment: isUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 4),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isUser
                                    ? Colors.amber[800]
                                    : (isBot
                                        ? Colors.blueGrey[100]
                                        : (isAgent
                                            ? Colors.blue[700]
                                            : Colors.grey[200])),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  if (isBot)
                                    Padding(
                                      padding:
                                          EdgeInsets.only(bottom: 2),
                                      child: Text(
                                        "AI Bot",
                                        style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blueGrey[800]),
                                      ),
                                    ),
                                  if (isAgent)
                                    Padding(
                                      padding:
                                          EdgeInsets.only(bottom: 2),
                                      child: Text(
                                        "Live Agent",
                                        style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white70),
                                      ),
                                    ),
                                  Text(
                                    message,
                                    style: TextStyle(
                                      color: isUser || isAgent
                                          ? Colors.white
                                          : Colors.black87,
                                      fontSize: 15,
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
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, -2))
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: isBotActive
                                ? 'Ask the bot anything...'
                                : 'Message the live agent...',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none),
                            filled: true,
                            fillColor: Colors.grey[100],
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: Colors.amber[800],
                        child: IconButton(
                          icon: Icon(Icons.send,
                              color: Colors.white, size: 18),
                          onPressed: _sendMessage,
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