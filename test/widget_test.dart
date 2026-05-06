import 'package:flutter_test/flutter_test.dart';
import 'package:sociefy/main.dart';
import 'package:sociefy/providers/app_state.dart';

void main() {
  testWidgets('MyApp builds without throwing', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(MyApp), findsOneWidget);
  });

  testWidgets(
    'app initially shows the SignInScreen with email and password fields',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    },
  );

  test(
    'AppState(skipFirebase: true) initialises with isAuthenticated false',
    () {
      final appState = AppState(skipFirebase: true);
      expect(appState.isAuthenticated, false);
    },
  );
}
