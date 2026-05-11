import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sociefy/models/announcement.dart';
import 'package:sociefy/models/society.dart';
import 'package:sociefy/providers/app_state.dart';
import 'package:sociefy/screens/feed_screen.dart';

/// Helper function to build a test widget tree with FeedScreen.
Widget buildTestWidget(AppState appState) {
  return MaterialApp(
    home: ChangeNotifierProvider.value(
      value: appState,
      child: const FeedScreen(),
    ),
  );
}

void main() {
  group('FeedScreen Tests', () {
    testWidgets('renders app bar with title \'My Societies Feed\'', (
      WidgetTester tester,
    ) async {
      final appState = AppState(skipFirebase: true);
      await tester.pumpWidget(buildTestWidget(appState));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('My Societies Feed'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets(
      'shows empty-state text when user has not joined any societies and is not admin',
      (WidgetTester tester) async {
        final appState = AppState(skipFirebase: true);
        await tester.pumpWidget(buildTestWidget(appState));
        await tester.pump(const Duration(milliseconds: 100));

        expect(
          find.text(
            "You haven't joined any societies yet. Explore to see updates here!",
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'does NOT show \'Add Post\' or \'Create Society\' buttons when user is not admin',
      (WidgetTester tester) async {
        final appState = AppState(skipFirebase: true);
        // Set user as non-admin directly (don't call login() as it has Firebase side effects)
        appState.userId = 'testuser';
        appState.isAdmin = false;
        // Create a test society for the user to be part of
        appState.createSociety(
          name: 'Test Society',
          category: 'Academic',
          description: 'Test',
        );

        await tester.pumpWidget(buildTestWidget(appState));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Add Post'), findsNothing);
        expect(find.text('Create Society'), findsNothing);
      },
    );

    testWidgets(
      'shows "Add Post" and "Create Society" buttons when user is admin',
      (WidgetTester tester) async {
        final appState = AppState(skipFirebase: true);
        appState.userId = 'admin-user';
        appState.isAdmin = true;

        await tester.pumpWidget(buildTestWidget(appState));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Add Post'), findsOneWidget);
        expect(find.text('Create Society'), findsOneWidget);
      },
    );

    testWidgets(
      'admin can open Create Society dialog by tapping Create Society button',
      (WidgetTester tester) async {
        final appState = AppState(skipFirebase: true);
        appState.userId = 'admin-user';
        appState.isAdmin = true;

        await tester.pumpWidget(buildTestWidget(appState));
        await tester.pumpAndSettle();

        // Tap Create Society button
        await tester.tap(find.text('Create Society'));
        await tester.pumpAndSettle();

        // Dialog should open - look for form fields in the dialog
        expect(find.byType(AlertDialog), findsOneWidget);
      },
    );

    testWidgets(
      'displays announcements in a list when announcements exist',
      (WidgetTester tester) async {
        final appState = AppState(skipFirebase: true);
        appState.userId = 'test-user';
        appState.isAdmin = false;

        // Create a society
        final society = Society(
          id: 'society-1',
          name: 'Test Society',
          category: 'Academic',
          description: 'A test society',
        );
        appState.societies.add(society);

        // Join the society
        appState.joinedSocieties.add(society);

        // Create an announcement
        final announcement = Announcement(
          id: 'announcement-1',
          societyId: 'society-1',
          title: 'Test Announcement',
          content: 'This is a test announcement',
          date: DateTime.now(),
          likeCount: 0,
          likedByUsers: const [],
          comments: const [],
        );
        appState.announcements.add(announcement);
        appState.notifyListeners();

        await tester.pumpWidget(buildTestWidget(appState));
        await tester.pumpAndSettle();

        // Announcement should be visible
        expect(find.text('Test Announcement'), findsOneWidget);
        expect(find.text('This is a test announcement'), findsOneWidget);
        expect(find.text('Test Society'), findsOneWidget);
      },
    );

    testWidgets(
      'non-admin user only sees announcements from joined societies',
      (WidgetTester tester) async {
        final appState = AppState(skipFirebase: true);
        appState.userId = 'test-user';
        appState.isAdmin = false;

        // Create two societies
        final joinedSociety = Society(
          id: 'society-1',
          name: 'Joined Society',
          category: 'Academic',
          description: 'A society I joined',
        );
        final otherSociety = Society(
          id: 'society-2',
          name: 'Other Society',
          category: 'Academic',
          description: 'A society I did not join',
        );
        appState.societies.addAll([joinedSociety, otherSociety]);

        // Join only the first society
        appState.joinedSocieties.add(joinedSociety);

        // Create announcements from both societies
        final joinedAnnouncement = Announcement(
          id: 'announcement-1',
          societyId: 'society-1',
          title: 'Joined Society Announcement',
          content: 'From joined society',
          date: DateTime.now(),
          likeCount: 0,
          likedByUsers: const [],
          comments: const [],
        );
        final otherAnnouncement = Announcement(
          id: 'announcement-2',
          societyId: 'society-2',
          title: 'Other Society Announcement',
          content: 'From other society',
          date: DateTime.now(),
          likeCount: 0,
          likedByUsers: const [],
          comments: const [],
        );
        appState.announcements.addAll([joinedAnnouncement, otherAnnouncement]);
        appState.notifyListeners();

        await tester.pumpWidget(buildTestWidget(appState));
        await tester.pumpAndSettle();

        // Should see announcement from joined society
        expect(find.text('Joined Society Announcement'), findsOneWidget);
        // Should NOT see announcement from other society
        expect(find.text('Other Society Announcement'), findsNothing);
      },
    );

    testWidgets(
      'like button shows filled heart icon when announcement is liked by current user',
      (WidgetTester tester) async {
        final appState = AppState(skipFirebase: true);
        appState.userId = 'test-user';
        appState.isAdmin = false;

        final society = Society(
          id: 'society-1',
          name: 'Test Society',
          category: 'Academic',
          description: 'A test society',
        );
        appState.societies.add(society);
        appState.joinedSocieties.add(society);

        final announcement = Announcement(
          id: 'announcement-1',
          societyId: 'society-1',
          title: 'Test Announcement',
          content: 'Test content',
          date: DateTime.now(),
          likeCount: 1,
          likedByUsers: const ['test-user'],
          comments: const [],
        );
        appState.announcements.add(announcement);
        appState.notifyListeners();

        await tester.pumpWidget(buildTestWidget(appState));
        await tester.pumpAndSettle();

        // Filled heart icon should be present
        expect(find.byIcon(Icons.favorite), findsOneWidget);
      },
    );

    testWidgets(
      'like button shows heart border when announcement is not liked by current user',
      (WidgetTester tester) async {
        final appState = AppState(skipFirebase: true);
        appState.userId = 'test-user';
        appState.isAdmin = false;

        final society = Society(
          id: 'society-1',
          name: 'Test Society',
          category: 'Academic',
          description: 'A test society',
        );
        appState.societies.add(society);
        appState.joinedSocieties.add(society);

        final announcement = Announcement(
          id: 'announcement-1',
          societyId: 'society-1',
          title: 'Test Announcement',
          content: 'Test content',
          date: DateTime.now(),
          likeCount: 0,
          likedByUsers: const [],
          comments: const [],
        );
        appState.announcements.add(announcement);
        appState.notifyListeners();

        await tester.pumpWidget(buildTestWidget(appState));
        await tester.pumpAndSettle();

        // Heart border icon should be present
        expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      },
    );

    testWidgets(
      'like count displays correctly when likes exist',
      (WidgetTester tester) async {
        final appState = AppState(skipFirebase: true);
        appState.userId = 'test-user';
        appState.isAdmin = false;

        final society = Society(
          id: 'society-1',
          name: 'Test Society',
          category: 'Academic',
          description: 'A test society',
        );
        appState.societies.add(society);
        appState.joinedSocieties.add(society);

        final announcement = Announcement(
          id: 'announcement-1',
          societyId: 'society-1',
          title: 'Test Announcement',
          content: 'Test content',
          date: DateTime.now(),
          likeCount: 5,
          likedByUsers: const [
            'user-1',
            'user-2',
            'user-3',
            'user-4',
            'user-5'
          ],
          comments: const [],
        );
        appState.announcements.add(announcement);
        appState.notifyListeners();

        await tester.pumpWidget(buildTestWidget(appState));
        await tester.pumpAndSettle();

        // Like count should be displayed
        expect(find.text('5'), findsWidgets);
      },
    );

    testWidgets(
      'comment icon shows comment count when comments exist',
      (WidgetTester tester) async {
        final appState = AppState(skipFirebase: true);
        appState.userId = 'test-user';
        appState.isAdmin = false;

        final society = Society(
          id: 'society-1',
          name: 'Test Society',
          category: 'Academic',
          description: 'A test society',
        );
        appState.societies.add(society);
        appState.joinedSocieties.add(society);

        final comments = [
          Comment(
            id: 'comment-1',
            author: 'User 1',
            content: 'Great announcement!',
            dateTime: DateTime.now(),
          ),
          Comment(
            id: 'comment-2',
            author: 'User 2',
            content: 'Thanks for sharing!',
            dateTime: DateTime.now(),
          ),
        ];

        final announcement = Announcement(
          id: 'announcement-1',
          societyId: 'society-1',
          title: 'Test Announcement',
          content: 'Test content',
          date: DateTime.now(),
          likeCount: 0,
          likedByUsers: const [],
          comments: comments,
        );
        appState.announcements.add(announcement);
        appState.notifyListeners();

        await tester.pumpWidget(buildTestWidget(appState));
        await tester.pumpAndSettle();

        // Comment count should be displayed
        expect(find.text('2'), findsWidgets);
      },
    );

    testWidgets(
      'comment input field appears when comment button is tapped',
      (WidgetTester tester) async {
        final appState = AppState(skipFirebase: true);
        appState.userId = 'test-user';
        appState.isAdmin = false;

        final society = Society(
          id: 'society-1',
          name: 'Test Society',
          category: 'Academic',
          description: 'A test society',
        );
        appState.societies.add(society);
        appState.joinedSocieties.add(society);

        final announcement = Announcement(
          id: 'announcement-1',
          societyId: 'society-1',
          title: 'Test Announcement',
          content: 'Test content',
          date: DateTime.now(),
          likeCount: 0,
          likedByUsers: const [],
          comments: const [],
        );
        appState.announcements.add(announcement);
        appState.notifyListeners();

        await tester.pumpWidget(buildTestWidget(appState));
        await tester.pumpAndSettle();

        // Tap the comment button (chat bubble icon)
        final chatBubbleButton = find.byIcon(Icons.chat_bubble_outline);
        expect(chatBubbleButton, findsOneWidget);

        await tester.tap(chatBubbleButton);
        await tester.pumpAndSettle();

        // Comment input should now be visible
        expect(find.byType(TextField), findsOneWidget);
      },
    );

    testWidgets(
      'pull to refresh completes without error',
      (WidgetTester tester) async {
        final appState = AppState(skipFirebase: true);
        appState.userId = 'test-user';
        appState.isAdmin = false;

        await tester.pumpWidget(buildTestWidget(appState));
        await tester.pumpAndSettle();

        // Perform pull to refresh
        await tester.fling(
          find.byType(RefreshIndicator),
          const Offset(0, 300),
          1000,
        );
        await tester.pumpAndSettle();

        // Should complete without error
        expect(find.byType(FeedScreen), findsOneWidget);
      },
    );

    testWidgets(
      'displays announcement image when imageUrl is provided',
      (WidgetTester tester) async {
        final appState = AppState(skipFirebase: true);
        appState.userId = 'test-user';
        appState.isAdmin = false;

        final society = Society(
          id: 'society-1',
          name: 'Test Society',
          category: 'Academic',
          description: 'A test society',
        );
        appState.societies.add(society);
        appState.joinedSocieties.add(society);

        final announcement = Announcement(
          id: 'announcement-1',
          societyId: 'society-1',
          title: 'Test Announcement',
          content: 'Test content',
          date: DateTime.now(),
          imageUrl: 'https://example.com/image.jpg',
          likeCount: 0,
          likedByUsers: const [],
          comments: const [],
        );
        appState.announcements.add(announcement);
        appState.notifyListeners();

        await tester.pumpWidget(buildTestWidget(appState));
        await tester.pumpAndSettle();

        // Image widget should be present
        expect(find.byType(Image), findsOneWidget);
      },
    );

    testWidgets(
      'announcement date is formatted correctly as DD/MM/YYYY',
      (WidgetTester tester) async {
        final appState = AppState(skipFirebase: true);
        appState.userId = 'test-user';
        appState.isAdmin = false;

        final society = Society(
          id: 'society-1',
          name: 'Test Society',
          category: 'Academic',
          description: 'A test society',
        );
        appState.societies.add(society);
        appState.joinedSocieties.add(society);

        final announcement = Announcement(
          id: 'announcement-1',
          societyId: 'society-1',
          title: 'Test Announcement',
          content: 'Test content',
          date: DateTime(2024, 3, 15),
          likeCount: 0,
          likedByUsers: const [],
          comments: const [],
        );
        appState.announcements.add(announcement);
        appState.notifyListeners();

        await tester.pumpWidget(buildTestWidget(appState));
        await tester.pumpAndSettle();

        // Date should be formatted as DD/MM/YYYY
        expect(find.text('15/03/2024'), findsOneWidget);
      },
    );

    testWidgets(
      'shows "No announcements yet" when announcements list is empty but data is loaded',
      (WidgetTester tester) async {
        final appState = AppState(skipFirebase: true);
        appState.userId = 'test-user';
        appState.isAdmin = false;

        final society = Society(
          id: 'society-1',
          name: 'Test Society',
          category: 'Academic',
          description: 'A test society',
        );
        appState.societies.add(society);
        appState.joinedSocieties.add(society);

        // Don't add any announcements
        appState.notifyListeners();

        await tester.pumpWidget(buildTestWidget(appState));
        await tester.pumpAndSettle();

        // Should show "No announcements yet"
        expect(find.text('No announcements yet.'), findsOneWidget);
      },
    );

    testWidgets(
      'admin can see all announcements regardless of society membership',
      (WidgetTester tester) async {
        final appState = AppState(skipFirebase: true);
        appState.userId = 'admin-user';
        appState.isAdmin = true;

        final society = Society(
          id: 'society-1',
          name: 'Test Society',
          category: 'Academic',
          description: 'A test society',
        );
        appState.societies.add(society);
        // Admin doesn't join society but can still see announcements

        final announcement = Announcement(
          id: 'announcement-1',
          societyId: 'society-1',
          title: 'Admin Viewable Announcement',
          content: 'Visible to admin',
          date: DateTime.now(),
          likeCount: 0,
          likedByUsers: const [],
          comments: const [],
        );
        appState.announcements.add(announcement);
        appState.notifyListeners();

        await tester.pumpWidget(buildTestWidget(appState));
        await tester.pumpAndSettle();

        // Admin should see the announcement
        expect(find.text('Admin Viewable Announcement'), findsOneWidget);
      },
    );
  });
}
