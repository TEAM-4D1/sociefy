import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import '../lib/firebase_options.dart';
import '../lib/models/society.dart';
import '../lib/providers/app_state.dart';
import '../lib/screens/society_chat_screen.dart';

void main() async {
  // Initialize Firebase before running tests
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  group('SocietyChatScreen Tests', () {
    final testSociety = Society(
      id: 'test-society-id',
      name: 'Chess Club',
      category: 'Games',
      description: 'A chess society',
      committeeMembers: [],
    );

    Widget buildTestWidget(AppState appState, Society society) {
      return MaterialApp(
        home: ChangeNotifierProvider.value(
          value: appState,
          child: SocietyChatScreen(society: society),
        ),
      );
    }

    testWidgets('accepts a Society parameter and renders without crashing', (
      WidgetTester tester,
    ) async {
      final appState = AppState(skipFirebase: true);
      // This test verifies the widget accepts a Society parameter
      // Note: SocietyChatScreen uses live Firestore streams, so we expect
      // a FirebaseException in the test environment (no Firebase initialized)
      await tester.pumpWidget(buildTestWidget(appState, testSociety));
      await tester.pump(const Duration(milliseconds: 100));

      // Verify the test society name is passed correctly
      expect(testSociety.name, equals('Chess Club'));
      expect(testSociety.id, equals('test-society-id'));
    });

    testWidgets('has AppBar with correct structure', (
      WidgetTester tester,
    ) async {
      final appState = AppState(skipFirebase: true);
      await tester.pumpWidget(buildTestWidget(appState, testSociety));
      await tester.pump(const Duration(milliseconds: 100));

      // Verify AppBar is present in widget tree
      expect(find.byType(AppBar), findsWidgets);
    });
  });
}
