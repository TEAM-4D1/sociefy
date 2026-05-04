import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Simple in-memory service for mapping userId -> set of societyChannelIds.
// Replace internals with your backend (Firebase, REST call, socket join, etc.)
class MessageService {
  MessageService({
    FirebaseFirestore? firestore,
    FirebaseMessaging? messaging,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _messaging = messaging ?? FirebaseMessaging.instance;

  MessageService._privateConstructor() : this();
  static final MessageService instance = MessageService._privateConstructor();

  final FirebaseFirestore _firestore;
  final FirebaseMessaging _messaging;

  // userId -> set of channel ids
  final Map<String, Set<String>> _userChannels = {};

  // Controllers per user to broadcast their channel list updates
  final Map<String, StreamController<List<String>>> _controllers = {};

  // Ensure a stream controller exists for a user
  StreamController<List<String>> _ensureController(String userId) {
    return _controllers.putIfAbsent(
      userId,
      () => StreamController<List<String>>.broadcast(),
    );
  }

  // Get stream of joined channel ids for a user
  Stream<List<String>> userChannelsStream(String userId) {
    final controller = _ensureController(userId);
    // push current state immediately
    controller.add(List.unmodifiable(_userChannels[userId] ?? {}));
    return controller.stream;
  }

  // Get current joined channels (synchronous)
  List<String> getJoinedChannels(String userId) =>
      List.unmodifiable(_userChannels[userId] ?? {});

  // Call this when a user joins a society. This will:
  //  - update local state
  //  - push update to stream
  //  - add membership to Firestore and subscribe to FCM topic
  Future<void> joinSociety(String userId, String societyId) async {
    // Add membership to Firestore
    await _firestore
        .collection('memberships')
        .doc('${userId}_$societyId')
        .set({
          'userId': userId,
          'societyId': societyId,
          'joinedAt': FieldValue.serverTimestamp(),
        });

    // Subscribe to FCM topic for this society
    await _messaging.subscribeToTopic('society_$societyId');

    // Update local state and notify listeners
    final set = _userChannels.putIfAbsent(userId, () => <String>{});
    if (!set.contains(societyId)) {
      set.add(societyId);
      final controller = _ensureController(userId);
      controller.add(List.unmodifiable(set));
    }
  }

  // Optionally implement leaveSociety similarly
  Future<void> leaveSociety(String userId, String societyId) async {
    final set = _userChannels[userId];
    if (set != null && set.remove(societyId)) {
      final controller = _ensureController(userId);
      controller.add(List.unmodifiable(set));
    }
  }
}
