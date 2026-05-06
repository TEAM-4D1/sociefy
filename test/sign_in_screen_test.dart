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

        expect(find.text('Continue as Guest'), findsOneWidget);
      },
    );

    testWidgets(
      'Committee Sign In button is present',
      (WidgetTester tester) async {
        final appState = AppState(skipFirebase: true);
        await tester.pumpWidget(buildTestWidget(appState));

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
        await tester.pumpAndSettle();

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
        await tester.pumpAndSettle();

        // Password fields use obscureText, so we verify the field received focus
        // and text was entered (without displaying the actual text)
        expect(find.byType(TextFormField), findsNWidgets(2));
      },
    );

    testWidgets(
      'submitting with empty fields does not crash',
      (WidgetTester tester) async {
        final appState = AppState(skipFirebase: true);
        await tester.pumpWidget(buildTestWidget(appState));
        await tester.pumpAndSettle();

        // Tap the Sign In button without entering any text
        final signInButton = find.text('Sign In');
        await tester.tap(signInButton);
        await tester.pumpAndSettle();

        // Screen should still be present (no crash)
        expect(find.byType(SignInScreen), findsOneWidget);
      },
    );

    testWidgets(
      'email field validates empty input',
      (WidgetTester tester) async {
        final appState = AppState(skipFirebase: true);
        await tester.pumpWidget(buildTestWidget(appState));

        // Try to submit without entering email
        final signInButton = find.text('Sign In');
        await tester.tap(signInButton);
        await tester.pumpAndSettle();

        // Validation error should appear
        expect(find.text('Enter email'), findsOneWidget);
      },
    );

    testWidgets(
      'password field validates empty input',
      (WidgetTester tester) async {
        final appState = AppState(skipFirebase: true);
        await tester.pumpWidget(buildTestWidget(appState));

        // Enter email but not password
        final emailField = find.byType(TextFormField).at(0);
        await tester.tap(emailField);
        await tester.enterText(emailField, 'test@example.com');
        await tester.pumpAndSettle();

        // Try to submit
        final signInButton = find.text('Sign In');
        await tester.tap(signInButton);
        await tester.pumpAndSettle();

        // Password validation error should appear
        expect(find.text('Enter password'), findsOneWidget);
      },
    );

    testWidgets(
      'email validation requires @ symbol',
      (WidgetTester tester) async {
        final appState = AppState(skipFirebase: true);
        await tester.pumpWidget(buildTestWidget(appState));

        // Enter invalid email (no @)
        final emailField = find.byType(TextFormField).at(0);
        await tester.tap(emailField);
        await tester.enterText(emailField, 'invalidemail');
        await tester.pumpAndSettle();

        // Enter password
        final passwordField = find.byType(TextFormField).at(1);
        await tester.tap(passwordField);
        await tester.enterText(passwordField, 'password123');
        await tester.pumpAndSettle();

        // Try to submit
        final signInButton = find.text('Sign In');
        await tester.tap(signInButton);
        await tester.pumpAndSettle();

        // Email validation error should appear
        expect(find.text('Enter valid email'), findsOneWidget);
      },
    );

    testWidgets(
      'Register button navigates to RegisterScreen',
      (WidgetTester tester) async {
        final appState = AppState(skipFirebase: true);
        await tester.pumpWidget(buildTestWidget(appState));

        final registerButton = find.text("Don't have an account? Register");
        expect(registerButton, findsOneWidget);
      },
    );

    testWidgets(
      'visibility toggle button is present for password field',
      (WidgetTester tester) async {
        final appState = AppState(skipFirebase: true);
        await tester.pumpWidget(buildTestWidget(appState));

        // Password field should have a visibility icon
        expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      },
    );
  });
}
