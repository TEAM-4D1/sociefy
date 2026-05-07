import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:add_2_calendar/add_2_calendar.dart' as add2;
import '../models/event.dart';
import '../providers/app_state.dart';
import '../utils/society_image_mapper.dart';

/// Parses a time string like "14:00" or "2:00 PM" against a base date.
/// Returns the base date unchanged if parsing fails.
DateTime _parseEventTime(String timeStr, DateTime baseDate) {
  try {
    final parsed = DateFormat.Hm().parse(timeStr);
    return DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
      parsed.hour,
      parsed.minute,
    );
  } catch (_) {
    try {
      final parsed = DateFormat.jm().parse(timeStr);
      return DateTime(
        baseDate.year,
        baseDate.month,
        baseDate.day,
        parsed.hour,
        parsed.minute,
      );
    } catch (_) {
      return baseDate;
    }
  }
}

/// Displays detailed information about a specific event including title, description, date, time, and venue.
/// Users can save events, add to device calendar, and RSVP.
/// Guests can view but cannot save, RSVP, or add to calendar.
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
    _checkRsvpStatus();
  }

  /// Checks if the user has already RSVP'd by querying the Firestore 'rsvps' collection.
  /// Skips the lookup for guest users.
  Future<void> _checkRsvpStatus() async {
    if (widget.userId.isEmpty || widget.userId.startsWith('guest')) return;
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('rsvps')
          .doc('${widget.userId}_${widget.event.id}')
          .get();
      if (docSnapshot.exists && mounted) {
        setState(() => _hasRsvp = true);
      }
    } catch (e) {
      debugPrint('Error checking RSVP status: $e');
    }
  }

  /// Adds the event to the device calendar using the add_2_calendar package.
  Future<void> _addToCalendar(BuildContext context, Event event) async {
    try {
      final startDateTime = _parseEventTime(event.startTime, event.date);
      final endDateTime = _parseEventTime(event.endTime, event.date);

      final calEvent = add2.Event(
        title: event.title,
        description: event.description,
        location: event.venue,
        startDate: startDateTime,
        endDate: endDateTime,
      );

      await add2.Add2Calendar.addEvent2Cal(calEvent);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event added to calendar!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error adding to calendar: $e')));
      }
    }
  }

  /// Toggles the saved state of the event, persisting via AppState.
  Future<void> _toggleSave(BuildContext context, Event event) async {
    final newSaved = !_isSaved;
    setState(() => _isSaved = newSaved);

    final appState = context.read<AppState>();
    try {
      if (newSaved) {
        appState.saveEvent(event.id);
        final startDateTime = _parseEventTime(event.startTime, event.date);
        final endDateTime = _parseEventTime(event.endTime, event.date);
        final calEvent = add2.Event(
          title: event.title,
          description: event.description,
          location: event.venue,
          startDate: startDateTime,
          endDate: endDateTime,
        );
        await add2.Add2Calendar.addEvent2Cal(calEvent);
      } else {
        appState.unsaveEvent(event.id);
      }
    } catch (e) {
      // Revert local state on failure
      if (mounted) setState(() => _isSaved = !newSaved);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving event: $e')));
      }
      return;
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newSaved
                ? 'Event saved to calendar!'
                : 'Event removed from calendar!',
          ),
        ),
      );
    }
  }

  /// Toggles RSVP status and persists to Firestore 'rsvps' collection.
  Future<void> _toggleRsvp(BuildContext context, Event event) async {
    final newRsvp = !_hasRsvp;
    setState(() => _hasRsvp = newRsvp);

    try {
      final docId = '${widget.userId}_${event.id}';
      if (newRsvp) {
        await FirebaseFirestore.instance.collection('rsvps').doc(docId).set({
          'eventId': event.id,
          'userId': widget.userId,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        await FirebaseFirestore.instance
            .collection('rsvps')
            .doc(docId)
            .delete();
      }
    } catch (e) {
      // Revert on failure
      if (mounted) setState(() => _hasRsvp = !newRsvp);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating RSVP: $e')));
      }
      return;
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(newRsvp ? 'RSVP confirmed!' : 'RSVP removed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final appState = context.watch<AppState>();
    final isGuest = appState.isGuest;
    final imageAsset = getSocietyImageAsset(event.societyName);

    return Scaffold(
      appBar: AppBar(title: Text(event.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imageAsset,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text(event.description, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Text(
              'Date: ${DateFormat.yMMMMd().format(event.date)}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Time: ${event.startTime} - ${event.endTime}',
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

            // Add to Calendar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: const Text('Add to Calendar'),
                onPressed: isGuest
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Sign in to add events to your calendar',
                            ),
                          ),
                        );
                      }
                    : () => _addToCalendar(context, event),
              ),
            ),
            const SizedBox(height: 12),

            // RSVP
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.how_to_reg),
                label: Text(
                  isGuest
                      ? 'Sign in to RSVP'
                      : (_hasRsvp ? 'Cancel RSVP' : 'RSVP'),
                ),
                onPressed: isGuest ? null : () => _toggleRsvp(context, event),
              ),
            ),
            const SizedBox(height: 12),

            // Save to Calendar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(
                  _isSaved
                      ? Icons.event_available
                      : Icons.bookmark_add_outlined,
                ),
                label: Text(
                  _isSaved ? 'Saved to Calendar' : 'Save to Calendar',
                ),
                onPressed: isGuest
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Sign in to save events'),
                          ),
                        );
                      }
                    : () => _toggleSave(context, event),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
