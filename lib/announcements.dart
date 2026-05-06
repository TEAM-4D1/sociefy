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
  const AnnouncementHome({super.key});

  @override
  State<AnnouncementHome> createState() => _AnnouncementHomeState();
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
      MaterialPageRoute(builder: (_) => const CreateAnnouncementPage()),
    );

    if (result != null) {
      setState(() => _announcements.insert(0, result));
      _scheduleAutoRemove(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    for (final a in _announcements) {
      if (!_timers.containsKey(a)) {
        _scheduleAutoRemove(a);
      }
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Society Announcements')),
      body: _announcements.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('No announcements yet.', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _openCreatePage,
                    child: const Text('Post'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _announcements.length,
              itemBuilder: (context, i) {
                final a = _announcements[i];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(
                      a.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Text(a.description),
                        const SizedBox(height: 8),
                        Text(
                          a.dateTimeVenueString,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ends: ${a.endDateTime}',
                          style: const TextStyle(fontSize: 12, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreatePage,
        label: const Text('Post'),
        icon: const Icon(Icons.post_add),
      ),
    );
  }
}

class CreateAnnouncementPage extends StatefulWidget {
  const CreateAnnouncementPage({super.key});

  @override
  State<CreateAnnouncementPage> createState() => _CreateAnnouncementPageState();
}

class _CreateAnnouncementPageState extends State<CreateAnnouncementPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _venueCtrl = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

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

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => _startTime = picked);
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => _endTime = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick date, start time, and end time')),
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
        const SnackBar(content: Text('End time must be after start time')),
      );
      return;
    }

    Navigator.of(context).pop(
      Announcement(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        date: _selectedDate!,
        time: _startTime!,
        venue: _venueCtrl.text.trim(),
        startDateTime: startDateTime,
        endDateTime: endDateTime,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Announcement')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                minLines: 3,
                maxLines: 6,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _venueCtrl,
                decoration: const InputDecoration(
                  labelText: 'Venue',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Please enter a venue' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(_selectedDate == null
                    ? 'Pick a date'
                    : 'Date: ${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              ListTile(
                title: Text(_startTime == null
                    ? 'Pick start time'
                    : 'Start: ${_startTime!.format(context)}'),
                trailing: const Icon(Icons.access_time),
                onTap: _pickStartTime,
              ),
              ListTile(
                title: Text(_endTime == null
                    ? 'Pick end time'
                    : 'End: ${_endTime!.format(context)}'),
                trailing: const Icon(Icons.access_time_filled),
                onTap: _pickEndTime,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _save,
                child: const Text('Save Announcement'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
