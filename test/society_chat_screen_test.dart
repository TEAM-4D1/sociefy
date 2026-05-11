import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../lib/models/society.dart';
import '../lib/providers/app_state.dart';
import '../lib/screens/society_chat_screen.dart';

void main() {
  group('SocietyChatScreen Tests', () {
    final testSociety = Society(
      id: 'test-society-id',
      name: 'Chess Club',
      category: 'Games',
      description: 'A chess society',
      committeeMembers: [],
    );

    Widget buildTestWidget(AppState appState, Society society) {
      return MaterialApp(
        home: ChangeNotifierProvider.value(
          value: appState,
          child: SocietyChatScreen(society: society),
        ),
      );
    }

    testWidgets('renders app bar with the society name (\'Chess Club\')', (
      WidgetTester tester,
    ) async {
      final appState = AppState(skipFirebase: true);
      await tester.pumpWidget(buildTestWidget(appState, testSociety));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Chess Club'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets(
      'renders a CircularProgressIndicator while the Firestore stream is waiting',
      (WidgetTester tester) async {
        final appState = AppState(skipFirebase: true);
        await tester.pumpWidget(buildTestWidget(appState, testSociety));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets(
      'renders the message input TextField and send button when user is NOT a guest',
      (WidgetTester tester) async {
        final appState = AppState(skipFirebase: true);
        // By default with skipFirebase: true, isGuest should be false
        await tester.pumpWidget(buildTestWidget(appState, testSociety));
        await tester.pump(const Duration(milliseconds: 100));

        // Verify user is not a guest
        expect(appState.isGuest, false);

        // Check for TextField with hint text
        expect(find.byType(TextField), findsOneWidget);
        expect(
          find.widgetWithText(TextField, 'Type a message…'),
          findsOneWidget,
        );

        // Check for send button (FloatingActionButton.small with send icon)
        expect(find.byIcon(Icons.send), findsOneWidget);
      },
    );

    testWidgets(
      'shows the guest message \'Guests can read the chat but cannot send messages.\' when appState.isGuest is true',
      (WidgetTester tester) async {
        final appState = AppState(skipFirebase: true);
        // Set guest mode by logging in with 'guest' userId
        await appState.login(userId: 'guest');
        await tester.pumpWidget(buildTestWidget(appState, testSociety));
        await tester.pump(const Duration(milliseconds: 100));

        // Verify user is a guest
        expect(appState.isGuest, true);

        // Check for guest message text
        expect(
          find.text('Guests can read the chat but cannot send messages.'),
          findsOneWidget,
        );

        // Verify no message input is shown
        expect(find.byType(TextField), findsNothing);
        expect(find.byIcon(Icons.send), findsNothing);
      },
    );
  });
}
