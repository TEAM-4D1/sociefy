import 'package:flutter/material.dart';

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

  /// Set of user identifiers who have liked this announcement.
  final Set<String> likedBy = {};

  final List<Comment> comments = [];

  /// Number of likes on this announcement.
  int get likeCount => likedBy.length;

  /// Check if the current user ('You') has liked this announcement.
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
