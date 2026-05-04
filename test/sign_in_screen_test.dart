import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sociefy/screens/sign_in_screen.dart';

void main() {
  testWidgets(
    'SignInScreen renders email field, password field, and Sign In button',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: SignInScreen()));
      await tester.pump();

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    },
  );
}
