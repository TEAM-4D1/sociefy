import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sociefy/screens/member_approval_screen.dart';

void main() {
  group('MemberApprovalScreen Tests', () {
    Widget buildTestWidget() {
      return const MaterialApp(
        home: MemberApprovalScreen(societyId: 'test-society-id'),
      );
    }

    testWidgets('renders app bar with title \'Approve New Members\'', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Approve New Members'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('shows a CircularProgressIndicator on initial render', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
