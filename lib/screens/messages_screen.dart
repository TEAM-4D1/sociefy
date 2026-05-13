import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/app_state.dart';
import 'society_chat_screen.dart';
import 'member_approval_screen.dart';
import '../widgets/app_bar_logo_action.dart';
import '../widgets/app_gradient_background.dart';

/// Fetches the last message for a given society's group chat.
Future<Map<String, dynamic>?> _getLastMessage(String societyId) async {
  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('groupChats')
        .doc(societyId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return null;
    }

    final doc = querySnapshot.docs.first;
    return {
      'text': doc['text'] as String? ?? '',
      'createdAt': doc['createdAt'] as Timestamp?,
    };
  } catch (e) {
    debugPrint('Error fetching last message for society $societyId: $e');
    return null;
  }
}

/// Formats a timestamp as "X mins ago", "X hours ago", or a date string.
String _formatTimestamp(Timestamp? timestamp) {
  if (timestamp == null) return '';

  final messageDate = timestamp.toDate();
  final now = DateTime.now();
  final difference = now.difference(messageDate);

  if (difference.inMinutes < 1) {
    return 'just now';
  } else if (difference.inMinutes < 60) {
    final mins = difference.inMinutes;
    return '$mins min${mins != 1 ? 's' : ''} ago';
  } else if (difference.inHours < 24) {
    final hours = difference.inHours;
    return '$hours hour${hours != 1 ? 's' : ''} ago';
  } else {
    return '${messageDate.month}/${messageDate.day}/${messageDate.year}';
  }
}

/// Displays a list of society group chat channels that the user is a member of.
/// Provides quick access to messages and member approval features for committee admins.
/// Accessible only to authenticated users who have joined societies.
class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final Map<String, Future<Map<String, dynamic>?>> _lastMessageFutures = {};

  Future<Map<String, dynamic>?> _cachedLastMessage(String societyId) {
    return _lastMessageFutures.putIfAbsent(
      societyId,
      () => _getLastMessage(societyId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final joinedSocieties = appState.joinedSocieties;
        final isCommittee = appState.isAdmin;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Messages',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            actions: const [AppBarLogoAction()],
          ),
          body: AppGradientBackground(
            child: joinedSocieties.isEmpty
                ? const Center(
                    child: Text(
                      'Join a society to access its message channel.',
                    ),
                  )
                : ListView.builder(
                    itemCount: joinedSocieties.length,
                    itemBuilder: (context, index) {
                      final society = joinedSocieties[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        color: Colors.white,
                        child: ListTile(
                          leading: const Icon(Icons.forum),
                          title: Text(society.name),
                          subtitle: FutureBuilder<Map<String, dynamic>?>(
                            future: _cachedLastMessage(society.id),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Text('Loading...');
                              }

                              if (snapshot.hasError) {
                                return const Text('Error loading message');
                              }

                              final messageData = snapshot.data;
                              if (messageData == null) {
                                return const Text('No messages yet');
                              }

                              final text = messageData['text'] as String;
                              final timestamp =
                                  messageData['createdAt'] as Timestamp?;
                              final timeAgo = _formatTimestamp(timestamp);

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    text.length > 50
                                        ? '${text.substring(0, 50)}...'
                                        : text,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    timeAgo,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: Colors.grey),
                                  ),
                                ],
                              );
                            },
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    SocietyChatScreen(society: society),
                              ),
                            );
                          },
                          trailing: isCommittee
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.admin_panel_settings,
                                    color: Colors.deepPurple,
                                  ),
                                  tooltip: 'Approve Members',
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      builder: (ctx) => SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                            0.7,
                                        child: MemberApprovalScreen(
                                          societyId: society.id,
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : null,
                        ),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }
}
