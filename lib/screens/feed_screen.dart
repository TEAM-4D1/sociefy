import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

// Announcement card for feed
class _AnnouncementCard extends StatelessWidget {
  final String societyName;
  final String title;
  final String date;
  final String content;

  const _AnnouncementCard({
    Key? key,
    required this.societyName,
    required this.title,
    required this.date,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  societyName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  date,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(content),
          ],
        ),
      ),
    );
  }
}

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  Future<void> _showCreateSocietyDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final categoryController = TextEditingController();
    final descriptionController = TextEditingController();

    final created = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Create Society'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Society name'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter a society name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: categoryController,
                    decoration: const InputDecoration(labelText: 'Category'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter a category';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    minLines: 2,
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter a description';
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
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) {
                  return;
                }

                context.read<AppState>().createSociety(
                      name: nameController.text.trim(),
                      category: categoryController.text.trim(),
                      description: descriptionController.text.trim(),
                    );
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );

    nameController.dispose();
    categoryController.dispose();
    descriptionController.dispose();

    if (created == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Society created successfully.')),
      );
    }
  }

  Future<void> _showCreatePostDialog(BuildContext context) async {
    final appState = context.read<AppState>();
    final societies = appState.societies;

    if (societies.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Create a society before adding posts.')),
      );
      return;
    }

    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String selectedSocietyId = societies.first.id;

    final created = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Create Post'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: selectedSocietyId,
                        decoration: const InputDecoration(labelText: 'Society'),
                        items: societies
                            .map(
                              (society) => DropdownMenuItem<String>(
                                value: society.id,
                                child: Text(society.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() {
                              selectedSocietyId = value;
                            });
                          }
                        },
                      ),
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(labelText: 'Post title'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter a post title';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: contentController,
                        decoration: const InputDecoration(labelText: 'Post content'),
                        minLines: 3,
                        maxLines: 5,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter post content';
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
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) {
                      return;
                    }

                    context.read<AppState>().createAnnouncement(
                          societyId: selectedSocietyId,
                          title: titleController.text.trim(),
                          content: contentController.text.trim(),
                        );
                    Navigator.of(dialogContext).pop(true);
                  },
                  child: const Text('Post'),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    contentController.dispose();

    if (created == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post created successfully.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Societies Feed')),
      body: Consumer<AppState>(
        builder: (context, appState, _) {
          final joinedSocieties = appState.joinedSocieties;
          final joinedSocietyIds = joinedSocieties.map((s) => s.id).toSet();
          final isAdmin = appState.isAdmin;
          final visibleAnnouncements = isAdmin
              ? appState.announcements
              : appState.announcements
                  .where((a) => joinedSocietyIds.contains(a.societyId))
                  .toList();

          if (joinedSocieties.isEmpty) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isAdmin)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Add Post'),
                          onPressed: () {
                            _showCreatePostDialog(context);
                          },
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.group_add),
                          label: const Text('Create Society'),
                          onPressed: () {
                            _showCreateSocietyDialog(context);
                          },
                        ),
                      ],
                    ),
                  ),
                Center(
                  child: Text(
                    isAdmin
                        ? 'No posts yet. Use Add Post to publish your first announcement.'
                        : "You haven't joined any societies yet. Explore to see updates here!",
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            );
          }
          return Column(
            children: [
              if (isAdmin)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Add Post'),
                        onPressed: () {
                          _showCreatePostDialog(context);
                        },
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.group_add),
                        label: const Text('Create Society'),
                        onPressed: () {
                          _showCreateSocietyDialog(context);
                        },
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: visibleAnnouncements.isEmpty
                    ? const Center(
                        child: Text('No announcements yet.'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(24.0),
                        itemCount: visibleAnnouncements.length,
                        itemBuilder: (context, index) {
                          final announcement = visibleAnnouncements[index];
                          return _AnnouncementCard(
                            societyName:
                                appState.societyNameById(announcement.societyId),
                            title: announcement.title,
                            date:
                                '${announcement.date.day.toString().padLeft(2, '0')}/${announcement.date.month.toString().padLeft(2, '0')}/${announcement.date.year}',
                            content: announcement.content,
                          );
                        },
                      ),
                ),
          ],
          );
        },
      ),
    );
  }
}
