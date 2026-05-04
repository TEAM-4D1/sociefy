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

class _CommitteeMemberDialog extends StatefulWidget {
  final CommitteeMember? member;
  const _CommitteeMemberDialog({Key? key, this.member}) : super(key: key);

  @override
  State<_CommitteeMemberDialog> createState() => __CommitteeMemberDialogState();
}

class __CommitteeMemberDialogState extends State<_CommitteeMemberDialog> {
  late TextEditingController _nameController;
  late TextEditingController _roleController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.member?.name ?? '');
    _roleController = TextEditingController(text: widget.member?.role ?? '');
    _emailController = TextEditingController(text: widget.member?.email ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.member == null
            ? 'Add Committee Member'
            : 'Edit Committee Member',
      ),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _roleController,
              decoration: const InputDecoration(labelText: 'Role'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final member = CommitteeMember(
              name: _nameController.text,
              role: _roleController.text,
              email: _emailController.text,
            );
            Navigator.of(context).pop(member);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
