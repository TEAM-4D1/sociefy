import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sociefy/main_tabs.dart';
import 'package:sociefy/providers/app_state.dart';

/// Wraps MainTabs with the Provider and navigator it requires.
Widget buildTestWidget() {
  return ChangeNotifierProvider<AppState>(
    create: (_) => AppState(skipFirebase: true),
    child: const MaterialApp(home: MainTabs()),
  );
}

void main() {
  group('MainTabs', () {
    // MT-01 — BottomNavigationBar renders with all 5 labels
    testWidgets('renders BottomNavigationBar with all 5 tab labels',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('Home/Feed'), findsOneWidget);
      expect(find.text('Discover'), findsOneWidget);
      expect(find.text('Messages'), findsOneWidget);
      expect(find.text('Saved'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    // MT-02 — BottomNavigationBar has exactly 5 items
    testWidgets('BottomNavigationBar has 5 items', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      final bar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bar.items.length, 5);
    });

    // MT-03 — default selected tab is index 0 (Home/Feed)
    testWidgets('default selected tab is Home/Feed (index 0)', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      final bar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bar.currentIndex, 0);
    });

    // MT-04 — IndexedStack is used to keep all pages alive
    testWidgets('uses IndexedStack to manage page children', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byType(IndexedStack), findsOneWidget);
    });

    // MT-05 — type is fixed so all labels are always visible
    testWidgets('BottomNavigationBar type is fixed', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      final bar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bar.type, BottomNavigationBarType.fixed);
    });

    // MT-06 — correct icons for each tab
    testWidgets('nav items show correct icons', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      expect(find.byIcon(Icons.dynamic_feed), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.message), findsOneWidget);
      expect(find.byIcon(Icons.bookmark), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    // MT-07 — tapping Discover sets currentIndex to 1
    testWidgets('tapping Discover switches to index 1', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      await tester.tap(find.text('Discover'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final bar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bar.currentIndex, 1);
    });

    // MT-08 — tapping Messages sets currentIndex to 2
    testWidgets('tapping Messages switches to index 2', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      await tester.tap(find.text('Messages'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final bar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bar.currentIndex, 2);
    });

    // MT-09 — tapping Saved sets currentIndex to 3
    testWidgets('tapping Saved switches to index 3', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      await tester.tap(find.text('Saved'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final bar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bar.currentIndex, 3);
    });

    // MT-10 — tapping Profile sets currentIndex to 4
    testWidgets('tapping Profile switches to index 4', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      await tester.tap(find.text('Profile'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final bar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bar.currentIndex, 4);
    });

    // MT-11 — switching back to Home restores currentIndex to 0
    testWidgets('switching back to Home sets currentIndex to 0', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      await tester.tap(find.text('Messages'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text('Home/Feed'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final bar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bar.currentIndex, 0);
    });

    // MT-12 — tapping same tab twice keeps currentIndex unchanged
    testWidgets('tapping same tab twice keeps currentIndex unchanged',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      await tester.tap(find.text('Discover'));
      await tester.pump();
      await tester.tap(find.text('Discover'));
      await tester.pump();

      final bar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bar.currentIndex, 1);
    });
  });
}
