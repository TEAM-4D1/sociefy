import 'package:flutter/foundation.dart';

/// Domain entity representing a single university society.
///
/// Each [Society] is uniquely identified by its [name]. The optional
/// [imageBytes] field holds the raw bytes of a banner image (read from an
/// `XFile` via `readAsBytes()`), so the same value renders on mobile, desktop
/// and web without using `dart:io`. The [members] list is a simple in-memory
/// collection of display names; in the absence of a real backend the model
/// seeds every new society with the same default roster.
@immutable
class Society {
  /// Default roster used when no [members] list is supplied. The current user
  /// always appears first as `'You'` so the detail page can highlight them.
  static const _defaultMembers = <String>[
    'You',
    'Alex T.',
    'Sam R.',
    'Jordan K.',
    'Morgan W.',
  ];

  /// Display name. Doubles as the society's identifier for join/leave checks.
  final String name;

  /// Free-text description shown on cards and the detail page.
  final String description;

  /// Banner image bytes. Null means "no image picked" → render placeholder.
  final Uint8List? imageBytes;

  /// Member display names. Defaults to [_defaultMembers] when omitted.
  final List<String> members;

  const Society({
    required this.name,
    required this.description,
    this.imageBytes,
    this.members = _defaultMembers,
  });
}

/// `ChangeNotifier` acting as the app's [Society] store and membership
/// register.
///
/// Maps to the **MembershipManager** component in the architectural model:
/// it owns the canonical list of societies and the set of joined names, and
/// notifies listeners whenever either changes so `HomePage` and
/// `MessagesPage` stay in sync.
class SocietyNotifier extends ChangeNotifier {
  final List<Society> _societies = [];
  final Set<String> _joinedNames = {};

  /// All societies the user has created (read-only view).
  List<Society> get societies => List.unmodifiable(_societies);

  /// Subset of [societies] the user has joined, in creation order.
  List<Society> get joinedSocieties =>
      _societies.where((s) => _joinedNames.contains(s.name)).toList();

  /// Whether the society with [name] is currently joined.
  bool isJoined(String name) => _joinedNames.contains(name);

  /// Append [society] to the store and notify listeners.
  void add(Society society) {
    _societies.add(society);
    notifyListeners();
  }

  /// Mark the society identified by [name] as joined. Idempotent.
  void join(String name) {
    if (_joinedNames.add(name)) notifyListeners();
  }

  /// Remove the society identified by [name] from the joined set. Idempotent.
  void leave(String name) {
    if (_joinedNames.remove(name)) notifyListeners();
  }
}
