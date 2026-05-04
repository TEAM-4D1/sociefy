// Firebase configuration for Sociefy
// Generated from Firebase Console credentials
// Project: sociefy-data-persistence

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
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
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBXOTgNt2yciK1tLj4lefspEEsSi9jW4Uo',
    appId: '1:1006868101484:web:a718c63367bd97f5941b49',
    messagingSenderId: '1006868101484',
    projectId: 'sociefy-data-persistence',
    authDomain: 'sociefy-data-persistence.firebaseapp.com',
    storageBucket: 'sociefy-data-persistence.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBXOTgNt2yciK1tLj4lefspEEsSi9jW4Uo',
    appId: '1:1006868101484:android:a718c63367bd97f5941b49',
    messagingSenderId: '1006868101484',
    projectId: 'sociefy-data-persistence',
    storageBucket: 'sociefy-data-persistence.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBXOTgNt2yciK1tLj4lefspEEsSi9jW4Uo',
    appId: '1:1006868101484:ios:a718c63367bd97f5941b49',
    messagingSenderId: '1006868101484',
    projectId: 'sociefy-data-persistence',
    iosBundleId: 'com.example.sociefy',
    storageBucket: 'sociefy-data-persistence.firebasestorage.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBXOTgNt2yciK1tLj4lefspEEsSi9jW4Uo',
    appId: '1:1006868101484:ios:a718c63367bd97f5941b49',
    messagingSenderId: '1006868101484',
    projectId: 'sociefy-data-persistence',
    iosBundleId: 'com.example.sociefy',
    storageBucket: 'sociefy-data-persistence.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBXOTgNt2yciK1tLj4lefspEEsSi9jW4Uo',
    appId: '1:1006868101484:windows:a718c63367bd97f5941b49',
    messagingSenderId: '1006868101484',
    projectId: 'sociefy-data-persistence',
    storageBucket: 'sociefy-data-persistence.firebasestorage.app',
  );
}
