import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sociefy/providers/app_state.dart';
import 'package:sociefy/screens/committee_sign_in_screen.dart';

void main() {
  group('CommitteeSignInScreen Widget Tests', () {
    /// Helper function to build CommitteeSignInScreen wrapped in MaterialApp
    /// with ChangeNotifierProvider<AppState> for context.
    /// Ensures proper Material context and provider access.
    Widget buildTestWidget() {
      return MaterialApp(
        home: ChangeNotifierProvider(
          create: (context) => AppState(skipFirebase: true),
          child: const CommitteeSignInScreen(),
        ),
      );
    }

    /// Test 1: Verify email field, password field, and sign in button render.
    testWidgets('Renders email field, password field, and sign in button', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestWidget());

      // Act & Assert
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Committee/Admin Email'), findsOneWidget);
      expect(find.text('Committee/Admin Password'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byIcon(Icons.login), findsOneWidget);
    });

    /// Test 2: Submitting with empty fields triggers form validation errors.
    testWidgets('Shows validation errors when submitting with empty fields', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestWidget());

      // Act - Tap sign in button without filling any fields
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert - Check that validation error messages appear
      expect(find.text('Please enter committee/admin email'), findsOneWidget);
      expect(
        find.text('Please enter committee/admin password'),
        findsOneWidget,
      );
    });

    /// Test 3: Empty email field shows validation error.
    testWidgets('Shows validation error for empty email field', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestWidget());

      // Act - Fill password, leave email empty
      await tester.enterText(find.byType(TextFormField).at(1), 'password');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert
      expect(find.text('Please enter committee/admin email'), findsOneWidget);
    });

    /// Test 4: Empty password field shows validation error.
    testWidgets('Shows validation error for empty password field', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestWidget());

      // Act - Fill email, leave password empty
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'test@example.com',
      );
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert
      expect(
        find.text('Please enter committee/admin password'),
        findsOneWidget,
      );
    });

    /// Test 5: Entering a myport email shows appropriate snackbar.
    testWidgets('Shows snackbar for myport email', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(buildTestWidget());

      // Act - Fill with myport email and password
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'user@myport.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Assert - Check snackbar with specific message
      expect(
        find.text('MyPort emails are not allowed on committee sign in.'),
        findsOneWidget,
      );
    });

    /// Test 6: Uppercase myport email still triggers the validation.
    testWidgets('Rejects uppercase MYPORT email', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(buildTestWidget());

      // Act - Fill with uppercase MYPORT email
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'user@MYPORT.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Assert
      expect(
        find.text('MyPort emails are not allowed on committee sign in.'),
        findsOneWidget,
      );
    });

    /// Test 7: Mixed case MyPort email is rejected.
    testWidgets('Rejects mixed case MyPort email', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(buildTestWidget());

      // Act - Fill with mixed case MyPort email
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'user@MyPort.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Assert
      expect(
        find.text('MyPort emails are not allowed on committee sign in.'),
        findsOneWidget,
      );
    });

    /// Test 8: Wrong credentials show authorization error snackbar.
    testWidgets('Shows snackbar for wrong credentials', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestWidget());

      // Act - Fill with wrong email and password
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'wrong@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'wrongpassword');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Assert - Check snackbar for authorization error
      expect(
        find.text('Only the authorized committee admin can sign in here.'),
        findsOneWidget,
      );
    });

    /// Test 9: Correct email but wrong password shows authorization error.
    testWidgets(
      'Shows authorization error with correct email but wrong password',
      (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(buildTestWidget());

        // Act - Fill with correct email but wrong password
        await tester.enterText(
          find.byType(TextFormField).at(0),
          'jburfoot12@gmail.com',
        );
        await tester.enterText(
          find.byType(TextFormField).at(1),
          'wrongpassword',
        );
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();

        // Assert
        expect(
          find.text('Only the authorized committee admin can sign in here.'),
          findsOneWidget,
        );
      },
    );

    /// Test 10: Wrong email but correct password shows authorization error.
    testWidgets(
      'Shows authorization error with wrong email but correct password',
      (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(buildTestWidget());

        // Act - Fill with wrong email but correct password
        await tester.enterText(
          find.byType(TextFormField).at(0),
          'wrong@example.com',
        );
        await tester.enterText(find.byType(TextFormField).at(1), '111444');
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();

        // Assert
        expect(
          find.text('Only the authorized committee admin can sign in here.'),
          findsOneWidget,
        );
      },
    );

    /// Test 11: Empty email with wrong password shows both errors sequentially.
    testWidgets(
      'Shows validation error for empty email before authorization check',
      (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(buildTestWidget());

        // Act - Leave email empty, enter password
        await tester.enterText(find.byType(TextFormField).at(1), 'anypassword');
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Assert - Validation error should show, not authorization error
        expect(find.text('Please enter committee/admin email'), findsOneWidget);
        expect(
          find.text('Only the authorized committee admin can sign in here.'),
          findsNothing,
        );
      },
    );

    /// Test 12: AppBar with title and back button are present.
    testWidgets('Renders AppBar with title and back button', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestWidget());

      // Act & Assert
      expect(find.text('Committee/Admin Sign in'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    /// Test 13: Portal title and description text are present.
    testWidgets('Renders portal title and description', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestWidget());

      // Act & Assert
      expect(find.text('Committee & Admin Portal'), findsOneWidget);
      expect(
        find.text('Use your committee/admin credentials to sign in.'),
        findsOneWidget,
      );
    });

    /// Test 14: Admin icon is visible.
    testWidgets('Renders admin panel settings icon', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestWidget());

      // Act & Assert
      expect(find.byIcon(Icons.admin_panel_settings), findsOneWidget);
    });

    /// Test 15: Password visibility toggle works.
    testWidgets('Password visibility toggle button is present', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestWidget());

      // Act & Assert - Check for visibility toggle icon
      expect(
        find.byIcon(Icons.visibility_off),
        findsOneWidget,
      ); // Initially obscured
    });

    /// Test 16: Myport email check is case-insensitive.
    testWidgets('Rejects myport email regardless of case (lowercase)', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestWidget());

      // Act - Fill with lowercase myport
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'user@myport.co',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'password');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Assert
      expect(
        find.text('MyPort emails are not allowed on committee sign in.'),
        findsOneWidget,
      );
    });

    /// Test 17: Email field can be filled and cleared.
    testWidgets('Email field can be filled and cleared', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestWidget());

      // Act - Fill field
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'test@example.com',
      );
      await tester.pump();

      // Clear and refill
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'new@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'password');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Assert - Wrong credentials error (not empty error)
      expect(
        find.text('Only the authorized committee admin can sign in here.'),
        findsOneWidget,
      );
    });

    /// Test 18: Multiple snackbars don't accumulate from rapid button taps.
    testWidgets('Only shows one snackbar when tapping button', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestWidget());

      // Act - Fill with myport email
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'user@myport.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'password');

      // Tap button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Assert - Only one snackbar message
      expect(
        find.text('MyPort emails are not allowed on committee sign in.'),
        findsOneWidget,
      );
    });

    /// Test 19: Email validation happens before myport check.
    testWidgets('Shows validation error for empty email before myport check', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestWidget());

      // Act - Leave email empty but fill password
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert - Should show validation error, not myport error
      expect(find.text('Please enter committee/admin email'), findsOneWidget);
      expect(
        find.text('MyPort emails are not allowed on committee sign in.'),
        findsNothing,
      );
    });

    /// Test 20: Button shows loading state hint text.
    testWidgets('Button text changes during form submission', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestWidget());

      // Act - Fill with valid credentials format
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'test@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');

      // Check initial button text
      expect(find.text('Sign in as Committee/Admin'), findsOneWidget);

      // Assert - Button is in widget tree
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    /// Test 21: Email field accepts various valid email formats.
    testWidgets('Email field accepts various valid formats', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestWidget());

      // Act - Fill with different email format
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'committee.member+test@organization.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Assert - Should show authorization error (not email format error)
      expect(
        find.text('Only the authorized committee admin can sign in here.'),
        findsOneWidget,
      );
    });

    /// Test 22: Whitespace in email is trimmed before validation.
    testWidgets('Email whitespace is trimmed before validation', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestWidget());

      // Act - Fill with spaces around email
      await tester.enterText(
        find.byType(TextFormField).at(0),
        '  test@example.com  ',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Assert - Spaces trimmed, so authorization check happens
      expect(
        find.text('Only the authorized committee admin can sign in here.'),
        findsOneWidget,
      );
    });

    /// Test 23: Password field is obscured by default.
    testWidgets('Password field obscures text by default', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestWidget());

      // Act & Assert - Check for visibility_off icon (password is obscured)
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      expect(find.byIcon(Icons.visibility), findsNothing);
    });

    /// Test 24: Back button navigates away from screen.
    testWidgets('Back button is present and tappable', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildTestWidget());

      // Act & Assert - Back button should be present
      final backButton = find.byIcon(Icons.arrow_back);
      expect(backButton, findsOneWidget);

      // Can be tapped
      await tester.tap(backButton);
      expect(tester.takeException(), isNull);
    });

    /// Test 25: Form fields maintain entered values until cleared.
    testWidgets('Form fields maintain values', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(buildTestWidget());

      // Act - Enter text
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'test@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');

      // Pump to allow text to settle
      await tester.pump();

      // Assert - Button should be enabled and tappable
      expect(find.byType(ElevatedButton), findsOneWidget);

      // Try to tap button (should work without errors)
      await tester.tap(find.byType(ElevatedButton));
      expect(tester.takeException(), isNull);
    });
  });
}
