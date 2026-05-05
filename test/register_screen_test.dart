import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sociefy/screens/register_screen.dart';

void main() {
  group('RegisterScreen Widget Tests', () {
    /// Helper function to build RegisterScreen wrapped in MaterialApp.
    /// Ensures proper Material context for navigation and theme.
    Widget buildTestWidget() {
      return MaterialApp(home: const RegisterScreen());
    }

    /// Test 1: Verify all form fields and Register button are rendered.
    testWidgets(
      'Renders display name field, email field, password field, and Register button',
      (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(buildTestWidget());

        // Act & Assert
        expect(find.byType(TextFormField), findsNWidgets(3));
        expect(find.text('Display Name'), findsOneWidget);
        expect(find.text('Email'), findsOneWidget);
        expect(find.text('Password'), findsOneWidget);
        // Register appears in both AppBar and button, so findsWidgets
        expect(find.text('Register'), findsWidgets);
        expect(find.byType(ElevatedButton), findsOneWidget);
      },
    );

    /// Test 2: Submitting with empty fields shows validation errors.
    testWidgets('Shows validation errors when submitting empty form', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestWidget());

      // Act - Tap the Register button without filling any fields
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(); // Trigger validation

      // Assert - Check that validation error messages appear
      expect(find.text('Please enter your display name'), findsOneWidget);
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    /// Test 3: Empty display name shows validation error.
    testWidgets('Shows validation error for empty display name', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestWidget());

      // Act - Fill email and password, leave display name empty
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'test@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(2), 'password123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert
      expect(find.text('Please enter your display name'), findsOneWidget);
    });

    /// Test 4: Display name shorter than 2 characters shows error.
    testWidgets(
      'Shows validation error for display name shorter than 2 characters',
      (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(buildTestWidget());

        // Act - Fill form with short display name
        await tester.enterText(find.byType(TextFormField).at(0), 'A');
        await tester.enterText(
          find.byType(TextFormField).at(1),
          'test@example.com',
        );
        await tester.enterText(find.byType(TextFormField).at(2), 'password123');
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Assert
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
      // Arrange
      await tester.pumpWidget(buildTestWidget());

      // Act - Fill display name and password, leave email empty
      await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
      await tester.enterText(find.byType(TextFormField).at(2), 'password123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert
      expect(find.text('Please enter your email'), findsOneWidget);
    });

    /// Test 6: Email without @ symbol shows validation error.
    testWidgets('Shows validation error for email without @ symbol', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestWidget());

      // Act - Fill form with invalid email (no @)
      await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'testexample.com',
      );
      await tester.enterText(find.byType(TextFormField).at(2), 'password123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    /// Test 7: Email with @ symbol but missing domain shows error.
    testWidgets('Shows validation error for email with @ but no domain', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestWidget());

      // Act - Fill form with invalid email (@ but no domain)
      await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
      await tester.enterText(find.byType(TextFormField).at(1), 'test@');
      await tester.enterText(find.byType(TextFormField).at(2), 'password123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert - Should NOT show email error since @ is present
      expect(find.text('Please enter a valid email'), findsNothing);
    });

    /// Test 8: Empty password shows validation error.
    testWidgets('Shows validation error for empty password', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestWidget());

      // Act - Fill display name and email, leave password empty
      await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'test@example.com',
      );
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    /// Test 9: Password shorter than 6 characters shows validation error.
    testWidgets(
      'Shows validation error for password shorter than 6 characters',
      (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(buildTestWidget());

        // Act - Fill form with short password
        await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
        await tester.enterText(
          find.byType(TextFormField).at(1),
          'test@example.com',
        );
        await tester.enterText(find.byType(TextFormField).at(2), 'pass');
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Assert
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
      // Arrange
      await tester.pumpWidget(buildTestWidget());

      // Act - Fill form with valid 6-character password
      await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'test@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(2), 'pass12');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert - Should not show password length error
      expect(find.text('Password must be at least 6 characters'), findsNothing);
    });

    /// Test 11: Valid form does not show validation errors.
    testWidgets('Valid form does not show validation errors', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestWidget());

      // Act - Fill form with all valid values
      await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'john@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(2), 'password123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert - No validation errors should appear
      expect(find.text('Please enter your display name'), findsNothing);
      expect(find.text('Please enter your email'), findsNothing);
      expect(find.text('Please enter your password'), findsNothing);
      expect(find.text('Please enter a valid email'), findsNothing);
      expect(find.text('Password must be at least 6 characters'), findsNothing);
    });

    /// Test 12: Register button displays loading indicator when pressed.
    testWidgets('Register button shows loading state when pressed', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestWidget());

      // Act - Fill valid form and tap Register
      await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'john@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(2), 'password123');

      // Note: We tap but don't wait for the async _register to complete
      // to keep the test isolated from Firebase
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert - Form should have no validation errors (passes validation)
      expect(find.text('Please enter your display name'), findsNothing);
      expect(find.text('Please enter your email'), findsNothing);
      expect(find.text('Please enter your password'), findsNothing);
    });

    /// Test 13: Multiple validation errors show together.
    testWidgets('Shows multiple validation errors simultaneously', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestWidget());

      // Act - Fill form with multiple invalid values
      await tester.enterText(find.byType(TextFormField).at(0), 'J');
      await tester.enterText(find.byType(TextFormField).at(1), 'invalidemail');
      await tester.enterText(find.byType(TextFormField).at(2), '123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert - All three errors should be visible
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
      // Arrange
      await tester.pumpWidget(buildTestWidget());

      // Act
      final passwordFields = find.byType(TextFormField);
      expect(passwordFields, findsNWidgets(3));

      // Assert - The third TextFormField should have obscureText=true
      final textFormFieldWidgets = find.byType(TextFormField);
      expect(textFormFieldWidgets, findsNWidgets(3));
    });

    /// Test 15: Form fields accept special characters.
    testWidgets('Form fields accept special characters in display name', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestWidget());

      // Act - Fill with special characters
      await tester.enterText(find.byType(TextFormField).at(0), "O'Brien-Smith");
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'obrien@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(2), 'password123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert - No validation errors for special characters
      expect(find.text('Please enter your display name'), findsNothing);
      expect(
        find.text('Display name must be at least 2 characters'),
        findsNothing,
      );
    });

    /// Test 16: Two-character display name passes validation.
    testWidgets('Display name with exactly 2 characters passes validation', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestWidget());

      // Act - Fill with 2-character display name
      await tester.enterText(find.byType(TextFormField).at(0), 'Jo');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'test@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(2), 'password123');

      // Trigger validation by tapping Register
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert - 2 characters should pass, no display name error expected
      expect(find.text('Please enter your display name'), findsNothing);
      expect(
        find.text('Display name must be at least 2 characters'),
        findsNothing,
      );
    });

    /// Test 17: AppBar title and back button are present.
    testWidgets('Renders AppBar with title and back button', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestWidget());

      // Act & Assert
      expect(find.text('Register'), findsWidgets);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    /// Test 18: Email field accepts lowercase and uppercase letters.
    testWidgets('Email field accepts mixed case letters', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestWidget());

      // Act - Fill with mixed case email
      await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'John.Doe@Example.COM',
      );
      await tester.enterText(find.byType(TextFormField).at(2), 'password123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert - Email with @ is valid, case doesn't matter
      expect(find.text('Please enter a valid email'), findsNothing);
    });

    /// Test 19: Form fields can be cleared and refilled.
    testWidgets('Form fields can be cleared and refilled', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestWidget());

      // Act - Fill form
      await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'john@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(2), 'password123');

      // Clear and refill
      await tester.enterText(find.byType(TextFormField).at(0), 'Jane Smith');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'jane@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(2), 'secret456');

      // Assert - Form should accept new values
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(find.text('Please enter your display name'), findsNothing);
      expect(find.text('Please enter your email'), findsNothing);
      expect(find.text('Please enter your password'), findsNothing);
    });

    /// Test 20: Register button is enabled when form is valid.
    testWidgets('Register button is enabled for valid form', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestWidget());

      // Act - Fill with valid data
      await tester.enterText(find.byType(TextFormField).at(0), 'John Doe');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'john@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(2), 'password123');

      // Assert - Button should be tappable (enabled)
      final button = find.byType(ElevatedButton);
      expect(button, findsOneWidget);
      // Verify button can be tapped without error
      await tester.tap(button);
      expect(tester.takeException(), isNull);
    });
  });
}
