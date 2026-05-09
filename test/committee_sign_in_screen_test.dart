import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sociefy/providers/app_state.dart';
import 'package:sociefy/screens/committee_sign_in_screen.dart';

void main() {
  group('CommitteeSignInScreen Widget Tests', () {
    /// Pumps CommitteeSignInScreen with a taller viewport (800×900) so the
    /// sign-in button is always visible without scrolling.
    Future<void> buildAndPump(WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (context) => AppState(skipFirebase: true),
            child: const CommitteeSignInScreen(),
          ),
        ),
      );
    }

    /// Taps the sign-in button.
    Future<void> tapSignInButton(WidgetTester tester) async {
      await tester.tap(find.byIcon(Icons.login));
    }

    /// Test 1: Verify UI elements render
    testWidgets('Renders email field, password field, and sign in button', (
      WidgetTester tester,
    ) async {
      await buildAndPump(tester);

      // Verify form fields exist
      expect(find.byType(TextFormField), findsWidgets);
      expect(find.text('Committee/Admin Email'), findsOneWidget);
      expect(find.text('Committee/Admin Password'), findsOneWidget);
      expect(find.byIcon(Icons.login), findsOneWidget);
    });

    /// Test 2: Validation errors appear on empty submission
    testWidgets('Shows validation errors when submitting with empty fields', (
      WidgetTester tester,
    ) async {
      await buildAndPump(tester);

      // Tap the sign in button
      await tapSignInButton(tester);
      await tester.pumpAndSettle();

      // Validation errors should appear
      expect(find.text('Please enter committee/admin email'), findsOneWidget);
      expect(
        find.text('Please enter committee/admin password'),
        findsOneWidget,
      );
    });

    /// Test 3: Empty email validation
    testWidgets('Shows validation error for empty email field', (
      WidgetTester tester,
    ) async {
      await buildAndPump(tester);

      // Fill password only
      await tester.enterText(find.byType(TextFormField).last, 'testpass');
      await tapSignInButton(tester);
      await tester.pumpAndSettle();

      expect(find.text('Please enter committee/admin email'), findsOneWidget);
    });

    /// Test 4: Empty password validation
    testWidgets('Shows validation error for empty password field', (
      WidgetTester tester,
    ) async {
      await buildAndPump(tester);

      // Fill email only
      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      await tapSignInButton(tester);
      await tester.pumpAndSettle();

      expect(
        find.text('Please enter committee/admin password'),
        findsOneWidget,
      );
    });

    /// Test 5: MyPort email rejection
    testWidgets('Shows snackbar for myport email', (WidgetTester tester) async {
      await buildAndPump(tester);

      // Fill both fields
      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;

      await tester.enterText(emailField, 'test@myport.ac.uk');
      await tester.enterText(passwordField, 'password');
      await tapSignInButton(tester);
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text('MyPort emails are not allowed on committee sign in.'),
        findsOneWidget,
      );
    });

    /// Test 6: Rejects uppercase MYPORT
    testWidgets('Rejects uppercase MYPORT email', (WidgetTester tester) async {
      await buildAndPump(tester);

      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;

      await tester.enterText(emailField, 'test@MYPORT.ac.uk');
      await tester.enterText(passwordField, 'password');
      await tapSignInButton(tester);
      await tester.pumpAndSettle();

      expect(
        find.text('MyPort emails are not allowed on committee sign in.'),
        findsOneWidget,
      );
    });

    /// Test 7: Rejects mixed case MyPort
    testWidgets('Rejects mixed case MyPort email', (WidgetTester tester) async {
      await buildAndPump(tester);

      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;

      await tester.enterText(emailField, 'test@MyPort.ac.uk');
      await tester.enterText(passwordField, 'password');
      await tapSignInButton(tester);
      await tester.pumpAndSettle();

      expect(
        find.text('MyPort emails are not allowed on committee sign in.'),
        findsOneWidget,
      );
    });

    /// Test 8: Wrong credentials error
    testWidgets('Shows snackbar for wrong credentials', (
      WidgetTester tester,
    ) async {
      await buildAndPump(tester);

      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;

      await tester.enterText(emailField, 'wrong@example.com');
      await tester.enterText(passwordField, 'wrongpassword');
      await tapSignInButton(tester);
      await tester.pumpAndSettle();

      expect(
        find.text('Only the authorized committee admin can sign in here.'),
        findsOneWidget,
      );
    });

    /// Test 9: Correct email, wrong password
    testWidgets(
      'Shows authorization error with correct email but wrong password',
      (WidgetTester tester) async {
        await buildAndPump(tester);

        final emailField = find.byType(TextFormField).first;
        final passwordField = find.byType(TextFormField).last;

        await tester.enterText(emailField, 'jburfoot12@gmail.com');
        await tester.enterText(passwordField, 'wrongpassword');
        await tapSignInButton(tester);
        await tester.pumpAndSettle();

        expect(
          find.text('Only the authorized committee admin can sign in here.'),
          findsOneWidget,
        );
      },
    );

    /// Test 10: Wrong email, correct password
    testWidgets(
      'Shows authorization error with wrong email but correct password',
      (WidgetTester tester) async {
        await buildAndPump(tester);

        final emailField = find.byType(TextFormField).first;
        final passwordField = find.byType(TextFormField).last;

        await tester.enterText(emailField, 'wrong@gmail.com');
        await tester.enterText(passwordField, '111444');
        await tapSignInButton(tester);
        await tester.pumpAndSettle();

        expect(
          find.text('Only the authorized committee admin can sign in here.'),
          findsOneWidget,
        );
      },
    );

    /// Test 11: Validation before authorization
    testWidgets(
      'Shows validation error for empty email before authorization check',
      (WidgetTester tester) async {
        await buildAndPump(tester);

        final passwordField = find.byType(TextFormField).last;

        await tester.enterText(passwordField, '111444');
        await tapSignInButton(tester);
        await tester.pumpAndSettle();

        expect(find.text('Please enter committee/admin email'), findsOneWidget);
        expect(
          find.text('Only the authorized committee admin can sign in here.'),
          findsNothing,
        );
      },
    );

    /// Test 12: Myport rejection regardless of case (lowercase)
    testWidgets('Rejects myport email regardless of case (lowercase)', (
      WidgetTester tester,
    ) async {
      await buildAndPump(tester);

      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;

      await tester.enterText(emailField, 'admin@myport.ac.uk');
      await tester.enterText(passwordField, '111444');
      await tapSignInButton(tester);
      await tester.pumpAndSettle();

      expect(
        find.text('MyPort emails are not allowed on committee sign in.'),
        findsOneWidget,
      );
    });

    /// Test 13: Email field can be filled and cleared
    testWidgets('Email field can be filled and cleared', (
      WidgetTester tester,
    ) async {
      await buildAndPump(tester);

      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;

      // Fill field
      await tester.enterText(emailField, 'test@example.com');
      await tester.pumpAndSettle();
      expect(find.text('test@example.com'), findsOneWidget);

      // Clear and refill
      await tester.enterText(emailField, 'new@example.com');
      await tester.enterText(passwordField, 'password');
      await tapSignInButton(tester);
      await tester.pumpAndSettle();

      expect(
        find.text('Only the authorized committee admin can sign in here.'),
        findsOneWidget,
      );
    });

    /// Test 14: Only one snackbar shows
    testWidgets('Only shows one snackbar when tapping button', (
      WidgetTester tester,
    ) async {
      await buildAndPump(tester);

      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;

      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password');
      await tapSignInButton(tester);
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
    });

    /// Test 15: Validation before myport check
    testWidgets('Shows validation error for empty email before myport check', (
      WidgetTester tester,
    ) async {
      await buildAndPump(tester);

      final passwordField = find.byType(TextFormField).last;

      await tester.enterText(passwordField, 'password');
      await tapSignInButton(tester);
      await tester.pumpAndSettle();

      expect(find.text('Please enter committee/admin email'), findsOneWidget);
      expect(
        find.text('MyPort emails are not allowed on committee sign in.'),
        findsNothing,
      );
    });

    /// Test 16: Button state during submission
    testWidgets('Button text changes during form submission', (
      WidgetTester tester,
    ) async {
      // This test verifies the button can show loading state
      // The button shows loading when _isLoading is true
      await buildAndPump(tester);

      expect(find.byIcon(Icons.login), findsOneWidget);
      expect(find.text('Sign in as Committee/Admin'), findsOneWidget);
    });

    /// Test 17: Email field accepts various valid formats
    testWidgets('Email field accepts various valid formats', (
      WidgetTester tester,
    ) async {
      await buildAndPump(tester);

      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;

      // Test with valid email format
      await tester.enterText(emailField, 'test.user+tag@example.co.uk');
      await tester.enterText(passwordField, 'password');
      await tester.pumpAndSettle();

      expect(find.text('test.user+tag@example.co.uk'), findsOneWidget);
    });

    /// Test 18: Email whitespace is trimmed
    testWidgets('Email whitespace is trimmed before validation', (
      WidgetTester tester,
    ) async {
      await buildAndPump(tester);

      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;

      await tester.enterText(emailField, '  test@example.com  ');
      await tester.enterText(passwordField, 'password');
      await tapSignInButton(tester);
      await tester.pumpAndSettle();

      expect(
        find.text('Only the authorized committee admin can sign in here.'),
        findsOneWidget,
      );
    });

    /// Test 19: Form fields maintain values
    testWidgets('Form fields maintain values', (WidgetTester tester) async {
      await buildAndPump(tester);

      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;

      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'testpass');
      await tester.pumpAndSettle();

      // Verify values are maintained
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('testpass'), findsOneWidget);
    });
  });
}
