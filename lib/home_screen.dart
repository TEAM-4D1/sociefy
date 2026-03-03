//Home screen will include scrolling through posts similar to instagram to catch up on upcoming events posted by the socities they follow, and include search bar, likes count, comments and include buttom prompts to chats/forums
//The logo should be rendered at the top left of the screen here

import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Center(child: Text('Home feed goes here')),
    );
  }
}
