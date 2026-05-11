import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sociefy/models/event.dart';
import 'package:sociefy/providers/app_state.dart';
import 'package:sociefy/screens/event_detail_screen.dart';

/// Helper function to build a test widget tree with EventDetailScreen.
Widget buildTestWidget(AppState appState, Event event) {
  return MaterialApp(
    home: ChangeNotifierProvider.value(
      value: appState,
      child: EventDetailScreen(
        event: event,
        userId: 'test-user',
        isSaved: false,
      ),
    ),
  );
}

void main() {
  group('EventDetailScreen Tests', () {
    testWidgets('renders the event title somewhere on screen', (
      WidgetTester tester,
    ) async {
      final testEvent = Event(
        id: 'event-1',
        societyId: 'society-1',
        societyName: 'Computer Science Society',
        title: 'Machine Learning Workshop',
        description: 'Learn the basics of machine learning',
        date: DateTime(2026, 5, 20),
        startTime: '14:00',
        endTime: '16:00',
        venue: 'Building A, Room 101',
        isSaved: false,
      );
      final appState = AppState(skipFirebase: true);
      await tester.pumpWidget(buildTestWidget(appState, testEvent));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Machine Learning Workshop'), findsWidgets);
    });

    testWidgets('renders the event venue somewhere on screen', (
      WidgetTester tester,
    ) async {
      final testEvent = Event(
        id: 'event-1',
        societyId: 'society-1',
        societyName: 'Computer Science Society',
        title: 'Machine Learning Workshop',
        description: 'Learn the basics of machine learning',
        date: DateTime(2026, 5, 20),
        startTime: '14:00',
        endTime: '16:00',
        venue: 'Building A, Room 101',
        isSaved: false,
      );
      final appState = AppState(skipFirebase: true);
      await tester.pumpWidget(buildTestWidget(appState, testEvent));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Building A, Room 101'), findsOneWidget);
    });

    testWidgets('renders a save/bookmark button', (WidgetTester tester) async {
      final testEvent = Event(
        id: 'event-1',
        societyId: 'society-1',
        societyName: 'Computer Science Society',
        title: 'Machine Learning Workshop',
        description: 'Learn the basics of machine learning',
        date: DateTime(2026, 5, 20),
        startTime: '14:00',
        endTime: '16:00',
        venue: 'Building A, Room 101',
        isSaved: false,
      );
      final appState = AppState(skipFirebase: true);
      await tester.pumpWidget(buildTestWidget(appState, testEvent));
      await tester.pump(const Duration(milliseconds: 100));

      // Look for bookmark_border icon (unsaved state)
      expect(find.byIcon(Icons.bookmark_border), findsWidgets);
      // Look for "Save Event" text
      expect(find.text('Save Event'), findsOneWidget);
    });

    testWidgets('renders with isSaved: true and reflects saved state', (
      WidgetTester tester,
    ) async {
      final testEvent = Event(
        id: 'event-1',
        societyId: 'society-1',
        societyName: 'Computer Science Society',
        title: 'Machine Learning Workshop',
        description: 'Learn the basics of machine learning',
        date: DateTime(2026, 5, 20),
        startTime: '14:00',
        endTime: '16:00',
        venue: 'Building A, Room 101',
        isSaved: true,
      );
      final appState = AppState(skipFirebase: true);
      // Create custom widget with isSaved: true
      final testWidget = MaterialApp(
        home: ChangeNotifierProvider.value(
          value: appState,
          child: EventDetailScreen(
            event: testEvent,
            userId: 'test-user',
            isSaved: true,
          ),
        ),
      );
      await tester.pumpWidget(testWidget);
      await tester.pump(const Duration(milliseconds: 100));

      // When saved, button should show "Unsave Event"
      expect(find.text('Unsave Event'), findsOneWidget);
      // And should use the filled bookmark icon
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Icon && widget.icon == Icons.bookmark,
        ),
        findsWidgets,
      );
    });
  });
}
