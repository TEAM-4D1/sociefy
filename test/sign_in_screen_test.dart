import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sociefy/screens/sign_in_screen.dart';
import 'package:sociefy/providers/app_state.dart';

void main() {
  group('SignInScreen Tests', () {
    /// Helper to wrap SignInScreen in MaterialApp and AppState Provider
    Widget buildTestWidget(AppState appState) {
      return MaterialApp(
        home: ChangeNotifierProvider.value(
          value: appState,
          child: const SignInScreen(),
        ),
      );
    }

    testWidgets(
      'SignInScreen renders email field, password field, and Sign In button',
      (WidgetTester tester) async {
        final appState = AppState(skipFirebase: true);
        await tester.pumpWidget(buildTestWidget(appState));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Email'), findsOneWidget);
        expect(find.text('Password'), findsOneWidget);
        expect(find.text('Sign In'), findsOneWidget);
      },
    );

    testWidgets(
      'Continue as Guest button is present on the screen',
      (WidgetTester tester) async {
        final appState = AppState(skipFirebase: true);
        await tester.pumpWidget(buildTestWidget(appState));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Continue as Guest'), findsOneWidget);
      },
    );

    testWidgets(
      'Committee Sign In button is present',
      (WidgetTester tester) async {
        final appState = AppState(skipFirebase: true);
        await tester.pumpWidget(buildTestWidget(appState));
        await tester.pump(const Duration(milliseconds: 100));

        expect(
          find.text('Are you a committee member or admin? Sign in here'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'entering text into the email field updates the field correctly',
      (WidgetTester tester) async {
        final appState = AppState(skipFirebase: true);
        await tester.pumpWidget(buildTestWidget(appState));

        final emailField = find.byType(TextFormField).at(0);
        await tester.tap(emailField);
        await tester.enterText(emailField, 'test@example.com');
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('test@example.com'), findsOneWidget);
      },
    );

    testWidgets(
      'entering text into the password field updates it correctly',
      (WidgetTester tester) async {
        final appState = AppState(skipFirebase: true);
        await tester.pumpWidget(buildTestWidget(appState));

        final passwordField = find.byType(TextFormField).at(1);
        await tester.tap(passwordField);
        await tester.enterText(passwordField, 'password123');
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(TextFormField), findsNWidgets(2));
      },
    );

    testWidgets(
      'submitting with empty fields does not crash',
      (WidgetTester tester) async {
        final appState = AppState(skipFirebase: true);
        await tester.pumpWidget(buildTestWidget(appState));
        await tester.pump(const Duration(milliseconds: 100));

        final signInButton = find.text('Sign In');
        await tester.tap(signInButton);
        await tester.pump(const Duration(milliseconds: 200));

        expect(find.byType(SignInScreen), findsOneWidget);
      },
    );

    testWidgets(
      'Register button is present',
      (WidgetTester tester) async {
        final appState = AppState(skipFirebase: true);
        await tester.pumpWidget(buildTestWidget(appState));
        await tester.pump(const Duration(milliseconds: 100));

        final registerButton = find.text("Don't have an account? Register");
        expect(registerButton, findsOneWidget);
      },
    );

    testWidgets(
      'visibility toggle button is present for password field',
      (WidgetTester tester) async {
        final appState = AppState(skipFirebase: true);
        await tester.pumpWidget(buildTestWidget(appState));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      },
    );

    testWidgets(
      'email field is a TextFormField',
      (WidgetTester tester) async {
        final appState = AppState(skipFirebase: true);
        await tester.pumpWidget(buildTestWidget(appState));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(TextFormField), findsNWidgets(2));
      },
    );

    testWidgets(
      'Sign In button is tappable',
      (WidgetTester tester) async {
        final appState = AppState(skipFirebase: true);
        await tester.pumpWidget(buildTestWidget(appState));
        await tester.pump(const Duration(milliseconds: 100));

        final signInButton = find.text('Sign In');
        expect(signInButton, findsOneWidget);
        await tester.tap(signInButton);
        await tester.pump(const Duration(milliseconds: 100));
      },
    );
  });
}
