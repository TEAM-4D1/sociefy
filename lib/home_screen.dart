//Home screen will include scrolling through posts similar to instagram to catch up on upcoming events posted by the socities they follow, and include search bar, likes count, comments and include buttom prompts to chats/forums
//The logo should be rendered at the top left of the screen here

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> societies = [];
  final List<Map<String, dynamic>> joinedSocieties = [];
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  XFile? _pickedImage;
  PlatformFile? _webPickedFile;
  Uint8List? _webImageBytes;

  void _showCreateSocietyDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Society'),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Society Name'),
                    ),
                    TextField(
                      controller: descController,
                      decoration: const InputDecoration(labelText: 'Description'),
                    ),
                    const SizedBox(height: 8),
                    if (!kIsWeb && _pickedImage == null)
                      TextButton(
                        onPressed: () async {
                          final ImagePicker picker = ImagePicker();
                          final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                          if (image != null) {
                            setState(() {
                              _pickedImage = image;
                            });
                            setStateDialog(() {});
                          }
                        },
                        child: const Text('Pick Image'),
                      )
                    else if (kIsWeb && _webPickedFile == null)
                      TextButton(
                        onPressed: () async {
                          FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
                          if (result != null && result.files.single.bytes != null) {
                            setState(() {
                              _webPickedFile = result.files.single;
                              _webImageBytes = result.files.single.bytes;
                            });
                            setStateDialog(() {});
                          }
                        },
                        child: const Text('Pick Image'),
                      )
                    else if (!kIsWeb && _pickedImage != null) ...[
                      Row(
                        children: [
                          const Icon(Icons.image, size: 18),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _pickedImage!.name,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () {
                              setState(() {
                                _pickedImage = null;
                              });
                              setStateDialog(() {});
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      (_pickedImage!.path.isNotEmpty && File(_pickedImage!.path).existsSync())
                          ? Image.file(File(_pickedImage!.path), height: 120)
                          : const SizedBox.shrink(),
                    ]
                    else if (kIsWeb && _webPickedFile != null && _webImageBytes != null) ...[
                      Row(
                        children: [
                          const Icon(Icons.image, size: 18),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _webPickedFile!.name,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () {
                              setState(() {
                                _webPickedFile = null;
                                _webImageBytes = null;
                              });
                              setStateDialog(() {});
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Image.memory(_webImageBytes!, height: 120),
                    ],
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                nameController.clear();
                descController.clear();
                setState(() {
                  _pickedImage = null;
                  _webPickedFile = null;
                  _webImageBytes = null;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && descController.text.isNotEmpty) {
                  setState(() {
                    societies.add({
                      'name': nameController.text,
                      'desc': descController.text,
                      'image': kIsWeb ? _webImageBytes : _pickedImage?.path,
                      'imageName': kIsWeb ? _webPickedFile?.name : _pickedImage?.name,
                    });
                    _pickedImage = null;
                    _webPickedFile = null;
                    _webImageBytes = null;
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
          title: const Text('Joined Society'),
          content: const Text('You have joined this society.'),
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

  void _joinSociety(int index) {
    setState(() {
      joinedSocieties.add(societies[index]);
      societies.removeAt(index);
    });
    _showJoinConfirmation(joinedSocieties.last['name'] ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: (societies.isEmpty && joinedSocieties.isEmpty)
          ? const Center(child: Text('No societies yet.'))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (joinedSocieties.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text('Joined Societies', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: joinedSocieties.length,
                        itemBuilder: (context, index) {
                          final society = joinedSocieties[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 280,
                                    color: Colors.grey[300],
                                    child: kIsWeb
                                        ? (society['image'] != null
                                            ? Image.memory(society['image'], fit: BoxFit.cover)
                                            : const Center(child: Text('Image Placeholder')))
                                        : (society['image'] != null
                                            ? Image.file(File(society['image']), fit: BoxFit.cover)
                                            : const Center(child: Text('Image Placeholder'))),
                                  ),
                                  const SizedBox(height: 8),
                                  const Divider(),
                                  const SizedBox(height: 8),
                                  Text(
                                    society['name'] ?? '',
                                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(society['desc'] ?? ''),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                    if (societies.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text('Available Societies', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: societies.length,
                        itemBuilder: (context, index) {
                          final society = societies[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 280,
                                    color: Colors.grey[300],
                                    child: kIsWeb
                                        ? (society['image'] != null
                                            ? Image.memory(society['image'], fit: BoxFit.cover)
                                            : const Center(child: Text('Image Placeholder')))
                                        : (society['image'] != null
                                            ? Image.file(File(society['image']), fit: BoxFit.cover)
                                            : const Center(child: Text('Image Placeholder'))),
                                  ),
                                  const SizedBox(height: 8),
                                  const Divider(),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          society['name'] ?? '',
                                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          _joinSociety(index);
                                        },
                                        child: const Text('Join'),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(society['desc'] ?? ''),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateSocietyDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
