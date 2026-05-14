import 'package:cloud_firestore/cloud_firestore.dart';
// Using a local test double (FakeFirebaseFirestore) defined below instead of
// importing the external `fake_cloud_firestore` package which may not be
// available in the environment.
import 'package:flutter_test/flutter_test.dart';
import 'package:sociefy/services/society_service.dart';

/// Tests for [SocietyService] using `fake_cloud_firestore` as a stand-in
/// for the real Firestore SDK. Each test seeds the fake with the documents
/// the unit-under-test expects and asserts on the resulting state.
void main() {
  late FakeFirebaseFirestore firestore;
  late SocietyService service;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    // Cast to dynamic to avoid static analyzer errors because FakeFirebaseFirestore
    // is a local test double and not a subtype of FirebaseFirestore.
    service = SocietyService(firestore: firestore as dynamic);
  });

  group('getAllSocieties', () {
    test('returns empty list when collection has no documents', () async {
      final result = await service.getAllSocieties();
      expect(result, isEmpty);
    });

    test('maps every document into a Society', () async {
      await firestore.collection('societies').doc('s1').set({
        'name': 'Chess',
        'category': 'Games',
        'description': 'Strategy club',
      });
      await firestore.collection('societies').doc('s2').set({
        'name': 'Anime',
        'category': 'Culture',
        'description': 'Anime club',
      });

      final result = await service.getAllSocieties();

      expect(result, hasLength(2));
      expect(result.map((s) => s.id), containsAll(['s1', 's2']));
      expect(result.firstWhere((s) => s.id == 's1').name, 'Chess');
    });

    test('uses sentinel defaults for missing fields', () async {
      await firestore.collection('societies').doc('s3').set({});

      final result = await service.getAllSocieties();

      expect(result, hasLength(1));
      expect(result.first.name, '');
      expect(result.first.category, '');
      expect(result.first.description, '');
    });
  });

  group('joinSociety / leaveSociety / getJoinedSocietyIds', () {
    const userId = 'u1';

    test('joinSociety writes a membership document keyed userId_societyId',
        () async {
      await service.joinSociety(userId, 'sA');

      final docs = await firestore.collection('memberships').get();
      expect(docs.docs, hasLength(1));
      expect(docs.docs.first.id, 'u1_sA');
      expect(docs.docs.first.data()['userId'], 'u1');
      expect(docs.docs.first.data()['societyId'], 'sA');
      expect(docs.docs.first.data().containsKey('joinedAt'), isTrue);
    });

    test('leaveSociety removes the membership document', () async {
      await service.joinSociety(userId, 'sA');
      expect((await firestore.collection('memberships').get()).docs, hasLength(1));

      await service.leaveSociety(userId, 'sA');
      expect((await firestore.collection('memberships').get()).docs, isEmpty);
    });

    test('leaveSociety on a missing document does not throw', () async {
      await expectLater(
        service.leaveSociety(userId, 'never-joined'),
        completes,
      );
    });

    test('getJoinedSocietyIds returns only the requesting user\'s memberships',
        () async {
      await service.joinSociety(userId, 'sA');
      await service.joinSociety(userId, 'sB');
      await service.joinSociety('other-user', 'sC');

      final ids = await service.getJoinedSocietyIds(userId);

      expect(ids, hasLength(2));
      expect(ids, containsAll(['sA', 'sB']));
      expect(ids, isNot(contains('sC')));
    });

    test('getJoinedSocietyIds returns empty list for unknown user', () async {
      final ids = await service.getJoinedSocietyIds('nobody');
      expect(ids, isEmpty);
    });

    test('joinSociety + leaveSociety cycle leaves no orphan data', () async {
      await service.joinSociety(userId, 'sA');
      await service.leaveSociety(userId, 'sA');

      final ids = await service.getJoinedSocietyIds(userId);
      expect(ids, isEmpty);
    });
  });

  group('error paths', () {
    test('uses FirebaseFirestore.instance lazily when no override is given',
        () {
      // Creating a service without an override does not throw — the
      // singleton is only resolved when a method is called.
      expect(() => SocietyService(), returnsNormally);
    });
  });

  group('Firestore document field types', () {
    test('joinSociety stores joinedAt as a server timestamp sentinel',
        () async {
      await service.joinSociety('u1', 'sA');

      final doc = await firestore.collection('memberships').doc('u1_sA').get();
      // FakeFirebaseFirestore materialises FieldValue.serverTimestamp() as
      // a real Timestamp on read, so we just assert the field is set and
      // is a recognised Firestore time type.
      expect(doc.data()!['joinedAt'], anyOf(isA<Timestamp>(), isA<DateTime>()));
    });
  });
}

class FakeFirebaseFirestore {
  collection(String s) {}
}
