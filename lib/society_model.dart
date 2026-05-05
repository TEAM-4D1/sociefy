import 'package:flutter/foundation.dart';

class Society {
  static const _defaultMembers = [
    'You',
    'Alex T.',
    'Sam R.',
    'Jordan K.',
    'Morgan W.',
  ];

  final String name;
  final String description;
  final String? imagePath;
  final List<String> members;

  Society({
    required this.name,
    required this.description,
    this.imagePath,
    List<String>? members,
  }) : members = members ?? _defaultMembers;
}

class SocietyNotifier extends ChangeNotifier {
  final List<Society> _societies = [];
  final Set<String> _joinedNames = {};

  List<Society> get societies => List.unmodifiable(_societies);

  List<Society> get joinedSocieties =>
      _societies.where((s) => _joinedNames.contains(s.name)).toList();

  bool isJoined(String name) => _joinedNames.contains(name);

  void add(Society society) {
    _societies.add(society);
    notifyListeners();
  }

  void join(String name) {
    _joinedNames.add(name);
    notifyListeners();
  }

  void leave(String name) {
    _joinedNames.remove(name);
    notifyListeners();
  }
}
