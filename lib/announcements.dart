import 'package:flutter/material.dart';

class Announcement {
  final String title;
  final String description;
  final DateTime date;
  final TimeOfDay time;
  final String venue;

  Announcement({
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.venue,
  });

  String get dateTimeVenueString {
    final dateStr =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    final timeStr =
        "${time.hourOfPeriod.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} ${time.period == DayPeriod.am ? 'AM' : 'PM'}";
    return "$dateStr, $timeStr @ $venue";
  }
}

class AnnouncementHome extends StatefulWidget {
  const AnnouncementHome({super.key});

  @override
  State<AnnouncementHome> createState() => _AnnouncementHomeState();
}

class _AnnouncementHomeState extends State<AnnouncementHome> {
  final List<Announcement> _announcements = [];

  Future<void> _openCreatePage() async {
    final result = await Navigator.of(context).push<Announcement>(
      MaterialPageRoute(builder: (_) => const CreateAnnouncementPage()),
    );
    if (result != null) {
      setState(() => _announcements.insert(0, result));
    }
  }

  Widget _buildAnnouncementCard(Announcement a, int index) {
    final colorScheme = Theme.of(context).colorScheme;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + index * 60),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 16 * (1 - value)),
          child: child,
        ),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 5,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        a.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 13,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              a.dateTimeVenueString,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Society Announcements'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      body: _announcements.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.campaign_outlined,
                    size: 88,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No announcements yet.',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Be the first to post an announcement',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _openCreatePage,
                    icon: const Icon(Icons.post_add),
                    label: const Text('Post'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _announcements.length,
              itemBuilder: (context, i) =>
                  _buildAnnouncementCard(_announcements[i], i),
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
  State<CreateAnnouncementPage> createState() =>
      _CreateAnnouncementPageState();
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
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick date and time')),
      );
      return;
    }
    Navigator.of(context).pop(
      Announcement(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        date: _selectedDate!,
        time: _selectedTime!,
        venue: _venueCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Announcement'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'Announcement Details',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description_outlined),
                  alignLabelWithHint: true,
                ),
                minLines: 3,
                maxLines: 6,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _venueCtrl,
                decoration: const InputDecoration(
                  labelText: 'Venue',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Please enter a venue' : null,
              ),
              const SizedBox(height: 20),
              Text(
                'Date & Time',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: Text(
                        _selectedDate == null
                            ? 'Pick date'
                            : '${_selectedDate!.year}-'
                                '${_selectedDate!.month.toString().padLeft(2, '0')}-'
                                '${_selectedDate!.day.toString().padLeft(2, '0')}',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickTime,
                      icon: const Icon(Icons.access_time, size: 18),
                      label: Text(
                        _selectedTime == null
                            ? 'Pick time'
                            : _selectedTime!.format(context),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text('Save', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
