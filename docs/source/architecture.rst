System Architecture 
===================
The proposed system utilizes a 3-Tier Layered Architecture, designed to ensure a strict separation of concerns between the user interface, business logic, and data storage.
This model guarantees that the client application never interacts directly with the database, enhancing security and maintainability.

1. Presentation Layer (Client-Side)
The top layer consists of the user-facing mobile interface. It is responsible for capturing user inputs and displaying data returned from the server. Key views include:
* Authentication UI: Handles Login and Registration.
* Society Browser UI & Details: Allows users to find societies and view contact information.
* My Societies & Updates UI: A personalized feed of announcements for the groups a user has joined.
2. Business Logic Layer (Server-Side)
This middle layer acts as the system's brain, processing requests from the client before they reach the database. It contains specialized Manager components:
* AuthManager: Validates credentials and manages session security.
* SocietyManager: Handles the retrieval of society lists and contact details.
* MembershipManager: Manages user subscriptions and generates the updates feed.
* CalendarManager: Handles the logic for validating events and synchronizing them with external devices.
3. Data Persistence Layer 
The bottom layer handles all data storage.
* DBConnector: Acts as the centralized gatekeeper, executing SQL queries (e.g., INSERT, SELECT) on the SQL Database. By funneling all data access through this single component, the system prevents inconsistent database states.

External Integrations
======================
The architecture includes an interface for an External Calendar API (such as Google or Apple Calendar) and a Push Notification Server.
The CalendarManager communicates with the calendar service to push event data only after verifying the event exists in the internal database.
