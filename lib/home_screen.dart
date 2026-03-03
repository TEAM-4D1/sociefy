//Home screen will include scrolling through posts similar to instagram to catch up on upcoming events posted by the socities they follow, and include search bar, likes count, comments and include buttom prompts to chats/forums
//The logo should be rendered at the top left of the screen here

import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, String>> societies = [];
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  void _showCreateSocietyDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Society'),
          content: Column(
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
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                nameController.clear();
                descController.clear();
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
                    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: societies.isEmpty
          ? const Center(child: Text('No societies yet.'))
          : ListView.builder(
              itemCount: societies.length,
              itemBuilder: (context, index) {
                final society = societies[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 280, // Increased height for image placeholder (4x larger)
                            color: Colors.grey[300],
                            child: const Center(child: Text('Image Placeholder')),
                          ),
                          const SizedBox(height: 8),
                          const Divider(), // Line dividing image and title
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  society['name'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 22, // Larger font for title
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  _showJoinConfirmation(society['name'] ?? ''); 
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
                  ),
                );
              },
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateSocietyDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
