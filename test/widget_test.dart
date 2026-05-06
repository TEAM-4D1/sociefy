import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sociefy/screens/sign_in_screen.dart';
import 'package:sociefy/providers/app_state.dart';

void main() {
  testWidgets('SignInScreen builds without throwing', (
    WidgetTester tester,
  ) async {
    final appState = AppState(skipFirebase: true);
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider.value(
          value: appState,
          child: const SignInScreen(),
        ),
      ),
    );
    expect(find.byType(SignInScreen), findsOneWidget);
  });

  testWidgets('SignInScreen shows email and password fields', (
    WidgetTester tester,
  ) async {
    final appState = AppState(skipFirebase: true);
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider.value(
          value: appState,
          child: const SignInScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });

  test(
    'AppState(skipFirebase: true) initialises with isAuthenticated false',
    () {
      final appState = AppState(skipFirebase: true);
      expect(appState.isAuthenticated, false);
    },
  );
}
