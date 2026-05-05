import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/society.dart';
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
                      return _SocietyBrowserCard(
                        key: ValueKey(society.id),
                        society: society,
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

class _SocietyBrowserCard extends StatefulWidget {
  final Society society;

  const _SocietyBrowserCard({super.key, required this.society});

  @override
  State<_SocietyBrowserCard> createState() => _SocietyBrowserCardState();
}

class _SocietyBrowserCardState extends State<_SocietyBrowserCard> {
  bool _showActions = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final canDelete = appState.canDeleteSociety(widget.society);

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: InkWell(
            onTap: () {
              if (canDelete) {
                setState(() {
                  _showActions = !_showActions;
                });
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SocietyDetailScreen(society: widget.society),
                ),
              );
            },
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ListTile(
                    title: Text(widget.society.name),
                    subtitle: Text(widget.society.category),
                    trailing: Icon(
                      canDelete ? Icons.expand_more : Icons.chevron_right,
                    ),
                  ),
                ),
                if (canDelete && _showActions)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                      ),
                      child: IconButton(
                        tooltip: 'Delete society',
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              title: const Text('Delete society'),
                              content: Text(
                                'Delete ${widget.society.name}? This cannot be undone.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(dialogContext).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.of(dialogContext).pop(true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );

                          if (confirmed == true) {
                            await context.read<AppState>().deleteSociety(widget.society.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${widget.society.name} deleted'),
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
