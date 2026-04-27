import '../models/society.dart';
import '../models/event.dart';
import '../models/announcement.dart';
import '../services/society_service.dart';

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class AppState extends ChangeNotifier {
  String? userId;
  bool isAdmin = false;

  StreamSubscription<QuerySnapshot>? _announcementsSubscription;

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
    if (_societies.isNotEmpty) return;
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
    if (_events.isNotEmpty) return;
    final querySnapshot = await FirebaseFirestore.instance
        .collection('events')
        .where(
          'date',
          isGreaterThanOrEqualTo: Timestamp.fromDate(
            DateTime.now().subtract(Duration(days: 1)),
          ),
        )
        .limit(100)
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

  void loadAnnouncements() {
    _announcementsSubscription?.cancel();
    _announcementsSubscription = FirebaseFirestore.instance
        .collection('announcements')
        .orderBy('date', descending: true)
        .limit(50)
        .snapshots()
        .listen((querySnapshot) {
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
        });
  }

  bool get isAuthenticated => userId != null;

  Future<void> loadJoinedSocieties(String userId) async {
    try {
      final ids = await SocietyService().getJoinedSocietyIds(userId);
      _joinedSocietyIds.clear();
      _joinedSocietyIds.addAll(ids);
      notifyListeners();
    } catch (e) {
      debugPrint('loadJoinedSocieties error: $e');
    }
  }

  Future<void> login({String? userId, bool isAdmin = false}) async {
    this.userId = userId ?? this.userId;
    this.isAdmin = isAdmin;
    notifyListeners();

    // Fire all data loads without awaiting
    loadSocieties();
    loadEvents();
    loadAnnouncements();

    if (this.userId != null && !this.userId!.startsWith('guest')) {
      loadJoinedSocieties(this.userId!);
      loadSavedEvents(this.userId!);
    }
  }

  Future<void> refreshFeed() async {
    // Clear all data lists
    _societies.clear();
    _events.clear();
    _announcements.clear();

    // Reload loadSocieties and loadEvents in parallel, then load announcements
    await Future.wait<void>([loadSocieties(), loadEvents()]);

    // loadAnnouncements is stream-based, just call it
    loadAnnouncements();
  }

  void logout() {
    userId = null;
    isAdmin = false;
    _joinedSocietyIds.clear();
    _savedEventIds.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _announcementsSubscription?.cancel();
    super.dispose();
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
    if (userId != null && !userId!.startsWith('guest')) {
      try {
        await SocietyService().joinSociety(userId!, id);
      } catch (e) {
        debugPrint('joinSociety Firestore error: $e');
      }
    }
  }

  Future<void> leaveSociety(String id) async {
    _joinedSocietyIds.remove(id);
    notifyListeners();
    if (userId != null && !userId!.startsWith('guest')) {
      try {
        await SocietyService().leaveSociety(userId!, id);
      } catch (e) {
        debugPrint('leaveSociety Firestore error: $e');
      }
    }
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

    try {
      FirebaseFirestore.instance.collection('societies').doc(id).set({
        'name': name,
        'category': category,
        'description': description,
      });
    } catch (e) {
      debugPrint('createSociety Firestore error: $e');
    }
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

    try {
      FirebaseFirestore.instance.collection('announcements').add({
        'societyId': societyId,
        'title': title,
        'content': content,
        'date': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('createAnnouncement Firestore error: $e');
    }
  }

  void createEvent({
    required String societyId,
    required String title,
    required String description,
    required DateTime date,
    required String startTime,
    required String endTime,
    required String venue,
  }) {
    final eventId = 'e-${DateTime.now().millisecondsSinceEpoch}';
    final societyName = societyNameById(societyId);

    _events.insert(
      0,
      Event(
        id: eventId,
        societyId: societyId,
        societyName: societyName,
        title: title,
        description: description,
        date: date,
        startTime: startTime,
        endTime: endTime,
        venue: venue,
        isSaved: false,
      ),
    );
    notifyListeners();

    try {
      FirebaseFirestore.instance.collection('events').doc(eventId).set({
        'societyId': societyId,
        'societyName': societyName,
        'title': title,
        'description': description,
        'date': Timestamp.fromDate(date),
        'startTime': startTime,
        'endTime': endTime,
        'venue': venue,
      });
    } catch (e) {
      debugPrint('createEvent Firestore error: $e');
    }
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
    if (userId != null && !userId!.startsWith('guest')) {
      try {
        persistSaveEvent(userId!, id);
      } catch (e) {
        debugPrint('saveEvent Firestore error: $e');
      }
    }
  }

  void unsaveEvent(String id) {
    _savedEventIds.remove(id);
    notifyListeners();
    if (userId != null && !userId!.startsWith('guest')) {
      try {
        persistUnsaveEvent(userId!, id);
      } catch (e) {
        debugPrint('unsaveEvent Firestore error: $e');
      }
    }
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
