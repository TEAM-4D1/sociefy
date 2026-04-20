import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// A service class for initializing and accessing Firebase services.
class FirebaseService {
  /// Initializes Firebase for the application.
  ///
  /// This method must be called before using any Firebase services.
  static Future<void> initialize() async {
    await Firebase.initializeApp();
  }

  /// Provides an instance of [FirebaseAuth] for authentication operations.
  static FirebaseAuth get auth => FirebaseAuth.instance;

  /// Provides an instance of [FirebaseFirestore] for database operations.
  static FirebaseFirestore get db => FirebaseFirestore.instance;
}
