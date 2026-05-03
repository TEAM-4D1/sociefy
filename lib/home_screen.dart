import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, String?>> societies = [];
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  XFile? _pickedImage;

  @override
  void dispose() {
    nameController.dispose();
    descController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    setState(() => _pickedImage = image);
  }

  void _showCreateSocietyDialog() {
    nameController.clear();
    descController.clear();
    _pickedImage = null;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            children: [
              Icon(Icons.groups, color: Theme.of(context).colorScheme.primary),
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
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  (_pickedImage!.path.isNotEmpty &&
                          File(_pickedImage!.path).existsSync())
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(_pickedImage!.path),
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const SizedBox.shrink(),
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
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    descController.text.isNotEmpty) {
                  setState(() {
                    societies.add({
                      'name': nameController.text,
                      'desc': descController.text,
                      'image': _pickedImage?.path,
                    });
                    _pickedImage = null;
                  });
                  nameController.clear();
                  descController.clear();
                  Navigator.of(context).pop();
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
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              const Text('Joined Society'),
            ],
          ),
          content: Text('You have successfully joined "$societyName".'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSocietyCard(Map<String, String?> society, int index) {
    final colorScheme = Theme.of(context).colorScheme;
    final gradients = [
      [colorScheme.primary, colorScheme.tertiary],
      [Colors.indigo.shade400, Colors.purple.shade600],
      [Colors.teal.shade400, Colors.cyan.shade600],
    ];
    final gradient = gradients[index % gradients.length];

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 350 + index * 80),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 24 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header image / gradient banner
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: SizedBox(
                height: 160,
                width: double.infinity,
                child: society['image'] != null &&
                        File(society['image']!).existsSync()
                    ? Image.file(
                        File(society['image']!),
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
                        child: const Center(
                          child: Icon(
                            Icons.groups,
                            size: 64,
                            color: Colors.white,
                          ),
                        ),
                      ),
              ),
            ),
            // Society info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          society['name'] ?? '',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            _showJoinConfirmation(society['name'] ?? ''),
                        child: const Text('Join'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    society['desc'] ?? '',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.grey.shade600),
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
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
            tooltip: 'Search',
          ),
        ],
      ),
      body: societies.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.groups_outlined,
                    size: 88,
                    color: Colors.grey.shade300,
                  ),
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
              itemCount: societies.length,
              itemBuilder: (context, index) =>
                  _buildSocietyCard(societies[index], index),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateSocietyDialog,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }
}
