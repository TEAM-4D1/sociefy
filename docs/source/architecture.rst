System Architecture 
===================

The Sociefy application utilizes a 3-Tier Layered Architecture, designed to ensure a strict separation of concerns between the user interface, business logic, and data storage.
This model guarantees that the client application never interacts directly with the database, enhancing security and maintainability.

Architecture Overview
=====================

Sociefy is built on a **Flutter + Firebase** architecture that combines:

* **Frontend:** Flutter provides a cross-platform mobile interface with responsive widgets
* **Backend:** Firebase Firestore serves as the real-time database
* **Authentication:** Firebase Authentication manages user credentials and sessions
* **Storage:** Firebase Storage handles file uploads (profile pictures, event images)
* **Notifications:** Firebase Cloud Messaging (FCM) for push notifications

This architecture enables real-time synchronization of data across all clients while maintaining a serverless infrastructure that scales automatically.

Presentation Layer (Client-Side)
================================

The top layer consists of the user-facing mobile interface. It is responsible for capturing user inputs and displaying data returned from the server. Key views include:

* **Authentication UI:** Handles login, registration, and committee sign-in
* **Society Browser UI & Details:** Allows users to find societies and view information
* **My Societies & Updates UI:** A personalized feed of announcements for the groups a user has joined
* **Event Discovery & Detail:** Browse and interact with society events
* **Messages & Chat:** Real-time group messaging for society members
* **Profile & Settings:** User profile management and preferences

Business Logic Layer (AppState)
===============================

The middle layer in Sociefy is implemented as the **AppState** ChangeNotifier, which acts as a centralized state management solution. It processes requests from the UI layer before communicating with Firebase. Key responsibilities include:

* **AuthManager:** Validates credentials via Firebase Authentication and manages session state
* **SocietyManager:** Handles retrieval of society lists, filtering, and user memberships
* **EventManager:** Manages event creation, queries, and user RSVPs/saves
* **AnnouncementManager:** Handles announcements with real-time stream subscriptions
* **MessagesManager:** Manages real-time chat messages with Firestore listeners
* **UserManager:** Manages joined societies, saved events, and user profiles

Data Persistence Layer 
======================

The bottom layer handles all data storage through **Firebase Firestore**, a NoSQL cloud database. All data access is funneled through AppState methods, preventing inconsistent states and providing a single source of truth.

Library Folder Structure
========================

.. code-block:: text

   lib/
   ├── main.dart                          # App entry point
   ├── main_tabs.dart                     # Main navigation shell
   ├── firebase_options.dart              # Firebase configuration
   │
   ├── models/                            # Data models
   │   ├── announcement.dart
   │   ├── committee_member.dart
   │   ├── event.dart
   │   └── society.dart
   │
   ├── providers/                         # State management
   │   └── app_state.dart                 # Central ChangeNotifier for app state
   │
   ├── screens/                           # UI screens
   │   ├── committee_sign_in_screen.dart
   │   ├── contact_info_screen.dart
   │   ├── event_detail_screen.dart
   │   ├── feed_screen.dart
   │   ├── member_approval_screen.dart
   │   ├── messages_screen.dart
   │   ├── profile_screen.dart
   │   ├── register_screen.dart
   │   ├── saved_events_screen.dart
   │   ├── sign_in_screen.dart
   │   ├── society_browser_screen.dart
   │   ├── society_chat_screen.dart
   │   └── society_detail_screen.dart
   │
   ├── services/                          # External integrations
   │   └── auth_service.dart              # Firebase Auth wrapper
   │
   ├── theme/                             # UI styling
   │   └── app_theme.dart
   │
   └── data/                              # Sample/test data
       ├── sample_events.dart
       └── sample_societies.dart

Data Flow Architecture
======================

The data flow in Sociefy follows a unidirectional pattern:

1. **UI Layer (Screens)** → User interaction triggers an action
2. **AppState Layer** → Business logic processes the request:
   - Local state updates via ``setState()`` or ``notifyListeners()``
   - Optional Firebase operation (read/write)
   - Stream subscriptions for real-time data
3. **Firebase Layer** → Data persisted or retrieved
4. **Listener Callback** → AppState notifies all listeners of changes
5. **UI Rebuild** → Widgets rebuild with new data via ``Consumer<AppState>``

Example flow for joining a society:

.. code-block:: dart

   // UI layer calls AppState method
   appState.joinSociety(societyId);
   
   // AppState updates local state and Firebase
   // Listeners are notified
   
   // UI rebuilds with updated society count

.. note::

   AppState sits between the UI and Firebase, ensuring:
   - All Firebase calls are centralized
   - UI never directly accesses Firestore
   - Real-time listeners automatically update the UI
   - Guest users can browse without authentication
   - Admin actions are protected by role checks

Firebase Collections
====================

Sociefy uses the following Firestore collections:

.. list-table::
   :header-rows: 1
   :widths: 25 75

   * - Collection
     - Purpose
   * - societies
     - Stores all university societies with metadata (name, category, description, members)
   * - events
     - Contains event records linked to societies (title, date, time, venue, description)
   * - announcements
     - Announcements posted by committee members for their societies (title, content, timestamp)
   * - memberships
     - Tracks which users have joined which societies (userId, societyId, joinDate)
   * - savedEvents
     - Records which users have saved events to their calendar (userId, eventId, timestamp)
   * - messages
     - Real-time messages for society group chats (societyId, userId, content, timestamp)
   * - rsvps
     - Event RSVPs and attendance records (userId, eventId, timestamp)

.. note::

   **Real-Time Streams:** Announcements and messages collections use Firestore real-time stream listeners (via ``StreamBuilder`` or subscription patterns) to automatically update the UI as new data arrives. This provides a live chat and announcements experience without polling.

External Integrations
=====================

The architecture includes interfaces for external services:

* **Firebase Cloud Messaging (FCM):** Push notifications for announcements and direct messages
* **External Calendar APIs:** Integration with device calendars (iOS/Android) via ``add_2_calendar`` package
* **Firebase Storage:** Image uploads for society profiles and event banners

The application enforces proper data validation and security rules at the Firestore level, ensuring that users can only access societies and events they have permission to view.
