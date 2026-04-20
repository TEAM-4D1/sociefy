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
              Expanded(
                child: ListView.builder(
                  itemCount: societies.length,
                  itemBuilder: (context, index) {
                    final society = societies[index];
                    return ListTile(
                      title: Text(society.name),
                      subtitle: Text(society.category),
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
