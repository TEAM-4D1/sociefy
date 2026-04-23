import '../models/society.dart';
import '../models/event.dart';
import '../models/announcement.dart';

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppState extends ChangeNotifier {
  String? userId;
  bool isAdmin = false;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  AppState() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        login(userId: user.uid);
      } else {
        logout();
      }
    });
  }

  final List<String> _joinedSocietyIds = [];
  final List<String> _savedEventIds = [];

  List<Society> _societies = [];

  List<Event> _events = [];

  List<Announcement> _announcements = [];

  Future<void> loadSocieties() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('societies')
        .get();
    _societies = querySnapshot.docs.map((doc) {
      final data = doc.data();
      return Society(
        id: doc.id,
        name: data['name'] ?? 'Unknown Society',
        category: data['category'] ?? 'General',
        description: data['description'] ?? '',
      );
    }).toList();
    notifyListeners();
  }

  Future<void> loadEvents() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('events')
        .get();
    _events = querySnapshot.docs.map((doc) {
      final data = doc.data();
      return Event(
        id: doc.id,
        societyId: data['societyId'] ?? '',
        societyName: data['societyName'] ?? 'Unknown Society',
        title: data['title'] ?? 'Untitled Event',
        description: data['description'] ?? '',
        date: data['date'] != null
            ? (data['date'] as Timestamp).toDate()
            : DateTime.now(),
        startTime: data['startTime'] ?? '',
        endTime: data['endTime'] ?? '',
        venue: data['venue'] ?? '',
        isSaved: false,
      );
    }).toList();
    notifyListeners();
  }

  Future<void> loadAnnouncements() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('announcements')
        .get();
    _announcements = querySnapshot.docs.map((doc) {
      final data = doc.data();
      return Announcement(
        id: doc.id,
        societyId: data['societyId'] ?? '',
        title: data['title'] ?? 'Untitled',
        content: data['content'] ?? '',
        date: data['date'] != null
            ? (data['date'] as Timestamp).toDate()
            : DateTime.now(),
      );
    }).toList();
    notifyListeners();
  }

  bool get isAuthenticated => userId != null;

  Future<void> login({String? userId, bool isAdmin = false}) async {
    this.userId = userId ?? this.userId;
    this.isAdmin = isAdmin;
    notifyListeners();

    _isLoading = true;
    notifyListeners();
    try {
      await Future.wait([loadSocieties(), loadEvents(), loadAnnouncements()]);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    if (this.userId != null) {
      loadSavedEvents(this.userId!);
    }
  }

  void logout() {
    userId = null;
    isAdmin = false;
    _joinedSocietyIds.clear();
    _savedEventIds.clear();
    notifyListeners();
  }

  List<Society> get societies => _societies;

  List<Announcement> get announcements => _announcements;

  bool isJoined(String id) => _joinedSocietyIds.contains(id);

  List<Society> get joinedSocieties =>
      _societies.where((s) => _joinedSocietyIds.contains(s.id)).toList();

  List<Society> get availableSocieties =>
      _societies.where((s) => !_joinedSocietyIds.contains(s.id)).toList();

  Future<void> joinSociety(String id) async {
    if (!_joinedSocietyIds.contains(id)) {
      _joinedSocietyIds.add(id);
      notifyListeners();
    }
  }

  Future<void> leaveSociety(String id) async {
    _joinedSocietyIds.remove(id);
    notifyListeners();
  }

  void createSociety({
    required String name,
    required String category,
    required String description,
  }) {
    final id =
        '${name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-')}-${DateTime.now().millisecondsSinceEpoch}';
    _societies.add(
      Society(id: id, name: name, category: category, description: description),
    );
    notifyListeners();
  }

  void createAnnouncement({
    required String societyId,
    required String title,
    required String content,
  }) {
    _announcements.insert(
      0,
      Announcement(
        id: 'a-${DateTime.now().millisecondsSinceEpoch}',
        societyId: societyId,
        title: title,
        content: content,
        date: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  String societyNameById(String id) {
    for (final society in _societies) {
      if (society.id == id) {
        return society.name;
      }
    }
    return 'Society';
  }

  List<Event> get events => _events;

  bool isEventSaved(String id) => _savedEventIds.contains(id);

  List<Event> get savedEvents =>
      _events.where((e) => _savedEventIds.contains(e.id)).toList();

  List<Event> eventsForSociety(String societyId) =>
      _events.where((e) => e.societyId == societyId).toList();

  void saveEvent(String id) {
    if (!_savedEventIds.contains(id)) {
      _savedEventIds.add(id);
      notifyListeners();
    }
  }

  void unsaveEvent(String id) {
    _savedEventIds.remove(id);
    notifyListeners();
  }

  /// Persist a saved event to Firestore for the given user.
  Future<void> persistSaveEvent(String userId, String eventId) async {
    try {
      await FirebaseFirestore.instance
          .collection('savedEvents')
          .doc('${userId}_$eventId')
          .set({
            'eventId': eventId,
            'userId': userId,
            'createdAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      debugPrint('persistSaveEvent error: $e');
      rethrow;
    }
  }

  /// Remove a saved event document for the given user/event.
  Future<void> persistUnsaveEvent(String userId, String eventId) async {
    try {
      await FirebaseFirestore.instance
          .collection('savedEvents')
          .doc('${userId}_$eventId')
          .delete();
    } catch (e) {
      debugPrint('persistUnsaveEvent error: $e');
      rethrow;
    }
  }

  /// Load saved events for a user from Firestore into local state.
  Future<void> loadSavedEvents(String userId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('savedEvents')
          .where('userId', isEqualTo: userId)
          .get();
      for (final doc in snapshot.docs) {
        final eid = doc['eventId'] as String?;
        if (eid != null && !_savedEventIds.contains(eid)) {
          _savedEventIds.add(eid);
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('loadSavedEvents error: $e');
    }
  }
}
