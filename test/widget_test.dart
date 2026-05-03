import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sociefy/main.dart';

void main() {
  testWidgets('app smoke test — renders without errors', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });
}
