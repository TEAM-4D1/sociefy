import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sociefy/announcements.dart';
import 'package:sociefy/models/announcement.dart';

void main() {
  // ── Unit tests: Announcement.dateTimeVenueString ──────────────────────────

  group('Announcement.dateTimeVenueString', () {
    // ANN-01 — EP: valid AM time, zero-padded single-digit hour
    test('formats AM time with zero-padded hour (9:30 AM)', () {
      final a = Announcement(
        title: 'Test',
        description: 'Desc',
        date: DateTime(2025, 3, 5),
        time: const TimeOfDay(hour: 9, minute: 30),
        venue: 'Room A', id: '', societyId: '', content: '',
      );
      expect(a.dateTimeVenueString, '2025-03-05, 09:30 AM @ Room A');
    });

    // ANN-02 — EP: valid PM time, 24-hour input maps to 12-hour with zero-pad
    test('formats PM time correctly (14:45 → 02:45 PM)', () {
      final a = Announcement(
        title: 'Test',
        description: 'Desc',
        date: DateTime(2025, 11, 25),
        time: const TimeOfDay(hour: 14, minute: 45),
        venue: 'Hall', id: '', societyId: '', content: '',
      );
      expect(a.dateTimeVenueString, '2025-11-25, 02:45 PM @ Hall');
    });

    // ANN-03 — BVA: noon boundary (hour 12 = PM, hourOfPeriod = 12)
    test('formats noon as 12:00 PM', () {
      final a = Announcement(
        title: 'Test',
        description: 'Desc',
        date: DateTime(2025, 6, 15),
        time: const TimeOfDay(hour: 12, minute: 0),
        venue: 'Venue', id: '', societyId: '', content: '',
      );
      expect(a.dateTimeVenueString, '2025-06-15, 12:00 PM @ Venue');
    });

    // ANN-04 — BVA: midnight boundary (hour 0 = AM, hourOfPeriod = 12)
    test('formats midnight as 12:00 AM', () {
      final a = Announcement(
        title: 'Test',
        description: 'Desc',
        date: DateTime(2025, 1, 1),
        time: const TimeOfDay(hour: 0, minute: 0),
        venue: 'Venue', id: '', societyId: '', content: '',
      );
      expect(a.dateTimeVenueString, '2025-01-01, 12:00 AM @ Venue');
    });

    // ANN-05 — BVA: zero-pads single-digit month and day
    test('zero-pads single-digit month and day in date string', () {
      final a = Announcement(
        title: 'Test',
        description: 'Desc',
        date: DateTime(2025, 3, 5),
        time: const TimeOfDay(hour: 9, minute: 7),
        venue: 'Room', id: '', societyId: '', content: '',
      );
      expect(a.dateTimeVenueString, contains('2025-03-05'));
    });

    // ANN-06 — BVA: double-digit month and day need no zero-padding
    test('does not alter double-digit month and day', () {
      final a = Announcement(
        title: 'Test',
        description: 'Desc',
        date: DateTime(2025, 11, 25),
        time: const TimeOfDay(hour: 10, minute: 0),
        venue: 'Hall', id: '', societyId: '', content: '',
      );
      expect(a.dateTimeVenueString, contains('2025-11-25'));
    });

    // ANN-07 — EP: multi-word venue is preserved verbatim
    test('includes multi-word venue after @ symbol', () {
      final a = Announcement(
        title: 'Test',
        description: 'Desc',
        date: DateTime(2025, 5, 20),
        time: const TimeOfDay(hour: 10, minute: 0),
        venue: 'Main Hall Room 2A', id: '', societyId: '', content: '',
      );
      expect(a.dateTimeVenueString, endsWith('@ Main Hall Room 2A'));
    });

    // ANN-08 — BVA: zero-pads single-digit minutes
    test('zero-pads single-digit minutes', () {
      final a = Announcement(
        title: 'Test',
        description: 'Desc',
        date: DateTime(2025, 5, 20),
        time: const TimeOfDay(hour: 10, minute: 5),
        venue: 'Room', id: '', societyId: '', content: '',
      );
      expect(a.dateTimeVenueString, contains('10:05'));
    });
  });

  // ── Widget tests: AnnouncementHome ───────────────────────────────────────

  group('AnnouncementHome', () {
    // AH-01 — empty state shows placeholder text
    testWidgets('shows empty-state text when no announcements exist', (tester) async {
      await tester.pumpWidget(MaterialApp(home: AnnouncementHome()));
      expect(find.text('No announcements yet.'), findsOneWidget);
    });

    // AH-02 — empty state shows Post button
    testWidgets('shows Post button in empty state', (tester) async {
      await tester.pumpWidget(MaterialApp(home: AnnouncementHome()));
      expect(find.text('Post'), findsWidgets);
    });

    // AH-03 — AppBar title
    testWidgets('shows correct AppBar title', (tester) async {
      await tester.pumpWidget(MaterialApp(home: AnnouncementHome()));
      expect(find.text('Society Announcements'), findsOneWidget);
    });

    // AH-04 — FAB label
    testWidgets('FloatingActionButton has Post label', (tester) async {
      await tester.pumpWidget(MaterialApp(home: AnnouncementHome()));
      expect(find.widgetWithText(FloatingActionButton, 'Post'), findsOneWidget);
    });

    // AH-05 — FAB navigates to create page
    testWidgets('tapping FAB navigates to CreateAnnouncementPage', (tester) async {
      await tester.pumpWidget(MaterialApp(home: AnnouncementHome()));
      await tester.tap(find.widgetWithText(FloatingActionButton, 'Post'));
      await tester.pumpAndSettle();
      expect(find.text('Create Announcement'), findsOneWidget);
    });
  });

  // ── Widget tests: CreateAnnouncementPage ─────────────────────────────────

  group('CreateAnnouncementPage', () {
    // CAP-01 — initial render has all required fields
    testWidgets('shows 3 form fields, date/time pickers and Save button', (tester) async {
      await tester.pumpWidget(MaterialApp(home: CreateAnnouncementPage()));
      expect(find.byType(TextFormField), findsNWidgets(3));
      expect(find.text('Pick date'), findsOneWidget);
      expect(find.text('Pick time'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    // CAP-02 — EP: empty title is rejected
    testWidgets('empty title shows validation error', (tester) async {
      await tester.pumpWidget(MaterialApp(home: CreateAnnouncementPage()));
      await tester.enterText(find.byType(TextFormField).at(1), 'Description');
      await tester.enterText(find.byType(TextFormField).at(2), 'Hall');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter a title'), findsOneWidget);
    });

    // CAP-03 — BVA: whitespace-only title is rejected (trim().isEmpty = true)
    testWidgets('whitespace-only title shows validation error', (tester) async {
      await tester.pumpWidget(MaterialApp(home: CreateAnnouncementPage()));
      await tester.enterText(find.byType(TextFormField).at(0), '   ');
      await tester.enterText(find.byType(TextFormField).at(1), 'Description');
      await tester.enterText(find.byType(TextFormField).at(2), 'Hall');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter a title'), findsOneWidget);
    });

    // CAP-04 — EP: empty description is rejected
    testWidgets('empty description shows validation error', (tester) async {
      await tester.pumpWidget(MaterialApp(home: CreateAnnouncementPage()));
      await tester.enterText(find.byType(TextFormField).at(0), 'Annual Gala');
      await tester.enterText(find.byType(TextFormField).at(2), 'Hall');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter a description'), findsOneWidget);
    });

    // CAP-05 — EP: empty venue is rejected
    testWidgets('empty venue shows validation error', (tester) async {
      await tester.pumpWidget(MaterialApp(home: CreateAnnouncementPage()));
      await tester.enterText(find.byType(TextFormField).at(0), 'Annual Gala');
      await tester.enterText(find.byType(TextFormField).at(1), 'A great event');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter a venue'), findsOneWidget);
    });

    // CAP-06 — EP: valid text fields but no date/time picked shows SnackBar
    testWidgets('shows snackbar when date and time are not selected', (tester) async {
      await tester.pumpWidget(MaterialApp(home: CreateAnnouncementPage()));
      await tester.enterText(find.byType(TextFormField).at(0), 'Annual Gala');
      await tester.enterText(find.byType(TextFormField).at(1), 'A great event');
      await tester.enterText(find.byType(TextFormField).at(2), 'Main Hall');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Please pick date and time'), findsOneWidget);
    });
  });
}

