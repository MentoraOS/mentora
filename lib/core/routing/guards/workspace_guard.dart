import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../application/workspace/workspace_state.dart';
import '../../../domain/workspace/workspace_type.dart';

class WorkspaceGuard extends StatelessWidget {
  final WorkspaceType requiredType;
  final Widget child;

  const WorkspaceGuard({
    super.key,
    required this.requiredType,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final current = context.read<WorkspaceState>().currentWorkspace;

    if (current == null) {
      return const Scaffold(body: Center(child: Text('Aucun workspace actif')));
    }

    if (current.type != requiredType) {
      return const Scaffold(
        body: Center(child: Text('Workspace non autorisé')),
      );
    }

    return child;
  }
}
