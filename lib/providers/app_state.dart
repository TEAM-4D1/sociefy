import '../models/society.dart';
import '../models/committee_member.dart';
import '../models/event.dart';
import '../models/announcement.dart';
import '../services/society_service.dart';
import '../data/sample_events.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

/// Centralised application state shared across the widget tree via
/// [provider].
///
/// Holds the authenticated user, joined societies, saved events, cached
/// society/event/announcement lists, and exposes mutation methods that
/// update local state synchronously and persist to Firestore in the
/// background.
///
/// Construct with `AppState(skipFirebase: true)` in tests so the auth
/// listener is not registered.
class AppState extends ChangeNotifier {
  static const String _committeeAdminEmail = 'jburfoot12@gmail.com';

  String? userId;
  bool isAdmin = false;
  bool _pendingAdminLogin = false;

  StreamSubscription<QuerySnapshot>? _announcementsSubscription;

  /// Whether to skip Firebase initialization (used for testing).
  final bool _skipFirebase;

  /// Firestore instance used for all reads/writes. Resolved lazily so
  /// constructing an `AppState(skipFirebase: true)` in unit tests does not
  /// touch `FirebaseFirestore.instance`. Inject a `FakeFirebaseFirestore`
  /// via the constructor to override.
  final FirebaseFirestore? _firestoreOverride;
  FirebaseFirestore get _firestore =>
      _firestoreOverride ?? FirebaseFirestore.instance;

  AppState({
    bool skipFirebase = false,
    FirebaseFirestore? firestore,
    SocietyService? societyService,
  }) : _skipFirebase = skipFirebase,
       _firestoreOverride = firestore,
       _societyService =
           societyService ?? SocietyService(firestore: firestore) {
    if (!_skipFirebase) {
      _initializeFirebaseListener();
    }
  }

  final SocietyService _societyService;

  /// Initialize the Firebase auth listener (called after construction in production).
  void _initializeFirebaseListener() {
    try {
      FirebaseAuth.instance.authStateChanges().listen((user) {
        if (user != null) {
          final normalizedEmail = user.email?.trim().toLowerCase();
          final isCommitteeAdmin = normalizedEmail == _committeeAdminEmail;
          login(
            userId: user.uid,
            isAdmin: _pendingAdminLogin || isCommitteeAdmin,
          );
          _pendingAdminLogin = false;
        } else {
          _pendingAdminLogin = false;
          if (!isGuest) {
            logout();
          }
        }
      });
    } catch (e) {
      debugPrint('Firebase not initialized, auth listener skipped: $e');
    }
  }

  /// Sets the pending admin login flag for committee/admin authentication.
  /// [value] The admin pending flag value.
  void setAdminPending(bool value) {
    _pendingAdminLogin = value;
  }

  final List<String> _joinedSocietyIds = [];
  final List<String> _savedEventIds = [];

  int _eventIdCounter = 0; // Counter to ensure unique event IDs

  List<Society> _societies = [];

  List<Society> _mySocieties = [];

  List<Event> _events = [];

  List<Announcement> _announcements = [];

  /// Fetches all available societies from the Firestore 'societies' collection and caches them locally.
  /// Calls [notifyListeners] after loading. Only fetches once per session.
  Future<void> loadSocieties({bool forceReload = false}) async {
    if (_societies.isNotEmpty && !forceReload) return;
    final querySnapshot = await _firestore.collection('societies').get();
    _societies = querySnapshot.docs.map((doc) {
      final data = doc.data();

      // Parse committeeMembers from Firestore data
      List<CommitteeMember> committeeMembers = [];
      final membersData = data['committeeMembers'] as List<dynamic>?;
      if (membersData != null) {
        committeeMembers = membersData.map((memberMap) {
          final map = memberMap as Map<String, dynamic>;
          return CommitteeMember(
            name: map['name'] ?? '',
            role: map['role'] ?? '',
            email: map['email'] ?? '',
          );
        }).toList();
      }

      return Society(
        id: doc.id,
        name: data['name'] ?? 'Unknown Society',
        category: data['category'] ?? 'General',
        description: data['description'] ?? '',
        committeeMembers: committeeMembers,
      );
    }).toList();
    notifyListeners();
  }

  /// Fetches upcoming events from the Firestore 'events' collection with a 100-event limit and caches them locally.
  /// Calls [notifyListeners] after loading. Only fetches once per session unless [forceReload] is true.
  Future<void> loadEvents({bool forceReload = false}) async {
    if (_events.isNotEmpty && !forceReload) return;
    try {
      final querySnapshot = await _firestore
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

      // Append sample events (non-duplicated) so sample data appears
      // for all users (guest or authenticated). This prevents the
      // UI showing an empty list for some accounts while still keeping
      // real Firestore events when present.
      final existingIds = _events.map((e) => e.id).toSet();
      for (final se in sampleEvents) {
        if (!existingIds.contains(se.id)) {
          _events.add(se);
        }
      }
      debugPrint('Loaded ${_events.length} events (including sample events)');
    } catch (e) {
      debugPrint('loadEvents Firestore error: $e, loading sample events');
      // Load sample events as fallback if Firestore fails
      _events = List.from(sampleEvents);
    }
    notifyListeners();
  }

  /// Sets up a real-time stream listener for announcements from the Firestore 'announcements' collection.
  /// Also fetches likes and comments for each announcement in parallel without blocking. Calls [notifyListeners] on stream update.
  void loadAnnouncements() {
    // Cancel any existing subscription to prevent duplicates
    _announcementsSubscription?.cancel();
    _announcementsSubscription = null;

    // Set up new snapshots listener
    _announcementsSubscription = _firestore
        .collection('announcements')
        .orderBy('date', descending: true)
        .limit(50)
        .snapshots()
        .listen((querySnapshot) async {
          // Build a map of existing announcements to preserve likes/comments
          final existingMap = {
            for (final announcement in _announcements) 
              announcement.id: announcement,
          };

          // Build new announcements list from snapshot
          _announcements = querySnapshot.docs.map((doc) {
            final data = doc.data();
            final newAnnouncement = Announcement(
              // ...
            );
            
            // Preserve likes and comments from existing announcement if it exists
            if (existingMap.containsKey(newAnnouncement.id)) {
              final existing = existingMap[newAnnouncement.id]!;
              newAnnouncement.likedBy.addAll(existing.likedBy);
              newAnnouncement.comments.addAll(existing.comments);
            }
            
            return newAnnouncement;
          }).toList();

          notifyListeners();

          // Launch likes/comments loads in parallel for all announcements
          await Future.wait([
            for (final announcement in _announcements) ...[
              _loadLikesForAnnouncement(announcement),
              _loadCommentsForAnnouncement(announcement),
            ]
          ]);
        });
  }

  /// Loads all likes for a specific announcement from Firestore.
  Future<void> _loadLikesForAnnouncement(Announcement announcement) async {
    try {
      final likesSnapshot = await _firestore
          .collection('announcements')
          .doc(announcement.id)
          .collection('likes')
          .get();

      announcement.likedBy.clear();
      for (final doc in likesSnapshot.docs) {
        final userId = doc['userId'] as String?;
        if (userId != null) {
          announcement.likedBy.add(userId);
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading likes for announcement ${announcement.id}: $e');
    }
  }

  /// Loads all comments for a specific announcement from Firestore.
  Future<void> _loadCommentsForAnnouncement(Announcement announcement) async {
    try {
      final commentsSnapshot = await _firestore
          .collection('announcements')
          .doc(announcement.id)
          .collection('comments')
          .orderBy('dateTime', descending: false)
          .get();

      announcement.comments.clear();
      for (final doc in commentsSnapshot.docs) {
        final comment = Comment.fromFirestore(doc.data(), doc.id);
        announcement.comments.add(comment);
      }
      notifyListeners();
    } catch (e) {
      debugPrint(
        'Error loading comments for announcement ${announcement.id}: $e',
      );
    }
  }

  /// Returns true if a user is currently logged in (userId is not null and not empty).
  bool get isAuthenticated => userId != null && userId!.isNotEmpty;

  /// Returns true if the current user is a guest (userId equals exactly 'guest').
  bool get isGuest => userId != null && userId == 'guest';

  /// Returns the pending admin login flag status.
  bool get isPendingAdminLogin => _pendingAdminLogin;

  /// Loads the list of society IDs that the user with [userId] has joined from the Firestore 'memberships' collection.
  /// [userId] The ID of the user to load memberships for.
  /// Calls [notifyListeners] after loading.
  Future<void> loadJoinedSocieties(String userId) async {
    try {
      final ids = await _societyService.getJoinedSocietyIds(userId);
      _joinedSocietyIds.clear();
      _joinedSocietyIds.addAll(ids);
      notifyListeners();
    } catch (e) {
      debugPrint('loadJoinedSocieties error: $e');
    }
  }

  /// Fetches full Society objects for all societies the user is a member of from the Firestore 'memberships' collection.
  /// [userId] The ID of the user to fetch societies for.
  /// Populates [_mySocieties] with complete society data and calls [notifyListeners] after loading.
  Future<void> fetchMySocieties(String userId) async {
    try {
      final membershipSnapshot = await _firestore
          .collection('memberships')
          .where('userId', isEqualTo: userId)
          .get();

      // Collect all societyIds from memberships
      final societyIds = <String>[];
      for (final mem in membershipSnapshot.docs) {
        final sid = mem['societyId'] as String?;
        if (sid != null) {
          societyIds.add(sid);
        }
      }

      // Return early if no societies found
      if (societyIds.isEmpty) {
        _mySocieties = [];
        notifyListeners();
        return;
      }

      // Fetch all societies in a single query using whereIn
      final societiesSnapshot = await _firestore
          .collection('societies')
          .where(FieldPath.documentId, whereIn: societyIds)
          .get();

      final List<Society> results = [];
      for (final doc in societiesSnapshot.docs) {
        final data = doc.data();
        results.add(
          Society(
            id: doc.id,
            name: data['name'] ?? 'Unknown Society',
            category: data['category'] ?? 'General',
            description: data['description'] ?? '',
          ),
        );
      }

      _mySocieties = results;
      notifyListeners();
    } catch (e) {
      debugPrint('fetchMySocieties error: $e');
    }
  }

  /// Sets the current user's ID and admin status and triggers data loading.
  /// [userId] The ID of the user to log in (optional, defaults to existing userId).
  /// [isAdmin] Whether the user has admin privileges (defaults to false).
  /// Calls [notifyListeners], triggers [loadSocieties], [loadEvents], [loadAnnouncements]. For non-guest users, also loads joined societies and saved events.
  Future<void> login({String? userId, bool isAdmin = false}) async {
    this.userId = userId ?? this.userId;
    this.isAdmin = isAdmin;
    notifyListeners();

    // Fire all data loads without awaiting
    loadSocieties();
    loadEvents();
    loadAnnouncements();

    if (!isGuest) {
      loadJoinedSocieties(this.userId!);
      loadSavedEvents(this.userId!);
    }
  }

  /// Clears all cached data and reloads societies and events in parallel.
  /// Calls [notifyListeners] after reloading. Streams are set up separately via [loadAnnouncements].
  Future<void> refreshFeed() async {
    // Clear all data lists
    _societies.clear();
    _events.clear();
    _announcements.clear();

    // Reload loadSocieties and loadEvents in parallel with forceReload: true to fetch fresh data
    await Future.wait<void>([
      loadSocieties(forceReload: true),
      loadEvents(forceReload: true),
    ]);

    // loadAnnouncements is stream-based, just call it
    loadAnnouncements();
  }

  /// Clears all user data and resets the application state.
  /// Clears all ID lists and cached data, cancels the announcements stream subscription, and calls [notifyListeners].
  void logout() {
    userId = null;
    isAdmin = false;
    _pendingAdminLogin = false;
    _joinedSocietyIds.clear();
    _savedEventIds.clear();

    // Clear all cached data so fresh user gets a clean slate
    _societies.clear();
    _mySocieties.clear();
    _events.clear();
    _announcements.clear();

    // Cancel announcements stream subscription
    _announcementsSubscription?.cancel();
    _announcementsSubscription = null;

    notifyListeners();
  }

  @override
  void dispose() {
    _announcementsSubscription?.cancel();
    super.dispose();
  }

  /// Returns the complete list of all available societies.
  List<Society> get societies => _societies;

  /// Returns societies the current user is a member of.
  List<Society> get mySocieties => _mySocieties;

  /// Returns the current list of announcements from all societies.
  List<Announcement> get announcements => _announcements;

  /// Checks if the user has joined the society with the given [id].
  bool isJoined(String id) => _joinedSocietyIds.contains(id);

  /// Returns a filtered list of societies the user has joined.
  List<Society> get joinedSocieties =>
      _societies.where((s) => _joinedSocietyIds.contains(s.id)).toList();

  /// Returns a filtered list of societies the user has not joined.
  List<Society> get availableSocieties =>
      _societies.where((s) => !_joinedSocietyIds.contains(s.id)).toList();

  /// Adds a society to the user's joined list and persists the membership to Firestore.
  /// [id] The ID of the society to join.
  /// Calls [notifyListeners]. For authenticated users, writes to the Firestore 'memberships' collection via [SocietyService].
  Future<void> joinSociety(String id) async {
    if (!_joinedSocietyIds.contains(id)) {
      _joinedSocietyIds.add(id);
      notifyListeners();
    }
    if (!isGuest) {
      try {
        await _societyService.joinSociety(userId!, id);
      } catch (e) {
        debugPrint('joinSociety Firestore error: $e');
      }
    }
  }

  /// Removes a society from the user's joined list and updates Firestore.
  /// [id] The ID of the society to leave.
  /// Calls [notifyListeners]. For authenticated users, deletes from the Firestore 'memberships' collection via [SocietyService].
  Future<void> leaveSociety(String id) async {
    _joinedSocietyIds.remove(id);
    notifyListeners();
    if (!isGuest) {
      try {
        await _societyService.leaveSociety(userId!, id);
      } catch (e) {
        debugPrint('leaveSociety Firestore error: $e');
      }
    }
  }

  /// Creates a new society with the given details and writes it to Firestore.
  /// [name] The name of the society.
  /// [category] The category of the society.
  /// [description] A description of the society.
  /// Generates a unique ID, adds to [_societies], calls [notifyListeners], and writes to Firestore 'societies' collection.
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
      _firestore
          .collection('societies')
          .doc(id)
          .set({'name': name, 'category': category, 'description': description})
          .then((_) {
            // Force reload societies after successful Firestore write to ensure consistency
            loadSocieties(forceReload: true);
          });
    } catch (e) {
      debugPrint('createSociety Firestore error: $e');
    }
  }

  /// Creates a new announcement for a society and writes it to Firestore.
  /// [societyId] The ID of the society posting the announcement.
  /// [title] The title of the announcement.
  /// [content] The body content of the announcement.
  /// [imageUrl] An optional image URL for the announcement.
  /// Inserts at beginning of [_announcements], calls [notifyListeners], and writes to Firestore 'announcements' collection with server timestamp.
  Future<void> createAnnouncement({
    required String societyId,
    required String title,
    required String content,
    String? imageUrl,
    String? venue,
    String? startTime,
    String? endTime,
    DateTime? date,
  }) async {
    final announcementDate = date ?? DateTime.now();
    _announcements.insert(
      0,
      Announcement(
        id: 'a-${DateTime.now().millisecondsSinceEpoch}',
        societyId: societyId,
        title: title,
        content: content,
        date: announcementDate,
        imageUrl: imageUrl,
        time: null,
        venue: venue ?? '',
        description: '',
      ),
    );
    notifyListeners();

    if (!_skipFirebase || _firestoreOverride != null) {
      try {
        await _firestore.collection('announcements').add({
          'societyId': societyId,
          'title': title,
          'content': content,
          'date': FieldValue.serverTimestamp(),
          if (imageUrl != null) 'imageUrl': imageUrl,
          if (venue != null) 'venue': venue,
          if (startTime != null) 'startTime': startTime,
          if (endTime != null) 'endTime': endTime,
        });
      } catch (e) {
        debugPrint('createAnnouncement Firestore error: $e');
        rethrow;
      }
    }
  }

  /// Creates a new event for a society and writes it to Firestore.
  /// [societyId] The ID of the society hosting the event.
  /// [title] The title of the event.
  /// [description] A detailed description of the event.
  /// [date] The date the event occurs.
  /// [startTime] The start time of the event.
  /// [endTime] The end time of the event.
  /// [venue] The location where the event takes place.
  /// Generates unique ID, inserts at beginning of [_events], calls [notifyListeners], and writes to Firestore 'events' collection.
  void createEvent({
    required String societyId,
    required String title,
    required String description,
    required DateTime date,
    required String startTime,
    required String endTime,
    required String venue,
  }) {
    final eventId =
        'e-${DateTime.now().microsecondsSinceEpoch}-${_eventIdCounter++}';
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
      _firestore.collection('events').doc(eventId).set({
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

  /// Helper method that returns the name of a society by its [id].
  /// Returns 'Society' if the ID is not found.
  String societyNameById(String id) {
    for (final society in _societies) {
      if (society.id == id) {
        return society.name;
      }
    }
    return 'Society';
  }

  /// Returns the complete list of all upcoming events.
  List<Event> get events => _events;

  /// Checks if the event with the given [id] has been saved by the user.
  bool isEventSaved(String id) => _savedEventIds.contains(id);

  /// Returns a filtered list of events the user has saved/bookmarked.
  List<Event> get savedEvents =>
      _events.where((e) => _savedEventIds.contains(e.id)).toList();

  /// Returns a filtered list of events for a specific society.
  /// [societyId] The ID of the society to filter events for.
  List<Event> eventsForSociety(String societyId) =>
      // Some sample events may use a placeholder societyId (e.g., 'soc_1').
      // Match by `societyId` first, and also fall back to matching by
      // society name to ensure sample events appear for the correct
      // society details screen when Firestore IDs don't line up.
      _events.where((e) {
        if (e.societyId == societyId) return true;
        final expectedName = societyNameById(societyId).toLowerCase();
        return e.societyName.toLowerCase() == expectedName;
      }).toList();

  /// Adds an event to the user's saved events list and persists to Firestore.
  /// [id] The ID of the event to save.
  /// Calls [notifyListeners]. For authenticated users, writes to the Firestore 'savedEvents' collection via [persistSaveEvent].
  void saveEvent(String id) {
    if (!_savedEventIds.contains(id)) {
      _savedEventIds.add(id);
      notifyListeners();
    }
    if (!isGuest) {
      try {
        persistSaveEvent(userId!, id);
      } catch (e) {
        debugPrint('saveEvent Firestore error: $e');
      }
    }
  }

  /// Removes an event from the user's saved events list and updates Firestore.
  /// [id] The ID of the event to unsave.
  /// Calls [notifyListeners]. For authenticated users, deletes from the Firestore 'savedEvents' collection via [persistUnsaveEvent].
  void unsaveEvent(String id) {
    _savedEventIds.remove(id);
    notifyListeners();
    if (!isGuest) {
      try {
        persistUnsaveEvent(userId!, id);
      } catch (e) {
        debugPrint('unsaveEvent Firestore error: $e');
      }
    }
  }

  /// Writes a saved event record to the Firestore 'savedEvents' collection for the given user.
  /// [userId] The ID of the user saving the event.
  /// [eventId] The ID of the event being saved.
  /// Creates a document with userId, eventId, and server timestamp. Throws on error.
  Future<void> persistSaveEvent(String userId, String eventId) async {
    try {
      await _firestore.collection('savedEvents').doc('${userId}_$eventId').set({
        'eventId': eventId,
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('persistSaveEvent error: $e');
      rethrow;
    }
  }

  /// Deletes a saved event record from the Firestore 'savedEvents' collection.
  /// [userId] The ID of the user unsaving the event.
  /// [eventId] The ID of the event being unsaved.
  /// Deletes the document from 'savedEvents' collection. Throws on error.
  Future<void> persistUnsaveEvent(String userId, String eventId) async {
    try {
      await _firestore
          .collection('savedEvents')
          .doc('${userId}_$eventId')
          .delete();
    } catch (e) {
      debugPrint('persistUnsaveEvent error: $e');
      rethrow;
    }
  }

  /// Loads saved event IDs from the Firestore 'savedEvents' collection for a user.
  /// [userId] The ID of the user to load saved events for.
  /// Populates [_savedEventIds] list and calls [notifyListeners].
  Future<void> loadSavedEvents(String userId) async {
    try {
      final snapshot = await _firestore
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
