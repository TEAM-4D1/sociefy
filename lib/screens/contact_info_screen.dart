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
      appBar: AppBar(title: Text('Contact ${widget.society.name}')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Committee Members',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _committeeMembers.length,
                itemBuilder: (context, index) {
                  final member = _committeeMembers[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(member.role),
                      subtitle: Text(member.name),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.email),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Email: ${member.email}'),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editMember(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _removeMember(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Committee Member'),
                onPressed: _addMember,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
