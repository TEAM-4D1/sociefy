import 'package:flutter/material.dart';

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
      body: const Center(child: Text('Member approval screen')),
    );
  }
}
