import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sociefy/providers/app_state.dart';
import 'package:sociefy/screens/society_browser_screen.dart';

void main() {
  group('SocietyBrowserScreen Tests', () {
    Widget buildTestWidget(AppState appState) {
      return MaterialApp(
        home: ChangeNotifierProvider.value(
          value: appState,
          child: const SocietyBrowserScreen(),
        ),
      );
    }

    testWidgets('search text field renders on screen', (
      WidgetTester tester,
    ) async {
      final appState = AppState(skipFirebase: true);
      await tester.pumpWidget(buildTestWidget(appState));

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('All filter chip is present', (WidgetTester tester) async {
      final appState = AppState(skipFirebase: true);
      await tester.pumpWidget(buildTestWidget(appState));

      expect(find.text('All'), findsOneWidget);
      expect(find.byType(FilterChip), findsOneWidget);
    });

    testWidgets(
      'screen renders shimmer placeholders when societies list is empty',
      (WidgetTester tester) async {
        final appState = AppState(skipFirebase: true);
        await tester.pumpWidget(buildTestWidget(appState));

        // Empty list → shimmer containers, NOT "No societies found."
        expect(find.byType(SocietyBrowserScreen), findsOneWidget);
        expect(find.text('No societies found.'), findsNothing);
      },
    );

    testWidgets('"No societies found." shows when search matches nothing', (
      WidgetTester tester,
    ) async {
      final appState = AppState(skipFirebase: true);
      await appState.createSociety(
        name: 'Chess Club',
        category: 'Academic',
        description: 'Chess',
      );
      await tester.pumpWidget(buildTestWidget(appState));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'no match query');
      await tester.pumpAndSettle();

      expect(find.text('No societies found.'), findsOneWidget);
    });

    testWidgets('typing into search field updates displayed list', (
      WidgetTester tester,
    ) async {
      final appState = AppState(skipFirebase: true);

      await appState.createSociety(
        name: 'Computer Science Club',
        category: 'Academic',
        description: 'For CS enthusiasts',
      );
      await appState.createSociety(
        name: 'Dance Society',
        category: 'Arts',
        description: 'For dancers',
      );

      await tester.pumpWidget(buildTestWidget(appState));
      await tester.pumpAndSettle();

      expect(find.text('Computer Science Club'), findsOneWidget);
      expect(find.text('Dance Society'), findsOneWidget);

      final searchField = find.byType(TextField);
      await tester.tap(searchField);
      await tester.enterText(searchField, 'Computer');
      await tester.pumpAndSettle();

      expect(find.text('Computer Science Club'), findsOneWidget);
      expect(find.text('Dance Society'), findsNothing);
    });

    testWidgets('filtering by search shows correct society results', (
      WidgetTester tester,
    ) async {
      final appState = AppState(skipFirebase: true);

      await appState.createSociety(
        name: 'Photography Club',
        category: 'Arts',
        description: 'Photography lovers',
      );
      await appState.createSociety(
        name: 'Robotics Club',
        category: 'Academic',
        description: 'Robotics enthusiasts',
      );

      await tester.pumpWidget(buildTestWidget(appState));
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField);
      await tester.tap(searchField);
      await tester.enterText(searchField, 'Robotics');
      await tester.pumpAndSettle();

      expect(find.text('Robotics Club'), findsOneWidget);
      expect(find.text('Photography Club'), findsNothing);
    });

    testWidgets('clearing search field shows all societies again', (
      WidgetTester tester,
    ) async {
      final appState = AppState(skipFirebase: true);

      await appState.createSociety(
        name: 'Gaming Society',
        category: 'Entertainment',
        description: 'Games',
      );
      await appState.createSociety(
        name: 'Movie Club',
        category: 'Entertainment',
        description: 'Movies',
      );

      await tester.pumpWidget(buildTestWidget(appState));
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField);
      await tester.tap(searchField);
      await tester.enterText(searchField, 'Gaming');
      await tester.pumpAndSettle();

      expect(find.text('Gaming Society'), findsOneWidget);
      expect(find.text('Movie Club'), findsNothing);

      await tester.enterText(searchField, '');
      await tester.pumpAndSettle();

      expect(find.text('Gaming Society'), findsOneWidget);
      expect(find.text('Movie Club'), findsOneWidget);
    });

    testWidgets('society cards display correct information', (
      WidgetTester tester,
    ) async {
      final appState = AppState(skipFirebase: true);

      await appState.createSociety(
        name: 'Test Society',
        category: 'Academic',
        description: 'Test description',
      );

      await tester.pumpWidget(buildTestWidget(appState));
      await tester.pumpAndSettle();

      expect(find.text('Test Society'), findsOneWidget);
      // 'Academic' appears twice: once in the FilterChip and once in the ListTile subtitle
      expect(find.text('Academic'), findsWidgets);
    });

    testWidgets('multiple societies render in list', (
      WidgetTester tester,
    ) async {
      final appState = AppState(skipFirebase: true);

      await appState.createSociety(
        name: 'Society One',
        category: 'Category A',
        description: 'Description 1',
      );
      await appState.createSociety(
        name: 'Society Two',
        category: 'Category B',
        description: 'Description 2',
      );
      await appState.createSociety(
        name: 'Society Three',
        category: 'Category C',
        description: 'Description 3',
      );

      await tester.pumpWidget(buildTestWidget(appState));
      await tester.pumpAndSettle();

      expect(find.text('Society One'), findsOneWidget);
      expect(find.text('Society Two'), findsOneWidget);
      expect(find.text('Society Three'), findsOneWidget);
    });

    testWidgets('search is case-insensitive', (WidgetTester tester) async {
      final appState = AppState(skipFirebase: true);

      await appState.createSociety(
        name: 'Engineering Society',
        category: 'Academic',
        description: 'Engineers',
      );

      await tester.pumpWidget(buildTestWidget(appState));
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField);
      await tester.tap(searchField);
      await tester.enterText(searchField, 'ENGINEERING');
      await tester.pumpAndSettle();

      expect(find.text('Engineering Society'), findsOneWidget);
    });

    testWidgets('search works by category', (WidgetTester tester) async {
      final appState = AppState(skipFirebase: true);

      await appState.createSociety(
        name: 'Math Club',
        category: 'Academic',
        description: 'Math',
      );
      await appState.createSociety(
        name: 'Soccer Club',
        category: 'Sports',
        description: 'Soccer',
      );

      await tester.pumpWidget(buildTestWidget(appState));
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField);
      await tester.tap(searchField);
      await tester.enterText(searchField, 'Academic');
      await tester.pumpAndSettle();

      expect(find.text('Math Club'), findsOneWidget);
      expect(find.text('Soccer Club'), findsNothing);
    });
  });
}
