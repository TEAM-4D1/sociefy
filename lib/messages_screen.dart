//This will be the main area for forums and chats, where users of societies can message each other and ask questions to members of committee in the socities they have joined.

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'providers/app_state.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: Consumer<AppState>(
        builder: (context, appState, _) {
          final channels = appState.joinedChannels;
          if (channels.isEmpty) {
            return const Center(
              child: Text('Join a society to access its message channel.'),
            );
          }
          return ListView.builder(
            itemCount: channels.length,
            itemBuilder: (context, index) {
              final channel = channels[index];
              return ListTile(
                leading: const Icon(Icons.forum),
                title: Text(channel),
                onTap: () {
                  // Placeholder for entering the channel
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Open channel: $channel')),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
