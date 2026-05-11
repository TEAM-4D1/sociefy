import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sociefy/models/society.dart';
import 'package:sociefy/providers/app_state.dart';
import 'package:sociefy/screens/feed_screen.dart';

/// Helper function to build a test widget tree with FeedScreen.
Widget buildTestWidget(AppState appState) {
  return MaterialApp(
    home: ChangeNotifierProvider.value(
      value: appState,
      child: const FeedScreen(),
    ),
  );
}

void main() {
  group('FeedScreen Tests', () {
    testWidgets('renders app bar with title \'My Societies Feed\'', (
      WidgetTester tester,
    ) async {
      final appState = AppState(skipFirebase: true);
      await tester.pumpWidget(buildTestWidget(appState));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('My Societies Feed'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets(
      'shows empty-state text when user has not joined any societies and is not admin',
      (WidgetTester tester) async {
        final appState = AppState(skipFirebase: true);
        await tester.pumpWidget(buildTestWidget(appState));
        await tester.pump(const Duration(milliseconds: 100));

        expect(
          find.text(
            "You haven't joined any societies yet. Explore to see updates here!",
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'does NOT show \'Add Post\' or \'Create Society\' buttons when user is not admin',
      (WidgetTester tester) async {
        final appState = AppState(skipFirebase: true);
        // Set user as non-admin directly (don't call login() as it has Firebase side effects)
        appState.userId = 'testuser';
        appState.isAdmin = false;
        // Create a test society for the user to be part of
        appState.createSociety(
          name: 'Test Society',
          category: 'Academic',
          description: 'Test',
        );

        await tester.pumpWidget(buildTestWidget(appState));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Add Post'), findsNothing);
        expect(find.text('Create Society'), findsNothing);
      },
    );

    testWidgets(
      'shows "Add Post" and "Create Society" buttons when user is admin',
      (WidgetTester tester) async {
        final appState = AppState(skipFirebase: true);
        appState.userId = 'admin-user';
        appState.isAdmin = true;

        await tester.pumpWidget(buildTestWidget(appState));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Add Post'), findsOneWidget);
        expect(find.text('Create Society'), findsOneWidget);
      },
    );

    testWidgets(
      'admin can open Create Society dialog by tapping Create Society button',
      (WidgetTester tester) async {
        final appState = AppState(skipFirebase: true);
        appState.userId = 'admin-user';
        appState.isAdmin = true;

        await tester.pumpWidget(buildTestWidget(appState));
        await tester.pumpAndSettle();

        // Tap Create Society button
        await tester.tap(find.text('Create Society'));
        await tester.pumpAndSettle();

        // Dialog should open - look for form fields in the dialog
        expect(find.byType(AlertDialog), findsOneWidget);
      },
    );

    testWidgets(
      'displays empty state scaffold when user has joined societies',
      (WidgetTester tester) async {
        final appState = AppState(skipFirebase: true);
        appState.userId = 'test-user';
        appState.isAdmin = false;

        // Create a society
        final society = Society(
          id: 'society-1',
          name: 'Test Society',
          category: 'Academic',
          description: 'A test society',
        );
        appState.societies.add(society);

        // Join the society
        appState.joinedSocieties.add(society);
        appState.notifyListeners();

        await tester.pumpWidget(buildTestWidget(appState));
        await tester.pump(const Duration(milliseconds: 100));

        // Scaffold and loading state should be visible
        expect(find.byType(Scaffold), findsOneWidget);
      },
    );

    testWidgets('shows loading placeholders when data is not yet loaded', (
      WidgetTester tester,
    ) async {
      final appState = AppState(skipFirebase: true);
      appState.userId = 'test-user';
      appState.isAdmin = false;

      final society = Society(
        id: 'society-1',
        name: 'Test Society',
        category: 'Academic',
        description: 'A test society',
      );
      appState.societies.add(society);
      appState.joinedSocieties.add(society);
      // No announcements loaded yet
      appState.notifyListeners();

      await tester.pumpWidget(buildTestWidget(appState));
      await tester.pump(const Duration(milliseconds: 100));

      // Should render scaffold without crashing
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('firebase auth call during build does not crash widget', (
      WidgetTester tester,
    ) async {
      // This test verifies that FirebaseAuth calls in build don't crash the widget
      // even when Firebase is not initialized
      final appState = AppState(skipFirebase: true);
      appState.userId = 'test-user';
      appState.isAdmin = false;

      final society = Society(
        id: 'society-1',
        name: 'Test Society',
        category: 'Academic',
        description: 'A test society',
      );
      appState.societies.add(society);
      appState.joinedSocieties.add(society);
      appState.notifyListeners();

      // Widget should build without crashing even without Firebase
      await tester.pumpWidget(buildTestWidget(appState));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(FeedScreen), findsOneWidget);
    });

    testWidgets('user interface renders with correct widget hierarchy', (
      WidgetTester tester,
    ) async {
      final appState = AppState(skipFirebase: true);
      appState.userId = 'test-user';
      appState.isAdmin = false;

      final society = Society(
        id: 'society-1',
        name: 'Test Society',
        category: 'Academic',
        description: 'A test society',
      );
      appState.societies.add(society);
      appState.joinedSocieties.add(society);
      appState.notifyListeners();

      await tester.pumpWidget(buildTestWidget(appState));
      await tester.pump(const Duration(milliseconds: 100));

      // Should have Scaffold with AppBar
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });
  });
}
