import 'package:flutter/foundation.dart';

import '../models/society.dart';
import '../models/event.dart';

import '../models/announcement.dart';

class AppState extends ChangeNotifier {
  bool isAuthenticated = false;
  String? userId;

  // Dummy societies
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

  // Dummy events
  final List<Event> _events = [
    Event(
      id: 'e1',
      societyId: 'cs',
      title: 'Hackathon 2026',
      description: 'A 24-hour coding competition for all skill levels.',
      date: DateTime(2026, 5, 10),
      venue: 'Engineering Building, Room 101',
    ),
    Event(
      id: 'e2',
      societyId: 'drama',
      title: 'Spring Play Auditions',
      description: 'Open auditions for our annual spring production.',
      date: DateTime(2026, 4, 25),
      venue: 'Main Auditorium',
    ),
    Event(
      id: 'e3',
      societyId: 'sports',
      title: 'Inter-University Football Match',
      description: 'Cheer for our team in the big match!',
      date: DateTime(2026, 6, 2),
      venue: 'University Stadium',
    ),
  ];

  // Dummy announcements
  final List<Announcement> _announcements = [
    Announcement(
      id: 'a1',
      societyId: 'cs',
      title: 'Welcome to the new semester!',
      content: 'Our first meeting will be on April 22. All are welcome!',
      date: DateTime(2026, 4, 20),
    ),
    Announcement(
      id: 'a2',
      societyId: 'drama',
      title: 'Audition Results Posted',
      content:
          'Check your email for the cast list. Rehearsals start next week.',
      date: DateTime(2026, 4, 28),
    ),
    Announcement(
      id: 'a3',
      societyId: 'sports',
      title: 'Training Schedule Update',
      content: 'Training will now be held every Tuesday and Thursday at 5pm.',
      date: DateTime(2026, 4, 21),
    ),
  ];

  List<String> _savedEventIds = [];
  // List of message channels (by society name) the user has joined
  List<String> _joinedChannels = [];

  List<Society> get societies => List.unmodifiable(_societies);
  // List of joined message channels (society names)
  List<String> get joinedChannels => List.unmodifiable(_joinedChannels);

  List<Society> get joinedSocieties =>
      _societies.where((s) => s.isJoined).toList();

  List<Society> get availableSocieties =>
      _societies.where((s) => !s.isJoined).toList();

  List<Event> get events => List.unmodifiable(_events);

  List<Event> get savedEvents =>
      _events.where((e) => _savedEventIds.contains(e.id)).toList();

  List<Event> eventsForSociety(String societyId) =>
      _events.where((e) => e.societyId == societyId).toList();

  Future<void> joinSociety(String id) async {
    final idx = _societies.indexWhere((s) => s.id == id);
    if (idx != -1 && !_societies[idx].isJoined) {
      _societies[idx] = _societies[idx].copyWith(isJoined: true);
      // Add to joined channels if not already present
      final channelName = _societies[idx].name;
      if (!_joinedChannels.contains(channelName)) {
        _joinedChannels.add(channelName);
      }
      // Add user to message channel/forum
      if (userId != null) {
        await MessageService.instance.joinSociety(userId!, id);
      }
      notifyListeners();
    }
  }

  Future<void> leaveSociety(String id) async {
    final idx = _societies.indexWhere((s) => s.id == id);
    if (idx != -1 && _societies[idx].isJoined) {
      _societies[idx] = _societies[idx].copyWith(isJoined: false);
      // Remove from joined channels
      final channelName = _societies[idx].name;
      _joinedChannels.remove(channelName);
      // Remove user from message channel/forum
      if (userId != null) {
        await MessageService.instance.leaveSociety(userId!, id);
      }
      notifyListeners();
    }
  }

  void saveEvent(String id) {
    if (!_savedEventIds.contains(id)) {
      _savedEventIds.add(id);
      notifyListeners();
    }
  }

  void unsaveEvent(String id) {
    if (_savedEventIds.remove(id)) {
      notifyListeners();
    }
  }
}
