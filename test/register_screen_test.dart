import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sociefy/screens/register_screen.dart';

/// Wraps the screen in a minimal app that provides Navigator + Material context.
Widget buildTestWidget() {
  return const MaterialApp(home: RegisterScreen());
}

void main() {
  group('RegisterScreen Widget Tests', () {
    // ------------------------------------------------------------------ //
    //  UI structure
    // ------------------------------------------------------------------ //

    testWidgets('renders display name, email and password fields', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.byType(TextFormField), findsNWidgets(3));
    });

    testWidgets('renders a Register button', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.widgetWithText(ElevatedButton, 'Register'), findsOneWidget);
    });

    testWidgets('AppBar shows title "Register"', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.text('Register'), findsWidgets);
    });

    testWidgets('AppBar has a back/leading button', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.byType(IconButton), findsOneWidget);
    });

    // ------------------------------------------------------------------ //
    //  Empty form submission
    // ------------------------------------------------------------------ //

    testWidgets('submitting empty form shows all three required-field errors',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
      await tester.pump();

      expect(find.text('Please enter your display name'), findsOneWidget);
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    // ------------------------------------------------------------------ //
    //  Display name validation
    // ------------------------------------------------------------------ //

    testWidgets('empty display name shows required error', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.enterText(find.byType(TextFormField).at(1), 'a@b.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'password1');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
      await tester.pump();

      expect(find.text('Please enter your display name'), findsOneWidget);
    });

    testWidgets('display name with 1 character shows min-length error',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.enterText(find.byType(TextFormField).at(0), 'A');
      await tester.enterText(find.byType(TextFormField).at(1), 'a@b.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'password1');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
      await tester.pump();

      expect(find.text('Display name must be at least 2 characters'),
          findsOneWidget);
    });

    testWidgets('display name with exactly 2 characters passes validation',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.enterText(find.byType(TextFormField).at(0), 'Al');
      await tester.enterText(find.byType(TextFormField).at(1), 'a@b.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'password1');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
      await tester.pump();

      expect(find.text('Display name must be at least 2 characters'),
          findsNothing);
    });

    testWidgets('display name accepts special characters', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.enterText(
          find.byType(TextFormField).at(0), "O'Brien-Smith");
      await tester.enterText(find.byType(TextFormField).at(1), 'a@b.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'password1');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
      await tester.pump();

      expect(find.text('Please enter your display name'), findsNothing);
      expect(find.text('Display name must be at least 2 characters'),
          findsNothing);
    });

    // ------------------------------------------------------------------ //
    //  Email validation
    // ------------------------------------------------------------------ //

    testWidgets('empty email shows required error', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
      await tester.enterText(find.byType(TextFormField).at(2), 'password1');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
      await tester.pump();

      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('email without @ shows invalid-email error', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
      await tester.enterText(
          find.byType(TextFormField).at(1), 'notanemail.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'password1');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
      await tester.pump();

      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('email containing @ passes validation', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
      await tester.enterText(
          find.byType(TextFormField).at(1), 'user@example.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'password1');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
      await tester.pump();

      expect(find.text('Please enter a valid email'), findsNothing);
    });

    testWidgets('email field accepts mixed-case letters', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
      await tester.enterText(
          find.byType(TextFormField).at(1), 'User@Example.COM');
      await tester.enterText(find.byType(TextFormField).at(2), 'password1');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
      await tester.pump();

      expect(find.text('Please enter a valid email'), findsNothing);
    });

    // ------------------------------------------------------------------ //
    //  Password validation
    // ------------------------------------------------------------------ //

    testWidgets('empty password shows required error', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
      await tester.enterText(
          find.byType(TextFormField).at(1), 'user@example.com');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
      await tester.pump();

      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('password shorter than 6 characters shows min-length error',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
      await tester.enterText(
          find.byType(TextFormField).at(1), 'user@example.com');
      await tester.enterText(find.byType(TextFormField).at(2), '12345');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
      await tester.pump();

      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    });

    testWidgets('password with exactly 6 characters passes validation',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
      await tester.enterText(
          find.byType(TextFormField).at(1), 'user@example.com');
      await tester.enterText(find.byType(TextFormField).at(2), '123456');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
      await tester.pump();

      expect(find.text('Password must be at least 6 characters'), findsNothing);
    });

    testWidgets('password field obscures text', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      final editableText = tester.widget<EditableText>(
        find.descendant(
          of: find.byType(TextFormField).at(2),
          matching: find.byType(EditableText),
        ),
      );
      expect(editableText.obscureText, isTrue);
    });

    // ------------------------------------------------------------------ //
    //  Valid form behaviour
    // ------------------------------------------------------------------ //

    testWidgets('valid form shows no validation errors', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
      await tester.enterText(
          find.byType(TextFormField).at(1), 'john@example.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'securepass');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
      await tester.pump();

      expect(find.text('Please enter your display name'), findsNothing);
      expect(find.text('Please enter your email'), findsNothing);
      expect(find.text('Please enter your password'), findsNothing);
    });

    testWidgets('valid form submission shows "Registration failed" snackbar when auth unavailable',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
      await tester.enterText(
          find.byType(TextFormField).at(1), 'john@example.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'securepass');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
      // pump() drains microtasks so the async auth call completes and the
      // snackbar is queued; the second pump advances past the entrance frame.
      // We avoid pumpAndSettle because the screen has a repeating AnimationController
      // that never settles.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Registration failed'), findsOneWidget);
    });

    // ------------------------------------------------------------------ //
    //  Multiple simultaneous errors
    // ------------------------------------------------------------------ //

    testWidgets('short display name AND missing @ email both show errors',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.enterText(find.byType(TextFormField).at(0), 'J');
      await tester.enterText(find.byType(TextFormField).at(1), 'bademail');
      await tester.enterText(find.byType(TextFormField).at(2), 'short');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
      await tester.pump();

      expect(find.text('Display name must be at least 2 characters'),
          findsOneWidget);
      expect(find.text('Please enter a valid email'), findsOneWidget);
      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    });

    // ------------------------------------------------------------------ //
    //  Form interaction
    // ------------------------------------------------------------------ //

    testWidgets('form fields can be cleared and refilled', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.enterText(find.byType(TextFormField).at(0), 'First Name');
      await tester.enterText(find.byType(TextFormField).at(0), 'Second Name');

      expect(find.text('Second Name'), findsOneWidget);
    });
  });
}
