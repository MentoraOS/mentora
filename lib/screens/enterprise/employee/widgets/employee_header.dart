import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../application/workspace/workspace_state.dart';
import '../../../../core/identity/engine/identity_engine.dart';

class EmployeeHeader extends StatelessWidget {
  const EmployeeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final identity = IdentityEngine.currentIdentity;
    final membership = IdentityEngine.currentMembership;
    final workspace = context.read<WorkspaceState>().currentWorkspace;

    final fullName = '${identity?.firstName ?? ''} ${identity?.lastName ?? ''}'
        .trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF1E3A8A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 62,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, color: Colors.white, size: 32),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName.isNotEmpty ? fullName : 'Hassey DIALLO',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                _RoleBadge(role: membership?.role ?? ''),

                const SizedBox(height: 14),

                _InfoRow(
                  icon: Icons.business,
                  text: workspace?.name ?? 'Entreprise',
                ),

                const SizedBox(height: 6),

                _InfoRow(
                  icon: Icons.apartment,
                  text: membership?.departmentId ?? 'Département',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: const TextStyle(color: Colors.white70)),
        ),
      ],
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;

  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    Color color = Colors.orangeAccent;

    if (role == 'finance_member') {
      color = Colors.tealAccent;
    } else if (role == 'finance_manager') {
      color = Colors.greenAccent;
    } else if (role == 'hr_admin') {
      color = Colors.lightBlueAccent;
    } else if (role == 'director' || role == 'executive' || role == 'ceo') {
      color = Colors.purpleAccent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.18),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        role.isNotEmpty ? role.replaceAll('_', ' ').toUpperCase() : 'EMPLOYÉ',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
