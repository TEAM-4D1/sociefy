import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'society_model.dart';
import 'society_detail_page.dart';
import 'widgets/society_image.dart';

/// Home tab — lists every society and lets the user create or join one.
///
/// When [notifier] is provided (the in-app case from `MainTabs`) the screen
/// reads and writes through the shared store, so a join here is reflected on
/// the Messages tab. When [notifier] is omitted (the unit-test case) the
/// page falls back to a private, locally-owned `SocietyNotifier` so each test
/// starts from an empty state.
class HomePage extends StatefulWidget {
  /// Optional shared store. Null → page owns and disposes its own instance.
  final SocietyNotifier? notifier;

  const HomePage({super.key, this.notifier});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final SocietyNotifier _notifier;
  bool _ownNotifier = false;

  // Form state for the "Create Society" dialog.
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  Uint8List? _pickedImageBytes;
  String? _pickedImageName;

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

  /// Launch the system image picker and read the result as bytes.
  ///
  /// Bytes are stored (rather than a path) so they render uniformly on
  /// mobile, desktop and web — this is what removes the "_Namespace" error
  /// triggered by `dart:io` File on platforms without a real filesystem.
  Future<void> _pickImage(StateSetter setDialogState) async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;
    final bytes = await image.readAsBytes();
    setDialogState(() {
      _pickedImageBytes = bytes;
      _pickedImageName = image.name;
    });
  }

  /// Show the modal that captures name/description/image and adds the
  /// resulting [Society] to the store on Create.
  void _showCreateSocietyDialog() {
    nameController.clear();
    descController.clear();
    _pickedImageBytes = null;
    _pickedImageName = null;

    showDialog(
      context: context,
      builder: (ctx) {
        // StatefulBuilder lets the picked-image preview rebuild without
        // triggering setState on the underlying HomePage.
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
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
                    if (_pickedImageBytes == null)
                      TextButton.icon(
                        onPressed: () => _pickImage(setDialogState),
                        icon: const Icon(Icons.image_outlined),
                        label: const Text('Pick Image'),
                      )
                    else ...[
                      Text(
                        _pickedImageName ?? 'Selected image',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          _pickedImageBytes!,
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
                    _pickedImageBytes = null;
                    _pickedImageName = null;
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
                        imageBytes: _pickedImageBytes,
                      ));
                      nameController.clear();
                      descController.clear();
                      _pickedImageBytes = null;
                      _pickedImageName = null;
                      Navigator.of(ctx).pop();
                    }
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Mark a society as joined and confirm it via dialog. The confirmation
  /// dialog is required by the HP-10 / HP-11 test cases.
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

  /// Push the society detail route, sharing the same notifier so a
  /// join/leave on the detail page reflects back here immediately.
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

  /// Build a single animated card. Cycles through [gradients] by index so
  /// the empty-banner placeholders feel varied without needing per-society
  /// colour fields.
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
            // Tappable banner → opens detail page.
            GestureDetector(
              onTap: () => _openDetail(society),
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(
                  children: [
                    SocietyImage(
                      bytes: society.imageBytes,
                      gradientColors: gradient,
                      height: 160,
                    ),
                    Positioned(
                      bottom: 10,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.open_in_new,
                                size: 12, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              'View details',
                              style: TextStyle(
                                color: Colors.white,
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
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
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
                          label: const Text(
                            'Joined',
                            style: TextStyle(fontSize: 12),
                          ),
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
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
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
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
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
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
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
