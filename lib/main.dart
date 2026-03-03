import 'package:flutter/material.dart';
import 'sign_in_screen.dart';
import 'main_tabs.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Society App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Provide an onSignedIn callback so the sign-in screen can navigate
      // to the main tabbed area after a successful sign-in.
      home: SignInScreen(
        onSignedIn: () {
          // Use pushReplacement so users cannot go back to the sign-in screen
          // with the back button.
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainTabs()),
          );
        },
      ),
    );
  }
}
