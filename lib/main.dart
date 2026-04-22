import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'screens/sign_in_screen.dart';
import 'main_tabs.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {} catch (e) {
    debugPrint('Error initializing Firebase: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppState>(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'Society App',
        theme: AppTheme.theme,
        home: Consumer<AppState>(
          builder: (context, appState, _) {
            if (appState.isAuthenticated) {
              return const MainTabs();
            } else {
              return const SignInScreen();
            }
          },
        ),
      ),
    );
  }
}
