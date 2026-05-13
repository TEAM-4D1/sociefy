import 'package:flutter_test/flutter_test.dart';
import 'package:sociefy/providers/app_state.dart';

void main() {
  group('AppState Unit Tests', () {
    // ------------------------------------------------------------------ //
    //  Initial state
    // ------------------------------------------------------------------ //

    test('initializes with null userId', () {
      final appState = AppState(skipFirebase: true);
      expect(appState.userId, isNull);
    });

    test('initializes as not authenticated', () {
      final appState = AppState(skipFirebase: true);
      expect(appState.isAuthenticated, isFalse);
    });

    test('initializes as not admin', () {
      final appState = AppState(skipFirebase: true);
      expect(appState.isAdmin, isFalse);
    });

    test('initializes with empty societies list', () {
      final appState = AppState(skipFirebase: true);
      expect(appState.societies, isEmpty);
    });

    test('initializes with empty events list', () {
      final appState = AppState(skipFirebase: true);
      expect(appState.events, isEmpty);
    });

    test('initializes with empty announcements list', () {
      final appState = AppState(skipFirebase: true);
      expect(appState.announcements, isEmpty);
    });

    test('isPendingAdminLogin is false by default', () {
      final appState = AppState(skipFirebase: true);
      expect(appState.isPendingAdminLogin, isFalse);
    });

    // ------------------------------------------------------------------ //
    //  isAuthenticated / isGuest
    // ------------------------------------------------------------------ //

    test('isAuthenticated is true when userId is set', () {
      final appState = AppState(skipFirebase: true);
      appState.userId = 'user-123';
      expect(appState.isAuthenticated, isTrue);
    });

    test('isAuthenticated is false after userId cleared to null', () {
      final appState = AppState(skipFirebase: true);
      appState.userId = 'user-123';
      appState.userId = null;
      expect(appState.isAuthenticated, isFalse);
    });

    test('isGuest is true when userId equals "guest"', () {
      final appState = AppState(skipFirebase: true);
      appState.userId = 'guest';
      expect(appState.isGuest, isTrue);
    });

    test('isGuest is false when userId is a real user id', () {
      final appState = AppState(skipFirebase: true);
      appState.userId = 'real-user-id';
      expect(appState.isGuest, isFalse);
    });

    test('isGuest is false when userId is null', () {
      final appState = AppState(skipFirebase: true);
      expect(appState.isGuest, isFalse);
    });

    // ------------------------------------------------------------------ //
    //  logout()
    // ------------------------------------------------------------------ //

    test('logout() clears userId', () {
      final appState = AppState(skipFirebase: true);
      appState.userId = 'user-123';
      appState.logout();
      expect(appState.userId, isNull);
    });

    test('logout() clears isAdmin', () {
      final appState = AppState(skipFirebase: true);
      appState.userId = 'user-123';
      appState.isAdmin = true;
      appState.logout();
      expect(appState.isAdmin, isFalse);
    });

    test('logout() makes user not authenticated', () {
      final appState = AppState(skipFirebase: true);
      appState.userId = 'user-123';
      appState.logout();
      expect(appState.isAuthenticated, isFalse);
    });

    test('logout() notifies listeners', () {
      final appState = AppState(skipFirebase: true);
      appState.userId = 'user-123';
      bool notified = false;
      appState.addListener(() => notified = true);
      appState.logout();
      expect(notified, isTrue);
    });

    test('multiple logout() calls handled gracefully', () {
      final appState = AppState(skipFirebase: true);
      appState.userId = 'user-123';
      appState.logout();
      appState.logout();
      expect(appState.isAuthenticated, isFalse);
    });

    // ------------------------------------------------------------------ //
    //  createSociety()
    // ------------------------------------------------------------------ //

    test('createSociety() adds one society to list', () async {
      final appState = AppState(skipFirebase: true);
      await appState.createSociety(
        name: 'Chess Club',
        category: 'Academic',
        description: 'Play chess',
      );
      expect(appState.societies.length, equals(1));
    });

    test('createSociety() stores correct name', () async {
      final appState = AppState(skipFirebase: true);
      await appState.createSociety(
        name: 'Chess Club',
        category: 'Academic',
        description: 'Play chess',
      );
      expect(appState.societies.first.name, equals('Chess Club'));
    });

    test('createSociety() stores correct category', () async {
      final appState = AppState(skipFirebase: true);
      await appState.createSociety(
        name: 'Dance Society',
        category: 'Arts',
        description: 'For dancers',
      );
      expect(appState.societies.first.category, equals('Arts'));
    });

    test('createSociety() stores correct description', () async {
      final appState = AppState(skipFirebase: true);
      await appState.createSociety(
        name: 'Robotics',
        category: 'Tech',
        description: 'Build robots',
      );
      expect(appState.societies.first.description, equals('Build robots'));
    });

    test('createSociety() notifies listeners', () async {
      final appState = AppState(skipFirebase: true);
      bool notified = false;
      appState.addListener(() => notified = true);
      await appState.createSociety(
        name: 'Test',
        category: 'Test',
        description: 'Test',
      );
      expect(notified, isTrue);
    });

    test('multiple createSociety() calls accumulate', () {
      final appState = AppState(skipFirebase: true);
      appState.createSociety(name: 'S1', category: 'C1', description: 'D1');
      appState.createSociety(name: 'S2', category: 'C2', description: 'D2');
      appState.createSociety(name: 'S3', category: 'C3', description: 'D3');
      expect(appState.societies.length, equals(3));
    });

    // ------------------------------------------------------------------ //
    //  joinSociety() / leaveSociety() / isJoined()
    // ------------------------------------------------------------------ //

    test('isJoined() returns false for unknown id', () {
      final appState = AppState(skipFirebase: true);
      expect(appState.isJoined('nonexistent'), isFalse);
    });

    test('joinSociety() marks society as joined (guest user)', () async {
      final appState = AppState(skipFirebase: true);
      appState.userId = 'guest';
      appState.createSociety(
        name: 'Chess Club',
        category: 'Academic',
        description: 'Chess',
      );
      final id = appState.societies.first.id;
      await appState.joinSociety(id);
      expect(appState.isJoined(id), isTrue);
    });

    test('leaveSociety() marks society as not joined', () async {
      final appState = AppState(skipFirebase: true);
      appState.userId = 'guest';
      appState.createSociety(
        name: 'Chess Club',
        category: 'Academic',
        description: 'Chess',
      );
      final id = appState.societies.first.id;
      await appState.joinSociety(id);
      await appState.leaveSociety(id);
      expect(appState.isJoined(id), isFalse);
    });

    test('joinSociety() does not add duplicate entries', () async {
      final appState = AppState(skipFirebase: true);
      appState.userId = 'guest';
      appState.createSociety(
        name: 'Chess Club',
        category: 'Academic',
        description: 'Chess',
      );
      final id = appState.societies.first.id;
      await appState.joinSociety(id);
      await appState.joinSociety(id);
      expect(appState.joinedSocieties.length, equals(1));
    });

    test('joinedSocieties returns only joined societies', () async {
      final appState = AppState(skipFirebase: true);
      appState.userId = 'guest';
      appState.createSociety(name: 'S1', category: 'C', description: 'D');
      appState.createSociety(name: 'S2', category: 'C', description: 'D');
      final id1 = appState.societies[0].id;
      await appState.joinSociety(id1);
      expect(appState.joinedSocieties.length, equals(1));
      expect(appState.joinedSocieties.first.name, equals('S1'));
    });

    test('availableSocieties excludes joined societies', () async {
      final appState = AppState(skipFirebase: true);
      appState.userId = 'guest';
      appState.createSociety(name: 'S1', category: 'C', description: 'D');
      appState.createSociety(name: 'S2', category: 'C', description: 'D');
      final id1 = appState.societies[0].id;
      await appState.joinSociety(id1);
      expect(appState.availableSocieties.length, equals(1));
      expect(appState.availableSocieties.first.name, equals('S2'));
    });

    // ------------------------------------------------------------------ //
    //  saveEvent() / unsaveEvent() / isEventSaved()
    // ------------------------------------------------------------------ //

    test('isEventSaved() returns false for unknown id', () {
      final appState = AppState(skipFirebase: true);
      expect(appState.isEventSaved('nonexistent'), isFalse);
    });

    test('saveEvent() marks event as saved (guest user)', () async {
      final appState = AppState(skipFirebase: true);
      appState.userId = 'guest';
      appState.createSociety(name: 'T', category: 'T', description: 'T');
      appState.createEvent(
        societyId: appState.societies.first.id,
        title: 'Workshop',
        description: 'Desc',
        date: DateTime(2026, 6, 1),
        startTime: '10:00',
        endTime: '11:00',
        venue: 'Room 1',
      );
      final eventId = appState.events.first.id;
      await appState.saveEvent(eventId);
      expect(appState.isEventSaved(eventId), isTrue);
    });

    test('unsaveEvent() removes event from saved', () async {
      final appState = AppState(skipFirebase: true);
      appState.userId = 'guest';
      appState.createSociety(name: 'T', category: 'T', description: 'T');
      appState.createEvent(
        societyId: appState.societies.first.id,
        title: 'Workshop',
        description: 'Desc',
        date: DateTime(2026, 6, 1),
        startTime: '10:00',
        endTime: '11:00',
        venue: 'Room 1',
      );
      final eventId = appState.events.first.id;
      await appState.saveEvent(eventId);
      await appState.unsaveEvent(eventId);
      expect(appState.isEventSaved(eventId), isFalse);
    });

    test('savedEvents returns only saved events', () async {
      final appState = AppState(skipFirebase: true);
      appState.userId = 'guest';
      // Clear any sample events that might have been loaded
      appState.events.clear();
      appState.createSociety(name: 'T', category: 'T', description: 'T');
      appState.createEvent(
        societyId: appState.societies.first.id,
        title: 'Event A',
        description: 'D',
        date: DateTime(2026, 6, 1),
        startTime: '09:00',
        endTime: '10:00',
        venue: 'Hall',
      );
      appState.createEvent(
        societyId: appState.societies.first.id,
        title: 'Event B',
        description: 'D',
        date: DateTime(2026, 6, 2),
        startTime: '11:00',
        endTime: '12:00',
        venue: 'Lab',
      );
      // find by title to avoid millisecond-collision IDs
      final idA = appState.events.firstWhere((e) => e.title == 'Event A').id;
      await appState.saveEvent(idA);
      expect(appState.savedEvents.length, equals(1));
      expect(appState.savedEvents.first.title, equals('Event A'));
    });

    // ------------------------------------------------------------------ //
    //  societyNameById()
    // ------------------------------------------------------------------ //

    test('societyNameById() returns correct name', () {
      final appState = AppState(skipFirebase: true);
      appState.createSociety(
        name: 'Math Club',
        category: 'Academic',
        description: 'Math',
      );
      final id = appState.societies.first.id;
      expect(appState.societyNameById(id), equals('Math Club'));
    });

    test('societyNameById() returns "Society" for unknown id', () {
      final appState = AppState(skipFirebase: true);
      expect(appState.societyNameById('bad-id'), equals('Society'));
    });

    // ------------------------------------------------------------------ //
    //  createAnnouncement()
    // ------------------------------------------------------------------ //

    test('createAnnouncement() adds to announcements list', () async {
      final appState = AppState(skipFirebase: true);
      await appState.createAnnouncement(
        societyId: 'soc-1',
        title: 'Event Tonight',
        content: 'Come at 7pm',
        venue: 'Room 1',
        startTime: '19:00',
        endTime: '21:00',
        date: DateTime(2026, 6, 1),
      );
      expect(appState.announcements.length, equals(1));
      expect(appState.announcements.first.title, equals('Event Tonight'));
    });

    test('createAnnouncement() inserts at the beginning of the list', () async {
      final appState = AppState(skipFirebase: true);
      await appState.createAnnouncement(
        societyId: 'soc-1',
        title: 'First',
        content: 'Content',
        venue: 'Room 1',
        startTime: '10:00',
        endTime: '11:00',
        date: DateTime(2026, 6, 1),
      );
      await appState.createAnnouncement(
        societyId: 'soc-1',
        title: 'Second',
        content: 'Content',
        venue: 'Room 2',
        startTime: '12:00',
        endTime: '13:00',
        date: DateTime(2026, 6, 2),
      );
      expect(appState.announcements.first.title, equals('Second'));
    });

    // ------------------------------------------------------------------ //
    //  setAdminPending() / isPendingAdminLogin
    // ------------------------------------------------------------------ //

    test('setAdminPending(true) sets isPendingAdminLogin', () {
      final appState = AppState(skipFirebase: true);
      appState.setAdminPending(true);
      expect(appState.isPendingAdminLogin, isTrue);
    });

    test('setAdminPending(false) clears isPendingAdminLogin', () {
      final appState = AppState(skipFirebase: true);
      appState.setAdminPending(true);
      appState.setAdminPending(false);
      expect(appState.isPendingAdminLogin, isFalse);
    });

    // ------------------------------------------------------------------ //
    //  createEvent()
    // ------------------------------------------------------------------ //

    test('createEvent() adds event to events list', () async {
      final appState = AppState(skipFirebase: true);
      await appState.createSociety(
        name: 'CS Club',
        category: 'Tech',
        description: 'D',
      );
      await appState.createEvent(
        societyId: appState.societies.first.id,
        title: 'Hackathon',
        description: 'All-night coding',
        date: DateTime(2026, 7, 1),
        startTime: '18:00',
        endTime: '06:00',
        venue: 'Main Hall',
      );
      expect(appState.events.length, equals(1));
      expect(appState.events.first.title, equals('Hackathon'));
    });

    test('eventsForSociety() returns only events for that society', () async {
      final appState = AppState(skipFirebase: true);
      await appState.createSociety(
        name: 'CS Club',
        category: 'Tech',
        description: 'D',
      );
      await appState.createSociety(
        name: 'Art Club',
        category: 'Arts',
        description: 'D',
      );
      final csId = appState.societies[0].id;
      final artId = appState.societies[1].id;
      await appState.createEvent(
        societyId: csId,
        title: 'CS Event',
        description: 'D',
        date: DateTime(2026, 7, 1),
        startTime: '10:00',
        endTime: '11:00',
        venue: 'Lab',
      );
      await appState.createEvent(
        societyId: artId,
        title: 'Art Event',
        description: 'D',
        date: DateTime(2026, 7, 2),
        startTime: '14:00',
        endTime: '16:00',
        venue: 'Studio',
      );
      expect(appState.eventsForSociety(csId).length, equals(1));
      expect(appState.eventsForSociety(csId).first.title, equals('CS Event'));
    });
  });
}
