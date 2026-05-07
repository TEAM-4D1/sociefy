import 'package:flutter/material.dart';
import 'society_model.dart';

/// Group chat for a joined [Society].
///
/// This is the prototype-grade "Forum" surface referenced by the
/// `Messages / Forums go here` screen. Messages are kept entirely in
/// memory — there's no backend yet — so a fresh seeded conversation is
/// rebuilt every time the page is opened. The page is reachable from two
/// places:
///   1. Tapping a row on the Messages tab.
///   2. Tapping the `Chat` button on `SocietyDetailPage` after joining.
class SocietyChatPage extends StatefulWidget {
  /// The society whose group is being viewed. Used for the AppBar title,
  /// member count, and to keep the seeded conversation in scope.
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
        text: 'Looking forward to the next meetup!',
        time: '09:12',
      ),
      _ChatMessage(
        sender: 'Sam R.',
        text: "When's the next session?",
        time: '09:15',
      ),
      _ChatMessage(
        sender: 'Morgan W.',
        text: 'Check the announcements tab 📢',
        time: '09:20',
      ),
      _ChatMessage(
        sender: 'You',
        text: 'Just joined — really excited to be here! 🎉',
        time: '09:25',
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

  /// Append the trimmed contents of [_msgCtrl] as a new message from the
  /// current user, then scroll to the bottom on the next frame so the new
  /// bubble is visible.
  void _sendMessage() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(
        _ChatMessage(sender: 'You', text: text, time: _now(), isMe: true),
      );
    });
    _msgCtrl.clear();
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

  /// Wall-clock timestamp formatted as `HH:mm`, used as the timestamp on
  /// messages the user sends from this session.
  String _now() {
    final t = DateTime.now();
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  /// Delete the message at [index].
  void _deleteMessage(int index) {
    setState(() {
      if (index >= 0 && index < _messages.length) {
        _messages.removeAt(index);
      }
    });
  }

  /// Show an edit dialog for the message at [index]. If confirmed, updates the message text.
  Future<void> _showEditDialog(int index) async {
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

    if (result != null && result.isNotEmpty) {
      setState(() {
        _messages[index].text = result;
      });
    }
  }

  /// Show options for a message (edit/delete) when the bubble is long-pressed.
  void _showMessageOptions(int index) {
    if (index < 0 || index >= _messages.length) return;
    final msg = _messages[index];
    // Only allow edit/delete for messages sent by current user.
    if (!msg.isMe) return;

    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit message'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _showEditDialog(index);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete message'),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (c) => AlertDialog(
                      title: const Text('Delete message'),
                      content: const Text(
                        'Are you sure you want to delete this message?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(c).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(c).pop(true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    _deleteMessage(index);
                  }
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
                onLongPress: () => _showMessageOptions(i),
                onEdit: () => _showEditDialog(i),
                onDelete: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (c) => AlertDialog(
                      title: const Text('Delete message'),
                      content: const Text(
                        'Are you sure you want to delete this message?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(c).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(c).pop(true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) _deleteMessage(i);
                },
              ),
            ),
          ),
          // Input bar
          Container(
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
                      controller: _msgCtrl,
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
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton.small(
                    onPressed: _sendMessage,
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                    heroTag: 'chat_send',
                    child: const Icon(Icons.send, size: 20),
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

/// One entry in the in-memory chat log.
class _ChatMessage {
  /// Display name shown above the bubble for incoming messages.
  final String sender;

  /// Body text of the message.
  String text;

  /// `HH:mm` timestamp shown beneath the bubble.
  final String time;

  /// True when this message was sent by the current user — flips the
  /// bubble alignment, colour, and corner radius.
  final bool isMe;

  _ChatMessage({
    required this.sender,
    required this.text,
    required this.time,
    this.isMe = false,
  });
}

/// Single bubble row in the chat list. Layout direction, colour and corner
/// radii flip based on `msg.isMe`.
class _ChatBubble extends StatelessWidget {
  final _ChatMessage msg;
  final VoidCallback? onLongPress;

  const _ChatBubble({required this.msg, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isMe = msg.isMe;

    return GestureDetector(
      onLongPress: onLongPress,
      onSecondaryTap: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: isMe
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
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
            Flexible(
              child: Column(
                crossAxisAlignment: isMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
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
                        bottomLeft: isMe
                            ? const Radius.circular(18)
                            : const Radius.circular(4),
                        bottomRight: isMe
                            ? const Radius.circular(4)
                            : const Radius.circular(18),
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
                  Padding(
                    padding: const EdgeInsets.only(top: 3, left: 4, right: 4),
                    child: Text(
                      msg.time,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isMe) const SizedBox(width: 6),
          ],
        ),
      ),
    );
  }
}
