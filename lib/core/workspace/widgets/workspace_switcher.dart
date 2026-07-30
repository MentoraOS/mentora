import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../application/workspace/workspace_state.dart';
import '../../../presentation/controllers/workspace/workspace_controller.dart';

class WorkspaceSwitcher extends StatefulWidget {
  const WorkspaceSwitcher({super.key});

  @override
  State<WorkspaceSwitcher> createState() => _WorkspaceSwitcherState();
}

class _WorkspaceSwitcherState extends State<WorkspaceSwitcher> {
  late final WorkspaceController controller;

  @override
  void initState() {
    super.initState();
    controller = WorkspaceController(
      workspaceState: context.read<WorkspaceState>(),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentId = controller.currentWorkspaceId;
    final memberships = controller.memberships;

    if (currentId == null || memberships.isEmpty) {
      return const SizedBox.shrink();
    }

    final current = memberships.firstWhere(
      (m) => m.workspaceId == currentId,
      orElse: () => memberships.first,
    );

    return ListTile(
      leading: const Icon(Icons.workspaces),
      title: Text(current.workspaceName),
      subtitle: Text(current.workspaceType.name),
      trailing: const Icon(Icons.keyboard_arrow_down),
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (_) {
            return SafeArea(
              child: ListView(
                shrinkWrap: true,
                children: memberships.map((membership) {
                  final selected =
                      membership.workspaceId == current.workspaceId;

                  return ListTile(
                    leading: Icon(
                      selected ? Icons.check_circle : Icons.workspaces,
                    ),
                    title: Text(membership.workspaceName),
                    subtitle: Text(membership.workspaceType.name),
                    onTap: () {
                      final switched = controller.switchWorkspace(
                        membership.workspaceId,
                      );

                      if (switched) {
                        setState(() {});
                      }

                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }
}
