import 'package:flutter/material.dart';

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

  get dateTimeVenueString => null;
}
