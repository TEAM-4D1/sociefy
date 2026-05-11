import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sociefy/data/sample_events.dart';
import 'package:sociefy/providers/app_state.dart';
import 'package:sociefy/screens/saved_events_screen.dart';

/// Helper function to build a test widget tree with SavedEventsScreen.
Widget buildTestWidget(AppState appState) {
  return MaterialApp(
    home: ChangeNotifierProvider.value(
      value: appState,
      child: const SavedEventsScreen(),
    ),
  );
}

void main() {
  group('SavedEventsScreen Tests', () {
    testWidgets('renders app bar with title \'Events\'', (
      WidgetTester tester,
    ) async {
      final appState = AppState(skipFirebase: true);
      await tester.pumpWidget(buildTestWidget(appState));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Events'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets(
      'shows \'No events available.\' when appState.events is empty and appState.savedEvents is empty',
      (WidgetTester tester) async {
        final appState = AppState(skipFirebase: true);
        await tester.pumpWidget(buildTestWidget(appState));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('No events available.'), findsOneWidget);
      },
    );

    testWidgets('renders a ListView when appState has events loaded', (
      WidgetTester tester,
    ) async {
      final appState = AppState(skipFirebase: true);
      // Add a sample event to the appState
      appState.events.add(sampleEvents[0]);
      appState.notifyListeners();

      await tester.pumpWidget(buildTestWidget(appState));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('Friendly Doubles Tournament'), findsOneWidget);
    });
  });
}
