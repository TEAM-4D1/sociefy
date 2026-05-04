import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sociefy/screens/sign_in_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Performance Tests', () {
    testWidgets('Sign in screen renders within 2 seconds', (tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(const MaterialApp(home: SignInScreen()));
      await tester.pump();

      stopwatch.stop();
      expect(stopwatch.elapsed.inSeconds, lessThanOrEqualTo(2),
          reason: 'Sign in screen should load within 2 seconds');
    });

    testWidgets('Sign in controls render within 2 seconds', (tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(const MaterialApp(home: SignInScreen()));
      await tester.pump();

      stopwatch.stop();
      expect(stopwatch.elapsed.inSeconds, lessThanOrEqualTo(2),
          reason: 'Sign in controls should render within 2 seconds');
    });
  });

  group('Usability Tests', () {
    testWidgets('UI is accessible', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SignInScreen()));
      await tester.pump();

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    });
  });
}