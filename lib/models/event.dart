class Event {
  final String id;
  final String societyId;
  final String title;
  final String description;
  final DateTime date;
  final String venue;

  Event({
    required this.id,
    required this.societyId,
    required this.title,
    required this.description,
    required this.date,
    required this.venue,
  });

  String get formattedDate {
    // Example: '20 April 2026'
    return "${date.day.toString().padLeft(2, '0')} ${_monthName(date.month)} ${date.year}";
  }

  String _monthName(int month) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month];
  }
}
