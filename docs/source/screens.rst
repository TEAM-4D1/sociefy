Screens
=======

Sociefy includes a comprehensive set of screens providing different user experiences based on authentication status and role.

SignInScreen
~~~~~~~~~~~~

The SignInScreen is the primary entry point for authenticated users. It provides email and password login fields for students and a dedicated button for committee/admin sign in. The screen features gradient background branding and handles authentication state changes reactively.

.. note::
   Guest users can bypass authentication by clicking "Continue as Guest" to browse societies and events without creating an account.

RegisterScreen
~~~~~~~~~~~~~~

The RegisterScreen allows new students to create an account with a display name, email, and password. It includes form validation and transitions to the MainTabs screen upon successful registration. Navigation back to SignInScreen is available via the AppBar back button.

.. note::
   Guest users must register or sign in to access member-only features like joining societies and viewing announcements.

CommitteeSignInScreen
~~~~~~~~~~~~~~~~~~~~~

The CommitteeSignInScreen provides a dedicated authentication flow for committee members and admins. It includes email and password fields and checks against the committee admin email (jburfoot12@gmail.com) to grant administrative privileges. The screen features a distinctive purple gradient background and a back button to return to SignInScreen.

.. note::
   Only users with the designated committee admin email can access admin features. Guest users cannot access this screen.

FeedScreen
~~~~~~~~~~

The FeedScreen displays the main announcements feed with real-time updates from Firestore. It shows announcement cards with title, body, date, and associated society information. The screen supports pull-to-refresh functionality and is the default tab for authenticated users.

.. note::
   Guest users can view the feed but cannot interact with announcements. Full announcements feed access requires student or admin authentication.

SocietyBrowserScreen
~~~~~~~~~~~~~~~~~~~~

The SocietyBrowserScreen allows users to discover and search all available societies. It displays society cards with name, category, and description. The screen includes search and filter functionality to help users find societies matching their interests.

.. note::
   Guest users can browse societies but cannot join them. Student users can join societies directly from this screen.

SocietyDetailScreen
~~~~~~~~~~~~~~~~~~~

The SocietyDetailScreen displays comprehensive information about a selected society including description, member count, events, and announcements. Students can join or leave the society from this screen. Admins see additional management options.

.. note::
   Guest users can view society details but cannot join. Admin users see committee management and moderation tools.

SocietyChatScreen
~~~~~~~~~~~~~~~~~

The SocietyChatScreen provides real-time group chat functionality for society members. It displays message history and allows members to send messages. Messages are stored in Firestore and update reactively across all connected users.

.. note::
   Guest users cannot access society chat. Only joined members can send and view messages.

ProfileScreen
~~~~~~~~~~~~~

The ProfileScreen displays the current user's profile information including display name, email (or guest status), and a circular avatar. The screen provides a Sign Out button to end the current session. Guest users see a different display name and subtitle.

.. note::
   All authenticated users and guests can access their profile. Sign out clears all session data and returns to SignInScreen.

SavedEventsScreen
~~~~~~~~~~~~~~~~~

The SavedEventsScreen displays events that the current user has bookmarked or saved. Users can view saved event details and remove events from their saved list. The screen provides quick access to events of interest.

.. note::
   Guest users cannot save events. Only authenticated students and admins can bookmark events for later viewing.

MemberApprovalScreen
~~~~~~~~~~~~~~~~~~~~

The MemberApprovalScreen is an admin-only interface for approving or rejecting pending society membership requests. It displays a list of users waiting for approval with buttons to accept or deny their requests. The screen shows pending member details and status.

.. note::
   Only admin users can access this screen. Guest and regular student users cannot view or approve memberships.

EventDetailScreen
~~~~~~~~~~~~~~~~~

The EventDetailScreen shows detailed information about a specific event including title, description, date, time, venue, and associated society. Users can save events to their bookmarks or view more information about the hosting society.

.. note::
   Guest users can view event details but cannot save events. Student and admin users can bookmark events and navigate to the hosting society.

ContactInfoScreen
~~~~~~~~~~~~~~~~~

The ContactInfoScreen displays contact information and social media links for a society. It includes email addresses, phone numbers, and social media handles for committee members. Users can quickly contact society leadership from this screen.

.. note::
   Guest users can view contact information but cannot message directly. Authenticated users have full access to contact and direct messaging features.
