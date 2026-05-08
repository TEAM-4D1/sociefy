import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'society_chat_screen.dart';
import 'member_approval_screen.dart';
import '../widgets/app_bar_logo_action.dart';

/// Displays a list of society group chat channels that the user is a member of.
/// Provides quick access to messages and member approval features for committee admins.
/// Accessible only to authenticated users who have joined societies.
class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final joinedSocieties = appState.joinedSocieties;
        final isCommittee = appState.isAdmin;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Messages',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            actions: const [AppBarLogoAction()],
          ),
          body: joinedSocieties.isEmpty
              ? const Center(
                  child: Text('Join a society to access its message channel.'),
                )
              : ListView.builder(
                  itemCount: joinedSocieties.length,
                  itemBuilder: (context, index) {
                    final society = joinedSocieties[index];
                    return ListTile(
                      leading: const Icon(Icons.forum),
                      title: Text(society.name),
                      subtitle: Text(society.category),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SocietyChatScreen(society: society),
                          ),
                        );
                      },
                      trailing: isCommittee
                          ? IconButton(
                              icon: const Icon(
                                Icons.admin_panel_settings,
                                color: Colors.deepPurple,
                              ),
                              tooltip: 'Approve Members',
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (ctx) => SizedBox(
                                    height:
                                        MediaQuery.of(context).size.height *
                                        0.7,
                                    child: MemberApprovalScreen(
                                      societyId: society.id,
                                    ),
                                  ),
                                );
                              },
                            )
                          : null,
                    );
                  },
                ),
        );
      },
    );
  }
}
