import 'package:flutter_test/flutter_test.dart';
import 'package:sociefy/providers/app_state.dart';

void main() {
  group('ProfileScreen AppState Tests', () {
    void setupGuestAppState(AppState appState) {
      appState.userId = 'guest';
      appState.isAdmin = false;
      appState.notifyListeners();
    }

    test('AppState initializes with guest userId', () {
      final appState = AppState(skipFirebase: true);
      setupGuestAppState(appState);
      expect(appState.isAuthenticated, isTrue);
      expect(appState.isGuest, isTrue);
      expect(appState.userId, equals('guest'));
      expect(appState.isAdmin, isFalse);
    });

    test('Guest user flag reflects guest userId correctly', () {
      final appState = AppState(skipFirebase: true);
      setupGuestAppState(appState);
      expect(appState.isGuest, isTrue);
      expect(appState.userId, equals('guest'));
    });

    test('Sign Out clears authentication for guest user', () {
      final appState = AppState(skipFirebase: true);
      setupGuestAppState(appState);
      expect(appState.isAuthenticated, isTrue);
      appState.logout();
      expect(appState.isAuthenticated, isFalse);
      expect(appState.isGuest, isFalse);
    });

    test('Logout clears userId completely', () {
      final appState = AppState(skipFirebase: true);
      setupGuestAppState(appState);
      appState.logout();
      expect(appState.userId, isNull);
      expect(appState.isAuthenticated, isFalse);
    });

    test('Logout clears admin flag', () {
      final appState = AppState(skipFirebase: true);
      setupGuestAppState(appState);
      appState.logout();
      expect(appState.isAdmin, isFalse);
    });

    test('Guest userId is exactly guest', () {
      final appState = AppState(skipFirebase: true);
      setupGuestAppState(appState);
      expect(appState.userId, equals('guest'));
      expect(appState.isGuest, isTrue);
    });

    test('Admin status is separate from guest status', () {
      final appState = AppState(skipFirebase: true);
      setupGuestAppState(appState);
      expect(appState.isGuest, isTrue);
      expect(appState.isAdmin, isFalse);
      expect(appState.isAuthenticated, isTrue);
    });

    test('Non-guest user is not identified as guest', () {
      final appState = AppState(skipFirebase: true);
      appState.userId = 'real-user-id';
      appState.isAdmin = false;
      appState.notifyListeners();
      expect(appState.isGuest, isFalse);
      expect(appState.isAuthenticated, isTrue);
    });

    test('Multiple logout calls handled gracefully', () {
      final appState = AppState(skipFirebase: true);
      setupGuestAppState(appState);
      appState.logout();
      expect(appState.isAuthenticated, isFalse);
      appState.logout();
      expect(appState.isAuthenticated, isFalse);
    });

    test('Logout triggers listeners for state changes', () {
      final appState = AppState(skipFirebase: true);
      setupGuestAppState(appState);
      bool listenerCalled = false;
      appState.addListener(() {
        listenerCalled = true;
      });
      appState.logout();
      expect(listenerCalled, isTrue);
    });

    test('Setting guest state triggers listeners', () {
      final appState = AppState(skipFirebase: true);
      bool listenerCalled = false;
      appState.addListener(() {
        listenerCalled = true;
      });
      setupGuestAppState(appState);
      expect(listenerCalled, isTrue);
    });

    test('AppState transitions from guest to authenticated', () {
      final appState = AppState(skipFirebase: true);
      setupGuestAppState(appState);
      appState.userId = 'real-user-id';
      appState.notifyListeners();
      expect(appState.isGuest, isFalse);
      expect(appState.isAuthenticated, isTrue);
    });

    test('AppState transitions back to guest', () {
      final appState = AppState(skipFirebase: true);
      appState.userId = 'real-user-id';
      appState.notifyListeners();
      setupGuestAppState(appState);
      expect(appState.isGuest, isTrue);
      expect(appState.isAuthenticated, isTrue);
    });

    test('Guest user is not admin by default', () {
      final appState = AppState(skipFirebase: true);
      setupGuestAppState(appState);
      expect(appState.isGuest, isTrue);
      expect(appState.isAdmin, isFalse);
    });

    test('Logout completely resets authentication state', () {
      final appState = AppState(skipFirebase: true);
      setupGuestAppState(appState);
      appState.logout();
      expect(appState.isAuthenticated, isFalse);
      expect(appState.isGuest, isFalse);
      expect(appState.isAdmin, isFalse);
      expect(appState.userId, isNull);
    });
  });
}
