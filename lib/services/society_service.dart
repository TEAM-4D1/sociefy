import '../models/society.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// A service class for handling society-related operations.
class SocietyService {
  /// Constructs a SocietyService. Pass [firestore] in tests to substitute a
  /// `FakeFirebaseFirestore`; production callers can use the no-arg form.
  SocietyService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Retrieves all societies from the Firestore 'societies' collection.
  ///
  /// Reads from the Firestore 'societies' collection and returns a list of [Society] objects.
  /// Returns an empty list if an error occurs.
  Future<List<Society>> getAllSocieties() async {
    try {
      final snapshot = await _firestore
          .collection('societies')
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Society(
          id: doc.id,
          name: data['name'] ?? '',
          category: data['category'] ?? '',
          description: data['description'] ?? '',
        );
      }).toList();
    } catch (e) {
      debugPrint('getAllSocieties error: $e');
      return [];
    }
  }

  /// Adds a user to a society by creating a membership record in the Firestore 'memberships' collection.
  ///
  /// [userId] The ID of the user joining the society.
  /// [societyId] The ID of the society being joined.
  /// Writes to the Firestore 'memberships' collection with a document ID of '{userId}_{societyId}'.
  /// Throws an exception if the operation fails.
  Future<void> joinSociety(String userId, String societyId) async {
    try {
      await _firestore
          .collection('memberships')
          .doc('${userId}_$societyId')
          .set({
            'userId': userId,
            'societyId': societyId,
            'joinedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      debugPrint('joinSociety error: $e');
      rethrow;
    }
  }

  /// Removes a user from a society by deleting the membership record from the Firestore 'memberships' collection.
  ///
  /// [userId] The ID of the user leaving the society.
  /// [societyId] The ID of the society being left.
  /// Deletes the document from the Firestore 'memberships' collection with ID '{userId}_{societyId}'.
  /// Throws an exception if the operation fails.
  Future<void> leaveSociety(String userId, String societyId) async {
    try {
      await _firestore
          .collection('memberships')
          .doc('${userId}_$societyId')
          .delete();
    } catch (e) {
      debugPrint('leaveSociety error: $e');
      rethrow;
    }
  }

  /// Retrieves all society IDs that a user has joined from the Firestore 'memberships' collection.
  ///
  /// [userId] The ID of the user to get memberships for.
  /// Queries the Firestore 'memberships' collection for all documents where userId matches.
  /// Returns a list of society IDs, or an empty list if an error occurs.
  Future<List<String>> getJoinedSocietyIds(String userId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('memberships')
          .where('userId', isEqualTo: userId)
          .get();
      return snapshot.docs.map((doc) => doc['societyId'] as String).toList();
    } catch (e) {
      debugPrint('getJoinedSocietyIds error: $e');
      return [];
    }
  }
}
