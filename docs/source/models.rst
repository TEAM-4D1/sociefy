Models
======

Sociefy provides four primary data model classes that represent the core entities used throughout the application. These models encapsulate society data, events, announcements, and committee member information.

Society
~~~~~~~

The Society model represents a student society within the university application. A Society groups students around a shared interest, academic subject, or extracurricular activity.

Fields
   - ``id`` (String) - Unique identifier for the society, typically the Firestore document ID used to reference the society record
   - ``name`` (String) - Human-readable name of the society (e.g., "Computer Science Society", "Dance Collective")
   - ``category`` (String) - Broad classification such as "Academic", "Sports", "Arts", or a faculty/department tag for filtering and organizing
   - ``description`` (String) - Short summary of the society's purpose and activities, displayed on profile pages
   - ``committeeMembers`` (List<CommitteeMember>) - List of committee members managing the society; defaults to an empty list

Methods
   copyWith({id, name, category, description, committeeMembers})
      Returns a copy of this Society with the given fields replaced. Useful for immutable updates when only a subset of properties need to change.

      .. code-block:: dart

         Society copyWith({
           String? id,
           String? name,
           String? category,
           String? description,
           List<CommitteeMember>? committeeMembers,
         })

      **Parameters:**
         - ``id`` (String, optional) - New society ID
         - ``name`` (String, optional) - New society name
         - ``category`` (String, optional) - New category
         - ``description`` (String, optional) - New description
         - ``committeeMembers`` (List<CommitteeMember>, optional) - New committee members list

      **Returns:**
         - A new Society instance with specified fields updated

Event
~~~~~

The Event model represents an event associated with a society. Events carry metadata including date, time, venue, and a saved status for users.

Fields
   - ``id`` (String) - Unique identifier for the event
   - ``societyId`` (String) - ID of the society hosting the event
   - ``societyName`` (String) - Display name of the hosting society
   - ``title`` (String) - Event title or name
   - ``description`` (String) - Detailed description of the event
   - ``date`` (DateTime) - Date when the event occurs
   - ``startTime`` (String) - Start time of the event (e.g., "18:00")
   - ``endTime`` (String) - End time of the event (e.g., "20:00")
   - ``venue`` (String) - Location or venue where the event takes place
   - ``isSaved`` (bool) - Whether the current user has saved this event

Methods
   formattedDate
      Returns the event date as a formatted string in DD/MM/YYYY format.

      .. code-block:: dart

         String get formattedDate

      **Returns:**
         - Formatted date string (e.g., "15/05/2026")

Announcement
~~~~~~~~~~~~

The Announcement model represents a society announcement (post) shown in the home feed. Announcements can also carry optional event metadata (date, time, venue) to act as event invitations.

Fields
   - ``id`` (String) - Unique identifier for the announcement
   - ``societyId`` (String) - ID of the society posting the announcement
   - ``title`` (String) - Title of the announcement
   - ``content`` (String) - Main content or body of the announcement
   - ``date`` (DateTime) - Date when the announcement was posted
   - ``imageUrl`` (String, optional) - URL to an optional image associated with the announcement
   - ``time`` (TimeOfDay, optional) - Time component if the announcement represents an event
   - ``venue`` (String, optional) - Venue location if the announcement represents an event
   - ``description`` (String, optional) - Additional description
   - ``likedBy`` (Set<String>) - Set of user IDs who have liked this announcement
   - ``comments`` (List<Comment>) - List of comments on this announcement

Properties
   likeCount
      Returns the number of likes on this announcement.

      .. code-block:: dart

         int get likeCount => likedBy.length

   isLikedByUser(userId)
      Checks if a specific user has liked this announcement.

      .. code-block:: dart

         bool isLikedByUser(String? userId)

      **Parameters:**
         - ``userId`` (String, optional) - The user ID to check

      **Returns:**
         - ``true`` if the user has liked the announcement, ``false`` otherwise

Methods
   toggleLike(userId)
      Toggles the like status for the given user. Adds the user ID to ``likedBy`` if not present, or removes it if already present.

      .. code-block:: dart

         void toggleLike(String userId)

      **Parameters:**
         - ``userId`` (String) - The ID of the user toggling the like

   addComment(author, content)
      Adds a new comment to the announcement.

      .. code-block:: dart

         void addComment(String author, String content)

      **Parameters:**
         - ``author`` (String) - The user name or ID of the comment author
         - ``content`` (String) - The text content of the comment

   dateTimeVenueString
      Returns a formatted string combining date, time, and venue information if all are present.

      .. code-block:: dart

         String? get dateTimeVenueString

      **Returns:**
         - Formatted string (e.g., "2026-05-15, 06:30 PM @ Hall A") if time and venue are set, or null otherwise

Comment
+++++++

The Comment class represents a single user comment on an Announcement. Comments are immutable and typically constructed when comments are loaded from Firestore.

Fields
   - ``id`` (String) - Unique identifier for the comment
   - ``author`` (String) - Name or ID of the comment author
   - ``content`` (String) - Text content of the comment
   - ``dateTime`` (DateTime) - Timestamp when the comment was created

Factory Methods
   Comment.fromFirestore(data, docId)
      Creates a Comment instance from Firestore document data. Handles multiple timestamp formats (Firestore Timestamp, DateTime, milliseconds since epoch).

      .. code-block:: dart

         factory Comment.fromFirestore(Map<String, dynamic> data, String docId)

      **Parameters:**
         - ``data`` (Map<String, dynamic>) - Firestore document data containing author, content, and dateTime fields
         - ``docId`` (String) - The Firestore document ID

      **Returns:**
         - A new Comment instance with parsed data

      **Behavior:**
         - If ``data['author']`` is missing, defaults to ``'Unknown'``
         - If ``data['content']`` is missing, defaults to empty string
         - Parses ``data['dateTime']`` from Firestore Timestamp, DateTime, or milliseconds format
         - Defaults to ``DateTime.now()`` if dateTime format is unrecognized

CommitteeMember
~~~~~~~~~~~~~~~

The CommitteeMember model represents a member of a society's committee. Committee members hold leadership positions and manage society activities.

Fields
   - ``name`` (String) - Full name of the committee member
   - ``role`` (String) - Position or role within the committee (e.g., "President", "Treasurer")
   - ``email`` (String) - Email address of the committee member

Methods
   fromMap(map)
      Factory constructor that creates a CommitteeMember instance from a map (e.g., Firestore data).

      .. code-block:: dart

         factory CommitteeMember.fromMap(Map<String, dynamic> map)

      **Parameters:**
         - ``map`` (Map<String, dynamic>) - Map containing name, role, and email keys

      **Returns:**
         - A new CommitteeMember instance
         - Missing fields default to empty strings

   toMap()
      Converts the CommitteeMember instance to a map representation suitable for Firestore storage.

      .. code-block:: dart

         Map<String, dynamic> toMap()

      **Returns:**
         - A map with keys ``'name'``, ``'role'``, and ``'email'``
