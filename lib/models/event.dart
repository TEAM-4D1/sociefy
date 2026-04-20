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

  Event copyWith({bool? isSaved}) {
    return Event(
      id: id,
      societyId: societyId,
      societyName: societyName,
      title: title,
      description: description,
      date: date,
      startTime: startTime,
      endTime: endTime,
      venue: venue,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  String get formattedDate => "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year.toString()}";
}
