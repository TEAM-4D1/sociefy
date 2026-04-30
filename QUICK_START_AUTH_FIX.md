# Quick Start: Fix Authentication in 5 Minutes

## TL;DR - What's Wrong
Your Firebase configuration uses **stub values** instead of real credentials. That's why authentication doesn't work.

## Quick Fix

### Option 1: Automatic Configuration (Recommended)
```bash
# From your project root
dart pub global activate flutterfire_cli
flutterfire configure
flutter clean && flutter pub get && flutter run
```

### Option 2: Manual Configuration
1. Create Firebase project: https://console.firebase.google.com/
2. Enable Email/Password auth in Firebase Console
3. Copy credentials from Firebase Console
4. Replace 'stub' values in `lib/firebase_options.dart` with your real credentials

## What Was Fixed Automatically ✅

1. **Error logging** - Now shows actual Firebase errors instead of "$e"
2. **Code cleanup** - Removed unused imports
3. **Safety checks** - Added proper widget lifecycle checks
4. **Documentation** - Added setup guides

## What Still Needs You to Do 🚀

1. Run `flutterfire configure` to generate real Firebase credentials
2. Enable Email/Password authentication in Firebase Console (Settings → Authentication → Sign-in method)
3. Rebuild your app with the new Firebase configuration

## Test It
After configuration:
- Create account via "Register" button
- Sign in with your account
- Try admin/committee portal
- Guest login should still work

## Help
- See `FIREBASE_SETUP_GUIDE.md` for detailed instructions
- See `AUTHENTICATION_FIXES_SUMMARY.md` for all changes made
