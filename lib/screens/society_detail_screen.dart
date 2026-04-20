import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/society.dart';
import '../providers/app_state.dart';
import '../theme/colours.dart';
import '../theme/text_styles.dart';

class SocietyDetailScreen extends StatelessWidget {
  final Society society;
  const SocietyDetailScreen({Key? key, required this.society})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(society.name)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 160,
            width: double.infinity,
            color: AppColours.primaryPurple,
            alignment: Alignment.bottomLeft,
            padding: const EdgeInsets.all(24),
            child: Text(
              society.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
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
                const Divider(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(
                      Icons.email,
                      color: AppColours.primaryPurple,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(society.contactEmail, style: AppTextStyles.bodyGrey),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.person,
                      color: AppColours.primaryPurple,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(society.contactName, style: AppTextStyles.bodyGrey),
                  ],
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
                    return SizedBox(
                      height: 180,
                      child: ListView.builder(
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
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
