import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../application/workspace/workspace_state.dart';
import '../../../../application/authentication/authentication_session.dart';
import '../../../../core/di/modules/enterprise_module.dart';
import '../controllers/enterprise_invitation_controller.dart';

class SendEnterpriseInvitationScreen extends StatefulWidget {
  const SendEnterpriseInvitationScreen({super.key});

  @override
  State<SendEnterpriseInvitationScreen> createState() =>
      _SendEnterpriseInvitationScreenState();
}

class _SendEnterpriseInvitationScreenState
    extends State<SendEnterpriseInvitationScreen> {
  late final EnterpriseInvitationController controller;

  final emailController = TextEditingController();

  String department = 'Finance';
  String role = 'finance_member';

  @override
  void initState() {
    super.initState();
    controller = EnterpriseModule.createInvitationController(
      workspaceState: context.read<WorkspaceState>(),
      session: context.read<AuthenticationSession>(),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> sendInvitation() async {
    final email = emailController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Email invalide')));
      return;
    }

    await controller.sendInvitation(
      receiverEmail: email,
      role: role,
      department: department,
    );

    if (!mounted) return;

    if (controller.error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(controller.error!)));
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Invitation envoyée')));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Inviter un membre')),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email du collaborateur',
                  hintText: 'exemple@entreprise.com',
                ),
              ),

              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                value: department,
                decoration: const InputDecoration(labelText: 'Département'),
                items: const [
                  DropdownMenuItem(value: 'Finance', child: Text('Finance')),
                  DropdownMenuItem(value: 'RH', child: Text('RH')),
                  DropdownMenuItem(value: 'IT', child: Text('IT')),
                  DropdownMenuItem(
                    value: 'Marketing',
                    child: Text('Marketing'),
                  ),
                  DropdownMenuItem(
                    value: 'Direction',
                    child: Text('Direction'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => department = value);
                  }
                },
              ),

              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                value: role,
                decoration: const InputDecoration(labelText: 'Rôle'),
                items: const [
                  DropdownMenuItem(
                    value: 'finance_member',
                    child: Text('Finance Member'),
                  ),
                  DropdownMenuItem(
                    value: 'finance_manager',
                    child: Text('Finance Manager'),
                  ),
                  DropdownMenuItem(value: 'hr_admin', child: Text('RH Admin')),
                  DropdownMenuItem(
                    value: 'team_manager',
                    child: Text('Team Manager'),
                  ),
                  DropdownMenuItem(value: 'employee', child: Text('Employee')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => role = value);
                  }
                },
              ),

              const SizedBox(height: 30),

              SizedBox(
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: controller.isLoading ? null : sendInvitation,
                  icon: const Icon(Icons.send),
                  label: Text(
                    controller.isLoading
                        ? 'Envoi en cours...'
                        : 'Envoyer l’invitation',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
