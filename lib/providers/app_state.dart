import '../models/society.dart';
import '../models/event.dart';
import '../models/announcement.dart';

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppState extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? userId;
  bool isAdmin = false;

  final List<String> _joinedSocietyIds = [];
  final List<String> _savedEventIds = [];

  final List<Society> _societies = [
    Society(
      id: 'cs',
      name: 'Computer Science Society',
      category: 'Academic',
      description:
          'A society for students interested in computing, coding, and technology.',
    ),
    Society(
      id: 'drama',
      name: 'Drama Club',
      category: 'Arts',
      description: 'For those who love acting, theatre, and stage production.',
    ),
    Society(
      id: 'sports',
      name: 'Sports Society',
      category: 'Recreation',
      description:
          'Join to participate in a variety of sports and fitness activities.',
    ),
  ];

  final List<Event> _events = [
    Event(
      id: 'e1',
      societyId: 'cs',
      societyName: 'Computer Science Society',
      title: 'Hackathon 2026',
      description: 'A 24-hour coding competition for all skill levels.',
      date: DateTime(2026, 5, 10),
      startTime: '10:00 AM',
      endTime: '4:00 PM',
      venue: 'Engineering Building, Room 101',
      isSaved: false,
    ),
    Event(
      id: 'e2',
      societyId: 'drama',
      societyName: 'Drama Club',
      title: 'Spring Play Auditions',
      description: 'Open auditions for our annual spring production.',
      date: DateTime(2026, 4, 25),
      startTime: '7:00 PM',
      endTime: '9:00 PM',
      venue: 'Main Auditorium',
      isSaved: false,
    ),
    Event(
      id: 'e3',
      societyId: 'sports',
      societyName: 'Sports Society',
      title: 'Inter-University Football Match',
      description: 'Cheer for our team in the big match!',
      date: DateTime(2026, 6, 2),
      startTime: '5:00 PM',
      endTime: '7:00 PM',
      venue: 'University Stadium',
      isSaved: false,
    ),
  ];

  final List<Announcement> _announcements = [
    Announcement(
      id: 'a1',
      societyId: 'cs',
      title: 'Welcome Back Meeting',
      content: 'Join us this Friday to plan upcoming coding events.',
      date: DateTime(2026, 4, 20),
    ),
    Announcement(
      id: 'a2',
      societyId: 'drama',
      title: 'Audition Schedule Released',
      content: 'Check the notice board for updated audition time slots.',
      date: DateTime(2026, 4, 19),
    ),
  ];

  bool get isAuthenticated => _isAuthenticated;

  void login({String? userId, bool isAdmin = false}) {
    _isAuthenticated = true;
    this.userId = userId ?? this.userId;
    this.isAdmin = isAdmin;
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
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
