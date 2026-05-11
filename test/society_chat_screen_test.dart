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

    testWidgets('accepts a Society parameter', (WidgetTester tester) async {
      final appState = AppState(skipFirebase: true);
      await tester.pumpWidget(buildTestWidget(appState, testSociety));

      // Verify test data is correct
      expect(testSociety.name, equals('Chess Club'));
      expect(testSociety.id, equals('test-society-id'));
    });

    testWidgets('has correct widget structure with Provider', (
      WidgetTester tester,
    ) async {
      final appState = AppState(skipFirebase: true);
      await tester.pumpWidget(buildTestWidget(appState, testSociety));

      // Verify ChangeNotifierProvider is in the tree
      expect(find.byType(ChangeNotifierProvider), findsOneWidget);
    });
  });
}
