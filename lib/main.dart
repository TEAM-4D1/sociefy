import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'sign_in_screen.dart';
import 'main_tabs.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppState>(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'Society App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: Builder(
          builder: (context) => SignInScreen(
            onSignedIn: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const MainTabs()),
              );
            },
          ),
        ),
      ),
    );
  }
}
