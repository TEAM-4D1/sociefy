import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../providers/app_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final currentUser = FirebaseAuth.instance.currentUser;

    // Determine display name and subtitle based on user type
    String displayName;
    String subtitle;

    if (appState.userId == 'guest-committee') {
      displayName = 'Guest Committee';
      subtitle = 'Committee preview mode';
    } else if (appState.isGuest) {
      displayName = 'Guest User';
      subtitle = 'Browsing as guest';
    } else {
      displayName = currentUser?.displayName ?? 'User';
      subtitle = currentUser?.email ?? 'No email';
    }

    final firstLetter = displayName.isNotEmpty
        ? displayName[0].toUpperCase()
        : '?';

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                firstLetter,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              displayName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
              onPressed: () async {
                final appState = context.read<AppState>();

                if (appState.userId == 'guest' ||
                    appState.userId == 'guest-committee') {
                  appState.logout();
                } else {
                  await AuthService().signOut();
                  appState.logout();
                }
                // Navigation handled by Consumer<AppState> in main.dart
              },
            ),
          ],
        ),
      ),
    );
  }
}
