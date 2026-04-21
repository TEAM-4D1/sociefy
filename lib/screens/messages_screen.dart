import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sociefy/providers/app_state.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: Consumer<AppState>(
        builder: (context, appState, _) {
          // ✅ derive joined societies instead of joinedChannels
          final joinedSocieties = appState.joinedSocieties;

          if (joinedSocieties.isEmpty) {
            return const Center(
              child: Text('Join a society to access its message channel.'),
            );
          }

          return ListView.builder(
            itemCount: joinedSocieties.length,
            itemBuilder: (context, index) {
              final society = joinedSocieties[index];

              return ListTile(
                leading: const Icon(Icons.forum),
                title: Text(society.name),
                subtitle: Text(society.category),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Open channel: ${society.name}')),
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
