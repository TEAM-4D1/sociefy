import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../providers/app_state.dart';
import 'sign_in_screen.dart';
import 'event_detail_screen.dart';
import '../widgets/app_bar_logo_action.dart';
import '../widgets/app_gradient_background.dart';

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
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        ),
        actions: const [AppBarLogoAction()],
      ),
      body: AppGradientBackground(
        child: Center(
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
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
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
                  // Ensure the user returns to the Sign In screen and clear navigation history
                  if (Navigator.canPop(context)) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const SignInScreen()),
                      (route) => false,
                    );
                  } else {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const SignInScreen()),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              if (appState.isAdmin)
                SizedBox(
                  width: 220,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.event),
                    label: const Text('View Events'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: () {
                      final events = appState.events;
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (ctx) => DraggableScrollableSheet(
                          expand: false,
                          builder: (context, scrollController) {
                            if (events.isEmpty) {
                              return const Center(
                                child: Text('No events available.'),
                              );
                            }
                            return ListView.builder(
                              controller: scrollController,
                              itemCount: events.length,
                              itemBuilder: (context, index) {
                                final event = events[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  child: ListTile(
                                    title: Text(event.title),
                                    subtitle: Text(
                                      '${event.societyName} • ${event.formattedDate}',
                                    ),
                                    trailing: const Icon(Icons.chevron_right),
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => EventDetailScreen(
                                            event: event,
                                            userId: appState.userId ?? '',
                                            isSaved: appState.isEventSaved(
                                              event.id,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
