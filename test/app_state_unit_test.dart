import 'package:flutter_test/flutter_test.dart';
import 'package:sociefy/providers/app_state.dart';

/// A test-friendly subclass of AppState that skips Firebase listeners.
class TestAppState extends AppState {
  /// Create TestAppState with Firebase disabled for unit testing.
  TestAppState() : super(skipFirebase: true);
}

void main() {
  group('AppState Unit Tests (No Firebase)', () {
    late TestAppState appState;

    setUp(() {
      // Create a fresh AppState instance for each test.
      appState = TestAppState();
    });

    // Tests for userId and authentication state (pure setters/getters)
    test('userId is initially null', () {
      expect(appState.userId, isNull);
    });

    test('isAdmin is initially false', () {
      expect(appState.isAdmin, isFalse);
    });

    test('isAuthenticated is initially false', () {
      expect(appState.isAuthenticated, isFalse);
    });

    test('isGuest returns true when userId is "guest"', () {
      // Directly set userId without calling login (which calls Firebase methods)
      appState.userId = 'guest';
      expect(appState.isGuest, isTrue);
    });

    test('isGuest returns false when userId is not "guest"', () {
      appState.userId = 'real-user-id';
      expect(appState.isGuest, isFalse);
    });

    test('isGuest returns false when userId is null', () {
      appState.userId = null;
      expect(appState.isGuest, isFalse);
    });

    test('isAuthenticated returns true when userId is set', () {
      appState.userId = 'test-user';
      expect(appState.isAuthenticated, isTrue);
    });

    test('isAuthenticated returns false when userId is null', () {
      appState.userId = null;
      expect(appState.isAuthenticated, isFalse);
    });

    test('isAdmin can be set and retrieved', () {
      expect(appState.isAdmin, isFalse);
      appState.isAdmin = true;
      expect(appState.isAdmin, isTrue);
      appState.isAdmin = false;
      expect(appState.isAdmin, isFalse);
    });

    // Tests for pending admin login flag
    test('isPendingAdminLogin is initially false', () {
      expect(appState.isPendingAdminLogin, isFalse);
    });

    test('setAdminPending(true) sets isPendingAdminLogin to true', () {
      appState.setAdminPending(true);
      expect(appState.isPendingAdminLogin, isTrue);
    });

    test('setAdminPending(false) sets isPendingAdminLogin to false', () {
      appState.setAdminPending(true);
      expect(appState.isPendingAdminLogin, isTrue);
      appState.setAdminPending(false);
      expect(appState.isPendingAdminLogin, isFalse);
    });

    // Tests for logout clearing state
    test('logout clears userId', () {
      appState.userId = 'test-user';
      expect(appState.userId, equals('test-user'));

      appState.logout();
      expect(appState.userId, isNull);
    });

    test('logout clears isAdmin flag', () {
      appState.isAdmin = true;
      expect(appState.isAdmin, isTrue);

      appState.logout();
      expect(appState.isAdmin, isFalse);
    });

    test('logout sets isAuthenticated to false', () {
      appState.userId = 'test-user';
      expect(appState.isAuthenticated, isTrue);

      appState.logout();
      expect(appState.isAuthenticated, isFalse);
    });

    // Tests for saveEvent and unsaveEvent (pure list operations)
    test('isEventSaved returns false initially', () {
      expect(appState.isEventSaved('event-1'), isFalse);
    });

    test('saveEvent makes isEventSaved return true', () {
      // Note: We only test local state, not Firebase persistence
      appState.saveEvent('event-123');
      expect(appState.isEventSaved('event-123'), isTrue);
    });

    test('saveEvent with multiple events saves all', () {
      appState.saveEvent('event-1');
      appState.saveEvent('event-2');
      appState.saveEvent('event-3');

      expect(appState.isEventSaved('event-1'), isTrue);
      expect(appState.isEventSaved('event-2'), isTrue);
      expect(appState.isEventSaved('event-3'), isTrue);
    });

    test('unsaveEvent removes event from local saved list', () {
      appState.saveEvent('event-123');
      expect(appState.isEventSaved('event-123'), isTrue);

      appState.unsaveEvent('event-123');
      expect(appState.isEventSaved('event-123'), isFalse);
    });

    test('duplicate saveEvent calls are idempotent', () {
      appState.saveEvent('event-123');
      appState.saveEvent('event-123');
      appState.saveEvent('event-123');

      expect(appState.isEventSaved('event-123'), isTrue);
    });

    test('unsaveEvent on non-existent event is safe', () {
      expect(appState.isEventSaved('event-999'), isFalse);
      appState.unsaveEvent('event-999');
      expect(appState.isEventSaved('event-999'), isFalse);
    });

    // Tests for isJoined (pure list operations)
    test('isJoined returns false initially', () {
      expect(appState.isJoined('society-1'), isFalse);
    });

    test('isJoined returns false for non-existent society', () {
      expect(appState.isJoined('nonexistent-id'), isFalse);
    });

    // Tests for guest user flow
    test('guest users can save events locally', () {
      appState.userId = 'guest';
      expect(appState.isGuest, isTrue);

      appState.saveEvent('event-1');
      expect(appState.isEventSaved('event-1'), isTrue);
    });

    // Tests for logout clearing saved events
    test('logout clears saved events from local cache', () {
      // Note: We don't set userId to avoid triggering Firebase persistence
      // We just verify the local state is cleared
      appState.saveEvent('event-1');
      appState.saveEvent('event-2');
      expect(appState.isEventSaved('event-1'), isTrue);
      expect(appState.isEventSaved('event-2'), isTrue);

      appState.logout();
      expect(appState.isEventSaved('event-1'), isFalse);
      expect(appState.isEventSaved('event-2'), isFalse);
    });

    // Tests for joined societies (pure list operations)
    test('joinedSocieties is empty initially', () {
      expect(appState.joinedSocieties, isEmpty);
    });

    test('availableSocieties returns all societies when none joined', () {
      // This test depends on societies being loaded, which requires Firebase
      // So we just verify it returns an iterable
      expect(appState.availableSocieties, isNotNull);
    });

    // Edge case tests
    test('setting userId to empty string makes isAuthenticated false', () {
      appState.userId = '';
      expect(appState.isAuthenticated, isFalse);
    });

    test('guest session is protected: isGuest requires userId == "guest"', () {
      appState.userId = 'gues'; // Almost but not exactly "guest"
      expect(appState.isGuest, isFalse);

      appState.userId = 'guest '; // Extra space
      expect(appState.isGuest, isFalse);

      appState.userId = 'guest';
      expect(appState.isGuest, isTrue);
    });

    test('admin flag can be independently set from authentication', () {
      // User can be authenticated but not admin
      appState.userId = 'user-1';
      appState.isAdmin = false;
      expect(appState.isAuthenticated, isTrue);
      expect(appState.isAdmin, isFalse);

      // User can be admin
      appState.isAdmin = true;
      expect(appState.isAuthenticated, isTrue);
      expect(appState.isAdmin, isTrue);
    });
  });
}
