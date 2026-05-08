import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../models/society.dart';
import '../providers/app_state.dart';
import '../widgets/app_bar_logo_action.dart';

/// Provides real-time group chat functionality for society members with message history.
/// Stores messages in Firestore and updates reactively across all connected users.
/// Accessible only to authenticated users who are members of the society.
class SocietyChatScreen extends StatefulWidget {
  final Society society;

  const SocietyChatScreen({Key? key, required this.society}) : super(key: key);

  @override
  State<SocietyChatScreen> createState() => _SocietyChatScreenState();
}

class _SocietyChatScreenState extends State<SocietyChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  /// Sends a message to the society's group chat and stores it in Firestore with sender information and timestamp.
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    final senderName = (currentUser?.displayName?.isNotEmpty ?? false)
        ? currentUser!.displayName!
        : (currentUser?.email ?? 'User');

    _messageController.clear();

    try {
      await FirebaseFirestore.instance
          .collection('groupChats')
          .doc(widget.society.id)
          .collection('messages')
          .add({
            'text': text,
            'senderName': senderName,
            'senderId': FirebaseAuth.instance.currentUser?.uid ?? '',
            'createdAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error sending message: $e')));
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isGuest = appState.isGuest;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.society.name),
        actions: const [AppBarLogoAction()],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('groupChats')
                  .doc(widget.society.id)
                  .collection('messages')
                  .orderBy('createdAt', descending: false)
                  .limit(100)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading messages.'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(
                    child: Text('No messages yet. Start the conversation!'),
                  );
                }

                // Only scroll to bottom if the controller is attached
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final text = data['text'] as String? ?? '';
                    final senderName =
                        data['senderName'] as String? ?? 'Unknown';
                    final createdAt = data['createdAt'] as Timestamp?;
                    final senderId = data['senderId'] as String? ?? '';

                    String formattedTime = '';
                    if (createdAt != null) {
                      final dateTime = createdAt.toDate();
                      formattedTime =
                          '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
                    }

                    final currentUserId =
                        FirebaseAuth.instance.currentUser?.uid;
                    final isOwnMessage = senderId == currentUserId;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 8.0,
                      ),
                      child: Row(
                        mainAxisAlignment: isOwnMessage
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: isOwnMessage
                                    ? Colors.purple.shade300
                                    : Colors.purple.shade100,
                              ),
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    senderName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isOwnMessage
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    text,
                                    style: TextStyle(
                                      color: isOwnMessage
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    formattedTime,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isOwnMessage
                                          ? Colors.white70
                                          : Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Show sign-in prompt for guests, input row for real users
          if (isGuest)
            Container(
              width: double.infinity,
              color: Colors.grey.shade200,
              padding: const EdgeInsets.all(16),
              child: const Text(
                'Sign in to participate in society chats',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send),
                      color: Theme.of(context).primaryColor,
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
