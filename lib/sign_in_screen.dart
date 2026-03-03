import 'package:flutter/material.dart';

/// Simplified sign-in screen: only a "Sign in with UoP" button.
/// Pressing the button immediately calls [onSignedIn] so the app can navigate
/// to the home screen. Manual email/password and forgot-password UI removed
/// for now per request.
class SignInScreen extends StatelessWidget {
  final VoidCallback? onSignedIn;
  const SignInScreen({Key? key, this.onSignedIn}) : super(key: key);

  void _signInWithUop(BuildContext context) {
    // Show a short feedback then invoke the callback to navigate to the app.
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Signing in with UoP...')));
    // Immediately proceed to the app for now (no verification).
    onSignedIn?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Sign in to continue',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.login),
                    label: const Text('Sign in with UoP'),
                    onPressed: () => _signInWithUop(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
