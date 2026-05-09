import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sociefy/providers/app_state.dart';

/// Tests that exercise [AppState] with a `FakeFirebaseFirestore` injected
/// in place of the real Firestore SDK. These cover the Firestore-touching
/// methods (`loadSocieties`, `loadEvents`, `fetchMySocieties`,
/// `loadSavedEvents`, `persistSaveEvent`, `persistUnsaveEvent`,
/// `createSociety`, `createAnnouncement`, `createEvent`, `joinSociety`,
/// `leaveSociety`) that the unit-test suite cannot reach.
void main() {
  late FakeFirebaseFirestore firestore;
  late AppState appState;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    appState = AppState(skipFirebase: true, firestore: firestore);
  });

  group('loadSocieties', () {
    test('returns empty list when collection is empty', () async {
      await appState.loadSocieties();
      expect(appState.societies, isEmpty);
    });

    test('caches results and skips reload by default', () async {
      await firestore.collection('societies').doc('s1').set({
        'name': 'Chess',
        'category': 'Games',
        'description': 'Strategy',
      });

      await appState.loadSocieties();
      expect(appState.societies, hasLength(1));

      // Add another doc, but loadSocieties should no-op
      await firestore.collection('societies').doc('s2').set({
        'name': 'Anime',
        'category': 'Culture',
        'description': 'Anime',
      });
      await appState.loadSocieties();
      expect(appState.societies, hasLength(1));
    });

    test('forceReload bypasses cache', () async {
      await firestore.collection('societies').doc('s1').set({
        'name': 'Chess',
        'category': 'Games',
        'description': 'Strategy',
      });
      await appState.loadSocieties();
      expect(appState.societies, hasLength(1));

      await firestore.collection('societies').doc('s2').set({
        'name': 'Anime',
        'category': 'Culture',
        'description': 'Anime',
      });
      await appState.loadSocieties(forceReload: true);
      expect(appState.societies, hasLength(2));
    });

    test('substitutes sentinel name/category/description for missing fields',
        () async {
      await firestore.collection('societies').doc('s1').set({});

      await appState.loadSocieties();

      expect(appState.societies.first.name, 'Unknown Society');
      expect(appState.societies.first.category, 'General');
      expect(appState.societies.first.description, '');
    });
  });

  group('loadEvents', () {
    test('returns sample events when Firestore collection is empty', () async {
      await appState.loadEvents();
      // The fallback samples seed the list so the UI is never blank.
      expect(appState.events, isNotEmpty);
    });

    test('reads upcoming events from Firestore', () async {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      await firestore.collection('events').doc('e1').set({
        'societyId': 'sA',
        'societyName': 'Chess',
        'title': 'Weekly meetup',
        'description': 'Casual play',
        'date': Timestamp.fromDate(tomorrow),
        'startTime': '18:00',
        'endTime': '20:00',
        'venue': 'Library',
      });

      await appState.loadEvents();

      final loaded = appState.events.firstWhere((e) => e.id == 'e1');
      expect(loaded.title, 'Weekly meetup');
      expect(loaded.venue, 'Library');
      expect(loaded.societyName, 'Chess');
    });

    test('caches results unless forceReload is true', () async {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      await firestore.collection('events').doc('e1').set({
        'societyId': 'sA',
        'societyName': 'Chess',
        'title': 'First',
        'date': Timestamp.fromDate(tomorrow),
      });

      await appState.loadEvents();
      final firstCount = appState.events.length;

      await firestore.collection('events').doc('e2').set({
        'societyId': 'sA',
        'societyName': 'Chess',
        'title': 'Second',
        'date': Timestamp.fromDate(tomorrow),
      });
      await appState.loadEvents();
      expect(appState.events, hasLength(firstCount));

      await appState.loadEvents(forceReload: true);
      expect(appState.events.where((e) => e.id == 'e2'), hasLength(1));
    });
  });

  group('fetchMySocieties', () {
    test('returns no societies when user has no memberships', () async {
      await appState.fetchMySocieties('u1');
      expect(appState.mySocieties, isEmpty);
    });

    test('returns full Society objects for the user\'s memberships', () async {
      await firestore.collection('memberships').doc('u1_sA').set({
        'userId': 'u1',
        'societyId': 'sA',
      });
      await firestore.collection('memberships').doc('u1_sB').set({
        'userId': 'u1',
        'societyId': 'sB',
      });
      // Other user's membership should be ignored
      await firestore.collection('memberships').doc('u2_sC').set({
        'userId': 'u2',
        'societyId': 'sC',
      });
      await firestore.collection('societies').doc('sA').set({
        'name': 'Chess',
        'category': 'Games',
        'description': '',
      });
      await firestore.collection('societies').doc('sB').set({
        'name': 'Anime',
        'category': 'Culture',
        'description': '',
      });

      await appState.fetchMySocieties('u1');

      expect(appState.mySocieties, hasLength(2));
      expect(
        appState.mySocieties.map((s) => s.name),
        containsAll(['Chess', 'Anime']),
      );
    });
  });

  group('saveEvent / persistSaveEvent / persistUnsaveEvent', () {
    test('persistSaveEvent writes a savedEvents document keyed userId_eventId',
        () async {
      await appState.persistSaveEvent('u1', 'e1');

      final doc =
          await firestore.collection('savedEvents').doc('u1_e1').get();
      expect(doc.exists, isTrue);
      expect(doc.data()!['eventId'], 'e1');
      expect(doc.data()!['userId'], 'u1');
    });

    test('persistUnsaveEvent deletes the savedEvents document', () async {
      await appState.persistSaveEvent('u1', 'e1');
      await appState.persistUnsaveEvent('u1', 'e1');

      final doc =
          await firestore.collection('savedEvents').doc('u1_e1').get();
      expect(doc.exists, isFalse);
    });

    test('loadSavedEvents populates savedEvents IDs from Firestore',
        () async {
      // user logs in
      await appState.login(userId: 'u1');
      // simulate prior saves
      await firestore.collection('savedEvents').doc('u1_e1').set({
        'userId': 'u1',
        'eventId': 'e1',
      });
      await firestore.collection('savedEvents').doc('u1_e2').set({
        'userId': 'u1',
        'eventId': 'e2',
      });
      // another user's saved event must not be loaded
      await firestore.collection('savedEvents').doc('u2_e3').set({
        'userId': 'u2',
        'eventId': 'e3',
      });

      await appState.loadSavedEvents('u1');

      expect(appState.isEventSaved('e1'), isTrue);
      expect(appState.isEventSaved('e2'), isTrue);
      expect(appState.isEventSaved('e3'), isFalse);
    });
  });

  group('createSociety / createAnnouncement / createEvent', () {
    test('createSociety writes a Firestore document with slugified ID',
        () async {
      appState.createSociety(
        name: 'Chess Club',
        category: 'Games',
        description: 'Strategy',
      );

      // Local insert is synchronous; Firestore write is fire-and-forget.
      await Future.delayed(Duration.zero);

      final docs = await firestore.collection('societies').get();
      expect(docs.docs, hasLength(1));
      expect(docs.docs.first.id, startsWith('chess-club-'));
      expect(docs.docs.first.data()['name'], 'Chess Club');
    });

    test('createAnnouncement writes a Firestore document with serverTimestamp',
        () async {
      appState.createAnnouncement(
        societyId: 'sA',
        title: 'Hello',
        content: 'Welcome',
      );

      // Fire-and-forget Firestore write; let the microtask drain.
      await Future.delayed(Duration.zero);

      final docs = await firestore.collection('announcements').get();
      expect(docs.docs, hasLength(1));
      expect(docs.docs.first.data()['title'], 'Hello');
      expect(docs.docs.first.data()['content'], 'Welcome');
      expect(docs.docs.first.data().containsKey('date'), isTrue);
    });

    test('createEvent writes a Firestore document with the event data',
        () async {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      appState.createEvent(
        societyId: 'sA',
        title: 'Tournament',
        description: 'Annual',
        date: tomorrow,
        startTime: '10:00',
        endTime: '17:00',
        venue: 'Hall',
      );

      await Future.delayed(Duration.zero);

      final docs = await firestore.collection('events').get();
      expect(docs.docs, hasLength(1));
      expect(docs.docs.first.data()['title'], 'Tournament');
      expect(docs.docs.first.data()['venue'], 'Hall');
      expect(docs.docs.first.id, startsWith('e-'));
    });
  });

  group('joinSociety / leaveSociety (full Firestore round-trip)', () {
    test('joinSociety persists a membership document for authenticated user',
        () async {
      await appState.login(userId: 'u1');
      await appState.joinSociety('sA');

      // The async Firestore write runs after notifyListeners; let it drain.
      await Future.delayed(Duration.zero);

      final doc =
          await firestore.collection('memberships').doc('u1_sA').get();
      expect(doc.exists, isTrue);
      expect(appState.isJoined('sA'), isTrue);
    });

    test('leaveSociety removes the membership document', () async {
      await appState.login(userId: 'u1');
      await appState.joinSociety('sA');
      await Future.delayed(Duration.zero);

      await appState.leaveSociety('sA');
      await Future.delayed(Duration.zero);

      final doc =
          await firestore.collection('memberships').doc('u1_sA').get();
      expect(doc.exists, isFalse);
      expect(appState.isJoined('sA'), isFalse);
    });

    test('guest user join updates local state but skips Firestore write',
        () async {
      await appState.login(userId: 'guest');
      await appState.joinSociety('sA');
      await Future.delayed(Duration.zero);

      expect(appState.isJoined('sA'), isTrue);
      // Guest writes must not pollute Firestore.
      final docs = await firestore.collection('memberships').get();
      expect(docs.docs, isEmpty);
    });
  });

  group('refreshFeed', () {
    test('clears caches and re-reads from Firestore', () async {
      await firestore.collection('societies').doc('s1').set({
        'name': 'Chess',
        'category': 'Games',
        'description': '',
      });
      await appState.loadSocieties();
      expect(appState.societies, hasLength(1));

      await firestore.collection('societies').doc('s2').set({
        'name': 'Anime',
        'category': 'Culture',
        'description': '',
      });

      await appState.refreshFeed();

      expect(appState.societies, hasLength(2));
    });
  });
}
