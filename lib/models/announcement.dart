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
