import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// A service class for handling authentication operations.
class AuthService {
  String? lastError;

  /// Signs in a user with the provided [email] and [password].
  ///
  /// Returns a [UserCredential] if successful, or null otherwise.
  /// Logs errors using debugPrint.
  Future<UserCredential?> signIn(String email, String password) async {
    try {
      return await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      // ignore: avoid_print
      debugPrint('signIn error: $e');
      return null;
    }
  }

  /// Registers a new user with the provided [email] and [password].
  ///
  /// Returns a [UserCredential] if successful, or null otherwise.
  /// Logs errors using debugPrint.
  Future<UserCredential?> register(String email, String password) async {
    try {
      lastError = null;
      return await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      debugPrint('register error: \$e');
      return null;
    }
  }

  /// Signs out the currently authenticated user.
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  /// Returns the currently authenticated [User], or null if not signed in.
  User? get currentUser {
    return FirebaseAuth.instance.currentUser;
  }
}
