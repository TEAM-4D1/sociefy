import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../providers/app_state.dart';

/// Displays the current user's profile information including display name, email, and avatar.
/// Provides a Sign Out button to end the current session and clear all session data.
/// Accessible to all authenticated users and guests.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    User? currentUser;
    try {
      currentUser = FirebaseAuth.instance.currentUser;
    } catch (_) {
      currentUser = null;
    }

    // Determine display name and subtitle based on user type
    String displayName;
    String subtitle;

    if (appState.isGuest) {
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
            if (!appState.isGuest)
              ElevatedButton.icon(
                icon: const Icon(Icons.lock_reset),
                label: const Text('Change Password'),
                onPressed: () async {
                  if (currentUser?.email != null) {
                    await FirebaseAuth.instance.sendPasswordResetEmail(
                      email: currentUser!.email!,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password reset email sent.'),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No email found for this user.'),
                      ),
                    );
                  }
                },
              ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
              onPressed: () async {
                final appState = context.read<AppState>();
                if (appState.isGuest) {
                  appState.logout();
                } else {
                  await AuthService().signOut();
                  appState.logout();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
