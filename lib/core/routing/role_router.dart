import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../application/authentication/authentication_session.dart';
import 'app_router.dart';

class RoleRouter {
  RoleRouter._();

  static Future<void> redirectAfterLogin(BuildContext context) async {
    final session = context.read<AuthenticationSession>();
    if (!session.isAuthenticated) {
      return AppRouter.openLogin(context);
    }

    if (session.isAdmin) {
      return AppRouter.openAdminDashboard(context);
    }

    if (session.isExpert) {
      final expertId = session.currentUserId ?? '';
      return AppRouter.openExpertDashboard(
        context: context,
        expertId: expertId,
      );
    }

    return AppRouter.openClientDashboard(context);
  }
}
