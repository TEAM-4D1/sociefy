import 'package:flutter/material.dart';
import 'society_model.dart';
import 'society_chat_page.dart';

class MessagesPage extends StatelessWidget {
  final SocietyNotifier? notifier;
  const MessagesPage({super.key, this.notifier});

  @override
  Widget build(BuildContext context) {
    // No notifier → standalone / test usage → always show placeholder
    if (notifier == null) return _Placeholder(key: key);

    return ListenableBuilder(
      listenable: notifier!,
      builder: (context, _) {
        final joined = notifier!.joinedSocieties;
        if (joined.isEmpty) return const _Placeholder();
        return _GroupList(societies: joined);
      },
    );
  }
}

// ── Placeholder ──────────────────────────────────────────────────────────────

class _Placeholder extends StatelessWidget {
  const _Placeholder({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.forum_outlined,
                size: 50,
                color: cs.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Messages / Forums go here',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Join a society to start chatting',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Joined groups list ────────────────────────────────────────────────────────

class _GroupList extends StatelessWidget {
  final List<Society> societies;
  const _GroupList({required this.societies});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: societies.length,
        separatorBuilder: (_, _) =>
            Divider(height: 1, indent: 72, color: Colors.grey.shade200),
        itemBuilder: (ctx, i) => _GroupTile(society: societies[i]),
      ),
    );
  }
}

class _GroupTile extends StatelessWidget {
  final Society society;
  const _GroupTile({required this.society});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: cs.primaryContainer,
        child: Icon(Icons.groups, color: cs.onPrimaryContainer),
      ),
      title: Text(
        society.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '${society.members.length} members · Tap to open chat',
        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SocietyChatPage(society: society),
        ),
      ),
    );
  }
}
