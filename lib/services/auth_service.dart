import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// A service class for handling authentication operations.
class AuthService {
  String? lastError;

  /// Signs in a user with the provided [email] and [password] via Firebase Authentication.
  ///
  /// Performs email/password authentication against Firebase Auth.
  /// Returns a [UserCredential] on success containing the authenticated user information.
  /// Returns null on failure and logs the error using debugPrint.
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

  /// Creates a new user account with the provided [email] and [password] via Firebase Authentication.
  ///
  /// Performs user account creation against Firebase Auth.
  /// Returns a [UserCredential] on success containing the newly created user information.
  /// Returns null on failure and logs the error using debugPrint.
  Future<UserCredential?> register(String email, String password) async {
    try {
      lastError = null;
      return await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      debugPrint('register error: $e');
      return null;
    }
  }

  /// Signs out the currently authenticated user from Firebase Authentication.
  ///
  /// Clears the user session in Firebase Auth.
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  /// Gets the currently authenticated user from Firebase Authentication.
  ///
  /// Returns the current [User] object if a user is authenticated, or null if no user is signed in.
  User? get currentUser {
    return FirebaseAuth.instance.currentUser;
  }
}
