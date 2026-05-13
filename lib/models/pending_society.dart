import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a society awaiting admin approval.
///
/// When a society is first created, it's stored in the 'pending_societies'
/// collection. Admins can then approve or reject the request, moving approved
/// societies to the main 'societies' collection.
class PendingSociety {
  final String id;
  final String name;
  final String category;
  final String description;
  final String founderEmail;
  final String founderName;
  final DateTime createdAt;
  final String status; // 'pending', 'approved', 'rejected'
  final String? rejectionReason;

  PendingSociety({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.founderEmail,
    required this.founderName,
    required this.createdAt,
    this.status = 'pending',
    this.rejectionReason,
  });

  /// Convert Firestore document to PendingSociety
  factory PendingSociety.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PendingSociety(
      id: doc.id,
      name: data['name'] ?? 'Unnamed Society',
      category: data['category'] ?? 'General',
      description: data['description'] ?? '',
      founderEmail: data['founderEmail'] ?? '',
      founderName: data['founderName'] ?? 'Unknown',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      status: data['status'] ?? 'pending',
      rejectionReason: data['rejectionReason'],
    );
  }

  /// Convert to Firestore-friendly map
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'category': category,
      'description': description,
      'founderEmail': founderEmail,
      'founderName': founderName,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status,
      'rejectionReason': rejectionReason,
    };
  }
}
