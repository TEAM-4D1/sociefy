import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sociefy/screens/register_screen.dart';

void main() {
  group('RegisterScreen Widget Tests', () {
    /// Helper function to build RegisterScreen wrapped in MaterialApp.
    Widget buildTestWidget() {
      return const MaterialApp(home: RegisterScreen());
    }

    /// Test 1: Verify all form fields and Register button are rendered.
    testWidgets(
      'Renders display name field, email field, password field, and Register button',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestWidget());

        expect(find.byType(TextFormField), findsNWidgets(3));
        expect(find.text('Display Name'), findsOneWidget);
        expect(find.text('Email'), findsOneWidget);
        expect(find.text('Password'), findsOneWidget);
        expect(find.text('Register'), findsWidgets);
        expect(find.byType(ElevatedButton), findsOneWidget);
      },
    );

    /// Test 2: Submitting with empty fields shows validation errors.
    testWidgets('Shows validation errors when submitting empty form', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Please enter your display name'), findsOneWidget);
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    /// Test 3: Empty display name shows validation error.
    testWidgets('Shows validation error for empty display name', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.enterText(find.byType(TextFormField).at(1), 'test@example.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'password123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Please enter your display name'), findsOneWidget);
    });

    /// Test 4: Display name shorter than 2 characters shows error.
    testWidgets(
      'Shows validation error for display name shorter than 2 characters',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestWidget());

        await tester.enterText(find.byType(TextFormField).at(0), 'A');
        await tester.enterText(find.byType(TextFormField).at(1), 'test@example.com');
        await tester.enterText(find.byType(TextFormField).at(2), 'password123');
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        expect(
          find.text('Display name must be at least 2 characters'),
          findsOneWidget,
        );
      },
    );

    /// Test 5: Empty email shows validation error.
    testWidgets('Shows validation error for empty email', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
      await tester.enterText(find.byType(TextFormField).at(2), 'password123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Please enter your email'), findsOneWidget);
    });

    /// Test 6: Email without @ symbol shows validation error.
    testWidgets('Shows validation error for email without @ symbol', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
      await tester.enterText(find.byType(TextFormField).at(1), 'testexample.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'password123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    /// Test 7: Email with @ symbol but missing domain shows no error (@ is sufficient).
    testWidgets('Shows no validation error for email with @ but no domain', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
      await tester.enterText(find.byType(TextFormField).at(1), 'test@');
      await tester.enterText(find.byType(TextFormField).at(2), 'password123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Please enter a valid email'), findsNothing);
    });

    /// Test 8: Empty password shows validation error.
    testWidgets('Shows validation error for empty password', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
      await tester.enterText(find.byType(TextFormField).at(1), 'test@example.com');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Please enter your password'), findsOneWidget);
    });

    /// Test 9: Password shorter than 6 characters shows validation error.
    testWidgets(
      'Shows validation error for password shorter than 6 characters',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestWidget());

        await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
        await tester.enterText(find.byType(TextFormField).at(1), 'test@example.com');
        await tester.enterText(find.byType(TextFormField).at(2), 'pass');
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        expect(
          find.text('Password must be at least 6 characters'),
          findsOneWidget,
        );
      },
    );

    /// Test 10: Password with exactly 6 characters passes validation.
    testWidgets('Password with exactly 6 characters passes validation', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
      await tester.enterText(find.byType(TextFormField).at(1), 'test@example.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'pass12');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Password must be at least 6 characters'), findsNothing);
    });

    /// Test 11: Valid form does not show validation errors.
    testWidgets('Valid form does not show validation errors', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
      await tester.enterText(find.byType(TextFormField).at(1), 'john@example.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'password123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Please enter your display name'), findsNothing);
      expect(find.text('Please enter your email'), findsNothing);
      expect(find.text('Please enter your password'), findsNothing);
      expect(find.text('Please enter a valid email'), findsNothing);
      expect(find.text('Password must be at least 6 characters'), findsNothing);
    });

    /// Test 12: Valid form submission shows "Registration failed" snackbar when Firebase unavailable.
    testWidgets(
      'Valid form submission shows "Registration failed" snackbar when auth unavailable',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestWidget());

        await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
        await tester.enterText(find.byType(TextFormField).at(1), 'john@example.com');
        await tester.enterText(find.byType(TextFormField).at(2), 'securepass');
        await tester.tap(find.byType(ElevatedButton));
        // pump() drains microtasks so the async auth call completes;
        // second pump advances past the snackbar entrance frame.
        // Avoid pumpAndSettle — the screen has a repeating AnimationController.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('Registration failed'), findsOneWidget);
      },
    );

    /// Test 13: Multiple validation errors show together.
    testWidgets('Shows multiple validation errors simultaneously', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.enterText(find.byType(TextFormField).at(0), 'J');
      await tester.enterText(find.byType(TextFormField).at(1), 'invalidemail');
      await tester.enterText(find.byType(TextFormField).at(2), '123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(
        find.text('Display name must be at least 2 characters'),
        findsOneWidget,
      );
      expect(find.text('Please enter a valid email'), findsOneWidget);
      expect(
        find.text('Password must be at least 6 characters'),
        findsOneWidget,
      );
    });

    /// Test 14: Password field obscures text input.
    testWidgets('Password field obscures text (obscureText is true)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());

      final editableText = tester.widget<EditableText>(
        find.descendant(
          of: find.byType(TextFormField).at(2),
          matching: find.byType(EditableText),
        ),
      );
      expect(editableText.obscureText, isTrue);
    });

    /// Test 15: Form fields accept special characters.
    testWidgets('Form fields accept special characters in display name', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.enterText(find.byType(TextFormField).at(0), "O'Brien-Smith");
      await tester.enterText(find.byType(TextFormField).at(1), 'obrien@example.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'password123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Please enter your display name'), findsNothing);
      expect(find.text('Display name must be at least 2 characters'), findsNothing);
    });

    /// Test 16: Two-character display name passes validation.
    testWidgets('Display name with exactly 2 characters passes validation', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.enterText(find.byType(TextFormField).at(0), 'Jo');
      await tester.enterText(find.byType(TextFormField).at(1), 'test@example.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'password123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Please enter your display name'), findsNothing);
      expect(find.text('Display name must be at least 2 characters'), findsNothing);
    });

    /// Test 17: AppBar title and back button are present.
    testWidgets('Renders AppBar with title and back button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Register'), findsWidgets);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    /// Test 18: Email field accepts mixed case letters.
    testWidgets('Email field accepts mixed case letters', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
      await tester.enterText(find.byType(TextFormField).at(1), 'John.Doe@Example.COM');
      await tester.enterText(find.byType(TextFormField).at(2), 'password123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Please enter a valid email'), findsNothing);
    });

    /// Test 19: Form fields can be cleared and refilled.
    testWidgets('Form fields can be cleared and refilled', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
      await tester.enterText(find.byType(TextFormField).at(1), 'john@example.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'password123');

      await tester.enterText(find.byType(TextFormField).at(0), 'Jane Smith');
      await tester.enterText(find.byType(TextFormField).at(1), 'jane@example.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'secret456');

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(find.text('Please enter your display name'), findsNothing);
      expect(find.text('Please enter your email'), findsNothing);
      expect(find.text('Please enter your password'), findsNothing);
    });

    /// Test 20: Register button is enabled for valid form.
    testWidgets('Register button is enabled for valid form', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
      await tester.enterText(find.byType(TextFormField).at(1), 'john@example.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'password123');

      final button = find.byType(ElevatedButton);
      expect(button, findsOneWidget);
      await tester.tap(button);
      expect(tester.takeException(), isNull);
    });
  });
}
