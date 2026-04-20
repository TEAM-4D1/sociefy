//This will be the main area for forums and chats, where users of societies can message each other and ask questions to members of committee in the socities they have joined.

import 'package:flutter/material.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: const Center(child: Text('Messages / Forums go here')),
    );
  }
}
