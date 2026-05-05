State Management
================

Sociefy uses the `Provider <https://pub.dev/packages/provider>`_ package for state management with a single ``AppState`` ChangeNotifier. This centralized approach manages authentication state, user data, and all society-related information throughout the application lifecycle.

Public Methods
--------------

login(userId, isAdmin)
   Sets the current user's ID and admin status after authentication. Parameters: ``userId`` (optional String), ``isAdmin`` (bool, default false). Side effects: Updates ``this.userId`` and ``this.isAdmin``, calls ``notifyListeners()``, triggers ``loadSocieties()``, ``loadEvents()``, and ``loadAnnouncements()``. For non-guest users, also loads joined societies and saved events.

logout()
   Clears all user data and resets the application state. No parameters. Side effects: Sets ``userId`` to null, clears ``isAdmin``, clears all ID lists (``_joinedSocietyIds``, ``_savedEventIds``), clears all cached data lists (``_societies``, ``_mySocieties``, ``_events``, ``_announcements``), cancels the announcements stream subscription, and calls ``notifyListeners()``.

setAdminPending(value)
   Sets the pending admin login flag for committee/admin authentication. Parameter: ``value`` (bool). Side effects: Updates ``_pendingAdminLogin`` flag without notifying listeners, allowing the flag to be set before Firebase auth completes.

loadSocieties()
   Fetches all available societies from Firestore and caches them locally. No parameters. Side effects: Populates ``_societies`` list, calls ``notifyListeners()``. Only fetches once per session (skips if already loaded).

loadEvents()
   Fetches upcoming events from Firestore with a 100-event limit. No parameters. Side effects: Populates ``_events`` list, calls ``notifyListeners()``. Only fetches once per session (skips if already loaded).

loadAnnouncements()
   Sets up a real-time stream listener for announcements from Firestore. No parameters. Side effects: Establishes a Firestore stream subscription in ``_announcementsSubscription``, populates ``_announcements`` list, automatically updates when new announcements are added.

loadJoinedSocieties(userId)
   Loads the list of society IDs the user has joined. Parameter: ``userId`` (String). Side effects: Populates ``_joinedSocietyIds`` list, calls ``notifyListeners()``.

fetchMySocieties(userId)
   Fetches full Society objects for all societies the current user is a member of. Parameter: ``userId`` (String). Side effects: Populates ``_mySocieties`` list with complete society data, calls ``notifyListeners()``. Uses memberships collection to determine user's societies.

refreshFeed()
   Clears and reloads all cached data (societies, events, announcements). No parameters. Side effects: Clears ``_societies``, ``_events``, ``_announcements`` lists, reloads data in parallel using ``Future.wait()``, calls ``notifyListeners()``.

joinSociety(id)
   Adds a society to the user's joined list and persists to Firestore. Parameter: ``id`` (String, society ID). Side effects: Adds to ``_joinedSocietyIds``, calls ``notifyListeners()``. For authenticated users, writes membership record to Firestore via ``SocietyService``.

leaveSociety(id)
   Removes a society from the user's joined list and updates Firestore. Parameter: ``id`` (String, society ID). Side effects: Removes from ``_joinedSocietyIds``, calls ``notifyListeners()``. For authenticated users, deletes membership record from Firestore via ``SocietyService``.

createSociety(name, category, description)
   Creates a new society and writes it to Firestore. Parameters: ``name`` (String), ``category`` (String), ``description`` (String). Side effects: Generates unique ID, adds to ``_societies`` list, calls ``notifyListeners()``, writes document to Firestore 'societies' collection.

createAnnouncement(societyId, title, content, imageUrl)
   Creates a new announcement for a society. Parameters: ``societyId`` (String), ``title`` (String), ``content`` (String), ``imageUrl`` (optional String). Side effects: Inserts at beginning of ``_announcements`` list, calls ``notifyListeners()``, writes announcement to Firestore with server timestamp.

createEvent(societyId, title, description, date, startTime, endTime, venue)
   Creates a new event for a society. Parameters: ``societyId`` (String), ``title`` (String), ``description`` (String), ``date`` (DateTime), ``startTime`` (String), ``endTime`` (String), ``venue`` (String). Side effects: Generates unique ID, inserts at beginning of ``_events`` list, calls ``notifyListeners()``, writes event document to Firestore.

saveEvent(id)
   Adds an event to the user's saved events list. Parameter: ``id`` (String, event ID). Side effects: Adds to ``_savedEventIds``, calls ``notifyListeners()``. For authenticated users, calls ``persistSaveEvent()`` to write to Firestore.

unsaveEvent(id)
   Removes an event from the user's saved events list. Parameter: ``id`` (String, event ID). Side effects: Removes from ``_savedEventIds``, calls ``notifyListeners()``. For authenticated users, calls ``persistUnsaveEvent()`` to delete from Firestore.

loadSavedEvents(userId)
   Loads saved event IDs from Firestore for a user. Parameter: ``userId`` (String). Side effects: Populates ``_savedEventIds`` list from Firestore 'savedEvents' collection, calls ``notifyListeners()``.

persistSaveEvent(userId, eventId)
   Writes a saved event record to Firestore. Parameters: ``userId`` (String), ``eventId`` (String). Side effects: Creates document in 'savedEvents' collection with server timestamp. Throws on error.

persistUnsaveEvent(userId, eventId)
   Deletes a saved event record from Firestore. Parameters: ``userId`` (String), ``eventId`` (String). Side effects: Deletes document from 'savedEvents' collection. Throws on error.

Getters
-------

isAuthenticated
   Returns true if a user is currently logged in (userId is not null). Returns: bool.

isGuest
   Returns true if the current user is a guest (userId starts with 'guest'). Returns: bool.

isAdmin
   Returns the admin status of the current user. Returns: bool.

isPendingAdminLogin
   Returns the pending admin login flag status. Returns: bool.

societies
   Returns the complete list of all available societies. Returns: List<Society>.

mySocieties
   Returns societies the current user is a member of. Returns: List<Society>.

announcements
   Returns the current list of announcements from all societies. Returns: List<Announcement>.

joinedSocieties
   Returns filtered list of societies the user has joined (from _societies). Returns: List<Society>.

availableSocieties
   Returns filtered list of societies the user has not joined (from _societies). Returns: List<Society>.

events
   Returns the complete list of all upcoming events. Returns: List<Event>.

savedEvents
   Returns filtered list of events the user has bookmarked. Returns: List<Event>.
