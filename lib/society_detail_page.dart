import 'package:flutter/material.dart';
import 'dart:io';
import 'society_model.dart';
import 'society_chat_page.dart';

class SocietyDetailPage extends StatelessWidget {
  final Society society;
  final SocietyNotifier notifier;

  const SocietyDetailPage({
    super.key,
    required this.society,
    required this.notifier,
  });

  void _toggleJoin(BuildContext context) {
    if (notifier.isJoined(society.name)) {
      notifier.leave(society.name);
    } else {
      notifier.join(society.name);
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Icon(Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              const Text('Joined!'),
            ],
          ),
          content: Text(
            'You joined "${society.name}". Open Messages to chat with the group.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: notifier,
      builder: (context, _) {
        final joined = notifier.isJoined(society.name);

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // Collapsing gradient/image header
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                backgroundColor: cs.primary,
                foregroundColor: Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    society.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(blurRadius: 4, color: Colors.black54),
                      ],
                    ),
                  ),
                  background: society.imagePath != null &&
                          File(society.imagePath!).existsSync()
                      ? Image.file(
                          File(society.imagePath!),
                          fit: BoxFit.cover,
                        )
                      : Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [cs.primary, cs.tertiary],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.groups,
                              size: 80,
                              color: Colors.white54,
                            ),
                          ),
                        ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Join / Leave / Chat buttons
                      Row(
                        children: [
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: joined
                                  ? OutlinedButton.icon(
                                      key: const ValueKey('leave'),
                                      onPressed: () =>
                                          _toggleJoin(context),
                                      icon: const Icon(Icons.exit_to_app,
                                          color: Colors.red),
                                      label: const Text('Leave',
                                          style:
                                              TextStyle(color: Colors.red)),
                                      style: OutlinedButton.styleFrom(
                                        minimumSize:
                                            const Size.fromHeight(48),
                                        side: const BorderSide(
                                            color: Colors.red),
                                      ),
                                    )
                                  : ElevatedButton.icon(
                                      key: const ValueKey('join'),
                                      onPressed: () =>
                                          _toggleJoin(context),
                                      icon: const Icon(Icons.group_add),
                                      label: const Text('Join Society'),
                                      style: ElevatedButton.styleFrom(
                                        minimumSize:
                                            const Size.fromHeight(48),
                                      ),
                                    ),
                            ),
                          ),
                          if (joined) ...[
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        SocietyChatPage(society: society),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.chat_bubble_outline),
                              label: const Text('Chat'),
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 28),

                      // About section
                      Text(
                        'About',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        society.description,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(height: 1.5),
                      ),

                      const SizedBox(height: 28),

                      // Members section
                      Row(
                        children: [
                          Text(
                            'Members',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 2),
                            decoration: BoxDecoration(
                              color: cs.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${society.members.length}',
                              style: TextStyle(
                                color: cs.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ...society.members.map(
                        (m) => _MemberTile(
                          name: m,
                          isYou: m == 'You',
                          colorScheme: cs,
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
  }
}

class _MemberTile extends StatelessWidget {
  final String name;
  final bool isYou;
  final ColorScheme colorScheme;

  const _MemberTile({
    required this.name,
    required this.isYou,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: isYou
                ? colorScheme.primary
                : colorScheme.secondaryContainer,
            child: Text(
              name[0].toUpperCase(),
              style: TextStyle(
                color: isYou
                    ? colorScheme.onPrimary
                    : colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              name,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          if (isYou)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'You',
                style: TextStyle(
                  color: colorScheme.onPrimaryContainer,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
