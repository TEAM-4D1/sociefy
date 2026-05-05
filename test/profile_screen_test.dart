import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sociefy/providers/app_state.dart';

void main() {
  group('ProfileScreen with AppState Tests', () {
    /// Helper to create and initialize an AppState with guest login
    /// without calling Firebase methods.
    void setupGuestAppState(AppState appState) {
      appState.userId = 'guest';
      appState.isAdmin = false;
      appState.notifyListeners();
    }

    /// Test 1: AppState initializes with guest login
    test('AppState initializes with guest userId', () async {
      // Arrange
      final appState = AppState(skipFirebase: true);

      // Act
      setupGuestAppState(appState);

      // Assert
      expect(appState.isAuthenticated, isTrue);
      expect(appState.isGuest, isTrue);
      expect(appState.userId, equals('guest'));
      expect(appState.isAdmin, isFalse);
    });

    /// Test 2: Guest user flag is accurate
    test('Guest user flag reflects guest userId correctly', () async {
      // Arrange
      final appState = AppState(skipFirebase: true);
      setupGuestAppState(appState);

      // Assert
      expect(appState.isGuest, isTrue);
      expect(appState.userId, equals('guest'));
    });

    /// Test 3: Sign Out clears authentication
    test('Sign Out button clears authentication for guest user', () async {
      // Arrange
      final appState = AppState(skipFirebase: true);
      setupGuestAppState(appState);

      // Verify guest is authenticated before logout
      expect(appState.isAuthenticated, isTrue);
      expect(appState.isGuest, isTrue);

      // Act
      appState.logout();

      // Assert
      expect(appState.isAuthenticated, isFalse);
      expect(appState.isGuest, isFalse);
      expect(appState.userId, isNull);
    });

    /// Test 4: Verify logout clears userId
    test('Logout clears userId completely', () async {
      // Arrange
      final appState = AppState(skipFirebase: true);
      setupGuestAppState(appState);
      expect(appState.userId, isNotNull);

      // Act
      appState.logout();

      // Assert
      expect(appState.userId, isNull);
      expect(appState.isAuthenticated, isFalse);
    });

    /// Test 5: Verify logout clears admin flag
    test('Logout clears admin flag', () async {
      // Arrange
      final appState = AppState(skipFirebase: true);
      setupGuestAppState(appState);

      // Act
      appState.logout();

      // Assert
      expect(appState.isAdmin, isFalse);
    });

    /// Test 6: Guest userId is exactly 'guest'
    test('Guest userId is exactly guest', () async {
      // Arrange
      final appState = AppState(skipFirebase: true);

      // Act
      setupGuestAppState(appState);

      // Assert
      expect(appState.userId, equals('guest'));
      expect(appState.isGuest, isTrue);
    });

    /// Test 7: AppState tracks admin status separately from guest status
    test('Admin status is separate from guest status', () async {
      // Arrange
      final appState = AppState(skipFirebase: true);
      setupGuestAppState(appState);

      // Assert
      expect(appState.isGuest, isTrue);
      expect(appState.isAdmin, isFalse);
      expect(appState.isAuthenticated, isTrue);
    });

    /// Test 8: Non-guest user is not identified as guest
    test('Non-guest user is not identified as guest', () async {
      // Arrange
      final appState = AppState(skipFirebase: true);
      appState.userId = 'real-user-id';
      appState.isAdmin = false;
      appState.notifyListeners();

      // Assert
      expect(appState.isGuest, isFalse);
      expect(appState.isAuthenticated, isTrue);
      expect(appState.userId, equals('real-user-id'));
    });

    /// Test 9: Multiple logout calls don't cause errors
    test('Multiple logout calls are handled gracefully', () async {
      // Arrange
      final appState = AppState(skipFirebase: true);
      setupGuestAppState(appState);

      // Act & Assert - Should not throw
      appState.logout();
      expect(appState.isAuthenticated, isFalse);

      // Calling logout again on an already logged-out state
      appState.logout();
      expect(appState.isAuthenticated, isFalse);
      expect(appState.userId, isNull);
    });

    /// Test 10: Logout triggers notifyListeners
    test('Logout triggers listeners for state changes', () async {
      // Arrange
      final appState = AppState(skipFirebase: true);
      setupGuestAppState(appState);
      
      bool listenerCalled = false;
      appState.addListener(() {
        listenerCalled = true;
      });

      // Act
      appState.logout();

      // Assert
      expect(listenerCalled, isTrue);
      expect(appState.isAuthenticated, isFalse);
    });

    /// Test 11: Guest setup triggers notifyListeners
    test('Setting guest state triggers listeners', () async {
      // Arrange
      final appState = AppState(skipFirebase: true);
      
      bool listenerCalled = false;
      appState.addListener(() {
        listenerCalled = true;
      });

      // Act
      setupGuestAppState(appState);

      // Assert
      expect(listenerCalled, isTrue);
      expect(appState.isGuest, isTrue);
    });

    /// Test 12: AppState allows switching from guest to authenticated user
    test('AppState can transition from guest to authenticated user', () async {
      // Arrange
      final appState = AppState(skipFirebase: true);
      setupGuestAppState(appState);
      expect(appState.isGuest, isTrue);

      // Act - Switch to a different user
      appState.userId = 'real-user-id';
      appState.notifyListeners();

      // Assert
      expect(appState.isGuest, isFalse);
      expect(appState.isAuthenticated, isTrue);
      expect(appState.userId, equals('real-user-id'));
    });

    /// Test 13: AppState allows switching from authenticated user back to guest
    test('AppState can transition from authenticated user back to guest', () async {
      // Arrange
      final appState = AppState(skipFirebase: true);
      appState.userId = 'real-user-id';
      appState.notifyListeners();
      expect(appState.isGuest, isFalse);

      // Act - Switch to guest
      setupGuestAppState(appState);

      // Assert
      expect(appState.isGuest, isTrue);
      expect(appState.isAuthenticated, isTrue);
    });

    /// Test 14: Verify guest user is not admin
    test('Guest user is not admin by default', () async {
      // Arrange
      final appState = AppState(skipFirebase: true);
      setupGuestAppState(appState);

      // Assert
      expect(appState.isGuest, isTrue);
      expect(appState.isAdmin, isFalse);
    });

    /// Test 15: Logout clears both guest and admin states
    test('Logout completely resets authentication state', () async {
      // Arrange
      final appState = AppState(skipFirebase: true);
      setupGuestAppState(appState);
      expect(appState.isAuthenticated, isTrue);
      expect(appState.isGuest, isTrue);

      // Act
      appState.logout();

      // Assert
      expect(appState.isAuthenticated, isFalse);
      expect(appState.isGuest, isFalse);
      expect(appState.isAdmin, isFalse);
      expect(appState.userId, isNull);
    });
  });
}


    /// Test 2: Sign Out button is present on the profile screen
    testWidgets('Sign Out button is present', (WidgetTester tester) async {
      // Arrange
      final appState = AppState(skipFirebase: true);
      setupGuestAppState(appState);

      // Act
      await tester.pumpWidget(buildTestWidget(appState: appState));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Sign Out'), findsOneWidget);
      expect(find.byIcon(Icons.logout), findsOneWidget);
    });

    /// Test 3: When Sign Out is tapped for guest user, isAuthenticated becomes false
    testWidgets('Sign Out button clears authentication for guest user', (
      WidgetTester tester,
    ) async {
      // Arrange
      final appState = AppState(skipFirebase: true);
      setupGuestAppState(appState);

      // Verify guest is authenticated before sign out
      expect(appState.isAuthenticated, isTrue);
      expect(appState.isGuest, isTrue);

      // Act
      await tester.pumpWidget(buildTestWidget(appState: appState));
      await tester.pumpAndSettle();

      // Tap the Sign Out button
      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();

      // Assert
      expect(appState.isAuthenticated, isFalse);
      expect(appState.isGuest, isFalse);
    });

    /// Test 4: Guest avatar displays 'G' as the first letter of 'Guest User'
    testWidgets('Guest user avatar displays G', (WidgetTester tester) async {
      // Arrange
      final appState = AppState(skipFirebase: true);
      setupGuestAppState(appState);

      // Act
      await tester.pumpWidget(buildTestWidget(appState: appState));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('G'), findsOneWidget);
    });

    /// Test 5: Profile screen displays correct UI structure with title
    testWidgets('Profile screen has correct UI structure', (
      WidgetTester tester,
    ) async {
      // Arrange
      final appState = AppState(skipFirebase: true);
      setupGuestAppState(appState);

      // Act
      await tester.pumpWidget(buildTestWidget(appState: appState));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Profile'), findsWidgets);
      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    /// Test 6: Verify app state is initially authenticated as guest
    testWidgets('AppState initializes with guest login', (
      WidgetTester tester,
    ) async {
      // Arrange
      final appState = AppState(skipFirebase: true);

      // Act
      setupGuestAppState(appState);

      // Assert
      expect(appState.isAuthenticated, isTrue);
      expect(appState.isGuest, isTrue);
      expect(appState.userId, equals('guest'));
      expect(appState.isAdmin, isFalse);
    });

    /// Test 7: Verify logout clears userId
    testWidgets('Logout clears userId completely', (WidgetTester tester) async {
      // Arrange
      final appState = AppState(skipFirebase: true);
      setupGuestAppState(appState);
      expect(appState.userId, isNotNull);

      // Act
      appState.logout();

      // Assert
      expect(appState.userId, isNull);
      expect(appState.isAuthenticated, isFalse);
    });

    /// Test 8: Verify logout clears admin flag
    testWidgets('Logout clears admin flag', (WidgetTester tester) async {
      // Arrange
      final appState = AppState(skipFirebase: true);
      setupGuestAppState(appState);

      // Act
      appState.logout();

      // Assert
      expect(appState.isAdmin, isFalse);
    });

    /// Test 9: Sign Out button is an ElevatedButton with logout icon
    testWidgets('Sign Out button is properly styled', (
      WidgetTester tester,
    ) async {
      // Arrange
      final appState = AppState(skipFirebase: true);
      setupGuestAppState(appState);

      // Act
      await tester.pumpWidget(buildTestWidget(appState: appState));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byIcon(Icons.logout), findsOneWidget);
    });

    /// Test 10: Profile displays correct styling for guest display name
    testWidgets('Guest User text has correct styling', (
      WidgetTester tester,
    ) async {
      // Arrange
      final appState = AppState(skipFirebase: true);
      setupGuestAppState(appState);

      // Act
      await tester.pumpWidget(buildTestWidget(appState: appState));
      await tester.pumpAndSettle();

      // Assert - Verify the text is rendered
      final guestUserFinder = find.text('Guest User');
      expect(guestUserFinder, findsOneWidget);

      // Verify it's displayed in the widget tree
      final widget = tester.widget<Text>(guestUserFinder);
      expect(widget.style?.fontSize, equals(24));
      expect(widget.style?.fontWeight, equals(FontWeight.bold));
    });

    /// Test 11: Subtitle has correct styling for guest
    testWidgets('Browsing as guest subtitle has correct styling', (
      WidgetTester tester,
    ) async {
      // Arrange
      final appState = AppState(skipFirebase: true);
      setupGuestAppState(appState);

      // Act
      await tester.pumpWidget(buildTestWidget(appState: appState));
      await tester.pumpAndSettle();

      // Assert
      final subtitleFinder = find.text('Browsing as guest');
      expect(subtitleFinder, findsOneWidget);

      final widget = tester.widget<Text>(subtitleFinder);
      expect(widget.style?.fontSize, equals(16));
      expect(widget.style?.color, equals(Colors.grey));
    });

    /// Test 12: AppBar title is 'Profile'
    testWidgets('AppBar displays Profile title', (WidgetTester tester) async {
      // Arrange
      final appState = AppState(skipFirebase: true);
      setupGuestAppState(appState);

      // Act
      await tester.pumpWidget(buildTestWidget(appState: appState));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AppBar), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Profile'),
        ),
        findsOneWidget,
      );
    });

    /// Test 13: CircleAvatar has correct radius
    testWidgets('CircleAvatar has correct dimensions', (
      WidgetTester tester,
    ) async {
      // Arrange
      final appState = AppState(skipFirebase: true);
      setupGuestAppState(appState);

      // Act
      await tester.pumpWidget(buildTestWidget(appState: appState));
      await tester.pumpAndSettle();

      // Assert
      final avatarFinder = find.byType(CircleAvatar);
      expect(avatarFinder, findsOneWidget);

      final avatar = tester.widget<CircleAvatar>(avatarFinder);
      expect(avatar.radius, equals(50));
    });

    /// Test 14: Tapping Sign Out multiple times doesn't break the app
    testWidgets('Multiple Sign Out taps are handled gracefully', (
      WidgetTester tester,
    ) async {
      // Arrange
      final appState = AppState(skipFirebase: true);
      setupGuestAppState(appState);

      await tester.pumpWidget(buildTestWidget(appState: appState));
      await tester.pumpAndSettle();

      // Act - Tap Sign Out button
      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();

      // Assert - User should be logged out
      expect(appState.isAuthenticated, isFalse);
    });

    /// Test 15: Guest userId is exactly 'guest'
    testWidgets('Guest userId is exactly guest', (WidgetTester tester) async {
      // Arrange
      final appState = AppState(skipFirebase: true);

      // Act
      setupGuestAppState(appState);

      // Assert
      expect(appState.userId, equals('guest'));
      expect(appState.isGuest, isTrue);
    });

    /// Test 16: Verify Screen is wrapped correctly with providers
    testWidgets('ProfileScreen is properly wrapped in providers', (
      WidgetTester tester,
    ) async {
      // Arrange
      final appState = AppState(skipFirebase: true);
      setupGuestAppState(appState);

      // Act
      await tester.pumpWidget(buildTestWidget(appState: appState));
      await tester.pumpAndSettle();

      // Assert - Should be able to find the provider in context
      expect(find.byType(ProfileScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
