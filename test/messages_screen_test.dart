import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sociefy/providers/app_state.dart';
import 'package:sociefy/screens/messages_screen.dart';

/// MessagesPage uses Consumer<AppState> so it needs a Provider ancestor.
Widget buildTestWidget() {
  return ChangeNotifierProvider<AppState>(
    create: (_) => AppState(skipFirebase: true),
    child: const MaterialApp(home: MessagesPage()),
  );
}

void main() {
  group('MessagesPage', () {
    // MP-01 — AppBar shows correct title
    testWidgets('shows Messages in the AppBar', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();
      expect(find.text('Messages'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    // MP-02 — empty state shows placeholder text when no societies joined
    testWidgets('shows placeholder text when no societies are joined',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();
      expect(
        find.text('Join a society to access its message channel.'),
        findsOneWidget,
      );
    });

    // MP-03 — placeholder text is wrapped in a Center widget
    testWidgets('placeholder text is wrapped in a Center widget', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();
      expect(
        find.ancestor(
          of: find.text('Join a society to access its message channel.'),
          matching: find.byType(Center),
        ),
        findsOneWidget,
      );
    });

    // MP-04 — widget tree contains MessagesPage
    testWidgets('MessagesPage widget is present in the tree', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();
      expect(find.byType(MessagesPage), findsOneWidget);
    });
  });
}
