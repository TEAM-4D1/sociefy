import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';

class EventDetailScreen extends StatelessWidget {
  final Event event;

  const EventDetailScreen({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: const Text('Save to Calendar'),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Event saved to device calendar!'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
