import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/society.dart';
import '../providers/app_state.dart';

class _CreateSocietyResult {
  final String name;
  final String category;
  final String description;

  const _CreateSocietyResult({
    required this.name,
    required this.category,
    required this.description,
  });
}

class _CreatePostResult {
  final String societyId;
  final String title;
  final String content;

  const _CreatePostResult({
    required this.societyId,
    required this.title,
    required this.content,
  });
}

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
    final result = await showDialog<_CreateSocietyResult>(
      context: context,
      builder: (_) => const _CreateSocietyDialog(),
    );

    if (result != null && mounted) {
      context.read<AppState>().createSociety(
            name: result.name,
            category: result.category,
            description: result.description,
          );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Society created successfully.')),
      );
    }
  }

  Future<void> _showCreatePostDialog(BuildContext context) async {
    final appState = context.read<AppState>();
    final societies = List.of(appState.societies);

    if (societies.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Create a society before adding posts.')),
      );
      return;
    }

    final result = await showDialog<_CreatePostResult>(
      context: context,
      builder: (_) => _CreatePostDialog(societies: societies),
    );

    if (!mounted) {
      return;
    }

    if (result != null) {
      appState.createAnnouncement(
        societyId: result.societyId,
        title: result.title,
        content: result.content,
      );
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

          if (!isAdmin && joinedSocieties.isEmpty) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                const Center(
                  child: Text(
                    "You haven't joined any societies yet. Explore to see updates here!",
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 8,
                  ),
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

class _CreateSocietyDialog extends StatefulWidget {
  const _CreateSocietyDialog();

  @override
  State<_CreateSocietyDialog> createState() => _CreateSocietyDialogState();
}

class _CreateSocietyDialogState extends State<_CreateSocietyDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Society'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Society name'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter a society name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter a category';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
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
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) {
              return;
            }

            Navigator.of(context).pop(
              _CreateSocietyResult(
                name: _nameController.text.trim(),
                category: _categoryController.text.trim(),
                description: _descriptionController.text.trim(),
              ),
            );
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}

class _CreatePostDialog extends StatefulWidget {
  final List<Society> societies;

  const _CreatePostDialog({required this.societies});

  @override
  State<_CreatePostDialog> createState() => _CreatePostDialogState();
}

class _CreatePostDialogState extends State<_CreatePostDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  late String _selectedSocietyId;

  @override
  void initState() {
    super.initState();
    _selectedSocietyId = widget.societies.first.id;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Post'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedSocietyId,
                decoration: const InputDecoration(labelText: 'Society'),
                items: widget.societies
                    .map(
                      (society) => DropdownMenuItem<String>(
                        value: society.id,
                        child: Text(society.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _selectedSocietyId = value;
                  });
                },
              ),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Post title'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter a post title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _contentController,
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
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) {
              return;
            }

            Navigator.of(context).pop(
              _CreatePostResult(
                societyId: _selectedSocietyId,
                title: _titleController.text.trim(),
                content: _contentController.text.trim(),
              ),
            );
          },
          child: const Text('Post'),
        ),
      ],
    );
  }
}
