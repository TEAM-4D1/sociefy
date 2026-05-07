import 'package:flutter/material.dart';
import 'society_model.dart';

/// Domain entity representing a single society announcement / event.
///
/// Holds the data captured by [CreateAnnouncementPage] and is the unit
/// formatted by the [dateTimeVenueString] getter, which is the function
/// directly exercised by the ANN-01..ANN-08 boundary-value tests.
class Announcement {
  /// Headline shown in bold on the card.
  final String title;

  /// Free-text description / body.
  final String description;

  /// Calendar date the event occurs on.
  final DateTime date;

  /// Wall-clock start time.
  final TimeOfDay time;

  /// Free-text venue label (e.g. "Main Hall Room 2A").
  final String venue;

  /// Optional society this announcement is posted under. Null means a
  /// general (non-society) announcement and renders without a chip.
  /// Maps to User Requirement 7 (committee can post per-society
  /// announcements) and Requirement 6 (filter by joined societies).
  final String? societyName;

  /// Whether the current user has RSVPed "Going". Mutable so the card
  /// can toggle without rebuilding the whole list.
  bool isGoing;

  /// Whether a local reminder is set for this event.
  bool reminderOn;

  Announcement({
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.venue,
    this.societyName,
    this.isGoing = false,
    this.reminderOn = false,
  });

  /// Combined start `DateTime` (date + time). Useful for sorting and for
  /// the upcoming/past filter.
  DateTime get eventDateTime => DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );

  /// True when [eventDateTime] is in the future relative to [now]
  /// (defaults to `DateTime.now()`). Drives the "Upcoming" filter chip.
  bool isUpcomingFrom([DateTime? now]) =>
      eventDateTime.isAfter(now ?? DateTime.now());

  /// Short, human-friendly delta to display alongside each card, e.g.
  /// `"In 3 days"`, `"Tomorrow"`, `"In 2h"`, `"Started 30m ago"`,
  /// `"5 days ago"`. The reference time defaults to `DateTime.now()`.
  String relativeTime([DateTime? now]) {
    final reference = now ?? DateTime.now();
    final diff = eventDateTime.difference(reference);

    if (diff.inMinutes.abs() < 60) {
      if (diff.isNegative) return 'Started ${(-diff).inMinutes}m ago';
      return 'In ${diff.inMinutes}m';
    }
    if (diff.inHours.abs() < 24) {
      if (diff.isNegative) return 'Started ${(-diff).inHours}h ago';
      return 'In ${diff.inHours}h';
    }
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Tomorrow';
    if (diff.inDays == -1) return 'Yesterday';
    if (diff.isNegative) return '${(-diff).inDays} days ago';
    return 'In ${diff.inDays} days';
  }

  /// Renders the announcement's date, time and venue as a single human
  /// string, e.g. `"2026-03-05, 09:30 AM @ Room A"`.
  ///
  /// Notes:
  /// * Year/month/day and hour/minute components are zero-padded so the
  ///   ANN-05 / ANN-08 single-digit boundaries produce two-digit output.
  /// * Hour conversion goes through `time.hourOfPeriod` so the noon /
  ///   midnight boundaries return `12:00 PM` and `12:00 AM` (ANN-03 /
  ///   ANN-04) rather than `00:00`.
  String get dateTimeVenueString {
    final dateStr =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    final timeStr =
        "${time.hourOfPeriod.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} ${time.period == DayPeriod.am ? 'AM' : 'PM'}";
    return "$dateStr, $timeStr @ $venue";
  }
}

/// Logical view filter for the announcement feed. `upcoming` is the
/// default because the iteration-1 interviews flagged "missing events"
/// as the primary pain point.
enum _FilterMode { upcoming, past, all }

/// Announcements tab — feed of upcoming and past society events.
///
/// When [societies] is provided the page populates the "Post under
/// society" dropdown on [CreateAnnouncementPage] from the user's
/// **joined** societies (User Req 6 — separate experience for joined
/// societies). When it is null the page still works in isolation, which
/// keeps the AH-* unit tests green.
class AnnouncementHome extends StatefulWidget {
  /// Optional shared store. Only used to source society names for the
  /// post dropdown and to scope the Upcoming filter.
  final SocietyNotifier? societies;

  const AnnouncementHome({super.key, this.societies});

  @override
  State<AnnouncementHome> createState() => _AnnouncementHomeState();
}

class _AnnouncementHomeState extends State<AnnouncementHome> {
  final List<Announcement> _announcements = [];
  _FilterMode _filter = _FilterMode.upcoming;

  /// Returns [_announcements] filtered by [_filter] and sorted: upcoming
  /// soonest-first, past most-recent-first.
  List<Announcement> get _visible {
    final now = DateTime.now();
    final list = switch (_filter) {
      _FilterMode.upcoming =>
        _announcements.where((a) => a.isUpcomingFrom(now)).toList(),
      _FilterMode.past =>
        _announcements.where((a) => !a.isUpcomingFrom(now)).toList(),
      _FilterMode.all => List.of(_announcements),
    };
    list.sort((a, b) => _filter == _FilterMode.past
        ? b.eventDateTime.compareTo(a.eventDateTime)
        : a.eventDateTime.compareTo(b.eventDateTime));
    return list;
  }

  /// Push the create-announcement route and prepend the returned
  /// [Announcement] to the feed if the user saved one. Joined-society
  /// names (if any) are forwarded so the dropdown can show them.
  Future<void> _openCreatePage() async {
    final options = widget.societies?.joinedSocieties
            .map((s) => s.name)
            .toList(growable: false) ??
        const <String>[];
    final result = await Navigator.of(context).push<Announcement>(
      MaterialPageRoute(
        builder: (_) => CreateAnnouncementPage(societyOptions: options),
      ),
    );
    if (result != null) {
      setState(() => _announcements.insert(0, result));
    }
  }

  /// Toggle the user's RSVP state for [a] and surface confirmation via
  /// snackbar so the action feels acknowledged on a single-user
  /// prototype.
  void _toggleGoing(Announcement a) {
    setState(() => a.isGoing = !a.isGoing);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(a.isGoing
            ? 'Marked as going to "${a.title}"'
            : 'No longer going to "${a.title}"'),
        duration: const Duration(seconds: 2),
      ));
  }

  /// Implements the "Save Event to Calendar" use case (User Req 1).
  /// In the prototype there's no real calendar integration; we simply
  /// flip the [Announcement.reminderOn] flag and confirm via snackbar
  /// — the live-demo behaviour the design chapter specifies.
  void _saveToCalendar(Announcement a) {
    setState(() => a.reminderOn = true);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('"${a.title}" saved to calendar'),
        duration: const Duration(seconds: 2),
      ));
  }

  /// Build a single announcement card. Accent strip turns dimmer for past
  /// events; the row of action buttons at the bottom implements RSVP
  /// (User Req 3 / interview pattern) and Save-to-Calendar (User Req 1).
  Widget _buildAnnouncementCard(Announcement a, int index) {
    final cs = Theme.of(context).colorScheme;
    final isUpcoming = a.isUpcomingFrom();
    final accent = isUpcoming ? cs.primary : Colors.grey.shade400;

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
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _openDetail(a),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 5, color: accent),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 12, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top row: optional society chip + relative time
                        Row(
                          children: [
                            if (a.societyName != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: cs.primaryContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  a.societyName!,
                                  style: TextStyle(
                                    color: cs.onPrimaryContainer,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            const Spacer(),
                            Text(
                              a.relativeTime(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isUpcoming
                                    ? cs.primary
                                    : Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          a.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          a.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.schedule,
                                size: 13, color: Colors.grey.shade500),
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
                        const SizedBox(height: 6),
                        // Action row: RSVP + Save to calendar
                        Row(
                          children: [
                            TextButton.icon(
                              onPressed: () => _toggleGoing(a),
                              icon: Icon(
                                a.isGoing
                                    ? Icons.check_circle
                                    : Icons.check_circle_outline,
                                size: 18,
                                color: a.isGoing ? cs.primary : null,
                              ),
                              label: Text(a.isGoing ? 'Going' : 'Going?'),
                              style: TextButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => _saveToCalendar(a),
                              icon: Icon(
                                a.reminderOn
                                    ? Icons.event_available
                                    : Icons.calendar_month_outlined,
                                size: 18,
                                color: a.reminderOn ? cs.primary : null,
                              ),
                              label:
                                  Text(a.reminderOn ? 'Saved' : 'Save'),
                              style: TextButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                            const Spacer(),
                            Icon(Icons.chevron_right,
                                color: Colors.grey.shade400, size: 20),
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
      ),
    );
  }

  /// Push the placeholder detail page; replaced by [AnnouncementDetailPage]
  /// in a follow-up commit. Wraps `Navigator.push` so callers don't need
  /// to know the route shape.
  void _openDetail(Announcement a) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AnnouncementDetailPage(
          announcement: a,
          onChanged: () => setState(() {}),
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
          : Column(
              children: [
                _FilterBar(
                  current: _filter,
                  onChanged: (f) => setState(() => _filter = f),
                  upcomingCount:
                      _announcements.where((a) => a.isUpcomingFrom()).length,
                  pastCount:
                      _announcements.where((a) => !a.isUpcomingFrom()).length,
                ),
                Expanded(
                  child: _visible.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              _filter == _FilterMode.upcoming
                                  ? 'No upcoming events.\nTap + to post one.'
                                  : 'No matching announcements.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                          itemCount: _visible.length,
                          itemBuilder: (context, i) =>
                              _buildAnnouncementCard(_visible[i], i),
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreatePage,
        label: const Text('Post'),
        icon: const Icon(Icons.post_add),
      ),
    );
  }
}

/// Horizontal bar of `ChoiceChip`s sitting above the announcement list.
/// Lets the user flip between Upcoming / Past / All. Selection is
/// driven by [current] / [onChanged] so the parent state stays the
/// single source of truth.
class _FilterBar extends StatelessWidget {
  final _FilterMode current;
  final ValueChanged<_FilterMode> onChanged;
  final int upcomingCount;
  final int pastCount;

  const _FilterBar({
    required this.current,
    required this.onChanged,
    required this.upcomingCount,
    required this.pastCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          _chip('Upcoming ($upcomingCount)', _FilterMode.upcoming),
          const SizedBox(width: 8),
          _chip('Past ($pastCount)', _FilterMode.past),
          const SizedBox(width: 8),
          _chip('All', _FilterMode.all),
        ],
      ),
    );
  }

  Widget _chip(String label, _FilterMode mode) => ChoiceChip(
        label: Text(label),
        selected: current == mode,
        onSelected: (_) => onChanged(mode),
      );
}

/// Read-only detail view for a single [Announcement].
///
/// Implements the **View Event Details** use case from the design
/// chapter: shows full description, formatted date/time/venue, and
/// exposes the same RSVP and Save-to-Calendar actions as the card —
/// but bigger, and with a reminder toggle for User Req 1.
///
/// [onChanged] is invoked whenever a toggle is flipped so the host
/// `AnnouncementHome` can rebuild the card list with the new state.
class AnnouncementDetailPage extends StatefulWidget {
  final Announcement announcement;
  final VoidCallback onChanged;

  const AnnouncementDetailPage({
    super.key,
    required this.announcement,
    required this.onChanged,
  });

  @override
  State<AnnouncementDetailPage> createState() =>
      _AnnouncementDetailPageState();
}

class _AnnouncementDetailPageState extends State<AnnouncementDetailPage> {
  Announcement get a => widget.announcement;

  void _flip(VoidCallback mutate, String message) {
    setState(mutate);
    widget.onChanged();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (a.societyName != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                a.societyName!,
                style: TextStyle(
                  color: cs.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          const SizedBox(height: 12),
          Text(
            a.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            a.relativeTime(),
            style: TextStyle(
              color: a.isUpcomingFrom() ? cs.primary : Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          _DetailRow(
            icon: Icons.event,
            label: a.dateTimeVenueString,
          ),
          const SizedBox(height: 28),
          Text(
            'About this event',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(a.description, style: const TextStyle(height: 1.5)),
          const SizedBox(height: 28),
          _ActionRow(
            icon:
                a.isGoing ? Icons.check_circle : Icons.check_circle_outline,
            label: a.isGoing ? "You're going" : 'Mark as going',
            highlighted: a.isGoing,
            onTap: () => _flip(
              () => a.isGoing = !a.isGoing,
              a.isGoing ? 'Marked as going' : 'Removed RSVP',
            ),
          ),
          _ActionRow(
            icon: a.reminderOn
                ? Icons.event_available
                : Icons.calendar_month_outlined,
            label: a.reminderOn ? 'Saved to calendar' : 'Save to calendar',
            highlighted: a.reminderOn,
            onTap: () => _flip(
              () => a.reminderOn = !a.reminderOn,
              a.reminderOn
                  ? 'Saved to calendar'
                  : 'Removed from calendar',
            ),
          ),
        ],
      ),
    );
  }
}

/// One read-only row of icon + label, used by [AnnouncementDetailPage]
/// for static info like the date/time/venue line.
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _DetailRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: const TextStyle(fontSize: 14)),
        ),
      ],
    );
  }
}

/// Tappable row used for the toggleable RSVP and Save-to-Calendar
/// actions on [AnnouncementDetailPage]. Highlighted when the action is
/// currently "on".
class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool highlighted;
  final VoidCallback onTap;

  const _ActionRow({
    required this.icon,
    required this.label,
    required this.highlighted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, color: highlighted ? cs.primary : null),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: highlighted ? cs.primary : null,
                ),
              ),
            ),
            Switch(value: highlighted, onChanged: (_) => onTap()),
          ],
        ),
      ),
    );
  }
}

/// Form page that captures a new [Announcement].
///
/// All three text fields use `TextFormField.validator` to enforce
/// non-empty input (with `trim()` to reject whitespace-only). Date and
/// time selection is checked separately in [_save] — if either is
/// missing, a SnackBar is shown rather than a field error, because the
/// pickers don't fit the validator pattern. On a successful save the page
/// pops with the new `Announcement` as the route result.
class CreateAnnouncementPage extends StatefulWidget {
  /// Names of the societies the current user has joined. Used to populate
  /// the optional "Post under society" dropdown so committee members can
  /// scope an announcement to one of their groups (User Req 7).
  ///
  /// When this list is empty (e.g. the standalone widget-test path
  /// `MaterialApp(home: CreateAnnouncementPage())`) the dropdown is
  /// omitted entirely and the form keeps exactly 3 `TextFormField`s, so
  /// CAP-01 still passes unchanged.
  final List<String> societyOptions;

  const CreateAnnouncementPage({
    super.key,
    this.societyOptions = const [],
  });

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

  /// Currently-selected society name for the post. Null = general
  /// announcement (no society chip on the resulting card).
  String? _selectedSociety;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _venueCtrl.dispose();
    super.dispose();
  }

  /// Open the platform date picker (1 year past, 5 years future) and
  /// store the result.
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

  /// Open the platform time picker and store the result.
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  /// Validate the form, ensure date+time were picked, then pop with the
  /// constructed [Announcement] as the route result.
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
        societyName: _selectedSociety,
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
              if (widget.societyOptions.isNotEmpty) ...[
                DropdownButtonFormField<String?>(
                  initialValue: _selectedSociety,
                  decoration: const InputDecoration(
                    labelText: 'Post under society',
                    prefixIcon: Icon(Icons.groups_outlined),
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('General announcement'),
                    ),
                    for (final name in widget.societyOptions)
                      DropdownMenuItem<String?>(
                        value: name,
                        child: Text(name),
                      ),
                  ],
                  onChanged: (v) => setState(() => _selectedSociety = v),
                ),
                const SizedBox(height: 14),
              ],
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
