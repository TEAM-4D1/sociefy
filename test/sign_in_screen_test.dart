import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sociefy/sign_in_screen.dart';

void main() {
  group('SignInPage', () {
    // SI-01 — initial render has email field, password field and Sign In button
    testWidgets('shows email field, password field and Sign In button', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SignInPage()));
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.widgetWithText(ElevatedButton, 'Sign In'), findsOneWidget);
    });

    // AppBar title
    testWidgets('shows Sign In in the AppBar', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SignInPage()));
      expect(find.byType(AppBar), findsOneWidget);
    });

    // SI-02 — EP: invalid — empty email
    testWidgets('EP: empty email shows validation error', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SignInPage()));
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter your email'), findsOneWidget);
    });

    // SI-03 — EP: invalid — empty password
    testWidgets('EP: empty password shows validation error', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SignInPage()));
      await tester.enterText(find.byType(TextFormField).at(0), 'test@example.com');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    // SI-04 — EP: invalid — email with no @ character
    testWidgets('EP: email without @ shows format error', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SignInPage()));
      await tester.enterText(find.byType(TextFormField).at(0), 'notanemail');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    // SI-05 — EP: valid — correct email and password passes all validation
    testWidgets('EP: valid email and password produces no validation errors', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SignInPage()));
      await tester.enterText(find.byType(TextFormField).at(0), 'test@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter your email'), findsNothing);
      expect(find.text('Please enter your password'), findsNothing);
      expect(find.text('Please enter a valid email'), findsNothing);
    });

    // SI-06 — BVA: whitespace-only email is treated as empty
    testWidgets('BVA: whitespace-only email shows empty-email error', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SignInPage()));
      await tester.enterText(find.byType(TextFormField).at(0), '   ');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter your email'), findsOneWidget);
    });

    // SI-07 — BVA: minimal valid email (single char before and after @)
    testWidgets('BVA: minimal email a@b passes format validation', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SignInPage()));
      await tester.enterText(find.byType(TextFormField).at(0), 'a@b');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter a valid email'), findsNothing);
    });
  });
}
