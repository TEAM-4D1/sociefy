import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/society.dart';
import '../providers/app_state.dart';
import '../theme/colours.dart';
import '../theme/text_styles.dart';
import '../utils/society_image_mapper.dart';
import 'event_detail_screen.dart';
import 'contact_info_screen.dart';

/// Displays comprehensive information about a selected society including description, member count, events, and announcements.
/// Students can join/leave societies; admins see additional management options.
/// Accessible to all authenticated users; guests can view but cannot join or interact.
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
                        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                          final imageAsset = getSocietyImageAsset(
                            event.societyName,
                          );

                          return Container(
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  final userId = context
                                      .read<AppState>()
                                      .userId;
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EventDetailScreen(
                                        event: event,
                                        userId: userId ?? '',
                                        isSaved: appState.isEventSaved(
                                          event.id,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Card(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(4),
                                          topRight: Radius.circular(4),
                                        ),
                                        child: Image.asset(
                                          imageAsset,
                                          height: 120,
                                          width: double.infinity,
                                          fit: BoxFit.contain,
                                          alignment: Alignment.center,
                                        ),
                                      ),
                                      ListTile(
                                        title: Text(event.title),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // Posts History Button
                  ElevatedButton.icon(
                    icon: const Icon(Icons.history),
                    label: const Text('Posts'),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) {
                          final posts = context
                              .read<AppState>()
                              .announcements
                              .where((a) => a.societyId == society.id)
                              .toList();
                          return DraggableScrollableSheet(
                            expand: false,
                            builder: (context, scrollController) {
                              if (posts.isEmpty) {
                                return const Center(
                                  child: Text('No posts yet.'),
                                );
                              }
                              return ListView.builder(
                                controller: scrollController,
                                itemCount: posts.length,
                                itemBuilder: (context, index) {
                                  final post = posts[index];
                                  return Card(
                                    margin: const EdgeInsets.all(12),
                                    child: ListTile(
                                      title: Text(post.title),
                                      subtitle: Text(post.content),
                                      trailing: post.imageUrl != null
                                          ? Image.network(
                                              post.imageUrl!,
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                    ),
                                  );
                                },
                              );
                            },
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

      bottomNavigationBar: Consumer<AppState>(
        builder: (context, appState, _) {
          final isJoined = appState.isJoined(society.id);
          final isGuest = appState.isGuest;

          return BottomAppBar(
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isGuest
                        ? Colors.grey[400]
                        : isJoined
                        ? Colors.grey[300]
                        : AppColours.primaryPurple,
                    foregroundColor: isGuest || isJoined
                        ? Colors.black87
                        : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);

                    // Guests cannot join
                    if (isGuest) {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Please sign in to join societies'),
                        ),
                      );
                      return;
                    }

                    if (isJoined) {
                      // Leave society — use AppState which handles Firestore
                      try {
                        await appState.leaveSociety(society.id);
                        if (!context.mounted) return;
                        messenger.showSnackBar(
                          SnackBar(content: Text('Left ${society.name}')),
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        messenger.showSnackBar(
                          SnackBar(content: Text('Error leaving society: $e')),
                        );
                      }
                      return;
                    }

                    // Join society — use AppState.joinSociety (handles both
                    // local state and Firestore in one call, no double-write)
                    try {
                      await appState.joinSociety(society.id);
                      if (!context.mounted) return;
                      messenger.showSnackBar(
                        SnackBar(content: Text('Joined ${society.name}')),
                      );
                    } catch (e) {
                      if (!context.mounted) return;
                      messenger.showSnackBar(
                        SnackBar(content: Text('Error joining society: $e')),
                      );
                    }
                  },
                  child: Text(
                    isGuest
                        ? 'Sign in to Join'
                        : isJoined
                        ? 'Leave Society'
                        : 'Join Society',
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Shows a modal dialog for admins to create a new event for this society.
  void _showCreateEventDialog(BuildContext context, AppState appState) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final venueController = TextEditingController();
    final startTimeController = TextEditingController();
    final endTimeController = TextEditingController();
    DateTime? selectedDate;

    showDialog<void>(
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
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter event title'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter description'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: venueController,
                        decoration: const InputDecoration(
                          labelText: 'Venue',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter venue'
                            : null,
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
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Start Time',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () async {
                                    final pickedTime = await showTimePicker(
                                      context: statefulContext,
                                      initialTime: TimeOfDay.now(),
                                    );
                                    if (pickedTime != null) {
                                      setState(() {
                                        startTimeController.text = pickedTime
                                            .format(statefulContext);
                                      });
                                    }
                                  },
                                  child: Text(
                                    startTimeController.text.isEmpty
                                        ? 'Pick Start Time'
                                        : startTimeController.text,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'End Time',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () async {
                                    final pickedTime = await showTimePicker(
                                      context: statefulContext,
                                      initialTime: TimeOfDay.now(),
                                    );
                                    if (pickedTime != null) {
                                      setState(() {
                                        endTimeController.text = pickedTime
                                            .format(statefulContext);
                                      });
                                    }
                                  },
                                  child: Text(
                                    endTimeController.text.isEmpty
                                        ? 'Pick End Time'
                                        : endTimeController.text,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
                        title: titleController.text.trim(),
                        description: descriptionController.text.trim(),
                        date: selectedDate!,
                        startTime: startTimeController.text,
                        endTime: endTimeController.text,
                        venue: venueController.text.trim(),
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
    ).whenComplete(() {
      titleController.dispose();
      descriptionController.dispose();
      venueController.dispose();
      startTimeController.dispose();
      endTimeController.dispose();
    });
  }
}
