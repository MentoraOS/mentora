import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../application/authentication/authentication_session.dart';
import '../../core/identity/identity.dart';
import '../../core/routing/app_router.dart';
import '../../core/routing/role_router.dart';
import '../theme/mentora_colors.dart';

class RegisterClientScreen extends StatefulWidget {
  const RegisterClientScreen({super.key});

  @override
  State<RegisterClientScreen> createState() => _RegisterClientScreenState();
}

class _RegisterClientScreenState extends State<RegisterClientScreen> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;

  Future<void> createAccount() async {
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();
    final confirmation = confirmPasswordController.text.trim();

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    if (password != confirmation) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Les mots de passe ne correspondent pas')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final uid = await context.read<AuthenticationSession>().registerClient(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        password: password,
      );

      debugPrint('Utilisateur créé : $uid');

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Compte créé avec succès. '
            'Connectez-vous maintenant.',
          ),
        ),
      );

      AppRouter.replaceWithLogin(context);
    } on AuthenticationFailure catch (failure) {
      final message = switch (failure.code) {
        AuthenticationFailureCode.emailAlreadyInUse =>
          'Cet email est déjà utilisé',
        AuthenticationFailureCode.weakPassword =>
          'Mot de passe trop faible : minimum 6 caractères',
        AuthenticationFailureCode.invalidEmail => 'Adresse email invalide',
        _ => 'Erreur lors de la création du compte',
      };

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur : $error')));
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MentoraColors.navy,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.35,
            colors: [Color(0xFF173A70), Color(0xFF061A3D), Color(0xFF020B1F)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset('assets/images/logo_mentora.png', width: 65),

                const SizedBox(height: 36),

                const Text(
                  'Créer un compte',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Rejoignez Mentora et accédez aux meilleurs experts.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 30),

                Row(
                  children: [
                    Expanded(
                      child: _InputField(
                        controller: firstNameController,
                        hint: 'Prénom',
                        icon: Icons.person_outline,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _InputField(
                        controller: lastNameController,
                        hint: 'Nom',
                        icon: Icons.person_outline,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                _InputField(
                  controller: emailController,
                  hint: 'Adresse e-mail',
                  icon: Icons.email_outlined,
                ),

                const SizedBox(height: 14),

                _InputField(
                  controller: phoneController,
                  hint: 'Téléphone',
                  icon: Icons.phone_outlined,
                ),

                const SizedBox(height: 14),

                _InputField(
                  controller: passwordController,
                  hint: 'Mot de passe',
                  icon: Icons.lock_outline,
                  obscureText: true,
                ),

                const SizedBox(height: 14),

                _InputField(
                  controller: confirmPasswordController,
                  hint: 'Confirmer le mot de passe',
                  icon: Icons.lock_outline,
                  obscureText: true,
                ),

                const SizedBox(height: 18),

                Row(
                  children: [
                    Checkbox(
                      value: true,
                      onChanged: (value) {},
                      activeColor: MentoraColors.gold,
                      checkColor: MentoraColors.navy,
                    ),
                    const Expanded(
                      child: Text(
                        'J’accepte les conditions d’utilisation et la politique de confidentialité.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                SizedBox(
                  width: double.infinity,
                  height: 62,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : createAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MentoraColors.gold,
                      foregroundColor: MentoraColors.navy,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(
                            color: MentoraColors.navy,
                          )
                        : const Text(
                            'Créer mon compte',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                Center(
                  child: GestureDetector(
                    onTap: () {
                      AppRouter.replaceWithLogin(context);
                    },
                    child: const Text.rich(
                      TextSpan(
                        style: TextStyle(color: Colors.white70, fontSize: 15),
                        children: [
                          TextSpan(text: 'Déjà un compte ? '),
                          TextSpan(
                            text: 'Se connecter',
                            style: TextStyle(
                              color: MentoraColors.gold,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextEditingController? controller;

  const _InputField({
    this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(
        color: MentoraColors.navy,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black45),
        prefixIcon: Icon(icon, color: MentoraColors.gold),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> loginUser() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    final session = context.read<AuthenticationSession>();

    setState(() => isLoading = true);

    try {
      await session.signIn(email: email, password: password);

      if (!mounted) {
        return;
      }

      await RoleRouter.redirectAfterLogin(context);
    } on AuthenticationFailure catch (failure) {
      final message = switch (failure.code) {
        AuthenticationFailureCode.userNotFound =>
          'Aucun compte trouvé avec cet email',
        AuthenticationFailureCode.wrongPassword => 'Mot de passe incorrect',
        AuthenticationFailureCode.invalidEmail => 'Adresse email invalide',
        AuthenticationFailureCode.invalidCredential =>
          'Email ou mot de passe incorrect',
        _ => 'Erreur de connexion',
      };

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur : $error')));
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MentoraColors.navy,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.35,
            colors: [Color(0xFF173A70), Color(0xFF061A3D), Color(0xFF020B1F)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset('assets/images/logo_mentora.png', width: 70),

                const SizedBox(height: 55),

                const Text(
                  'Bon retour 👋',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'Connectez-vous pour accéder à vos consultations, experts et masterclass.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 42),

                _InputField(
                  controller: emailController,
                  hint: 'Adresse e-mail',
                  icon: Icons.email_outlined,
                ),

                const SizedBox(height: 16),

                _InputField(
                  controller: passwordController,
                  hint: 'Mot de passe',
                  icon: Icons.lock_outline,
                  obscureText: true,
                ),

                const SizedBox(height: 14),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Mot de passe oublié ?',
                      style: TextStyle(
                        color: MentoraColors.gold,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                SizedBox(
                  width: double.infinity,
                  height: 62,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : loginUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MentoraColors.gold,
                      foregroundColor: MentoraColors.navy,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(
                            color: MentoraColors.navy,
                          )
                        : const Text(
                            'Se connecter',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 26),

                Row(
                  children: const [
                    Expanded(child: Divider(color: Colors.white24)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'ou',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.white24)),
                  ],
                ),

                const SizedBox(height: 24),

                _SocialButton(
                  icon: Icons.g_mobiledata_rounded,
                  text: 'Continuer avec Google',
                  onTap: () {},
                ),

                const SizedBox(height: 14),

                _SocialButton(
                  icon: Icons.apple,
                  text: 'Continuer avec Apple',
                  onTap: () {},
                ),

                const SizedBox(height: 36),

                Center(
                  child: GestureDetector(
                    onTap: () {
                      AppRouter.replaceWithChooseProfile(context);
                    },
                    child: const Text.rich(
                      TextSpan(
                        style: TextStyle(color: Colors.white70, fontSize: 15),
                        children: [
                          TextSpan(text: 'Pas encore de compte ? '),
                          TextSpan(
                            text: 'Créer un compte',
                            style: TextStyle(
                              color: MentoraColors.gold,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white, size: 30),
        label: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.white24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}
