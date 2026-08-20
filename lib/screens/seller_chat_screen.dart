import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';

class SellerChatScreen extends StatefulWidget {
  final String productId;
  final String productName;
  final String sellerId;
  final String sellerName;

  const SellerChatScreen({
    Key? key,
    required this.productId,
    required this.productName,
    required this.sellerId,
    required this.sellerName,
  }) : super(key: key);

  @override
  State<SellerChatScreen> createState() => _SellerChatScreenState();
}

class _SellerChatScreenState extends State<SellerChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _isSending = false;

  String get _conversationId {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
    final safeSellerId = widget.sellerId.replaceAll(
      RegExp(r'[^a-zA-Z0-9_-]'),
      '_',
    );
    return '${userId}_$safeSellerId';
  }

  CollectionReference<Map<String, dynamic>> get _messages => FirebaseFirestore
      .instance
      .collection('seller_chats')
      .doc(_conversationId)
      .collection('messages');

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    final user = FirebaseAuth.instance.currentUser;
    if (message.isEmpty || user == null || _isSending) return;

    _messageController.clear();
    setState(() => _isSending = true);
    final conversation = FirebaseFirestore.instance
        .collection('seller_chats')
        .doc(_conversationId);

    try {
      await conversation.set({
        'buyerId': user.uid,
        'buyerEmail': user.email ?? '',
        'sellerId': widget.sellerId,
        'sellerName': widget.sellerName,
        'lastProductId': widget.productId,
        'lastProductName': widget.productName,
        'productIds': FieldValue.arrayUnion([widget.productId]),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await _messages.add({
        'message': message,
        'sender': 'buyer',
        'senderId': user.uid,
        'productId': widget.productId,
        'productName': widget.productName,
        'createdAt': Timestamp.now(),
        'timestamp': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message sent successfully.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to send message: $error')));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final colorScheme = Theme.of(context).colorScheme;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chat with Seller')),
        body: Center(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.login),
            label: const Text('Login to chat'),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => LoginScreen()),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.sellerName)),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: colorScheme.primaryContainer,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(
              'About ${widget.productName}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _messages.orderBy('createdAt').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data?.docs ?? [];
                if (messages.isEmpty) {
                  return const Center(
                    child: Text('Ask the seller about this product.'),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final data = messages[index].data();
                    final isBuyer = data['sender'] == 'buyer';
                    return Align(
                      alignment: isBuyer
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        constraints: const BoxConstraints(maxWidth: 320),
                        decoration: BoxDecoration(
                          color: isBuyer
                              ? colorScheme.primary
                              : colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          data['message'] ?? '',
                          style: TextStyle(
                            color: isBuyer
                                ? colorScheme.onPrimary
                                : colorScheme.onSurface,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: const InputDecoration(
                        hintText: 'Message the seller...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    icon: _isSending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
