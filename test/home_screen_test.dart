import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sociefy/home_screen.dart';

void main() {
  group('HomePage', () {
    // HP-01 — empty state
    testWidgets('shows empty-state text when no societies exist', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomePage()));
      expect(find.text('No societies yet.'), findsOneWidget);
    });

    // HP-02 — FAB present
    testWidgets('shows FloatingActionButton with add icon', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomePage()));
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    // HP-03 — AppBar title
    testWidgets('shows Home in the AppBar', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomePage()));
      expect(find.text('Home'), findsOneWidget);
    });

    // HP-04 — tapping FAB opens Create Society dialog with two TextField widgets
    testWidgets('tapping FAB opens Create Society dialog', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomePage()));
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.text('Create Society'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
    });

    // Dialog label text is visible
    testWidgets('dialog shows Society Name and Description label text', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomePage()));
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.text('Society Name'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
    });

    // HP-05 — EP: invalid partition — name empty, desc provided → dialog stays open
    testWidgets('EP: create with empty name does not add society', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomePage()));
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).at(1), 'A cool society');
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();
      expect(find.text('Create Society'), findsOneWidget);
    });

    // HP-06 — EP: invalid partition — name provided, desc empty → dialog stays open
    testWidgets('EP: create with empty description does not add society', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomePage()));
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).at(0), 'Chess Club');
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();
      expect(find.text('Create Society'), findsOneWidget);
    });

    // HP-07 — EP: invalid partition — both fields empty → dialog stays open
    testWidgets('EP: create with both fields empty does not add society', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomePage()));
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();
      expect(find.text('Create Society'), findsOneWidget);
    });

    // HP-08 — EP: valid partition — both fields non-empty → society added
    testWidgets('EP: create with valid name and description adds society', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomePage()));
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).at(0), 'Chess Club');
      await tester.enterText(find.byType(TextField).at(1), 'A club for chess enthusiasts');
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();
      expect(find.text('Chess Club'), findsOneWidget);
      expect(find.text('No societies yet.'), findsNothing);
    });

    // HP-09 — Cancel button closes dialog without adding society
    testWidgets('Cancel closes dialog without adding society', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomePage()));
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).at(0), 'Chess Club');
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Create Society'), findsNothing);
      expect(find.text('No societies yet.'), findsOneWidget);
    });

    // HP-10 — Join button shows Joined Society confirmation dialog
    testWidgets('Join button shows Joined Society dialog with society name', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomePage()));
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).at(0), 'Drama Society');
      await tester.enterText(find.byType(TextField).at(1), 'For drama lovers');
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Join'));
      await tester.pumpAndSettle();
      expect(find.text('Joined Society'), findsOneWidget);
      // Society name appears in both the list card and the dialog body text
      expect(find.textContaining('Drama Society'), findsWidgets);
    });

    // HP-11 — OK button dismisses join confirmation dialog
    testWidgets('OK dismisses the Joined Society dialog', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomePage()));
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).at(0), 'Drama Society');
      await tester.enterText(find.byType(TextField).at(1), 'For drama lovers');
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Join'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('Joined Society'), findsNothing);
    });

    // HP-12 — BVA: single-character name and description are the minimum valid inputs
    testWidgets('BVA: single-character name and description create a society', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomePage()));
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).at(0), 'X');
      await tester.enterText(find.byType(TextField).at(1), 'Y');
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();
      expect(find.text('X'), findsOneWidget);
    });

    // HP-13 — multiple societies are all displayed
    testWidgets('multiple created societies are all shown in the list', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomePage()));
      // First society
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).at(0), 'Chess Club');
      await tester.enterText(find.byType(TextField).at(1), 'Chess');
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();
      // Second society
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).at(0), 'Drama Society');
      await tester.enterText(find.byType(TextField).at(1), 'Drama');
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();
      expect(find.text('Chess Club'), findsOneWidget);
      expect(find.text('Drama Society'), findsOneWidget);
    });
  });
}
