import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/app_bar_logo_action.dart';
import '../widgets/app_gradient_background.dart';

/// Admin-only interface for approving or rejecting pending society membership requests.
/// Displays pending members with buttons to accept or deny applications.
/// Accessible only to admin users; students and guests cannot access this screen.
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
      appBar: AppBar(
        title: const Text('Approve New Members'),
        actions: const [AppBarLogoAction()],
      ),
      body: AppGradientBackground(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('pending_memberships')
              .where('societyId', isEqualTo: widget.societyId)
              .snapshots(),          builder: (context, snapshot) {
            // Loading state
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // Error state
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading pending requests.'));
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
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    title: Text('User: $userId'),
                    subtitle: Text('Request ID: ${req.id}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [                        // APPROVE
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            try {
                              await FirebaseFirestore.instance
                                  .collection('memberships')
                                  .doc('${userId}_${widget.societyId}')
                                  .set({
                                    'userId': userId,
                                    'societyId': widget.societyId,
                                    'joinedAt': FieldValue.serverTimestamp(),
                                  });

                              await req.reference.delete();
                            } catch (e) {
                              messenger.showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          },
                        ),                        // REJECT
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            try {
                              await req.reference.delete();
                            } catch (e) {
                              messenger.showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
