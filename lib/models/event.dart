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

  String get formattedDate {
    return "${date.day}/${date.month}/${date.year}";
  }
}
