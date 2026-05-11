import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sociefy/models/society.dart';
import 'package:sociefy/providers/app_state.dart';
import 'package:sociefy/screens/society_detail_screen.dart';

/// Helper function to build a test widget tree with SocietyDetailScreen.
Widget buildTestWidget(AppState appState, Society society) {
  return MaterialApp(
    home: ChangeNotifierProvider.value(
      value: appState,
      child: SocietyDetailScreen(society: society),
    ),
  );
}

void main() {
  group('SocietyDetailScreen Tests', () {
    testWidgets('renders the society name in the app bar', (
      WidgetTester tester,
    ) async {
      final testSociety = Society(
        id: 'test-id',
        name: 'Test Society',
        category: 'Academic',
        description: 'A test society description',
      );
      final appState = AppState(skipFirebase: true);
      await tester.pumpWidget(buildTestWidget(appState, testSociety));
      await tester.pump(const Duration(milliseconds: 100));

      // Check that AppBar exists
      expect(find.byType(AppBar), findsOneWidget);
      // Check that society name appears at least once on screen
      expect(find.text('Test Society'), findsWidgets);
    });

    testWidgets('renders the society description text on screen', (
      WidgetTester tester,
    ) async {
      final testSociety = Society(
        id: 'test-id',
        name: 'Test Society',
        category: 'Academic',
        description: 'A test society description',
      );
      final appState = AppState(skipFirebase: true);
      await tester.pumpWidget(buildTestWidget(appState, testSociety));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('A test society description'), findsOneWidget);
    });

    testWidgets('renders the society category text on screen', (
      WidgetTester tester,
    ) async {
      final testSociety = Society(
        id: 'test-id',
        name: 'Test Society',
        category: 'Academic',
        description: 'A test society description',
      );
      final appState = AppState(skipFirebase: true);
      await tester.pumpWidget(buildTestWidget(appState, testSociety));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Academic'), findsOneWidget);
    });

    testWidgets('renders a join/leave button', (WidgetTester tester) async {
      final testSociety = Society(
        id: 'test-id',
        name: 'Test Society',
        category: 'Academic',
        description: 'A test society description',
      );
      final appState = AppState(skipFirebase: true);
      await tester.pumpWidget(buildTestWidget(appState, testSociety));
      await tester.pump(const Duration(milliseconds: 100));

      // Look for ElevatedButton
      expect(find.byType(ElevatedButton), findsOneWidget);
      // Look for text containing 'Join' or 'Leave'
      final joinText = find.text('Join Society');
      final leaveText = find.text('Leave Society');
      final signInText = find.text('Sign in to Join');

      // One of these three texts should exist
      expect(
        joinText.evaluate().isNotEmpty ||
            leaveText.evaluate().isNotEmpty ||
            signInText.evaluate().isNotEmpty,
        isTrue,
      );
    });
  });
}
