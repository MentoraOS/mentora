import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../application/authentication/authentication_session.dart';
import '../application/consultation_brief/consultation_brief_application_service.dart';
import '../domain/consultation_brief/consultation_brief.dart';
import '../theme/mentora_theme.dart';

/// Consultation Dashboard card showing the client's brief.
///
/// Read-only projection for the expert; the client can fill the brief in
/// when none exists yet. Legacy bookings without a brief simply show the
/// empty state.
class ConsultationBriefCard extends StatefulWidget {
  const ConsultationBriefCard({
    super.key,
    required this.bookingId,
    required this.onFillIn,
  });

  final String bookingId;

  /// Opens the brief form and resolves to true when a brief was saved.
  /// Navigation stays with the owning screen (ARC-013: this widget module
  /// never imports routing).
  final Future<bool?> Function() onFillIn;

  @override
  State<ConsultationBriefCard> createState() => _ConsultationBriefCardState();
}

enum _BriefState { loading, loaded, failed }

class _ConsultationBriefCardState extends State<ConsultationBriefCard> {
  ConsultationBrief? _brief;
  _BriefState _state = _BriefState.loading;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _state = _BriefState.loading);
    try {
      final brief = await context
          .read<ConsultationBriefApplicationService>()
          .loadByBookingId(widget.bookingId);
      if (!mounted) return;
      setState(() {
        _brief = brief;
        _state = _BriefState.loaded;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _state = _BriefState.failed);
    }
  }

  Future<void> _fillIn() async {
    final saved = await widget.onFillIn();
    if (saved == true && mounted) {
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isExpert = context.read<AuthenticationSession>().isExpert;

    return switch (_state) {
      _BriefState.loading => const LinearProgressIndicator(
        color: MentoraColors.gold,
        backgroundColor: Colors.white12,
      ),
      _BriefState.failed => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Impossible de charger le brief.',
            style: TextStyle(color: Colors.redAccent),
          ),
          TextButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
            label: const Text('Recharger'),
          ),
        ],
      ),
      _BriefState.loaded when _brief == null => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Aucun brief renseigné.',
            style: TextStyle(color: Colors.white54),
          ),
          if (!isExpert) ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _fillIn,
              icon: const Icon(Icons.edit_note),
              label: const Text('Préparer votre consultation'),
              style: OutlinedButton.styleFrom(
                foregroundColor: MentoraColors.gold,
                side: const BorderSide(color: MentoraColors.gold),
              ),
            ),
          ],
        ],
      ),
      _BriefState.loaded => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BriefSection(title: 'Objectif', value: _brief!.objective),
          _BriefSection(title: 'Description', value: _brief!.description),
          if (_brief!.questions.isNotEmpty)
            _BriefSection(title: 'Questions', value: _brief!.questions),
          if (_brief!.expectedOutcome.isNotEmpty)
            _BriefSection(
              title: 'Résultat attendu',
              value: _brief!.expectedOutcome,
            ),
        ],
      ),
    };
  }
}

class _BriefSection extends StatelessWidget {
  const _BriefSection({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: MentoraColors.gold,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}
