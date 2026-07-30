import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../application/authentication/authentication_session.dart';
import 'package:mentora/core/permissions/permission_engine.dart';

class AdminGuard extends StatelessWidget {
  final Widget child;

  const AdminGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final session = context.read<AuthenticationSession>();
    if (!session.isAuthenticated) {
      return const Scaffold(body: Center(child: Text('Session expirée')));
    }

    if (!PermissionEngine.canManagePayments(session)) {
      return const Scaffold(body: Center(child: Text('Accès refusé')));
    }

    return child;
  }
}
