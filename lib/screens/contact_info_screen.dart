import 'package:flutter/material.dart';

import '../models/society.dart';
import '../models/committee_member.dart';

class ContactInfoScreen extends StatefulWidget {
  final Society society;
  const ContactInfoScreen({Key? key, required this.society}) : super(key: key);

  @override
  State<ContactInfoScreen> createState() => _ContactInfoScreenState();
}

class _ContactInfoScreenState extends State<ContactInfoScreen> {
  late List<CommitteeMember> _committeeMembers;

  @override
  void initState() {
    super.initState();
    _committeeMembers = List<CommitteeMember>.from(
      widget.society.committeeMembers,
    );
  }

  void _editMember(int index) async {
    final member = _committeeMembers[index];
    final result = await showDialog<CommitteeMember>(
      context: context,
      builder: (context) => _CommitteeMemberDialog(member: member),
    );
    if (result != null) {
      setState(() {
        _committeeMembers[index] = result;
      });
    }
  }

  void _addMember() async {
    final result = await showDialog<CommitteeMember>(
      context: context,
      builder: (context) => _CommitteeMemberDialog(),
    );
    if (result != null) {
      setState(() {
        _committeeMembers.add(result);
      });
    }
  }

  void _removeMember(int index) {
    setState(() {
      _committeeMembers.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Contact ${society.name}')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            const Text(
              'Committee Members',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.person),
                title: const Text('President'),
                subtitle: const Text('Alex Johnson'),
                trailing: IconButton(
                  icon: const Icon(Icons.email),
                  onPressed: () => _showComingSoon(context),
                ),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Secretary'),
                subtitle: const Text('Jamie Lee'),
                trailing: IconButton(
                  icon: const Icon(Icons.email),
                  onPressed: () => _showComingSoon(context),
                ),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Treasurer'),
                subtitle: const Text('Morgan Smith'),
                trailing: IconButton(
                  icon: const Icon(Icons.email),
                  onPressed: () => _showComingSoon(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
