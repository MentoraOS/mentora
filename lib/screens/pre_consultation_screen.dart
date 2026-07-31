import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../application/booking/booking_creation_application_service.dart';
import '../application/booking/booking_creation_failure.dart';
import '../application/scheduling/civil_selection.dart';
import '../domain/expert_catalog/consultation_offer.dart';
import '../widgets/session_progress.dart';
import '../ai/mentora_ai_service.dart';
import 'payment_screen.dart';
import '../core/routing/app_router.dart';

class PreConsultationScreen extends StatefulWidget {
  final String expertName;
  final String expertId;

  /// The Consultation Offer the client selected, carried unchanged from the
  /// expert profile (AD-021 decision 15).
  final ConsultationOffer offer;

  /// The revalidated structured civil occurrence the client selected
  /// (AD-022 Clarification C). Carries explicit year/month/day/hour/minute;
  /// no localized string is ever parsed back into temporal truth.
  final CivilSelection occurrence;

  const PreConsultationScreen({
    super.key,
    required this.expertName,
    required this.expertId,
    required this.offer,
    required this.occurrence,
  });

  @override
  State<PreConsultationScreen> createState() => _PreConsultationScreenState();
}

class _PreConsultationScreenState extends State<PreConsultationScreen> {
  static String _two(int value) => value.toString().padLeft(2, '0');

  /// Deterministic date transport for the legacy `bookingDate` field. Derived
  /// from the structured occurrence; never parsed back from a localized
  /// string.
  String get _bookingDate {
    final start = widget.occurrence;
    return '${start.year}-${_two(start.month)}-${_two(start.day)}';
  }

  String get _bookingTime {
    final start = widget.occurrence;
    return '${_two(start.hour)}:${_two(start.minute)}';
  }

  /// Display-only rendering of the selected civil date.
  String get _displayDate {
    final start = widget.occurrence;
    return '${_two(start.day)}/${_two(start.month)}/${start.year}';
  }

  final TextEditingController needController = TextEditingController();
  final TextEditingController _needController = TextEditingController();
  String selectedCategory = 'Business';
  bool _loading = false;

  String? _summary;

  List<String> _goals = [];

  List<String> _questions = [];

  List<String> _documents = [];

  final List<Map<String, dynamic>> categories = [
    {"icon": Icons.business_center, "title": "Business"},
    {"icon": Icons.auto_awesome, "title": "IA"},
    {"icon": Icons.trending_up, "title": "Marketing"},
    {"icon": Icons.account_balance, "title": "Finance"},
    {"icon": Icons.gavel, "title": "Droit"},
    {"icon": Icons.health_and_safety, "title": "Santé"},
    {"icon": Icons.computer, "title": "Tech"},
    {"icon": Icons.more_horiz, "title": "Autre"},
  ];

  Future<void> generateSummary() async {
    setState(() {
      _loading = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _loading = false;

      _summary =
          "Le client souhaite ${_needController.text}. "
          "Il recherche un accompagnement stratégique.";

      _goals = [
        "Définir une stratégie",

        "Éviter les erreurs",

        "Préparer un plan d'action",
      ];

      _questions = [
        "Quelles sont les premières étapes ?",

        "Quel budget prévoir ?",

        "Quels risques anticiper ?",
      ];

      _documents = ["Business Plan", "Présentation", "Prévisions financières"];
    });
  }

  final MentoraAiService aiService = MentoraAiService();
  AiBrief? aiBrief;
  bool isGeneratingBrief = false;
  bool isCreatingBooking = false;

  static const navy = Color(0xFF061A3D);
  static const gold = Color(0xFFF5A400);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      appBar: AppBar(
        backgroundColor: navy,
        elevation: 0,
        title: const Text('Préparer la consultation'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _InfoCard(
              expertName: widget.expertName,
              date: _displayDate,
              time: _bookingTime,
            ),
            const SizedBox(height: 16),

            const SessionProgress(currentStep: 2),

            const SizedBox(height: 16),

            _SectionCard(
              title: 'Assistant IA Mentora',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Expliquez votre besoin. Mentora AI préparera un résumé clair pour l’expert.',
                    style: TextStyle(color: Colors.white70, height: 1.4),
                  ),

                  Text("", style: Theme.of(context).textTheme.titleMedium),

                  const SizedBox(height: 14),

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: categories.map((item) {
                      final selected = selectedCategory == item["title"];

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCategory = item["title"];
                          });
                        },

                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),

                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),

                          decoration: BoxDecoration(
                            color: selected
                                ? gold
                                : Colors.white.withOpacity(.08),

                            borderRadius: BorderRadius.circular(30),

                            border: Border.all(
                              color: selected ? gold : Colors.white24,
                            ),
                          ),

                          child: Row(
                            mainAxisSize: MainAxisSize.min,

                            children: [
                              Icon(
                                item["icon"],

                                size: 18,

                                color: selected ? navy : gold,
                              ),

                              const SizedBox(width: 8),

                              Text(
                                item["title"],

                                style: TextStyle(
                                  color: selected ? navy : Colors.white,

                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 14),
                  TextField(
                    controller: needController,
                    maxLines: 6,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText:
                          'Exemple : Je souhaite lancer une fintech au Mali...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.07),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isGeneratingBrief
                          ? null
                          : () async {
                              setState(() {
                                isGeneratingBrief = true;
                              });

                              final brief = await aiService.generateBrief(
                                "$selectedCategory\n\n${needController.text.trim()}",
                              );

                              setState(() {
                                aiBrief = brief;
                                isGeneratingBrief = false;
                              });
                            },
                      icon: const Icon(Icons.auto_awesome),
                      label: Text(
                        isGeneratingBrief
                            ? 'Préparation en cours...'
                            : 'Préparer avec Mentora AI',
                      ),
                    ),
                  ),
                  if (isGeneratingBrief) ...[
                    const SizedBox(height: 16),

                    const LinearProgressIndicator(
                      color: gold,
                      backgroundColor: Colors.white12,
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      "🤖 Mentora AI analyse votre besoin...",
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            _SectionCard(
              title: 'Documents',
              child: Column(
                children: const [
                  _DocumentRow(
                    icon: Icons.attach_file,
                    title: 'Ajouter un document',
                  ),
                  Divider(color: Colors.white12),
                  _DocumentRow(
                    icon: Icons.picture_as_pdf,
                    title: 'Ajouter un Business Plan',
                  ),
                  Divider(color: Colors.white12),
                  _DocumentRow(
                    icon: Icons.slideshow,
                    title: 'Ajouter une présentation',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _SectionCard(
              title: 'Résumé IA',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isGeneratingBrief
                          ? null
                          : () async {
                              setState(() {
                                isGeneratingBrief = true;
                              });

                              final brief = await aiService.generateBrief(
                                "$selectedCategory\n\n${needController.text.trim()}",
                              );

                              setState(() {
                                aiBrief = brief;
                                isGeneratingBrief = false;
                              });
                            },
                      icon: const Icon(Icons.auto_awesome),
                      label: Text(
                        isGeneratingBrief
                            ? 'Génération en cours...'
                            : 'Générer mon résumé IA',
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  if (aiBrief == null)
                    const Text(
                      'Décrivez votre besoin puis générez votre résumé IA.',
                      style: TextStyle(color: Colors.white70, height: 1.5),
                    )
                  else ...[
                    _AiCard(
                      icon: Icons.psychology,
                      title: "Compréhension IA",
                      items: [aiBrief!.summary],
                    ),

                    _AiCard(
                      icon: Icons.flag,
                      title: "Objectifs",
                      items: aiBrief!.objectives,
                    ),

                    _AiCard(
                      icon: Icons.help_outline,
                      title: "Questions recommandées",
                      items: aiBrief!.questions,
                    ),

                    _AiCard(
                      icon: Icons.event_note,
                      title: "Agenda proposé",
                      items: aiBrief!.agenda,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: isCreatingBooking ? null : _createBooking,
                icon: const Icon(Icons.payment),
                label: Text(
                  isCreatingBooking
                      ? 'Création en cours...'
                      : 'Continuer vers le paiement',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createBooking() async {
    setState(() => isCreatingBooking = true);

    try {
      final bookingId = await context
          .read<BookingCreationApplicationService>()
          .create(
            expertId: widget.expertId,
            expertName: widget.expertName,
            bookingDate: _bookingDate,
            bookingTime: _bookingTime,
            clientNeed: needController.text.trim(),
            aiSummary: aiBrief?.summary ?? '',
            offer: widget.offer,
          );

      if (!mounted) return;
      AppRouter.openPayment(
        context: context,
        bookingId: bookingId,
        expertName: widget.expertName,
        selectedDate: _displayDate,
        selectedTime: _bookingTime,
        aiSummary: aiBrief?.summary ?? needController.text.trim(),
        amountMinor: widget.offer.amountMinor,
        currency: widget.offer.currency,
      );
    } on BookingCreationSlotConflictFailure {
      _showCreationFailure(
        'Ce créneau vient d’être réservé. Choisissez un autre créneau.',
      );
    } on BookingCreationUnauthenticatedFailure {
      _showCreationFailure('Utilisateur non connecté');
    } on BookingCreationOfferUnavailableFailure {
      _showCreationFailure(
        'Cette offre n’est plus disponible. Choisissez une autre offre.',
      );
    } on BookingCreationExpertMismatchFailure {
      _showCreationFailure(
        'L’offre sélectionnée ne correspond pas à cet expert.',
      );
    } on BookingCreationInvalidRequestFailure {
      _showCreationFailure('La demande de réservation est invalide.');
    } on BookingCreationMalformedDataFailure {
      _showCreationFailure(
        'Les données de réservation sont invalides. Réessayez plus tard.',
      );
    } on BookingCreationInfrastructureUnavailableFailure {
      _showCreationFailure(
        'Le service de réservation est indisponible. Réessayez plus tard.',
      );
    } on BookingCreationPersistenceFailure {
      _showCreationFailure(
        'La réservation n’a pas pu être créée. Réessayez plus tard.',
      );
    } finally {
      if (mounted) {
        setState(() => isCreatingBooking = false);
      }
    }
  }

  void _showCreationFailure(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _InfoCard extends StatelessWidget {
  final String expertName;
  final String date;
  final String time;

  const _InfoCard({
    required this.expertName,
    required this.date,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Créneau confirmé',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            expertName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$date • $time',
            style: const TextStyle(
              color: Color(0xFFF5A400),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _DocumentRow extends StatelessWidget {
  final IconData icon;
  final String title;

  const _DocumentRow({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Color(0xFFF5A400)),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}

class _BriefBlock extends StatelessWidget {
  final String title;
  final List<String> items;

  const _BriefBlock({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFF5A400);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: gold,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text(
                '• $item',
                style: const TextStyle(color: Colors.white70, height: 1.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AiCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> items;

  static const gold = Color(0xFFF5A400);

  const _AiCard({required this.icon, required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: gold),

              const SizedBox(width: 10),

              Text(
                title,
                style: const TextStyle(
                  color: gold,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          ...items.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.greenAccent,
                    size: 18,
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      e,
                      style: const TextStyle(
                        color: Colors.white70,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
