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
          children: const [
            // Add contact info widgets here
          ],
        ),
      ),
    );
  }
}
