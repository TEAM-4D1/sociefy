import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'event_detail_screen.dart';

class SavedEventsScreen extends StatelessWidget {
  const SavedEventsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Events')),
      body: Consumer<AppState>(
        builder: (context, appState, _) {
          final events = appState.savedEvents;

          if (events.isEmpty) {
            return const Center(child: Text('No saved events yet.'));
          }

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
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
