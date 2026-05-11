import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
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
        // Add a society to joined list directly
        appState.joinedSocietyIds.add('society1');

        await tester.pumpWidget(buildTestWidget(appState));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Add Post'), findsNothing);
        expect(find.text('Create Society'), findsNothing);
      },
    );
  });
}
