import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'event_detail_screen.dart';

/// Displays the user's bookmarked/saved events with quick access to event details.
/// Allows users to remove events from their saved list and navigate to detailed event information.
/// Accessible only to authenticated students and admins; guests cannot save events.
class SavedEventsScreen extends StatelessWidget {
  const SavedEventsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Events')),
      body: Consumer<AppState>(
        builder: (context, appState, _) {
          // Ensure events are loaded (will no-op if already loaded)
          if (appState.events.isEmpty) {
            appState.loadEvents();
          }

          final saved = appState.savedEvents;
          // If user has no saved events, show all available events so the tab is populated
          final displayEvents = saved.isNotEmpty ? saved : appState.events;

          if (displayEvents.isEmpty) {
            return const Center(child: Text('No events available.'));
          }

          return ListView.builder(
            itemCount: displayEvents.length,
            itemBuilder: (context, index) {
              final event = displayEvents[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
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
                    final userId = appState.userId ?? '';
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EventDetailScreen(
                          event: event,
                          userId: userId,
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
    );
  }
}
