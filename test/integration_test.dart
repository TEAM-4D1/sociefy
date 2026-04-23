import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sociefy/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Performance Tests', () {
    testWidgets('Messages tab loads within 2 seconds', (tester) async {
      final stopwatch = Stopwatch()..start();

      // Start the app
      binding.attachRootWidget(MaterialApp(home: app.MyApp()));
      await tester.pumpAndSettle();

      // Navigate to Messages tab
      await tester.tap(find.text('Messages'));
      await tester.pumpAndSettle();

      stopwatch.stop();
      expect(stopwatch.elapsed.inSeconds, lessThanOrEqualTo(2),
          reason: 'Messages tab should load within 2 seconds');
    });

    testWidgets('Joining a society completes within 2 seconds', (tester) async {
      final stopwatch = Stopwatch()..start();

      // Start the app
      binding.attachRootWidget(MaterialApp(home: app.MyApp()));
      await tester.pumpAndSettle();

      // Simulate joining a society
      await tester.tap(find.text('Join Society'));
      await tester.pumpAndSettle();

      stopwatch.stop();
      expect(stopwatch.elapsed.inSeconds, lessThanOrEqualTo(2),
          reason: 'Joining a society should complete within 2 seconds');
    });
  });

  group('Usability Tests', () {
    testWidgets('UI is accessible', (tester) async {
      // Start the app
      binding.attachRootWidget(MaterialApp(home: app.MyApp()));
      await tester.pumpAndSettle();

      // Check for accessibility labels
      expect(find.bySemanticsLabel('Messages'), findsOneWidget);
      expect(find.bySemanticsLabel('Join Society'), findsOneWidget);
    });
  });
}