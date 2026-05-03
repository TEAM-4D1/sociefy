import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MemberApprovalScreen extends StatefulWidget {
  final String societyId;

  const MemberApprovalScreen({Key? key, required this.societyId})
    : super(key: key);

  @override
  State<MemberApprovalScreen> createState() => _MemberApprovalScreenState();
}

class _MemberApprovalScreenState extends State<MemberApprovalScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Approve New Members')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('pending_memberships')
            .where('societyId', isEqualTo: widget.societyId)
            .snapshots(),
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Empty state
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No pending requests.'));
          }

          final requests = snapshot.data!.docs;

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final req = requests[index];
              final userId = req['userId'];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text('User: $userId'),
                  subtitle: Text('Request ID: ${req.id}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
