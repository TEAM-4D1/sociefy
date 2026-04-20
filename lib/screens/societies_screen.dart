import '../theme/colours.dart';
import '../theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class SocietiesScreen extends StatefulWidget {
  const SocietiesScreen({Key? key}) : super(key: key);

  @override
  State<SocietiesScreen> createState() => _SocietiesScreenState();
}

class _SocietiesScreenState extends State<SocietiesScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Societies')),
      body: Consumer<AppState>(
        builder: (context, appState, _) {
          final societies = appState.societies
              .where((s) => s.name.toLowerCase().contains(_query.toLowerCase()))
              .toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Search societies...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _query = value;
                    });
                  },
                ),
              ),

              if (societies.isEmpty)
                const Expanded(child: Center(child: Text('No societies found')))
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: societies.length,
                    itemBuilder: (context, index) {
                      final society = societies[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        elevation: 2,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 6,
                              height: 90,
                              decoration: BoxDecoration(
                                color: AppColours.primaryPurple,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  bottomLeft: Radius.circular(8),
                                ),
                              ),
                            ),

                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            society.name,
                                            style: AppTextStyles.heading2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Chip(
                                          label: Text(
                                            society.category,
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                          backgroundColor: AppColours
                                              .accentAmber
                                              .withValues(alpha: 0.15),
                                          labelStyle: TextStyle(
                                            color: AppColours.accentAmber,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          padding: EdgeInsets.zero,
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 4),

                                    Text(
                                      society.description,
                                      style: AppTextStyles.bodyGrey,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),

                                    const SizedBox(height: 8),

                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.people,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 4),

                                        const Text('Members'),

                                        const Spacer(),

                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: society.isJoined
                                                ? Colors.grey[300]
                                                : AppColours.primaryPurple,
                                            foregroundColor: society.isJoined
                                                ? Colors.black87
                                                : Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 8,
                                            ),
                                          ),
                                          onPressed: () async {
                                            final appState = context
                                                .read<AppState>();

                                            if (society.isJoined) {
                                              await appState.leaveSociety(
                                                society.id,
                                              );
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Left ${society.name}',
                                                  ),
                                                ),
                                              );
                                            } else {
                                              await appState.joinSociety(
                                                society.id,
                                              );
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Joined ${society.name}',
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                          child: Text(
                                            society.isJoined ? 'Leave' : 'Join',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
