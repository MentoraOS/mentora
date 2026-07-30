import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../application/authentication/authentication_session.dart';
import '../../../../application/workspace/workspace_state.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/di/modules/enterprise_module.dart';
import '../controllers/enterprise_member_controller.dart';
import '../../../../core/permissions/permission_engine.dart';

class EnterpriseMembersScreen extends StatefulWidget {
  const EnterpriseMembersScreen({super.key});

  @override
  State<EnterpriseMembersScreen> createState() =>
      _EnterpriseMembersScreenState();
}

class _EnterpriseMembersScreenState extends State<EnterpriseMembersScreen> {
  late final EnterpriseMemberController controller;

  @override
  void initState() {
    super.initState();
    controller = EnterpriseModule.createMemberController(
      workspaceState: context.read<WorkspaceState>(),
    );
    controller.loadMembers();
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
          appBar: AppBar(title: const Text('Membres Entreprise')),
          floatingActionButton:
              PermissionEngine.canManageMembers(
                session: context.read<AuthenticationSession>(),
                workspacePermissions:
                    context
                        .read<WorkspaceState>()
                        .currentWorkspace
                        ?.permissions ??
                    const [],
              )
              ? FloatingActionButton.extended(
                  onPressed: () {
                    AppRouter.openSendEnterpriseInvitation(context);
                  },
                  icon: const Icon(Icons.person_add),
                  label: const Text('Inviter'),
                )
              : null,
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

    if (controller.members.isEmpty) {
      return const Center(child: Text('Aucun membre trouvé'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: controller.members.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final member = controller.members[index];

        return Card(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(member.fullName),
            subtitle: Text('${member.department} · ${member.role}'),
            trailing: const Icon(Icons.more_vert),
          ),
        );
      },
    );
  }
}
