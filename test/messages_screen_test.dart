import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sociefy/messages_screen.dart';

void main() {
  group('MessagesPage', () {
    // MP-01 — AppBar shows correct title
    testWidgets('shows Messages in the AppBar', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: MessagesPage()));
      expect(find.text('Messages'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    // MP-02 — body shows placeholder text
    testWidgets('shows forum placeholder text in the body', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: MessagesPage()));
      expect(find.text('Messages / Forums go here'), findsOneWidget);
    });

    // MP-03 — placeholder text is centred
    testWidgets('placeholder text is wrapped in a Center widget', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: MessagesPage()));
      expect(
        find.ancestor(
          of: find.text('Messages / Forums go here'),
          matching: find.byType(Center),
        ),
        findsOneWidget,
      );
    });

    // MP-04 — widget tree contains MessagesPage
    testWidgets('MessagesPage widget is present in the tree', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: MessagesPage()));
      expect(find.byType(MessagesPage), findsOneWidget);
    });
  });
}
