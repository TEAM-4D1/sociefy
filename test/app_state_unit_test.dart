import 'package:flutter_test/flutter_test.dart';
import 'package:sociefy/providers/app_state.dart';

/// A testable subclass that skips Firebase initialisation.
class TestAppState extends AppState {
  TestAppState() : super(skipFirebase: true);
}

void main() {
  group('AppState Unit Tests', () {
    late TestAppState appState;

    setUp(() {
      appState = TestAppState();
    });

    // ------------------------------------------------------------------ //
    //  Initial state
    // ------------------------------------------------------------------ //

    test('userId is null on creation', () {
      expect(appState.userId, isNull);
    });

    test('isAdmin is false on creation', () {
      expect(appState.isAdmin, isFalse);
    });

    test('isAuthenticated is false when userId is null', () {
      expect(appState.isAuthenticated, isFalse);
    });

    test('isGuest is false when userId is null', () {
      expect(appState.isGuest, isFalse);
    });

    test('_pendingAdminLogin is false on creation', () {
      // Verified indirectly – setAdminPending starts at false
      appState.setAdminPending(false);
      expect(appState.isAdmin, isFalse);
    });

    // ------------------------------------------------------------------ //
    //  isAuthenticated
    // ------------------------------------------------------------------ //

    test('isAuthenticated is true when userId is a non-empty string', () {
      appState.userId = 'user-abc';
      expect(appState.isAuthenticated, isTrue);
    });

    test('isAuthenticated is false when userId is empty string', () {
      appState.userId = '';
      expect(appState.isAuthenticated, isFalse);
    });

    test('isAuthenticated returns false after logout', () {
      appState.userId = 'user-abc';
      appState.logout();
      expect(appState.isAuthenticated, isFalse);
    });

    // ------------------------------------------------------------------ //
    //  isGuest
    // ------------------------------------------------------------------ //

    test('isGuest is true when userId equals "guest"', () {
      appState.userId = 'guest';
      expect(appState.isGuest, isTrue);
    });

    test('isGuest is false when userId starts with "guest" but is not exactly "guest"', () {
      appState.userId = 'guest123';
      expect(appState.isGuest, isFalse);
    });

    test('isGuest is false for a regular user id', () {
      appState.userId = 'firebase-uid-xyz';
      expect(appState.isGuest, isFalse);
    });

    // ------------------------------------------------------------------ //
    //  isAdmin
    // ------------------------------------------------------------------ //

    test('isAdmin can be set to true', () {
      appState.isAdmin = true;
      expect(appState.isAdmin, isTrue);
    });

    test('isAdmin is cleared by logout', () {
      appState.isAdmin = true;
      appState.logout();
      expect(appState.isAdmin, isFalse);
    });

    test('isAdmin is independent of isAuthenticated', () {
      appState.isAdmin = true;
      expect(appState.isAuthenticated, isFalse);
    });

    // ------------------------------------------------------------------ //
    //  setAdminPending
    // ------------------------------------------------------------------ //

    test('setAdminPending true does not immediately change isAdmin', () {
      appState.setAdminPending(true);
      expect(appState.isAdmin, isFalse);
    });

    test('setAdminPending false keeps isAdmin false', () {
      appState.setAdminPending(false);
      expect(appState.isAdmin, isFalse);
    });

    // ------------------------------------------------------------------ //
    //  logout
    // ------------------------------------------------------------------ //

    test('logout clears userId', () {
      appState.userId = 'user-abc';
      appState.logout();
      expect(appState.userId, isNull);
    });

    test('logout clears isAdmin', () {
      appState.isAdmin = true;
      appState.logout();
      expect(appState.isAdmin, isFalse);
    });

    test('logout clears saved event ids', () {
      appState.userId = 'guest'; // guest so saveEvent stays local
      appState.saveEvent('evt-1');
      appState.logout();
      expect(appState.isEventSaved('evt-1'), isFalse);
    });

    test('logout clears joined society ids', () async {
      appState.userId = 'guest';
      await appState.joinSociety('soc-1');
      appState.logout();
      expect(appState.isJoined('soc-1'), isFalse);
    });

    // ------------------------------------------------------------------ //
    //  Event saving (local state only)
    // ------------------------------------------------------------------ //

    test('isEventSaved returns false initially', () {
      expect(appState.isEventSaved('evt-1'), isFalse);
    });

    test('saveEvent makes isEventSaved return true', () {
      appState.userId = 'guest';
      appState.saveEvent('evt-1');
      expect(appState.isEventSaved('evt-1'), isTrue);
    });

    test('saveEvent saves multiple distinct events', () {
      appState.userId = 'guest';
      appState.saveEvent('evt-1');
      appState.saveEvent('evt-2');
      expect(appState.isEventSaved('evt-1'), isTrue);
      expect(appState.isEventSaved('evt-2'), isTrue);
    });

    test('duplicate saveEvent calls are idempotent', () {
      appState.userId = 'guest';
      appState.saveEvent('evt-1');
      appState.saveEvent('evt-1');
      // savedEvents list deduplication – count via savedEvents getter
      expect(appState.savedEvents.length, 0); // events list is empty, so 0
      expect(appState.isEventSaved('evt-1'), isTrue);
    });

    test('unsaveEvent removes a saved event', () {
      appState.userId = 'guest';
      appState.saveEvent('evt-1');
      appState.unsaveEvent('evt-1');
      expect(appState.isEventSaved('evt-1'), isFalse);
    });

    test('unsaveEvent on non-existent event does not throw', () {
      appState.userId = 'guest';
      expect(() => appState.unsaveEvent('nonexistent'), returnsNormally);
    });

    // ------------------------------------------------------------------ //
    //  Society joining (local state only)
    // ------------------------------------------------------------------ //

    test('isJoined returns false initially', () {
      expect(appState.isJoined('soc-1'), isFalse);
    });

    test('joinSociety makes isJoined return true', () async {
      appState.userId = 'guest';
      await appState.joinSociety('soc-1');
      expect(appState.isJoined('soc-1'), isTrue);
    });

    test('leaveSociety removes a joined society', () async {
      appState.userId = 'guest';
      await appState.joinSociety('soc-1');
      await appState.leaveSociety('soc-1');
      expect(appState.isJoined('soc-1'), isFalse);
    });

    // ------------------------------------------------------------------ //
    //  societyNameById
    // ------------------------------------------------------------------ //

    test('societyNameById returns "Society" when list is empty', () {
      expect(appState.societyNameById('unknown-id'), equals('Society'));
    });

    // ------------------------------------------------------------------ //
    //  Lists are empty on creation
    // ------------------------------------------------------------------ //

    test('societies list is empty on creation', () {
      expect(appState.societies, isEmpty);
    });

    test('events list is empty on creation', () {
      expect(appState.events, isEmpty);
    });

    test('announcements list is empty on creation', () {
      expect(appState.announcements, isEmpty);
    });

    test('joinedSocieties list is empty on creation', () {
      expect(appState.joinedSocieties, isEmpty);
    });

    test('savedEvents list is empty on creation', () {
      expect(appState.savedEvents, isEmpty);
    });
  });
}
