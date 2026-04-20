import 'package:flutter/foundation.dart';
import '../models/society.dart';
import '../models/event.dart';

class AppState extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? userId;
  bool isAdmin = false;

<<<<<<< HEAD
  void login({String? userId, bool isAdmin = false}) {
    isAuthenticated = true;
    this.userId = userId ?? this.userId;
    this.isAdmin = isAdmin;
=======
  // =====================
  // STATE STORAGE (IDs only)
  // =====================

  final List<String> _joinedSocietyIds = [];
  final List<String> _savedEventIds = [];

  // =====================
  // SOCIETIES
  // =====================

  final List<Society> _societies = [
    Society(
      id: 'cs',
      name: 'Computer Science Society',
      category: 'Academic',
      description:
          'A society for students interested in computing, coding, and technology.',
      contactName: 'Admin',
      contactEmail: 'cs@society.com',
      memberCount: 120,
    ),
    Society(
      id: 'drama',
      name: 'Drama Club',
      category: 'Arts',
      description: 'For those who love acting, theatre, and stage production.',
      contactName: 'Admin',
      contactEmail: 'drama@society.com',
      memberCount: 80,
    ),
    Society(
      id: 'sports',
      name: 'Sports Society',
      category: 'Recreation',
      description:
          'Join to participate in a variety of sports and fitness activities.',
      contactName: 'Admin',
      contactEmail: 'sports@society.com',
      memberCount: 150,
    ),
  ];

  // =====================
  // EVENTS (MATCHES YOUR MODEL)
  // =====================

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

  // =====================
  // AUTH
  // =====================

  bool get isAuthenticated => _isAuthenticated;

  void login({String? userId}) {
    _isAuthenticated = true;
    this.userId = userId;
>>>>>>> b5fe359c98136d8e5b8cee1acd4bbe8d2c1f0095
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    userId = null;
<<<<<<< HEAD
    isAdmin = false;
=======
    _joinedSocietyIds.clear();
    _savedEventIds.clear();
>>>>>>> b5fe359c98136d8e5b8cee1acd4bbe8d2c1f0095
    notifyListeners();
  }

  // =====================
  // SOCIETIES LOGIC
  // =====================

  List<Society> get societies => _societies;

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

  // =====================
  // EVENTS LOGIC
  // =====================

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
}
