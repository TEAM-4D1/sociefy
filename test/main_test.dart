import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sociefy/screens/sign_in_screen.dart';
import 'package:sociefy/providers/app_state.dart';
import 'package:sociefy/models/society.dart';

void main() {
  testWidgets('SignInScreen renders correctly with mocked AppState',
      (WidgetTester tester) async {
    final appState = AppState(skipFirebase: true);
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider.value(
          value: appState,
          child: const SignInScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });

  test('Society.fromMap parses valid map', () {
    final map = {
      'id': 's1',
      'name': 'Chess Club',
      'category': 'Sports',
      'description': 'We play chess',
    };

    final society = Society.fromMap(map);

    expect(society.id, 's1');
    expect(society.name, 'Chess Club');
    expect(society.category, 'Sports');
    expect(society.description, 'We play chess');
  });

  test('Society.fromMap handles missing keys gracefully', () {
    final map = {
      'name': 'Drama Society',
    };

    final society = Society.fromMap(map, id: 'generated-id');

    expect(society.id, 'generated-id');
    expect(society.name, 'Drama Society');
    expect(society.category, '');
    expect(society.description, '');
  });
}
