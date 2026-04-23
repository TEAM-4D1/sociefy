import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/society.dart';
import '../providers/app_state.dart';
import '../theme/colours.dart';
import '../theme/text_styles.dart';
import 'event_detail_screen.dart';
import 'contact_info_screen.dart';

class SocietyDetailScreen extends StatelessWidget {
  final Society society;

  const SocietyDetailScreen({Key? key, required this.society})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(society.name),
        backgroundColor: AppColours.primaryPurple,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: AppColours.primaryPurple.withValues(
                          alpha: 0.1,
                        ),
                        child: Icon(
                          Icons.groups,
                          size: 36,
                          color: AppColours.primaryPurple,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(society.name, style: AppTextStyles.heading1),
                            const SizedBox(height: 8),
                            Text(
                              society.category,
                              style: AppTextStyles.heading2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Text(society.description, style: AppTextStyles.bodyRegular),

                  const SizedBox(height: 16),

                  OutlinedButton.icon(
                    icon: const Icon(Icons.contact_mail),
                    label: const Text('View Contact Info'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ContactInfoScreen(society: society),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  const Text(
                    'Upcoming Events',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 16),

                  Consumer<AppState>(
                    builder: (context, appState, _) {
                      final events = appState.eventsForSociety(society.id);

                      if (events.isEmpty) {
                        return const Text('No upcoming events');
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          final event = events[index];

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              title: Text(event.title),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(event.formattedDate),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(event.venue),
                                    ],
                                  ),
                                ],
                              ),
                              onTap: () {
                                final userId = context.read<AppState>().userId;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EventDetailScreen(
                                      event: event,
                                      userId: userId ?? '',
                                      isSaved: appState.isEventSaved(event.id),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // =========================
      // JOIN / LEAVE BUTTON FIXED
      // =========================
      bottomNavigationBar: Consumer<AppState>(
        builder: (context, appState, _) {
          final isJoined = appState.isJoined(society.id);

          return BottomAppBar(
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isJoined
                        ? Colors.grey[300]
                        : AppColours.primaryPurple,
                    foregroundColor: isJoined ? Colors.black87 : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);

                    if (isJoined) {
                      await appState.leaveSociety(society.id);
                      messenger.showSnackBar(
                        SnackBar(content: Text('Left ${society.name}')),
                      );
                    } else {
                      await appState.joinSociety(society.id);
                      messenger.showSnackBar(
                        SnackBar(content: Text('Joined ${society.name}')),
                      );
                    }
                  },
                  child: Text(isJoined ? 'Leave Society' : 'Join Society'),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
