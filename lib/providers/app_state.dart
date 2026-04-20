import 'package:flutter/foundation.dart';
import '../models/society.dart';
import '../models/event.dart';
import '../data/sample_societies.dart';
import '../data/sample_events.dart';

class AppState extends ChangeNotifier {
  bool isAuthenticated = false;
  void login() {
    isAuthenticated = true;
    notifyListeners();
  }

  void logout() {
    isAuthenticated = false;
    notifyListeners();
  }

  List<Society> _societies = List.from(sampleSocieties);
  List<Event> _events = List.from(sampleEvents);
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

  void joinSociety(String id) {
    final idx = _societies.indexWhere((s) => s.id == id);
    if (idx != -1 && !_societies[idx].isJoined) {
      _societies[idx] = _societies[idx].copyWith(isJoined: true);
      // Add to joined channels if not already present
      final channelName = _societies[idx].name;
      if (!_joinedChannels.contains(channelName)) {
        _joinedChannels.add(channelName);
      }
      notifyListeners();
    }
  }

  void leaveSociety(String id) {
    final idx = _societies.indexWhere((s) => s.id == id);
    if (idx != -1 && _societies[idx].isJoined) {
      _societies[idx] = _societies[idx].copyWith(isJoined: false);
      // Remove from joined channels
      final channelName = _societies[idx].name;
      _joinedChannels.remove(channelName);
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
