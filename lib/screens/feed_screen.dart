import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

// Static map of announcements per society
const Map<String, Map<String, String>> _societyAnnouncements = {
  'cs': {
    'title': 'CS Society Hackathon',
    'date': 'April 25, 2026',
    'content':
        'Join our annual hackathon! Prizes and pizza for all participants.',
  },
  'drama': {
    'title': 'Drama Night',
    'date': 'April 28, 2026',
    'content': 'Don\'t miss our spring performance in the main auditorium.',
  },
  'sports': {
    'title': 'Sports Day',
    'date': 'May 2, 2026',
    'content': 'Compete or cheer at the inter-society sports day!',
  },
};

// Announcement card for feed
class _AnnouncementCard extends StatelessWidget {
  final String societyName;
  final String title;
  final String date;
  final String content;

  const _AnnouncementCard({
    Key? key,
    required this.societyName,
    required this.title,
    required this.date,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  societyName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  date,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(content),
          ],
        ),
      ),
    );
  }
}

class FeedScreen extends StatelessWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Societies Feed')),
      body: Consumer<AppState>(
        builder: (context, appState, _) {
          final joinedSocieties = appState.joinedSocieties;
          final isAdmin = appState.isAdmin;
          if (joinedSocieties.isEmpty) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isAdmin)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Add Post'),
                          onPressed: () {
                            // TODO: Implement add post dialog
                          },
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.group_add),
                          label: const Text('Create Society'),
                          onPressed: () {
                            // TODO: Implement create society dialog
                          },
                        ),
                      ],
                    ),
                  ),
                const Center(
                  child: Text(
                    "You haven't joined any societies yet. Explore to see updates here!",
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            );
          }
          return Column(
            children: [
              if (isAdmin)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Add Post'),
                        onPressed: () {
                          // TODO: Implement add post dialog
                        },
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.group_add),
                        label: const Text('Create Society'),
                        onPressed: () {
                          // TODO: Implement create society dialog
                        },
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(24.0),
                  itemCount: joinedSocieties.length,
                  itemBuilder: (context, index) {
                    final society = joinedSocieties[index];
                    // Use announcement data from map or fallback to generic
                    final ann =
                        _societyAnnouncements[society.id] ??
                        {
                          'title': 'Society Update',
                          'date': 'See details',
                          'content':
                              'Stay tuned for the latest news and events!',
                        };
                    return _AnnouncementCard(
                      societyName: society.name,
                      title: ann['title']!,
                      date: ann['date']!,
                      content: ann['content']!,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
