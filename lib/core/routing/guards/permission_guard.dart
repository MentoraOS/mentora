import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../application/authentication/authentication_session.dart';
import 'package:mentora/core/permissions/permission_engine.dart';

class PermissionGuard extends StatelessWidget {
  final Widget child;
  final String permission;

  const PermissionGuard({
    super.key,
    required this.child,
    required this.permission,
  });

  @override
  Widget build(BuildContext context) {
    if (!PermissionEngine.has(
      context.read<AuthenticationSession>(),
      permission,
    )) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Accès refusé',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return child;
  }
}
