import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sociefy/main.dart' as app;

void main() {
  group('Performance Tests', () {
    // INT-01 — Messages tab loads within 2 seconds
    testWidgets('Messages tab loads within 2 seconds', (tester) async {
      final stopwatch = Stopwatch()..start();
      await tester.pumpWidget(const app.MyApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Messages'));
      await tester.pumpAndSettle();
      stopwatch.stop();
      expect(
        stopwatch.elapsed.inSeconds,
        lessThanOrEqualTo(2),
        reason: 'Messages tab should load within 2 seconds',
      );
      expect(find.text('Messages / Forums go here'), findsOneWidget);
    });

    // INT-02 — creating a society completes within 2 seconds
    testWidgets('creating a society completes within 2 seconds', (tester) async {
      final stopwatch = Stopwatch()..start();
      await tester.pumpWidget(const app.MyApp());
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).at(0), 'Test Society');
      await tester.enterText(find.byType(TextField).at(1), 'Test Description');
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();
      stopwatch.stop();
      expect(
        stopwatch.elapsed.inSeconds,
        lessThanOrEqualTo(2),
        reason: 'Creating a society should complete within 2 seconds',
      );
    });
  });

  group('Usability Tests', () {
    // INT-03 — all key navigation elements are present
    testWidgets('UI displays all three navigation labels', (tester) async {
      await tester.pumpWidget(const app.MyApp());
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Announcements'), findsOneWidget);
      expect(find.text('Messages'), findsOneWidget);
    });

    // INT-04 — all 3 tabs are accessible and show correct content
    testWidgets('all 3 tabs are accessible with correct content', (tester) async {
      await tester.pumpWidget(const app.MyApp());
      await tester.pumpAndSettle();
      // Home tab (default)
      expect(find.text('No societies yet.'), findsOneWidget);
      // Announcements tab
      await tester.tap(find.text('Announcements'));
      await tester.pumpAndSettle();
      expect(find.text('No announcements yet.'), findsOneWidget);
      // Messages tab
      await tester.tap(find.text('Messages'));
      await tester.pumpAndSettle();
      expect(find.text('Messages / Forums go here'), findsOneWidget);
    });
  });
}
