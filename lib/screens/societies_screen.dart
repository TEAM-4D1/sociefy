import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class SocietiesScreen extends StatelessWidget {
  const SocietiesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Societies')),
      body: Consumer<AppState>(
        builder: (context, appState, _) {
          final societies = appState.societies;
          return ListView.builder(
            itemCount: societies.length,
            itemBuilder: (context, index) {
              final society = societies[index];
              return ListTile(
                title: Text(society.name),
                subtitle: Text(society.category),
              );
            },
          );
        },
      ),
    );
  }
}
