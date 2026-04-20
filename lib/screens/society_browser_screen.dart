import 'package:flutter/material.dart';

class SocietyBrowserScreen extends StatefulWidget {
  const SocietyBrowserScreen({Key? key}) : super(key: key);

  @override
  State<SocietyBrowserScreen> createState() => _SocietyBrowserScreenState();
}

class _SocietyBrowserScreenState extends State<SocietyBrowserScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discover Societies')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search societies...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
