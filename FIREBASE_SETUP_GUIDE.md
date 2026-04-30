# Firebase Setup Guide for Sociefy

## Problem
The `firebase_options.dart` file currently contains **stub values**, which is why authentication (login, registration) and admin portal login don't work. Only guest login works because it doesn't require Firebase authentication.

## Solution: Configure Firebase Properly

### Step 1: Install FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
```

### Step 2: Create/Link Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or select an existing one
3. Name it (e.g., "Sociefy")

### Step 3: Enable Email/Password Authentication
1. In Firebase Console, go to **Authentication**
2. Click **Get Started** (if needed)
3. Go to **Sign-in method** tab
4. Enable **Email/Password** provider
5. Click **Save**

### Step 4: Configure Firebase for Flutter
Run this command from your project root:
```bash
flutterfire configure
```

This will:
- Detect your platforms (Android, iOS, Web, etc.)
- Ask you to select your Firebase project
- Automatically generate the correct `firebase_options.dart` file

### Step 5: Verify Configuration
Your `firebase_options.dart` should now have real values like:
```dart
static FirebaseOptions get currentPlatform {
  if (kIsWeb) {
    return web;
  }
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return android;
    case TargetPlatform.iOS:
      return ios;
    case TargetPlatform.macOS:
      return macos;
    // ... other platforms
  }
}
```

### Step 6: Create Test Users (Optional)
In Firebase Console > Authentication > Users tab, you can manually create test user accounts for testing.

### Step 7: Test Authentication
1. Rebuild the app: `flutter clean && flutter pub get && flutter run`
2. Test registration by creating a new account
3. Test sign-in with created account
4. Test admin/committee login (same as regular sign-in but marked as admin)

## Important Security Notes
- Never commit real Firebase credentials to git (add `firebase_options.dart` to `.gitignore` if it contains production secrets)
- Use Firebase Security Rules to protect your database
- Enable strong password requirements in Firebase Console

## Troubleshooting
- If `flutterfire configure` fails, ensure you're logged into Firebase CLI: `firebase login`
- For Android: Check that your package name matches what's in Firebase Console
- For iOS: Verify the bundle ID matches your Xcode project
