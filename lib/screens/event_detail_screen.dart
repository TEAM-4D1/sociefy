import 'package:flutter/material.dart';
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
              'Date: ${event.formattedDate}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Start Time: ${event.startTime}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'End Time: ${event.endTime}',
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
          ],
        ),
      ),
    );
  }
}
