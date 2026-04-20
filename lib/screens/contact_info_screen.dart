import 'package:flutter/material.dart';
import '../models/society.dart';

class ContactInfoScreen extends StatelessWidget {
  final Society society;
  const ContactInfoScreen({Key? key, required this.society}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Contact ${society.name}')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            const Text(
              'Committee Members',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.person),
                title: const Text('President'),
                subtitle: const Text('Alex Johnson'),
                trailing: IconButton(
                  icon: const Icon(Icons.email),
                  onPressed: () {},
                ),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Secretary'),
                subtitle: const Text('Jamie Lee'),
                trailing: IconButton(
                  icon: const Icon(Icons.email),
                  onPressed: () {},
                ),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Treasurer'),
                subtitle: const Text('Morgan Smith'),
                trailing: IconButton(
                  icon: const Icon(Icons.email),
                  onPressed: () {},
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
