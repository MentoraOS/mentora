import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../application/profile/profile_application_service.dart';
import '../application/profile/profile_failure.dart';

import '../theme/mentora_theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();

  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      final profile = await context
          .read<ProfileApplicationService>()
          .getCurrentProfile();

      firstNameController.text = profile.firstName ?? '';
      lastNameController.text = profile.lastName ?? '';
      phoneController.text = profile.phone ?? '';
    } on ProfileNotFoundFailure {
      // Preserve the legacy empty form for a missing profile document.
    } on ProfileFailure {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible de charger le profil')),
        );
      }
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  Future<void> saveProfile() async {
    setState(() => isSaving = true);

    try {
      await context.read<ProfileApplicationService>().updateCurrentProfile(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        phone: phoneController.text.trim(),
      );
    } on ProfileFailure {
      if (!mounted) return;

      setState(() => isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible de mettre à jour le profil')),
      );
      return;
    }

    if (!mounted) return;
    setState(() => isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil mis à jour avec succès')),
    );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Widget _input({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyMedium?.color,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Theme.of(context).hintColor),
          prefixIcon: Icon(icon, color: MentoraColors.gold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Modifier le profil')),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: MentoraColors.gold),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(MentoraRadius.large),
                      boxShadow: MentoraShadows.soft,
                    ),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 52,
                              backgroundColor: MentoraColors.gold,
                              child: Icon(
                                Icons.person,
                                color: isDark
                                    ? MentoraColors.navy
                                    : Colors.white,
                                size: 56,
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: MentoraColors.gold,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: MentoraColors.gold,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        Text(
                          'Informations personnelles',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),

                        const SizedBox(height: 6),

                        Text(
                          'Mettez à jour vos informations de compte.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(MentoraRadius.large),
                      boxShadow: MentoraShadows.soft,
                    ),
                    child: Column(
                      children: [
                        _input(
                          label: 'Prénom',
                          controller: firstNameController,
                          icon: Icons.person_outline,
                        ),
                        _input(
                          label: 'Nom',
                          controller: lastNameController,
                          icon: Icons.person_outline,
                        ),
                        _input(
                          label: 'Téléphone',
                          controller: phoneController,
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
          child: SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              onPressed: isSaving ? null : saveProfile,
              icon: isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: MentoraColors.navy,
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(
                isSaving
                    ? 'Enregistrement...'
                    : 'Enregistrer les modifications',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
