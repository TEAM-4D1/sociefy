import 'package:flutter/material.dart';
import 'main_tabs.dart';

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
    // If a callback was provided use it; otherwise navigate using this context.
    if (onSignedIn != null) {
      onSignedIn!.call();
    } else {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const MainTabs()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4A148C), Color(0xFF7B1FA2)],
          ),
        ),
        child: Padding(
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
      ),
    );
  }
}
