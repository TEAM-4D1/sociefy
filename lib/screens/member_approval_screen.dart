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
          return const Center(child: Text('Loading pending requests...'));
        },
      ),
    );
  }
}
