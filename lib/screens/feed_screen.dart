import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/society.dart';
import '../models/announcement.dart';
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
class _AnnouncementCard extends StatefulWidget {
  final Announcement announcement;
  final String societyName;
  final bool isAdmin;
  final String? currentUserId;
  final Future<void> Function(Announcement announcement) onEdit;
  final Future<void> Function(String id) onDelete;

  const _AnnouncementCard({
    Key? key,
    required this.announcement,
    required this.societyName,
    required this.isAdmin,
    required this.currentUserId,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<_AnnouncementCard> createState() => _AnnouncementCardState();
}

class _AnnouncementCardState extends State<_AnnouncementCard> {
  bool _expanded = false;

  void _toggle() {
    setState(() {
      _expanded = !_expanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final announcement = widget.announcement;
    final canManage = widget.isAdmin && _expanded;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      child: InkWell(
        onTap: _toggle,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.societyName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    '${announcement.date.day.toString().padLeft(2, '0')}/${announcement.date.month.toString().padLeft(2, '0')}/${announcement.date.year}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                announcement.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 6),
              AnimatedCrossFade(
                firstChild: Text(
                  announcement.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                secondChild: Text(announcement.content),
                crossFadeState: _expanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
              ),
              if (canManage)
                Align(
                  alignment: Alignment.centerRight,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () async {
                          await widget.onEdit(announcement);
                        },
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Edit'),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete post'),
                              content: const Text('Are you sure you want to delete this post?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await widget.onDelete(announcement.id);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Post deleted')),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.delete, size: 18),
                        label: const Text('Delete'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
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
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Center(
                child: Text(
                  "You haven't joined any societies yet. Explore to see updates here!",
                  textAlign: TextAlign.center,
                ),
              ),
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
                child: RefreshIndicator(
                  onRefresh: () async {
                    await context.read<AppState>().refreshFeed();
                  },
                  child: () {
                    final isDataLoaded =
                        appState.announcements.isNotEmpty ||
                        appState.societies.isNotEmpty;

                    if (!isDataLoaded) {
                      // Show placeholder shimmer cards while data loads
                      return ListView.builder(
                        padding: const EdgeInsets.all(24.0),
                        itemCount: 4,
                        itemBuilder: (context, index) {
                          return Container(
                            height: 80,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          );
                        },
                      );
                    }

                    if (visibleAnnouncements.isEmpty) {
                      return const Center(child: Text('No announcements yet.'));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(24.0),
                      itemCount: visibleAnnouncements.length,
                      itemBuilder: (context, index) {
                        final announcement = visibleAnnouncements[index];
                        return _AnnouncementCard(
                          announcement: announcement,
                          societyName: appState.societyNameById(
                            announcement.societyId,
                          ),
                          isAdmin: isAdmin,
                          currentUserId: appState.userId,
                          onEdit: (announcement) async {
                            final edited = await showDialog<_CreatePostResult>(
                              context: context,
                              builder: (_) => _CreatePostDialog(
                                societies: appState.societies,
                                initialSocietyId: announcement.societyId,
                                initialTitle: announcement.title,
                                initialContent: announcement.content,
                                isEditing: true,
                              ),
                            );

                            if (edited != null) {
                              await appState.editAnnouncement(
                                id: announcement.id,
                                title: edited.title,
                                content: edited.content,
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Post updated')),
                                );
                              }
                            }
                          },
                          onDelete: (id) => appState.deleteAnnouncement(id),
                        );
                      },
                    );
                  }(),
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
                initialValue: _selectedSocietyId,
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
