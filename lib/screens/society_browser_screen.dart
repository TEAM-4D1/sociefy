import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/society.dart';
import 'society_detail_screen.dart';

/// Allows users to discover and search all available societies with category filtering.
/// Displays society cards and enables navigation to detailed society information.
/// Accessible to all authenticated users; guests can browse but cannot join societies.
class SocietyBrowserScreen extends StatefulWidget {
  const SocietyBrowserScreen({super.key});

  @override
  State<SocietyBrowserScreen> createState() => _SocietyBrowserScreenState();
}

class _SocietyBrowserScreenState extends State<SocietyBrowserScreen>
    with AutomaticKeepAliveClientMixin {
  String _searchQuery = '';
  // ignore: unused_field
  String? _selectedCategory;
  String? _selectedCategoryKey;

  @override
  bool get wantKeepAlive => true;

  /// Filters societies by search query and selected category.
  List<Society> get _filteredSocieties {
    final appState = context.watch<AppState>();
    return appState.societies.where((society) {
      final query = _searchQuery.toLowerCase();
      final matchesSearch =
          society.name.toLowerCase().contains(query) ||
          society.category.toLowerCase().contains(query);
      final matchesCategory =
          _selectedCategoryKey == null ||
          society.category.trim().toLowerCase() == _selectedCategoryKey;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final filteredSocieties = _filteredSocieties;

    return Scaffold(
      appBar: AppBar(title: const Text('Discover Societies')),
      body: Column(
        children: [
          _SearchBar(
            searchQuery: _searchQuery,
            onSearchChanged: (value) {
              setState(() => _searchQuery = value);
            },
          ),
          Consumer<AppState>(
            builder: (context, appState, _) {
              // Normalize and deduplicate categories (case-insensitive, trimmed)
              final Map<String, String> normalized = {};
              for (final s in appState.societies) {
                final raw = s.category;
                final key = raw.trim().toLowerCase();
                if (key.isEmpty) continue;
                // Preserve the first-seen display value for casing
                normalized.putIfAbsent(key, () => raw.trim());
              }
              final categories = normalized.entries.toList();

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: _selectedCategoryKey == null,
                        onSelected: (_) {
                          setState(() => _selectedCategoryKey = null);
                        },
                      ),
                      ...categories.map(
                        (entry) => FilterChip(
                          label: Text(entry.value),
                          selected: _selectedCategoryKey == entry.key,
                          onSelected: (_) {
                            setState(() => _selectedCategoryKey = entry.key);
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

                  final societies = filteredSocieties;

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

/// Stateless search bar widget to prevent unnecessary rebuilds of filter chips when search changes.
class _SearchBar extends StatelessWidget {
  final String searchQuery;
  final Function(String) onSearchChanged;

  const _SearchBar({required this.searchQuery, required this.onSearchChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          hintText: 'Search societies...',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        onChanged: onSearchChanged,
      ),
    );
  }
}
