import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'society_model.dart';

/// Group chat for a joined [Society].
class SocietyChatPage extends StatefulWidget {
  final Society society;

  const SocietyChatPage({super.key, required this.society});

  @override
  State<SocietyChatPage> createState() => _SocietyChatPageState();
}

class _SocietyChatPageState extends State<SocietyChatPage> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  late final List<_ChatMessage> _messages;

  @override
  void initState() {
    super.initState();
    _messages = [
      _ChatMessage(
        sender: 'Jordan K.',
        text: 'Hey everyone! 👋',
        time: '09:10',
      ),
      _ChatMessage(
        sender: 'Alex T.',
        text: 'Did you see the poster for the event?',
        time: '09:12',
      ),
      _ChatMessage(
        sender: 'You',
        text: 'Looks great — I can help set up.',
        time: '09:15',
        isMe: true,
      ),
    ];
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(
        _ChatMessage(sender: 'You', text: text, time: _now(), isMe: true),
      );
    });
    _msgCtrl.clear();

    try {
      final col = FirebaseFirestore.instance
          .collection('society_messages')
          .doc(widget.society.name)
          .collection('messages');
      final docRef = await col.add({
        'sender': 'You',
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
        'edited': false,
      });
      setState(() {
        final last = _messages.lastWhere((m) => m.text == text && m.isMe);
        last.id = docRef.id;
      });
    } catch (e) {
      debugPrint('Firestore write failed: $e');
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _now() {
    final t = DateTime.now();
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  void _deleteMessage(int index) {
    if (index < 0 || index >= _messages.length) return;

    setState(() {
      final msg = _messages.removeAt(index);
      if (msg.id != null) {
        FirebaseFirestore.instance
            .collection('society_messages')
            .doc(widget.society.name)
            .collection('messages')
            .doc(msg.id)
            .delete()
            .catchError((e) => debugPrint('Failed to delete message: $e'));
      }
    });
  }

  Future<void> _editMessage(int index) async {
    if (index < 0 || index >= _messages.length) return;

    final msg = _messages[index];
    final controller = TextEditingController(text: msg.text);

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit message'),
        content: TextField(
          controller: controller,
          maxLines: null,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter your message',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && result != msg.text) {
      setState(() {
        _messages[index].text = result;
        _messages[index].edited = true;
      });

      final id = _messages[index].id;
      if (id != null) {
        try {
          await FirebaseFirestore.instance
              .collection('society_messages')
              .doc(widget.society.name)
              .collection('messages')
              .doc(id)
              .update({
                'text': result,
                'edited': true,
                'editedAt': FieldValue.serverTimestamp(),
              });
        } catch (e) {
          debugPrint('Failed to persist edit: $e');
        }
      }
    }
  }

  Future<void> _confirmDelete(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete message'),
        content: const Text('Are you sure you want to delete this message?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _deleteMessage(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 17,
              backgroundColor: cs.primaryContainer,
              child: Icon(Icons.groups, size: 18, color: cs.onPrimaryContainer),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.society.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${widget.society.members.length} members',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              itemCount: _messages.length,
              itemBuilder: (ctx, i) => _ChatBubble(
                msg: _messages[i],
                onEdit: () => _editMessage(i),
                onDelete: () => _confirmDelete(i),
              ),
            ),
          ),
          _MessageInput(controller: _msgCtrl, onSend: _sendMessage),
        ],
      ),
    );
  }
}

/// Message data model
class _ChatMessage {
  final String sender;
  String text;
  final String time;
  final bool isMe;
  String? id;
  bool edited;

  _ChatMessage({
    required this.sender,
    required this.text,
    required this.time,
    this.isMe = false,
  });
}

/// Chat bubble widget with three-dot menu
class _ChatBubble extends StatelessWidget {
  final _ChatMessage msg;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _ChatBubble({required this.msg, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isMe = msg.isMe;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar for other users
          if (!isMe) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: cs.secondaryContainer,
              child: Text(
                msg.sender[0],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: cs.onSecondaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 6),
          ],

          // Three-dot menu before bubble for own messages
          if (isMe) _buildMenu(cs),

          // Message bubble
          Flexible(
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                // Sender name for other users
                if (!isMe)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 2),
                    child: Text(
                      msg.sender,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),

                // Bubble container
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isMe ? cs.primary : cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isMe ? 18 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 18),
                    ),
                  ),
                  child: Text(
                    msg.text,
                    style: TextStyle(
                      color: isMe ? cs.onPrimary : cs.onSurface,
                      fontSize: 14,
                    ),
                  ),
                ),

                // Timestamp and edited indicator
                Padding(
                  padding: const EdgeInsets.only(top: 3, left: 4, right: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        msg.time,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      if (msg.edited) ...[
                        const SizedBox(width: 6),
                        Text(
                          'edited',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade500,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Three-dot menu after bubble for other users
          if (!isMe) _buildMenu(cs),

          const SizedBox(width: 6),
        ],
      ),
    );
  }

  Widget _buildMenu(ColorScheme cs) {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      iconSize: 18,
      icon: Icon(Icons.more_vert, color: Colors.grey.shade400),
      tooltip: 'Message options',
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit?.call();
            break;
          case 'delete':
            onDelete?.call();
            break;
        }
      },
      itemBuilder: (ctx) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 18),
              SizedBox(width: 8),
              Text('Edit'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 18),
              SizedBox(width: 8),
              Text('Delete'),
            ],
          ),
        ),
      ],
    );
  }
}

/// Message input field
class _MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _MessageInput({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Type a message…',
                  filled: true,
                  fillColor: cs.surfaceContainerHighest,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => onSend(),
              ),
            ),
            const SizedBox(width: 8),
            FloatingActionButton.small(
              onPressed: onSend,
              backgroundColor: cs.primary,
              foregroundColor: cs.onPrimary,
              heroTag: 'chat_send',
              child: const Icon(Icons.send, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
