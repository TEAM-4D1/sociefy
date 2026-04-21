import 'society_detail_screen.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'package:flutter/material.dart';

class SocietyBrowserScreen extends StatefulWidget {
  const SocietyBrowserScreen({Key? key}) : super(key: key);

  @override
  State<SocietyBrowserScreen> createState() => _SocietyBrowserScreenState();
}

class _SocietyBrowserScreenState extends State<SocietyBrowserScreen> {
  String _searchQuery = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discover Societies')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search societies...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
          Expanded(
            child: Consumer<AppState>(
              builder: (context, appState, _) {
                final societies = appState.societies.where((society) {
                  final query = _searchQuery.toLowerCase();
                  return society.name.toLowerCase().contains(query) ||
                      society.category.toLowerCase().contains(query);
                }).toList();
                return ListView.builder(
                  itemCount: societies.length,
                  itemBuilder: (context, index) {
                    final society = societies[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: Text(society.name),
                        subtitle: Text(society.category),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  SocietyDetailScreen(society: society),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
