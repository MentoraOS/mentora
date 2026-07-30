import 'package:flutter/material.dart';

import '../../core/routing/app_router.dart';

import '../theme/mentora_colors.dart';

/* ONBOARDING 1 */

class OnboardingOneScreen extends StatelessWidget {
  const OnboardingOneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingScreen(
      image: 'assets/images/onboarding_1.png',
      title1: 'Apprenez, échangez',
      title2: 'et réussissez avec',
      titleGold: 'les meilleurs experts.',
      description:
          'Mentora vous connecte à des experts vérifiés\n'
          'pour obtenir des conseils privés, pratiques\n'
          'et adaptés à vos objectifs.',
      activeIndex: 0,
      buttonText: 'Suivant',
      onNext: () {
        AppRouter.openOnboardingTwo(context);
      },
    );
  }
}

/* ONBOARDING 2 */

class OnboardingTwoScreen extends StatelessWidget {
  const OnboardingTwoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingScreen(
      image: 'assets/images/onboarding_2.png',
      title1: 'Réservez vos sessions',
      title2: 'en quelques clics',
      titleGold: 'avec des experts vérifiés.',
      description:
          'Choisissez votre expert, sélectionnez une date\n'
          'et échangez en toute simplicité par vidéo.',
      activeIndex: 1,
      buttonText: 'Suivant',
      onNext: () {
        AppRouter.openOnboardingThree(context);
      },
    );
  }
}

/* ONBOARDING 3 */

class OnboardingThreeScreen extends StatelessWidget {
  const OnboardingThreeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingScreen(
      image: 'assets/images/onboarding_3.png',
      title1: 'Apprenez avec des',
      title2: 'masterclass',
      titleGold: 'exclusives.',
      description:
          'Participez à des sessions en direct,\n'
          'regardez les replays et développez\n'
          'vos compétences avec les meilleurs experts.',
      activeIndex: 2,
      buttonText: 'Suivant',
      onNext: () {
        AppRouter.openOnboardingFour(context);
      },
    );
  }
}

class OnboardingFourScreen extends StatelessWidget {
  const OnboardingFourScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingScreen(
      image: 'assets/images/onboarding_4.png',
      title1: 'Consultez en vidéo',
      title2: 'et passez',
      titleGold: 'à l’action.',
      description:
          'Payez en toute sécurité, recevez votre lien\n'
          'de consultation et échangez avec votre expert\n'
          'où que vous soyez.',
      activeIndex: 3,
      buttonText: 'Créer un compte',
      onNext: () {
        AppRouter.openChooseProfile(context);
      },
    );
  }
}

/* TEMPLATE PREMIUM ONBOARDING */

class OnboardingScreen extends StatelessWidget {
  final String image;
  final String title1;
  final String title2;
  final String titleGold;
  final String description;
  final int activeIndex;
  final String buttonText;
  final VoidCallback onNext;

  const OnboardingScreen({
    super.key,
    required this.image,
    required this.title1,
    required this.title2,
    required this.titleGold,
    required this.description,
    required this.activeIndex,
    required this.buttonText,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MentoraColors.navy,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.35,
            colors: [Color(0xFF173A70), Color(0xFF061A3D), Color(0xFF020B1F)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
            child: Column(
              children: [
                Row(
                  children: [
                    Image.asset('assets/images/logo_mentora.png', width: 58),
                    const Spacer(),
                    const Text(
                      'Passer',
                      style: TextStyle(
                        color: MentoraColors.gold,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: MentoraColors.gold,
                      size: 16,
                    ),
                  ],
                ),

                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Center(
                      child: Image.asset(image, fit: BoxFit.contain),
                    ),
                  ),
                ),

                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 31,
                      height: 1.15,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                    children: [
                      TextSpan(text: '$title1\n'),
                      TextSpan(text: '$title2\n'),
                      TextSpan(
                        text: titleGold,
                        style: const TextStyle(color: MentoraColors.gold),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14.5,
                    height: 1.5,
                  ),
                ),

                const Spacer(),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    4,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      width: index == activeIndex ? 13 : 10,
                      height: index == activeIndex ? 13 : 10,
                      decoration: BoxDecoration(
                        color: index == activeIndex
                            ? MentoraColors.gold
                            : Colors.white30,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 26),

                SizedBox(
                  width: double.infinity,
                  height: 62,
                  child: ElevatedButton(
                    onPressed: onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MentoraColors.gold,
                      foregroundColor: MentoraColors.navy,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          buttonText,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 18),
                        const Icon(Icons.arrow_forward, size: 28),
                      ],
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

class ChooseProfileScreen extends StatefulWidget {
  const ChooseProfileScreen({super.key});

  @override
  State<ChooseProfileScreen> createState() => _ChooseProfileScreenState();
}

class _ChooseProfileScreenState extends State<ChooseProfileScreen> {
  String selectedProfile = 'client';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MentoraColors.navy,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.35,
            colors: [Color(0xFF173A70), Color(0xFF061A3D), Color(0xFF020B1F)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset('assets/images/logo_mentora.png', width: 70),

                const SizedBox(height: 46),

                const Text(
                  'Choisissez votre\nprofil',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),

                const SizedBox(height: 14),

                const Text(
                  'Dites-nous comment vous souhaitez utiliser Mentora.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 36),

                _ProfileCard(
                  selected: selectedProfile == 'client',
                  icon: Icons.school_rounded,
                  title: 'Je cherche un Expert',
                  description:
                      'Je souhaite réserver des consultations et apprendre auprès des meilleurs experts.',
                  onTap: () {
                    setState(() {
                      selectedProfile = 'client';
                    });
                  },
                ),

                const SizedBox(height: 18),

                _ProfileCard(
                  selected: selectedProfile == 'expert',
                  icon: Icons.workspace_premium_rounded,
                  title: 'Je suis un Expert',
                  description:
                      'Je souhaite proposer des consultations, créer des masterclass et monétiser mon expertise.',
                  onTap: () {
                    setState(() {
                      selectedProfile = 'expert';
                    });
                  },
                ),

                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  height: 62,
                  child: ElevatedButton(
                    onPressed: () {
                      AppRouter.openRegisterClient(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MentoraColors.gold,
                      foregroundColor: MentoraColors.navy,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      'Continuer',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
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

class _ProfileCard extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _ProfileCard({
    required this.selected,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected
                ? MentoraColors.gold
                : Colors.white.withValues(alpha: 0.16),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: selected
                    ? MentoraColors.gold
                    : Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: selected ? MentoraColors.navy : MentoraColors.gold,
                size: 30,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: selected ? MentoraColors.navy : Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    description,
                    style: TextStyle(
                      color: selected ? Colors.black54 : Colors.white70,
                      fontSize: 13.5,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked,
              color: selected ? MentoraColors.gold : Colors.white38,
            ),
          ],
        ),
      ),
    );
  }
}
