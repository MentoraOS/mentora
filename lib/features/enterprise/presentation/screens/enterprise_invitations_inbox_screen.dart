import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../application/workspace/workspace_state.dart';
import '../../../../application/authentication/authentication_session.dart';
import '../../../../core/di/modules/enterprise_module.dart';
import '../controllers/enterprise_invitation_controller.dart';

class EnterpriseInvitationsInboxScreen extends StatefulWidget {
  const EnterpriseInvitationsInboxScreen({super.key});

  @override
  State<EnterpriseInvitationsInboxScreen> createState() =>
      _EnterpriseInvitationsInboxScreenState();
}

class _EnterpriseInvitationsInboxScreenState
    extends State<EnterpriseInvitationsInboxScreen> {
  late final EnterpriseInvitationController controller;

  @override
  void initState() {
    super.initState();
    controller = EnterpriseModule.createInvitationController(
      workspaceState: context.read<WorkspaceState>(),
      session: context.read<AuthenticationSession>(),
    );
    controller.loadPendingInvitations();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Mes invitations')),
          body: _buildBody(),
        );
      },
    );
  }

  Widget _buildBody() {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.error != null) {
      return Center(child: Text(controller.error!));
    }

    if (controller.pendingInvitations.isEmpty) {
      return const Center(child: Text('Aucune invitation en attente'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: controller.pendingInvitations.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final invitation = controller.pendingInvitations[index];

        return Card(
          child: ListTile(
            leading: const Icon(Icons.business),
            title: Text(invitation.workspaceName),
            subtitle: Text('${invitation.department} · ${invitation.role}'),
            trailing: Wrap(
              spacing: 8,
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () async {
                    await controller.rejectInvitation(invitation.id);
                    await controller.loadPendingInvitations();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: controller.isLoading
                      ? null
                      : () async {
                          await controller.acceptInvitation(invitation.id);

                          if (!context.mounted) return;

                          if (controller.error != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(controller.error!)),
                            );
                            return;
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Bienvenue dans ${invitation.workspaceName} 🎉',
                              ),
                            ),
                          );

                          Navigator.pop(context);
                        },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
