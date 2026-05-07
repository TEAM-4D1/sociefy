# Sociefy Development Setup Guide

## Quick Start

### 1. Install Flutter (if not already installed)
```bash
# Download from: https://flutter.dev/docs/get-started/install
# Then verify installation:
flutter --version
```

### 2. Install Dependencies
```bash
# From the project root directory:
flutter pub get
```

### 3. Install Firebase Emulator (Optional, for local testing)
```bash
npm install -g firebase-tools
firebase emulators:start
```

### 4. Run the App
```bash
# For development (hot reload):
flutter run

# For a specific device:
flutter run -d <device_id>

# List available devices:
flutter devices
```

### 5. Run Tests
```bash
# All tests:
flutter test

# Specific test file:
flutter test test/widget_test.dart

# With coverage:
flutter test --coverage
```

### 6. Build for Release
```bash
# Android:
flutter build apk

# iOS:
flutter build ios

# Web:
flutter build web
```

## Environment Setup

### Firebase Configuration
1. Create a Firebase project at https://console.firebase.google.com
2. Copy your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
3. Place them in the appropriate directories:
   - Android: `android/app/`
   - iOS: `ios/Runner/`

### Troubleshooting

**Problem: "flutter: command not found"**
- Solution: Add Flutter to your PATH environment variable
- See: https://flutter.dev/docs/get-started/install

**Problem: "CocoaPods dependency not found" (iOS)**
- Solution: Run `cd ios && pod update && cd ..`

**Problem: Android build fails**
- Solution: Run `flutter clean` then `flutter pub get`

**Problem: Firebase not initialized**
- Solution: Ensure `google-services.json` is in `android/app/`

## Dependencies

See `pubspec.yaml` for the complete list of Dart/Flutter dependencies.
Key packages:
- **provider**: State management
- **firebase_core, firebase_auth, cloud_firestore, firebase_storage**: Backend
- **image_picker, file_picker**: File handling
- **add_2_calendar**: Calendar integration

## Architecture

See `docs/source/architecture.rst` for detailed architecture documentation.

## Contributing

1. Create a feature branch
2. Make your changes
3. Run tests: `flutter test`
4. Run analyzer: `flutter analyze`
5. Commit with descriptive messages
