import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../utils/society_image_mapper.dart';
import 'event_detail_screen.dart';
import '../widgets/app_bar_logo_action.dart';
import '../widgets/app_gradient_background.dart';

/// Displays the user's bookmarked/saved events with quick access to event details.
/// Allows users to remove events from their saved list and navigate to detailed event information.
/// Accessible only to authenticated students and admins; guests cannot save events.
class SavedEventsScreen extends StatelessWidget {
  const SavedEventsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Events',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        ),
        actions: const [AppBarLogoAction()],
      ),
      body: AppGradientBackground(
        child: Consumer<AppState>(
          builder: (context, appState, _) {
            // Ensure events are loaded — defer to a post-frame callback so
            // notifyListeners() can't fire during this build phase, which would
            // crash with a "setState() called during build" assertion when
            // loadEvents() falls back to sample data synchronously.
            if (appState.events.isEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                appState.loadEvents();
              });
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
                final imageAsset = getSocietyImageAsset(event.societyName);
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: InkWell(
                      mouseCursor: SystemMouseCursors.click,
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(4),
                            ),
                            child: Image.asset(
                              imageAsset,
                              height: 140,
                              width: double.infinity,
                              fit: BoxFit.contain,
                              alignment: Alignment.center,
                            ),
                          ),
                          ListTile(
                            mouseCursor: SystemMouseCursors.click,
                            title: Text(event.title),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.societyName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                  ),
                                ),
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
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
