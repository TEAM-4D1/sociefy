import 'package:intl/intl.dart';

class Event {
  final String id;
  final String societyId;
  final String societyName;
  final String title;
  final String description;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String venue;
  final bool isSaved;

  Event({
    required this.id,
    required this.societyId,
    required this.societyName,
    required this.title,
    required this.description,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.venue,
    required this.isSaved,
  });

  Event copyWith({
    String? id,
    String? societyId,
    String? societyName,
    String? title,
    String? description,
    DateTime? date,
    String? startTime,
    String? endTime,
    String? venue,
    bool? isSaved,
  }) {
    return Event(
      id: id ?? this.id,
      societyId: societyId ?? this.societyId,
      societyName: societyName ?? this.societyName,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      venue: venue ?? this.venue,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  String get formattedDate {
    return DateFormat('EEEE, d MMMM y').format(date);
  }

  String get formattedTimeRange {
    return '$startTime – $endTime';
  }
}
