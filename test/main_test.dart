import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sociefy/main.dart';
import 'package:sociefy/main_tabs.dart';

void main() {
  group('MyApp', () {
    // APP-01 — app renders a MaterialApp
    testWidgets('renders a MaterialApp without errors', (tester) async {
      await tester.pumpWidget(const MyApp());
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    // APP-02 — home is MainTabs
    testWidgets('uses MainTabs as the home widget', (tester) async {
      await tester.pumpWidget(const MyApp());
      expect(find.byType(MainTabs), findsOneWidget);
    });

    // APP-03 — Material 3 is enabled
    testWidgets('theme has useMaterial3 = true', (tester) async {
      await tester.pumpWidget(const MyApp());
      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.theme?.useMaterial3, isTrue);
    });

    // APP-04 — app title
    testWidgets('title is Society App', (tester) async {
      await tester.pumpWidget(const MyApp());
      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.title, 'Society App');
    });

    // APP-05 — BottomNavigationBar is present
    testWidgets('BottomNavigationBar is present on launch', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    // APP-06 — color scheme has a primary color
    testWidgets('color scheme primary is not null', (tester) async {
      await tester.pumpWidget(const MyApp());
      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.theme?.colorScheme.primary, isNotNull);
    });
  });
}
