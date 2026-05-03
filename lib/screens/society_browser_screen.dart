import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'society_detail_screen.dart';

class SocietyBrowserScreen extends StatefulWidget {
  const SocietyBrowserScreen({super.key});

  @override
  State<SocietyBrowserScreen> createState() => _SocietyBrowserScreenState();
}

class _SocietyBrowserScreenState extends State<SocietyBrowserScreen> {
  String _searchQuery = '';
  String? _selectedCategory;

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
          Consumer<AppState>(
            builder: (context, appState, _) {
              final categories = appState.societies
                  .map((s) => s.category)
                  .toSet()
                  .toList();

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: _selectedCategory == null,
                        onSelected: (_) {
                          setState(() => _selectedCategory = null);
                        },
                      ),
                      ...categories.map(
                        (category) => FilterChip(
                          label: Text(category),
                          selected: _selectedCategory == category,
                          onSelected: (_) {
                            setState(() => _selectedCategory = category);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await context.read<AppState>().refreshFeed();
              },
              child: Consumer<AppState>(
                builder: (context, appState, _) {
                  // Show shimmer placeholders while societies are loading
                  if (appState.societies.isEmpty) {
                    return ListView.builder(
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return Container(
                          height: 72,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        );
                      },
                    );
                  }

                  final societies = appState.societies.where((society) {
                    final query = _searchQuery.toLowerCase();
                    final matchesSearch =
                        society.name.toLowerCase().contains(query) ||
                        society.category.toLowerCase().contains(query);
                    final matchesCategory =
                        _selectedCategory == null ||
                        society.category == _selectedCategory;
                    return matchesSearch && matchesCategory;
                  }).toList();

                  if (societies.isEmpty) {
                    return const Center(child: Text('No societies found.'));
                  }

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
          ),
        ],
      ),
    );
  }
}
