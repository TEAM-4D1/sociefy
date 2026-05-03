import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'society_model.dart';
import 'society_detail_page.dart';

class HomePage extends StatefulWidget {
  final SocietyNotifier? notifier;
  const HomePage({super.key, this.notifier});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final SocietyNotifier _notifier;
  bool _ownNotifier = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  XFile? _pickedImage;

  @override
  void initState() {
    super.initState();
    if (widget.notifier != null) {
      _notifier = widget.notifier!;
    } else {
      _notifier = SocietyNotifier();
      _ownNotifier = true;
    }
  }

  @override
  void dispose() {
    if (_ownNotifier) _notifier.dispose();
    nameController.dispose();
    descController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() => _pickedImage = image);
  }

  void _showCreateSocietyDialog() {
    nameController.clear();
    descController.clear();
    _pickedImage = null;
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Icon(Icons.groups,
                  color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              const Text('Create Society'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Society Name',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(Icons.description_outlined),
                  ),
                  maxLines: 3,
                  minLines: 1,
                ),
                const SizedBox(height: 8),
                if (_pickedImage == null)
                  TextButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image_outlined),
                    label: const Text('Pick Image'),
                  )
                else ...[
                  Text(
                    _pickedImage!.name,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  if (_pickedImage!.path.isNotEmpty &&
                      File(_pickedImage!.path).existsSync())
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(_pickedImage!.path),
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                nameController.clear();
                descController.clear();
                setState(() => _pickedImage = null);
                Navigator.of(ctx).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    descController.text.isNotEmpty) {
                  _notifier.add(Society(
                    name: nameController.text,
                    description: descController.text,
                    imagePath: _pickedImage?.path,
                  ));
                  nameController.clear();
                  descController.clear();
                  setState(() => _pickedImage = null);
                  Navigator.of(ctx).pop();
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void _showJoinConfirmation(String societyName) {
    _notifier.join(societyName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(Icons.check_circle,
                color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            const Text('Joined Society'),
          ],
        ),
        content: Text('You have successfully joined "$societyName".'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _openDetail(Society society) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SocietyDetailPage(
          society: society,
          notifier: _notifier,
        ),
      ),
    );
  }

  Widget _buildSocietyCard(Society society, int index) {
    final cs = Theme.of(context).colorScheme;
    final gradients = [
      [cs.primary, cs.tertiary],
      [Colors.indigo.shade400, Colors.purple.shade600],
      [Colors.teal.shade400, Colors.cyan.shade600],
    ];
    final gradient = gradients[index % gradients.length];
    final joined = _notifier.isJoined(society.name);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 350 + index * 80),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Transform.translate(
        offset: Offset(0, 24 * (1 - value)),
        child: Opacity(opacity: value, child: child),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tappable gradient / image banner → opens detail page
            GestureDetector(
              onTap: () => _openDetail(society),
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: society.imagePath != null &&
                          File(society.imagePath!).existsSync()
                      ? Image.file(
                          File(society.imagePath!),
                          fit: BoxFit.cover,
                        )
                      : Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: gradient,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Stack(
                            children: [
                              const Center(
                                child: Icon(
                                  Icons.groups,
                                  size: 64,
                                  color: Colors.white,
                                ),
                              ),
                              Positioned(
                                bottom: 10,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black26,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.open_in_new,
                                          size: 12, color: Colors.white70),
                                      SizedBox(width: 4),
                                      Text(
                                        'View details',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 11,
                                        ),
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
            ),

            // Society info row
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Tapping the name also opens detail
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _openDetail(society),
                          child: Text(
                            society.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (joined)
                        Chip(
                          label: const Text('Joined',
                              style: TextStyle(fontSize: 12)),
                          backgroundColor: cs.primaryContainer,
                          labelStyle:
                              TextStyle(color: cs.onPrimaryContainer),
                          padding: EdgeInsets.zero,
                        )
                      else
                        ElevatedButton(
                          onPressed: () =>
                              _showJoinConfirmation(society.name),
                          child: const Text('Join'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    society.description,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.grey.shade600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.people_outline,
                          size: 13, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Text(
                        '${society.members.length} members',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListenableBuilder(
      listenable: _notifier,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Home'),
            backgroundColor: cs.surface,
            foregroundColor: cs.onSurface,
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {},
                tooltip: 'Search',
              ),
            ],
          ),
          body: _notifier.societies.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.groups_outlined,
                          size: 88, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      const Text(
                        'No societies yet.',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tap + to create your first society',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: _notifier.societies.length,
                  itemBuilder: (ctx, i) =>
                      _buildSocietyCard(_notifier.societies[i], i),
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: _showCreateSocietyDialog,
            backgroundColor: cs.primary,
            foregroundColor: cs.onPrimary,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
