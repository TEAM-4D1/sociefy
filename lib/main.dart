import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/app_state.dart';
import 'firebase_options.dart';
import 'screens/sign_in_screen.dart';
import 'main_tabs.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
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
            // Show loading state when login is in progress
            if (!appState.isAuthenticated && appState.isPendingAdminLogin) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // Always return MainTabs when authenticated
            if (appState.isAuthenticated) {
              return const MainTabs();
            }

            // Always return SignInScreen when not authenticated
            return const SignInScreen();
          },
        ),
      ),
    );
  }
}
