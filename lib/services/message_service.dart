import 'dart:async';

// Simple in-memory service for mapping userId -> set of societyChannelIds.
// Replace internals with your backend (Firebase, REST call, socket join, etc.)
class MessageService {
  MessageService._privateConstructor();
  static final MessageService instance = MessageService._privateConstructor();

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
  //  - TODO: add real backend integration (subscribe to socket room / add to DB / call API)
  Future<void> joinSociety(String userId, String societyId) async {
    // Simulate network latency if desired:
    await Future.delayed(const Duration(milliseconds: 200));

    final set = _userChannels.putIfAbsent(userId, () => <String>{});
    if (!set.contains(societyId)) {
      set.add(societyId);

      // TODO: Replace the following with real channel subscription logic:
      // e.g. Firebase: add membership document, then subscribe to FCM topic or join socket room
      // e.g. WebSocket: send "join" message for 'societyId' room

      // notify listeners
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
