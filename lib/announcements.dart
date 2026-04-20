import 'package:flutter/material.dart';
import 'dart:async';

class Announcement {
  final String title;
  final String description;
  final DateTime date;
  final TimeOfDay time;
  final String venue;
  final DateTime startDateTime;
  final DateTime endDateTime;

  Announcement({
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.venue,
    required this.startDateTime,
    required this.endDateTime,
  });

  String get dateTimeVenueString {
    final dateStr =
        "${startDateTime.year}-${startDateTime.month.toString().padLeft(2, '0')}-${startDateTime.day.toString().padLeft(2, '0')}";
    final timeStr =
        "${startDateTime.hour.toString().padLeft(2, '0')}:${startDateTime.minute.toString().padLeft(2, '0')}";
    final endTimeStr =
        "${endDateTime.hour.toString().padLeft(2, '0')}:${endDateTime.minute.toString().padLeft(2, '0')}";
    return "$dateStr, $timeStr - $endTimeStr @ $venue";
  }

  bool get isExpired => DateTime.now().isAfter(endDateTime);
}

class AnnouncementHome extends StatefulWidget {
  @override
  _AnnouncementHomeState createState() => _AnnouncementHomeState();
}

class _AnnouncementHomeState extends State<AnnouncementHome> {
  final List<Announcement> _announcements = [];
  final Map<Announcement, Timer> _timers = {};

  @override
  void dispose() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    super.dispose();
  }

  void _scheduleAutoRemove(Announcement announcement) {
    final now = DateTime.now();
    final ms = announcement.endDateTime.difference(now).inMilliseconds;
    if (ms <= 0) {
      _removeAnnouncement(announcement);
      return;
    }
    final timer = Timer(Duration(milliseconds: ms), () {
      _removeAnnouncement(announcement);
    });
    _timers[announcement] = timer;
  }

  void _removeAnnouncement(Announcement announcement) {
    setState(() {
      _announcements.remove(announcement);
      _timers.remove(announcement)?.cancel();
    });
  }

  Future<void> _openCreatePage() async {
    final result = await Navigator.of(context).push<Announcement>(
      MaterialPageRoute(builder: (_) => CreateAnnouncementPage()),
    );

    if (result != null) {
      setState(() => _announcements.insert(0, result));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Society Announcements')),
      body: _announcements.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('No announcements yet.', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _openCreatePage,
                    child: Text('Post'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: _announcements.length,
              itemBuilder: (context, i) {
                final a = _announcements[i];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(
                      a.title,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 6),
                        Text(a.description),
                        SizedBox(height: 8),
                        Text(
                          a.dateTimeVenueString,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreatePage,
        label: Text('Post'),
        icon: Icon(Icons.post_add),
      ),
    );
  }
}

class CreateAnnouncementPage extends StatefulWidget {
  @override
  _CreateAnnouncementPageState createState() => _CreateAnnouncementPageState();
}

class _CreateAnnouncementPageState extends State<CreateAnnouncementPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _venueCtrl = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _venueCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(context: context, initialTime: now);
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please pick date, start time, and end time')),
      );
      return;
    }

    final startDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _startTime!.hour,
      _startTime!.minute,
    );
    final endDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _endTime!.hour,
      _endTime!.minute,
    );
    if (endDateTime.isBefore(startDateTime) ||
        endDateTime.isAtSameMomentAs(startDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('End time must be after start time')),
      );
      return;
    }

    final announcement = Announcement(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      date: _selectedDate!,
      time: _selectedTime!,
      venue: _venueCtrl.text.trim(),
    );

    Navigator.of(context).pop(announcement);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Announcement')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Please enter a title'
                    : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                minLines: 3,
                maxLines: 6,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Please enter a description'
                    : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _venueCtrl,
                decoration: InputDecoration(
                  labelText: 'Venue',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Please enter a venue'
                    : null,
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _pickDate,
                      child: Text(
                        _selectedDate == null
                            ? 'Pick date'
                            : '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}',
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _pickTime,
                      child: Text(
                        _selectedTime == null
                            ? 'Pick time'
                            : '${_selectedTime!.format(context)}',
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(onPressed: _save, child: Text('Save')),
            ],
          ),
        ),
      ),
    );
  }
}
