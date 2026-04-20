import 'package:flutter/material.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Societies Feed')),
      body: const Padding(
        padding: EdgeInsets.all(24.0),
        child: Text('Loading updates...'),
      ),
    );
  }
}
