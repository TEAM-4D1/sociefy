# Sociefy

<p align="center">
  <img src="assets/images/logo.png" alt="Sociefy Logo" width="180"/>
</p>

<p align="center">
  A modern university society platform built with Flutter & Firebase.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-Framework-blue?logo=flutter"/>
  <img src="https://img.shields.io/badge/Firebase-Backend-orange?logo=firebase"/>
  <img src="https://img.shields.io/badge/Dart-Language-blue?logo=dart"/>
  <img src="https://img.shields.io/badge/Provider-State%20Management-green"/>
</p>

---

# Overview

Sociefy is a cross-platform Flutter application designed to improve the university society experience for students and committee members.

The application acts as a centralised hub where students can:
- Discover societies
- Join communities
- RSVP to events
- Save events
- Receive announcements
- Communicate with other students
- Stay updated with university society activity

The goal of the project is to reduce fragmentation across platforms such as:
- Discord
- WhatsApp
- Instagram
- TikTok
- Email

by bringing society management and interaction into one modern mobile application.

---

# Features

## Authentication
- Firebase Authentication support
- Persistent user sessions
- Demo user fallback for development
- Secure authentication flow
- Login & registration screens

---

## Society Discovery
- Browse all university societies
- Search societies by name
- Filter societies by category
- View society details
- Responsive society cards

### Society Information Includes:
- Society name
- Category
- Description
- Committee information
- Contact email
- Membership status

---

## Society Membership
- Join societies
- Leave societies
- Persistent membership storage with Firebase
- Duplicate membership prevention
- Real-time membership updates

---

## Events System
- Browse upcoming events
- View detailed event pages
- RSVP to events
- Cancel RSVP
- Save/bookmark events
- Event attendee tracking

### Event Information Includes:
- Title
- Description
- Date & time
- Venue/location
- Capacity
- RSVP count

---

## Announcements
- Society announcements feed
- Personalised announcements
- Chronological sorting
- Society-specific updates

---

## Messaging & Community
- Community interaction
- Student discussion/forum support
- Society communication
- Committee announcements

---

## Personalised Experience
- "My Societies" page
- Joined society feed
- Saved events section
- Personalised updates
- User-specific interactions

---

# Tech Stack

## Frontend
- Flutter
- Dart
- Material Design

## State Management
- Provider

## Backend
- Firebase Authentication
- Cloud Firestore
- Firebase Cloud Functions

## Testing
- Flutter Test
- Widget Testing
- Integration Testing

## Documentation
- Markdown
- ReadTheDocs

---

# Architecture

The project follows a layered architecture to improve:
- Maintainability
- Scalability
- Code organisation
- Separation of concerns

---

## Project Structure

```text
lib/
├── models/
├── repositories/
├── services/
├── view_models/
├── views/
├── widgets/
└── main.dart
```

---

## Architecture Layers

### Models
Responsible for representing application data structures.

Examples:
- Society
- Event
- Announcement
- Membership
- UserProfile

---

### Repositories
Responsible for Firebase/Firestore interaction.

Responsibilities:
- Fetching data
- Saving memberships
- Handling RSVP persistence
- Managing announcements

---

### Services
Contains business logic.

Responsibilities:
- Membership validation
- RSVP handling
- Authentication logic
- Event saving logic

---

### View Models
Connect UI with repositories/services.

Responsibilities:
- State management
- Async loading
- Error handling
- UI updates

---

### Views
Application screens/pages.

Examples:
- Home Screen
- Events Screen
- Society Detail Screen
- My Societies Screen

---

### Widgets
Reusable UI components.

Examples:
- Society cards
- Event cards
- Announcement tiles
- Buttons
- Loading indicators

---

# Screens

## Home Screen
Features:
- Personalised feed
- Quick navigation
- Upcoming events
- Society highlights

---

## Societies Screen
Features:
- Browse societies
- Search/filter support
- Join/leave functionality

---

## Society Detail Screen
Features:
- Society description
- Events
- Announcements
- Contact information
- Membership actions

---

## Events Screen
Features:
- Upcoming events
- RSVP functionality
- Save event support

---

## Event Detail Screen
Features:
- Full event information
- RSVP management
- Event saving
- Attendee tracking

---

## My Societies Screen
Features:
- Joined societies
- Personalised announcements
- Saved events
- Membership management

---

## Messages Screen
Features:
- Community interaction
- Messaging/forum support
- Student communication

---

# Firebase Integration

The application uses Firebase for:
- Authentication
- Persistent cloud storage
- Firestore database
- Real-time updates


---

# Installation

## Prerequisites

Install the following before running the project:
- Flutter SDK
- Dart SDK
- Android Studio or VS Code
- Firebase CLI (optional)

---

# Setup Instructions

## 1. Clone Repository

```bash
git clone <repository-url>
cd sociefy-main
```

---

## 2. Install Dependencies

```bash
flutter pub get
```

---

## 3. Configure Firebase

Ensure Firebase is configured correctly.

Required files may include:
- google-services.json
- GoogleService-Info.plist
- firebase_options.dart

---

## 4. Run Application

```bash
flutter run
```

---

# Testing

## Run Unit Tests

```bash
flutter test
```

---

## Run Integration Tests

```bash
flutter test integration_test
```

---

## Generate Coverage Report

```bash
flutter test --coverage
```

Coverage reports are generated in:

```text
coverage/
```

---

# GitHub Actions

The project includes GitHub Actions workflows for:
- Flutter analysis
- Automated testing
- CI validation

Workflow directory:

```text
.github/workflows/
```

---

# Documentation

Additional documentation can be found in:

```text
docs/
```

Includes:
- Architecture documentation
- Testing documentation
- Firebase setup
- Development notes

---

# Development Notes

## Current Focus
- Improving Firebase persistence
- Enhancing event handling
- Increasing automated test coverage
- Improving responsive UI
- Expanding messaging/community features

---

## Future Improvements
- Push notifications
- Real-time chat
- Calendar API integration
- Enhanced accessibility
- Better moderation tools
- Advanced user profiles

---

# Contributors

Developed as part of the SETaP (Software Engineering Theory and Practice) coursework project.

## Team 4D(1)

| GitHub Username | Role |
|---|---|
| Trips424 | Developer |
| chikbunting | Developer |
| wdszn | Developer |
| justinb14 | Developer |
| rakh1mov | Developer |

---

# License

This project is intended for educational and coursework purposes.

---