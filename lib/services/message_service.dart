import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Maintains an in-memory map of `userId → joined societyChannelIds` and a
/// per-user broadcast stream so chat-list UIs can react to membership
/// changes. On `joinSociety` it also writes a `memberships` document to
/// Firestore and subscribes the device to the society's FCM topic so push
/// notifications can be received.
class MessageService {
  MessageService({FirebaseFirestore? firestore, FirebaseMessaging? messaging})
    : _firestore = firestore ?? FirebaseFirestore.instance,
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
    await _firestore.collection('memberships').doc('${userId}_$societyId').set({
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

  // Call this when a user leaves a society. This will:
  //  - delete membership from Firestore
  //  - unsubscribe from FCM topic
  //  - update local state
  //  - push update to stream
  Future<void> leaveSociety(String userId, String societyId) async {
    // Delete membership from Firestore
    await _firestore
        .collection('memberships')
        .doc('${userId}_$societyId')
        .delete();

    // Unsubscribe from FCM topic for this society
    await _messaging.unsubscribeFromTopic('society_$societyId');

    // Update local state and notify listeners
    final set = _userChannels[userId];
    if (set != null && set.remove(societyId)) {
      final controller = _ensureController(userId);
      controller.add(List.unmodifiable(set));
    }
  }
}
