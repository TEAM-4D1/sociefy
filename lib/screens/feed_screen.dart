import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/society.dart';
import '../models/announcement.dart';
import '../providers/app_state.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

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
  final String? imageUrl;

  const _CreatePostResult({
    required this.societyId,
    required this.title,
    required this.content,
    this.imageUrl,
  });
}

// Announcement card for feed
class _AnnouncementCard extends StatefulWidget {
  final String societyName;
  final String title;
  final String date;
  final String content;
  final String? imageUrl;
  final int likeCount;
  final bool isLikedByCurrentUser;
  final String? userId;
  final VoidCallback onLikeTap;
  final List<Comment> comments;
  final Function(String) onCommentAdded;

  const _AnnouncementCard({
    Key? key,
    required this.societyName,
    required this.title,
    required this.date,
    required this.content,
    this.imageUrl,
    required this.likeCount,
    required this.isLikedByCurrentUser,
    this.userId,
    required this.onLikeTap,
    required this.comments,
    required this.onCommentAdded,
  }) : super(key: key);

  @override
  State<_AnnouncementCard> createState() => _AnnouncementCardState();
}

class _AnnouncementCardState extends State<_AnnouncementCard> {
  final TextEditingController _commentController = TextEditingController();
  bool _showCommentInput = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _addComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    widget.onCommentAdded(text);
    _commentController.clear();
    setState(() => _showCommentInput = false);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

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
                Flexible(
                  child: Text(
                    widget.societyName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  widget.date,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            if (widget.imageUrl != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Image.network(
                  widget.imageUrl!,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),
              ),
            Text(widget.content),
            const SizedBox(height: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: widget.onLikeTap,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.isLikedByCurrentUser
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: 18,
                        color: widget.isLikedByCurrentUser
                            ? Colors.red
                            : Colors.grey.shade500,
                      ),
                      if (widget.likeCount > 0) ...[
                        const SizedBox(width: 6),
                        Text(
                          widget.likeCount.toString(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                if (!_showCommentInput)
                  GestureDetector(
                    onTap: () => setState(() => _showCommentInput = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 16,
                            color: cs.onSurface,
                          ),
                          if (widget.comments.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Text(
                              '${widget.comments.length}',
                              style: TextStyle(
                                fontSize: 12,
                                color: cs.onSurface,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.grey.shade300),
            const SizedBox(height: 12),

            // Expanded comments view
            if (_showCommentInput)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Show all comments when expanded
                  if (widget.comments.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...widget.comments.map(
                          (comment) => Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      comment.author,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      '${comment.dateTime.hour.toString().padLeft(2, '0')}:${comment.dateTime.minute.toString().padLeft(2, '0')}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  comment.content,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Divider(color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                      ],
                    ),
                  // Comment input
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: InputDecoration(
                            hintText: 'Add a comment...',
                            filled: true,
                            fillColor: cs.surfaceContainerHighest,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: const TextStyle(fontSize: 12),
                          maxLines: null,
                          minLines: 1,
                          autofocus: true,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _addComment,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: cs.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.send,
                            size: 16,
                            color: cs.onPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// Displays the main announcements feed with real-time updates from all societies.
/// Provides admin capabilities to create societies and announcements. Shows pull-to-refresh functionality.
/// Accessible to authenticated students and admins; guests can view but not create.
class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  /// Shows a dialog for creating a new society and creates it if confirmed.
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

  /// Shows a dialog for creating a new announcement for a society.
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

    if (!mounted) return;

    if (result != null) {
      appState.createAnnouncement(
        societyId: result.societyId,
        title: result.title,
        content: result.content,
        imageUrl: result.imageUrl,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post created successfully.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
            return const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
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
                        onPressed: () => _showCreatePostDialog(context),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.group_add),
                        label: const Text('Create Society'),
                        onPressed: () => _showCreateSocietyDialog(context),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await context.read<AppState>().refreshFeed();
                  },
                  child: Builder(
                    builder: (context) {
                      final isDataLoaded =
                          appState.announcements.isNotEmpty ||
                          appState.societies.isNotEmpty;

                      if (!isDataLoaded) {
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
                        return const Center(
                          child: Text('No announcements yet.'),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(24.0),
                        itemCount: visibleAnnouncements.length,
                        itemBuilder: (context, index) {
                          final announcement = visibleAnnouncements[index];
                          final userId =
                              FirebaseAuth.instance.currentUser?.uid ?? '';
                          final displayName =
                              FirebaseAuth.instance.currentUser?.displayName ??
                              'You';

                          return _AnnouncementCard(
                            societyName: appState.societyNameById(
                              announcement.societyId,
                            ),
                            title: announcement.title,
                            date:
                                '${announcement.date.day.toString().padLeft(2, '0')}/${announcement.date.month.toString().padLeft(2, '0')}/${announcement.date.year}',
                            content: announcement.content,
                            imageUrl: announcement.imageUrl,
                            likeCount: announcement.likeCount,
                            isLikedByCurrentUser: announcement.isLikedByUser(
                              userId,
                            ),
                            userId: userId,
                            onLikeTap: () async {
                              if (userId.isEmpty) return;

                              final wasLiked = announcement.isLikedByUser(
                                userId,
                              );
                              setState(() {
                                announcement.toggleLike(userId);
                              });

                              try {
                                if (wasLiked) {
                                  // Remove like from Firestore
                                  await FirebaseFirestore.instance
                                      .collection('announcements')
                                      .doc(announcement.id)
                                      .collection('likes')
                                      .doc(userId)
                                      .delete();
                                } else {
                                  // Add like to Firestore
                                  await FirebaseFirestore.instance
                                      .collection('announcements')
                                      .doc(announcement.id)
                                      .collection('likes')
                                      .doc(userId)
                                      .set({
                                        'userId': userId,
                                        'createdAt':
                                            FieldValue.serverTimestamp(),
                                      });
                                }
                              } catch (e) {
                                debugPrint('Error toggling like: $e');
                                // Revert local state on error
                                setState(() {
                                  announcement.toggleLike(userId);
                                });
                              }
                            },
                            comments: announcement.comments,
                            onCommentAdded: (commentText) async {
                              if (userId.isEmpty || commentText.trim().isEmpty)
                                return;

                              try {
                                // Add comment to Firestore
                                final docRef = await FirebaseFirestore.instance
                                    .collection('announcements')
                                    .doc(announcement.id)
                                    .collection('comments')
                                    .add({
                                      'author': displayName,
                                      'content': commentText.trim(),
                                      'dateTime': FieldValue.serverTimestamp(),
                                    });

                                // Add to local state
                                setState(() {
                                  announcement.comments.add(
                                    Comment(
                                      id: docRef.id,
                                      author: displayName,
                                      content: commentText.trim(),
                                      dateTime: DateTime.now(),
                                    ),
                                  );
                                });
                              } catch (e) {
                                debugPrint('Error adding comment: $e');
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Failed to add comment'),
                                    ),
                                  );
                                }
                              }
                            },
                          );
                        },
                      );
                    },
                  ),
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
            if (!_formKey.currentState!.validate()) return;
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
  XFile? _pickedImage;
  bool _uploading = false;

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

  /// Allows the user to select an image from the device gallery for attachment to announcements.
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null && mounted) {
      setState(() => _pickedImage = image);
    }
  }

  /// Uploads the picked image to Firebase Storage and returns the download URL.
  /// Returns null if the upload fails or the platform is web (File not supported on web).
  Future<String?> _uploadImage(XFile image) async {
    // File-based upload is not supported on web
    if (kIsWeb) return null;
    try {
      final storageRef = FirebaseStorage.instance.ref();
      final fileName =
          'post_images/${DateTime.now().millisecondsSinceEpoch}_${image.name}';
      final imageRef = storageRef.child(fileName);
      final uploadTask = imageRef.putFile(File(image.path));
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Image upload error: $e');
      return null;
    }
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
                  if (value == null) return;
                  setState(() => _selectedSocietyId = value);
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
              const SizedBox(height: 12),
              if (_pickedImage != null)
                Column(
                  children: [
                    // Safe image preview — never use File() on web
                    kIsWeb
                        ? const Icon(Icons.image, size: 60, color: Colors.grey)
                        : Image.file(File(_pickedImage!.path), height: 120),
                    TextButton(
                      onPressed: () => setState(() => _pickedImage = null),
                      child: const Text('Remove Image'),
                    ),
                  ],
                ),
              if (_pickedImage == null)
                OutlinedButton.icon(
                  icon: const Icon(Icons.image),
                  label: const Text('Add Image'),
                  onPressed: _pickImage,
                ),
              if (_uploading) ...[
                const SizedBox(height: 8),
                const CircularProgressIndicator(),
              ],
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
          onPressed: () async {
            if (!_formKey.currentState!.validate()) return;
            String? imageUrl;
            if (_pickedImage != null) {
              setState(() => _uploading = true);
              imageUrl = await _uploadImage(_pickedImage!);
              if (!mounted) return;
              setState(() => _uploading = false);
            }
            if (!mounted) return;
            Navigator.of(context).pop(
              _CreatePostResult(
                societyId: _selectedSocietyId,
                title: _titleController.text.trim(),
                content: _contentController.text.trim(),
                imageUrl: imageUrl,
              ),
            );
          },
          child: const Text('Post'),
        ),
      ],
    );
  }
}
