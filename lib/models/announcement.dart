import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String author;
  final String content;
  final DateTime dateTime;

  const Comment({
    required this.id,
    required this.author,
    required this.content,
    required this.dateTime,
  });

  /// Create a Comment from Firestore data
  factory Comment.fromFirestore(Map<String, dynamic> data, String docId) {
    DateTime parsedDateTime;

    if (data['dateTime'] is Timestamp) {
      // Handle Firestore Timestamp
      parsedDateTime = (data['dateTime'] as Timestamp).toDate();
    } else if (data['dateTime'] is DateTime) {
      // Handle DateTime object
      parsedDateTime = data['dateTime'] as DateTime;
    } else if (data['dateTime'] is int) {
      // Handle milliseconds since epoch
      parsedDateTime = DateTime.fromMillisecondsSinceEpoch(
        data['dateTime'] as int,
      );
    } else {
      // Default to now if no valid dateTime
      parsedDateTime = DateTime.now();
    }

    return Comment(
      id: docId,
      author: data['author'] ?? 'Unknown',
      content: data['content'] ?? '',
      dateTime: parsedDateTime,
    );
  }
}

class Announcement {
  final String id;
  final String societyId;
  final String title;
  final String content;
  final DateTime date;
  final String? imageUrl;
  final TimeOfDay? time;
  final String? venue;
  final String? description;

  /// Set of user IDs who have liked this announcement.
  final Set<String> likedBy = {};

  final List<Comment> comments = [];

  /// Number of likes on this announcement.
  int get likeCount => likedBy.length;

  /// Check if the current user has liked this announcement (requires actual userId).
  bool isLikedByUser(String? userId) =>
      userId != null && likedBy.contains(userId);

  /// Check if 'You' (deprecated) has liked this announcement.
  @deprecated
  bool get isLikedByCurrentUser => likedBy.contains('You');

  Announcement({
    required this.id,
    required this.societyId,
    required this.title,
    required this.content,
    required this.date,
    this.imageUrl,
    this.time,
    this.venue,
    this.description,
  });

  /// Toggle like status for the given user.
  void toggleLike(String userId) {
    if (likedBy.contains(userId)) {
      likedBy.remove(userId);
    } else {
      likedBy.add(userId);
    }
  }

  /// Add a comment to this announcement.
  void addComment(String author, String content) {
    final comment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      author: author,
      content: content,
      dateTime: DateTime.now(),
    );
    comments.add(comment);
  }

  String? get dateTimeVenueString {
    if (time == null || venue == null) return null;
    final y = date.year.toString();
    final mo = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    final period = time!.period == DayPeriod.am ? 'AM' : 'PM';
    final h = time!.hourOfPeriod.toString().padLeft(2, '0');
    final mi = time!.minute.toString().padLeft(2, '0');
    return '$y-$mo-$d, $h:$mi $period @ $venue';
  }
}
