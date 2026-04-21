import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/event.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;
  final String userId;
  final bool isSaved;

  const EventDetailScreen({
    Key? key,
    required this.event,
    required this.userId,
    required this.isSaved,
  }) : super(key: key);

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  bool _hasRsvp = false;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _isSaved = widget.isSaved;
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    return Scaffold(
      appBar: AppBar(title: Text(event.title)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Text(event.description, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),

            Text(
              'Date: ${DateFormat.yMMMMd().format(event.date)}',
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                const Icon(Icons.location_on, size: 20, color: Colors.grey),
                const SizedBox(width: 4),
                Text(event.venue, style: const TextStyle(fontSize: 16)),
              ],
            ),

            const SizedBox(height: 24),

            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(Icons.map, size: 48, color: Colors.grey),
              ),
            ),

            const SizedBox(height: 32),

            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.how_to_reg),
                    label: Text(_hasRsvp ? 'Cancel RSVP' : 'RSVP'),
                    onPressed: () async {
                      setState(() {
                        _hasRsvp = !_hasRsvp;
                      });
                      try {
                        final event = widget.event;
                        final userId = widget.userId;
                        final docId = '${userId}_${event.id}';
                        if (_hasRsvp) {
                          await FirebaseFirestore.instance
                              .collection('rsvps')
                              .doc(docId)
                              .set({
                                'eventId': event.id,
                                'userId': userId,
                                'createdAt': FieldValue.serverTimestamp(),
                              });
                        } else {
                          await FirebaseFirestore.instance
                              .collection('rsvps')
                              .doc(docId)
                              .delete();
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error updating RSVP: $e')),
                        );
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            _hasRsvp ? 'RSVP confirmed!' : 'RSVP removed',
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: _isSaved
                        ? const Icon(Icons.event_available)
                        : const Icon(Icons.calendar_today),
                    label: Text(
                      _isSaved ? 'Saved to Calendar' : 'Save to Calendar',
                    ),
                    onPressed: () async {
                      final event = widget.event;
                      final userId = widget.userId;
                      setState(() {
                        _isSaved = !_isSaved;
                      });
                      try {
                        if (_isSaved) {
                          context.read<AppState>().saveEvent(event.id);
                          await context.read<AppState>().persistSaveEvent(
                            userId,
                            event.id,
                          );
                        } else {
                          context.read<AppState>().unsaveEvent(event.id);
                          await context.read<AppState>().persistUnsaveEvent(
                            userId,
                            event.id,
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error saving event: $e')),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
