import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../application/consultation_brief/consultation_brief_application_service.dart';
import '../application/consultation_brief/consultation_brief_failure.dart';
import '../theme/mentora_theme.dart';

/// The client prepares their consultation with a simple brief form.
///
/// A plain persistent snapshot — no AI, no summary, no analysis.
class ConsultationBriefScreen extends StatefulWidget {
  const ConsultationBriefScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  State<ConsultationBriefScreen> createState() =>
      _ConsultationBriefScreenState();
}

class _ConsultationBriefScreenState extends State<ConsultationBriefScreen> {
  final _objective = TextEditingController();
  final _description = TextEditingController();
  final _questions = TextEditingController();
  final _expectedOutcome = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _objective.dispose();
    _description.dispose();
    _questions.dispose();
    _expectedOutcome.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_objective.text.trim().isEmpty || _description.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('L’objectif et la description sont obligatoires.'),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    var message = 'Impossible d’enregistrer le brief. Réessayez plus tard.';
    var success = false;
    try {
      await context.read<ConsultationBriefApplicationService>().save(
        bookingId: widget.bookingId,
        objective: _objective.text,
        description: _description.text,
        questions: _questions.text,
        expectedOutcome: _expectedOutcome.text,
      );
      success = true;
    } on ConsultationBriefBookingNotFoundFailure {
      message = 'Réservation introuvable. Le brief n’a pas été enregistré.';
    } on ConsultationBriefFailure {
      // Keep the generic message.
    } catch (_) {
      // Keep the generic message.
    }

    if (!mounted) return;
    setState(() => _saving = false);

    if (!success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Brief enregistré')));
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MentoraColors.navy,
      appBar: AppBar(
        backgroundColor: MentoraColors.navy,
        elevation: 0,
        title: const Text('Préparer votre consultation'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ces informations aident votre expert à préparer la '
              'consultation.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),

            _BriefField(
              controller: _objective,
              label: 'Objectif de la consultation *',
              hint: 'Exemple : structurer le lancement de mon activité',
            ),
            _BriefField(
              controller: _description,
              label: 'Description *',
              hint: 'Décrivez votre situation et votre besoin',
              maxLines: 5,
            ),
            _BriefField(
              controller: _questions,
              label: 'Questions à poser',
              hint: 'Les questions que vous souhaitez aborder',
              maxLines: 4,
            ),
            _BriefField(
              controller: _expectedOutcome,
              label: 'Résultat attendu',
              hint: 'Ce que vous voulez obtenir à la fin',
              maxLines: 3,
            ),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Documents à préparer',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Bientôt disponible',
                    style: TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                icon: const Icon(Icons.arrow_forward),
                label: Text(
                  _saving ? 'Enregistrement...' : 'Continuer',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BriefField extends StatelessWidget {
  const _BriefField({
    required this.controller,
    required this.label,
    required this.hint,
    this.maxLines = 2,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: MentoraColors.gold,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: Colors.white.withValues(alpha: .07),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
