import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sociefy/services/message_service.dart';

class RecordingFirebaseFirestore extends Mock implements FirebaseFirestore {
  RecordingFirebaseFirestore(this.collectionReference);

  final RecordingCollectionReference collectionReference;

  String? lastCollectionPath;

  @override
  CollectionReference<Map<String, dynamic>> collection(String path) {
    lastCollectionPath = path;
    return collectionReference;
  }
}

// ignore: must_be_immutable, subtype_of_sealed_class
class RecordingCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {
  RecordingCollectionReference(this.documentReference);

  final RecordingDocumentReference documentReference;

  String? lastDocPath;

  @override
  DocumentReference<Map<String, dynamic>> doc([String? path]) {
    lastDocPath = path;
    return documentReference;
  }
}

// ignore: must_be_immutable, subtype_of_sealed_class
class RecordingDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {
  Map<String, dynamic>? lastSetData;
  bool deleteWasCalled = false;

  @override
  Future<void> set(Map<String, dynamic> data, [SetOptions? options]) async {
    lastSetData = data;
  }

  @override
  Future<void> delete() async {
    deleteWasCalled = true;
  }
}

class RecordingFirebaseMessaging extends Mock implements FirebaseMessaging {
  String? lastTopic;
  String? lastUnsubscribedTopic;

  @override
  Future<void> subscribeToTopic(String topic) async {
    lastTopic = topic;
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) async {
    lastUnsubscribedTopic = topic;
  }
}

void main() {
  test(
    'sendMessage via joinSociety adds a Firestore membership document',
    () async {
      final document = RecordingDocumentReference();
      final collection = RecordingCollectionReference(document);
      final firestore = RecordingFirebaseFirestore(collection);
      final messaging = RecordingFirebaseMessaging();

      final service = MessageService(
        firestore: firestore,
        messaging: messaging,
      );

      await service.joinSociety('user1', 'societyA');

      expect(firestore.lastCollectionPath, 'memberships');
      expect(collection.lastDocPath, 'user1_societyA');
      expect(document.lastSetData, isNotNull);
      expect(document.lastSetData!['userId'], 'user1');
      expect(document.lastSetData!['societyId'], 'societyA');
      expect(document.lastSetData!.containsKey('joinedAt'), isTrue);
      expect(messaging.lastTopic, 'society_societyA');
    },
  );

  test(
    'leaveSociety deletes Firestore membership document and unsubscribes from FCM topic',
    () async {
      final document = RecordingDocumentReference();
      final collection = RecordingCollectionReference(document);
      final firestore = RecordingFirebaseFirestore(collection);
      final messaging = RecordingFirebaseMessaging();

      final service = MessageService(
        firestore: firestore,
        messaging: messaging,
      );

      // First join a society
      await service.joinSociety('user1', 'societyA');
      expect(firestore.lastCollectionPath, 'memberships');
      expect(collection.lastDocPath, 'user1_societyA');
      expect(messaging.lastTopic, 'society_societyA');

      // Then leave the society
      await service.leaveSociety('user1', 'societyA');

      // Verify the membership document was deleted
      expect(firestore.lastCollectionPath, 'memberships');
      expect(collection.lastDocPath, 'user1_societyA');
      expect(document.deleteWasCalled, isTrue);

      // Verify FCM unsubscribe was called
      expect(messaging.lastUnsubscribedTopic, 'society_societyA');
    },
  );
}
