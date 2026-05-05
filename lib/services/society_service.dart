import '../models/society.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// A service class for handling society-related operations.
class SocietyService {
  /// Retrieves all societies from the Firestore 'societies' collection.
  ///
  /// Returns a list of [Society] objects, or an empty list on error.
  Future<List<Society>> getAllSocieties() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('societies')
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Society(
          id: doc.id,
          name: data['name'] ?? '',
          category: data['category'] ?? '',
          description: data['description'] ?? '',
          createdBy: data['createdBy'] ?? '',
          createdByEmail: data['createdByEmail'] ?? '',
        );
      }).toList();
    } catch (e) {
      debugPrint('getAllSocieties error: \$e');
      return [];
    }
  }

  /// Joins the user with [userId] to the society with [societyId].
  Future<void> joinSociety(String userId, String societyId) async {
    try {
      await FirebaseFirestore.instance
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

  /// Removes the user with [userId] from the society with [societyId].
  Future<void> leaveSociety(String userId, String societyId) async {
    try {
      await FirebaseFirestore.instance
          .collection('memberships')
          .doc('${userId}_$societyId')
          .delete();
    } catch (e) {
      debugPrint('leaveSociety error: $e');
      rethrow;
    }
  }

  /// Retrieves the list of society IDs joined by the user with [userId].
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
