import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/society.dart';
import '../providers/app_state.dart';
import '../theme/colours.dart';
import '../theme/text_styles.dart';
import 'event_detail_screen.dart';
import 'contact_info_screen.dart';

class SocietyDetailScreen extends StatelessWidget {
  final Society society;

  const SocietyDetailScreen({Key? key, required this.society})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(society.name),
        backgroundColor: AppColours.primaryPurple,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: AppColours.primaryPurple.withValues(
                          alpha: 0.1,
                        ),
                        child: Icon(
                          Icons.groups,
                          size: 36,
                          color: AppColours.primaryPurple,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(society.name, style: AppTextStyles.heading1),
                            const SizedBox(height: 8),
                            Text(
                              society.category,
                              style: AppTextStyles.heading2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Text(society.description, style: AppTextStyles.bodyRegular),

                  const SizedBox(height: 16),

                  Consumer<AppState>(
                    builder: (context, appState, _) {
                      return Column(
                        children: [
                          OutlinedButton.icon(
                            icon: const Icon(Icons.contact_mail),
                            label: const Text('View Contact Info'),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ContactInfoScreen(society: society),
                                ),
                              );
                            },
                          ),
                          if (appState.isAdmin) ...[
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.event),
                              label: const Text('Create Event'),
                              onPressed: () {
                                _showCreateEventDialog(context, appState);
                              },
                            ),
                          ],
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  const Text(
                    'Upcoming Events',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 16),

                  Consumer<AppState>(
                    builder: (context, appState, _) {
                      final events = appState.eventsForSociety(society.id);

                      if (events.isEmpty) {
                        return const Text('No upcoming events');
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          final event = events[index];

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              title: Text(event.title),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(event.formattedDate),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(event.venue),
                                    ],
                                  ),
                                ],
                              ),
                              onTap: () {
                                final userId = context.read<AppState>().userId;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EventDetailScreen(
                                      event: event,
                                      userId: userId ?? '',
                                      isSaved: appState.isEventSaved(event.id),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // =========================
      // JOIN / LEAVE BUTTON FIXED
      // =========================
      bottomNavigationBar: Consumer<AppState>(
        builder: (context, appState, _) {
          final isJoined = appState.isJoined(society.id);

          return BottomAppBar(
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isJoined
                        ? Colors.grey[300]
                        : AppColours.primaryPurple,
                    foregroundColor: isJoined ? Colors.black87 : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);

                    if (isJoined) {
                      await appState.leaveSociety(society.id);
                      messenger.showSnackBar(
                        SnackBar(content: Text('Left ${society.name}')),
                      );
                    } else {
                      await appState.joinSociety(society.id);
                      messenger.showSnackBar(
                        SnackBar(content: Text('Joined ${society.name}')),
                      );
                    }
                  },
                  child: Text(isJoined ? 'Leave Society' : 'Join Society'),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showCreateEventDialog(BuildContext context, AppState appState) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final venueController = TextEditingController();
    final startTimeController = TextEditingController();
    final endTimeController = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (statefulContext, setState) {
            return AlertDialog(
              title: const Text('Create Event'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Event Title',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter event title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: venueController,
                        decoration: const InputDecoration(
                          labelText: 'Venue',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter venue';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Date',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () async {
                                    final pickedDate = await showDatePicker(
                                      context: statefulContext,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.now().add(
                                        const Duration(days: 365),
                                      ),
                                    );
                                    if (pickedDate != null) {
                                      setState(() {
                                        selectedDate = pickedDate;
                                      });
                                    }
                                  },
                                  child: Text(
                                    selectedDate == null
                                        ? 'Pick Date'
                                        : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: startTimeController,
                        keyboardType: TextInputType.datetime,
                        decoration: const InputDecoration(
                          labelText: 'Start Time (HH:MM)',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter start time';
                          }
                          if (!RegExp(r'^\d{2}:\d{2}$').hasMatch(value)) {
                            return 'Use HH:MM format (e.g. 14:30)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: endTimeController,
                        keyboardType: TextInputType.datetime,
                        decoration: const InputDecoration(
                          labelText: 'End Time (HH:MM)',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter end time';
                          }
                          if (!RegExp(r'^\d{2}:\d{2}$').hasMatch(value)) {
                            return 'Use HH:MM format (e.g. 14:30)';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate() &&
                        selectedDate != null) {
                      appState.createEvent(
                        societyId: society.id,
                        title: titleController.text,
                        description: descriptionController.text,
                        date: selectedDate!,
                        startTime: startTimeController.text,
                        endTime: endTimeController.text,
                        venue: venueController.text,
                      );
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Event created!')),
                      );
                    } else if (selectedDate == null) {
                      ScaffoldMessenger.of(statefulContext).showSnackBar(
                        const SnackBar(content: Text('Please pick a date')),
                      );
                    }
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      titleController.dispose();
      descriptionController.dispose();
      venueController.dispose();
      startTimeController.dispose();
      endTimeController.dispose();
    });
  }
}
