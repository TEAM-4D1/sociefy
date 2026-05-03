import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sociefy/main_tabs.dart';

void main() {
  group('MainTabs', () {
    // MT-01 — BottomNavigationBar with 3 labelled items
    testWidgets('renders BottomNavigationBar with Home, Announcements and Messages', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: MainTabs()));
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      // 'Home' appears in both the nav label and the active tab's AppBar
      expect(find.text('Home'), findsWidgets);
      expect(find.text('Announcements'), findsOneWidget);
      expect(find.text('Messages'), findsOneWidget);
    });

    // MT-02 — default selected tab is Home (index 0)
    testWidgets('default selected tab is Home (index 0)', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: MainTabs()));
      final bar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(bar.currentIndex, 0);
    });

    // MT-03 — IndexedStack is used to keep all pages alive
    testWidgets('uses IndexedStack to manage page children', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: MainTabs()));
      expect(find.byType(IndexedStack), findsOneWidget);
    });

    // MT-04 — Home icon present
    testWidgets('Home nav item shows home icon', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: MainTabs()));
      expect(find.byIcon(Icons.home), findsOneWidget);
    });

    // MT-05 — Announcements icon present
    testWidgets('Announcements nav item shows announcement icon', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: MainTabs()));
      expect(find.byIcon(Icons.announcement), findsOneWidget);
    });

    // MT-06 — Messages icon present
    testWidgets('Messages nav item shows message icon', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: MainTabs()));
      expect(find.byIcon(Icons.message), findsOneWidget);
    });

    // MT-07 — tapping Announcements sets currentIndex to 1
    testWidgets('tapping Announcements switches to index 1', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: MainTabs()));
      await tester.tap(find.text('Announcements'));
      await tester.pumpAndSettle();
      final bar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(bar.currentIndex, 1);
    });

    // MT-08 — tapping Messages sets currentIndex to 2
    testWidgets('tapping Messages switches to index 2', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: MainTabs()));
      await tester.tap(find.text('Messages'));
      await tester.pumpAndSettle();
      final bar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(bar.currentIndex, 2);
    });

    // MT-09 — Home tab content is visible on launch
    testWidgets('Home tab content is visible on launch', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: MainTabs()));
      await tester.pumpAndSettle();
      expect(find.text('No societies yet.'), findsOneWidget);
    });

    // MT-10 — Announcements content visible after tapping that tab
    testWidgets('Announcements tab shows Society Announcements after tap', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: MainTabs()));
      await tester.tap(find.text('Announcements'));
      await tester.pumpAndSettle();
      expect(find.text('Society Announcements'), findsOneWidget);
    });

    // MT-11 — Messages content visible after tapping that tab
    testWidgets('Messages tab shows forum placeholder after tap', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: MainTabs()));
      await tester.tap(find.text('Messages'));
      await tester.pumpAndSettle();
      expect(find.text('Messages / Forums go here'), findsOneWidget);
    });

    // MT-12 — switching back to Home restores currentIndex = 0
    testWidgets('switching back to Home sets currentIndex to 0', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: MainTabs()));
      await tester.tap(find.text('Announcements'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      final bar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(bar.currentIndex, 0);
    });
  });
}
