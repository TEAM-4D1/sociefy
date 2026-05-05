Services
========

Sociefy provides several service classes to handle authentication, society management, and real-time messaging operations. These services act as abstractions over Firebase APIs and provide error handling and data transformation.

AuthService
~~~~~~~~~~~

The AuthService class handles all user authentication operations including sign in, registration, and sign out.

signIn(email, password)
   Signs in a user with the provided email and password.

.. code-block:: dart

   Future<UserCredential?> signIn(String email, String password) async

**Parameters:**
   - ``email`` (String) - The user's email address
   - ``password`` (String) - The user's password

**Returns:**
   - ``UserCredential?`` - Firebase UserCredential object if successful, or null on error

**Error Behaviour:**
   Catches any exception from Firebase Auth, logs it using ``debugPrint('signIn error: $e')``, and returns null. Does not rethrow the exception.

register(email, password)
   Registers a new user account with the provided email and password.

.. code-block:: dart

   Future<UserCredential?> register(String email, String password) async

**Parameters:**
   - ``email`` (String) - The email address for the new account
   - ``password`` (String) - The password for the new account

**Returns:**
   - ``UserCredential?`` - Firebase UserCredential object if successful, or null on error

**Error Behaviour:**
   Catches any exception from Firebase Auth, logs it using ``debugPrint('register error: $e')``, and returns null. Sets ``lastError`` to null before attempting registration. Does not rethrow the exception.

signOut()
   Signs out the currently authenticated user from Firebase.

.. code-block:: dart

   Future<void> signOut() async

**Parameters:**
   None

**Returns:**
   - ``Future<void>`` - Completes when sign out is successful

**Error Behaviour:**
   Allows exceptions to propagate. Does not catch or log errors.

currentUser
   Gets the currently authenticated user from Firebase Auth.

.. code-block:: dart

   User? get currentUser

**Returns:**
   - ``User?`` - Firebase User object if a user is signed in, or null if not authenticated

**Error Behaviour:**
   Does not throw exceptions; returns null if no user is authenticated.

SocietyService
~~~~~~~~~~~~~~

The SocietyService class handles all society-related operations including joining/leaving societies and retrieving society membership data from Firestore.

joinSociety(userId, societyId)
   Adds a user to a society's membership list in Firestore.

.. code-block:: dart

   Future<void> joinSociety(String userId, String societyId) async

**Parameters:**
   - ``userId`` (String) - The ID of the user joining
   - ``societyId`` (String) - The ID of the society

**Firestore Operation:**
   Writes a document to the ``memberships`` collection with ID ``{userId}_{societyId}`` containing:
   - ``userId`` - User identifier
   - ``societyId`` - Society identifier
   - ``joinedAt`` - Server timestamp of when the join occurred

**Error Behaviour:**
   Catches exceptions, logs them using ``debugPrint('joinSociety error: $e')``, and rethrows the exception. Caller must handle the exception.

leaveSociety(userId, societyId)
   Removes a user from a society's membership list in Firestore.

.. code-block:: dart

   Future<void> leaveSociety(String userId, String societyId) async

**Parameters:**
   - ``userId`` (String) - The ID of the user leaving
   - ``societyId`` (String) - The ID of the society

**Firestore Operation:**
   Deletes the document from the ``memberships`` collection with ID ``{userId}_{societyId}``.

**Error Behaviour:**
   Catches exceptions, logs them using ``debugPrint('leaveSociety error: $e')``, and rethrows the exception. Caller must handle the exception.

getJoinedSocietyIds(userId)
   Retrieves all society IDs that a user is a member of.

.. code-block:: dart

   Future<List<String>> getJoinedSocietyIds(String userId) async

**Parameters:**
   - ``userId`` (String) - The ID of the user

**Returns:**
   - ``List<String>`` - List of society IDs the user has joined, or empty list on error

**Firestore Operation:**
   Queries the ``memberships`` collection where ``userId`` equals the provided user ID, extracts the ``societyId`` field from each document.

**Error Behaviour:**
   Catches exceptions, logs them using ``debugPrint('getJoinedSocietyIds error: $e')``, and returns an empty list instead of throwing.

MessageService
~~~~~~~~~~~~~~

The MessageService class manages real-time messaging and user channel subscriptions using Firestore and Firebase Cloud Messaging (FCM).

userChannelsStream(userId)
   Returns a stream of society channel IDs that a user is subscribed to.

.. code-block:: dart

   Stream<List<String>> userChannelsStream(String userId)

**Parameters:**
   - ``userId`` (String) - The ID of the user

**Returns:**
   - ``Stream<List<String>>`` - A broadcast stream emitting the list of joined channel IDs

**Behaviour:**
   Creates a broadcast stream controller for the user if one doesn't exist, immediately emits the current list of joined channels, and continues emitting updates when the user joins/leaves societies.

getJoinedChannels(userId)
   Gets the current list of society channels a user is joined to (synchronous).

.. code-block:: dart

   List<String> getJoinedChannels(String userId)

**Parameters:**
   - ``userId`` (String) - The ID of the user

**Returns:**
   - ``List<String>`` - Unmodifiable list of currently joined channel IDs

**Behaviour:**
   Returns an empty list if the user has no joined channels. The returned list cannot be modified.

joinSociety(userId, societyId)
   Adds a user to a society channel and subscribes to FCM notifications.

.. code-block:: dart

   Future<void> joinSociety(String userId, String societyId) async

**Parameters:**
   - ``userId`` (String) - The ID of the user joining
   - ``societyId`` (String) - The ID of the society (channel)

**Side Effects:**
   - Writes membership record to Firestore ``memberships`` collection
   - Subscribes the user's device to FCM topic ``society_{societyId}``
   - Updates local state in ``_userChannels`` map
   - Emits updated channel list to the user's stream controller

**Firestore Operation:**
   Writes to ``memberships`` collection with document ID ``{userId}_{societyId}`` containing user ID, society ID, and join timestamp.

**Error Behaviour:**
   Allows exceptions to propagate. Caller must handle failures.

leaveSociety(userId, societyId)
   Removes a user from a society channel.

.. code-block:: dart

   Future<void> leaveSociety(String userId, String societyId) async

**Parameters:**
   - ``userId`` (String) - The ID of the user leaving
   - ``societyId`` (String) - The ID of the society (channel)

**Side Effects:**
   - Removes the channel from the user's local channel set
   - Emits updated channel list to the user's stream controller

**Behaviour:**
   Only updates local state; does not modify Firestore or FCM subscriptions. Intended to be implemented as a counterpart to ``joinSociety``.

**Error Behaviour:**
   Does not throw exceptions; silently returns if the user is not in the channel.
