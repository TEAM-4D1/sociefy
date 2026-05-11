import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sociefy/models/committee_member.dart';
import 'package:sociefy/models/society.dart';
import 'package:sociefy/providers/app_state.dart';
import 'package:sociefy/screens/contact_info_screen.dart';

/// Helper function to build a test widget tree with ContactInfoScreen.
Widget buildTestWidget(AppState appState, Society society) {
  return MaterialApp(
    home: ChangeNotifierProvider.value(
      value: appState,
      child: ContactInfoScreen(society: society),
    ),
  );
}

void main() {
  group('ContactInfoScreen Tests', () {
    testWidgets('renders app bar with title \'Contact Info\'', (
      WidgetTester tester,
    ) async {
      final testMember = CommitteeMember(
        name: 'Alice Smith',
        role: 'President',
        email: 'alice@example.com',
      );
      final testSociety = Society(
        id: 'test-id',
        name: 'Test Society',
        category: 'Academic',
        description: 'A test society',
        committeeMembers: [testMember],
      );
      final appState = AppState(skipFirebase: true);
      await tester.pumpWidget(buildTestWidget(appState, testSociety));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Contact Info'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('renders the \'Committee Members\' heading text on screen', (
      WidgetTester tester,
    ) async {
      final testMember = CommitteeMember(
        name: 'Alice Smith',
        role: 'President',
        email: 'alice@example.com',
      );
      final testSociety = Society(
        id: 'test-id',
        name: 'Test Society',
        category: 'Academic',
        description: 'A test society',
        committeeMembers: [testMember],
      );
      final appState = AppState(skipFirebase: true);
      await tester.pumpWidget(buildTestWidget(appState, testSociety));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Committee Members'), findsOneWidget);
    });

    testWidgets(
      'renders a committee member\'s role text when the society has committee members',
      (WidgetTester tester) async {
        final testMember = CommitteeMember(
          name: 'Alice Smith',
          role: 'President',
          email: 'alice@example.com',
        );
        final testSociety = Society(
          id: 'test-id',
          name: 'Test Society',
          category: 'Academic',
          description: 'A test society',
          committeeMembers: [testMember],
        );
        final appState = AppState(skipFirebase: true);
        await tester.pumpWidget(buildTestWidget(appState, testSociety));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('President'), findsOneWidget);
      },
    );

    testWidgets(
      'renders a committee member\'s name text when the society has committee members',
      (WidgetTester tester) async {
        final testMember = CommitteeMember(
          name: 'Alice Smith',
          role: 'President',
          email: 'alice@example.com',
        );
        final testSociety = Society(
          id: 'test-id',
          name: 'Test Society',
          category: 'Academic',
          description: 'A test society',
          committeeMembers: [testMember],
        );
        final appState = AppState(skipFirebase: true);
        await tester.pumpWidget(buildTestWidget(appState, testSociety));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Alice Smith'), findsOneWidget);
      },
    );

    testWidgets(
      'Add Committee Member button is disabled when user is NOT admin',
      (WidgetTester tester) async {
        final testMember = CommitteeMember(
          name: 'Alice Smith',
          role: 'President',
          email: 'alice@example.com',
        );
        final testSociety = Society(
          id: 'test-id',
          name: 'Test Society',
          category: 'Academic',
          description: 'A test society',
          committeeMembers: [testMember],
        );
        final appState = AppState(skipFirebase: true);
        // Set user as non-admin directly (don't call login() as it has Firebase side effects)
        appState.userId = 'test-user';
        appState.isAdmin = false;

        await tester.pumpWidget(buildTestWidget(appState, testSociety));
        await tester.pump(const Duration(milliseconds: 100));

        // Find the button with "Add Committee Member" text
        // The button is rendered as ElevatedButton.icon with a label
        final buttonFinder = find.text('Add Committee Member');
        expect(buttonFinder, findsWidgets); // May appear in tooltip and label

        // Verify button is disabled (no onPressed)
        // Find parent ElevatedButton and check its onPressed
        final elevatedButtonFinder = find.descendant(
          of: find.byType(Tooltip),
          matching: find.byWidgetPredicate(
            (widget) => widget is ElevatedButton && widget.onPressed == null,
          ),
        );
        expect(elevatedButtonFinder, findsOneWidget);
      },
    );
  });
}
