import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../application/consultation_summary/consultation_summary_application_service.dart';
import '../domain/consultation_summary/consultation_summary.dart';
import '../theme/mentora_theme.dart';

/// The AI summary card — Mentora's first visible AI experience.
///
/// GOVERNANCE: this widget knows ONLY
/// ConsultationSummaryApplicationService. Every ounce of intelligence
/// (memory reading, prompting, engine, routing) stays behind the layers
/// already built; no gateway, engine or provider name ever reaches the
/// UI. Designed to host future actions (export, share, voice, richer
/// content) without a redesign: one status body, one action row.
class ConsultationSummaryCard extends StatefulWidget {
  const ConsultationSummaryCard({super.key, required this.bookingId});

  final String bookingId;

  @override
  State<ConsultationSummaryCard> createState() =>
      _ConsultationSummaryCardState();
}

enum _CardState { loading, unavailable, loaded }

class _ConsultationSummaryCardState extends State<ConsultationSummaryCard> {
  _CardState _state = _CardState.loading;
  ConsultationSummary? _summary;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    try {
      final summary = await context
          .read<ConsultationSummaryApplicationService>()
          .getSummary(widget.bookingId);
      if (!mounted) return;
      setState(() {
        _summary = summary;
        _state = _CardState.loaded;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _state = _CardState.unavailable);
    }
  }

  Future<void> _generate() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final summary = await context
          .read<ConsultationSummaryApplicationService>()
          .generate(widget.bookingId);
      if (!mounted) return;
      setState(() {
        _summary = summary;
        _state = _CardState.loaded;
        _busy = false;
      });
    } catch (_) {
      // Fail closed: the durable FAILED state is re-read, never invented.
      if (!mounted) return;
      setState(() => _busy = false);
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La génération du résumé a échoué.')),
      );
    }
  }

  Future<void> _copy(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Résumé copié.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_busy) return _generating();

    switch (_state) {
      case _CardState.loading:
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(12),
            child: CircularProgressIndicator(color: MentoraColors.gold),
          ),
        );
      case _CardState.unavailable:
        return const Text(
          'Le résumé est indisponible pour le moment.',
          style: TextStyle(color: Colors.white54),
        );
      case _CardState.loaded:
        final summary = _summary!;
        return switch (summary.status) {
          SummaryStatus.notGenerated => _notGenerated(),
          SummaryStatus.generating => _generating(),
          SummaryStatus.available => _available(summary),
          SummaryStatus.failed => _failed(),
        };
    }
  }

  Widget _notGenerated() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aucun résumé disponible.',
          style: TextStyle(color: Colors.white54),
        ),
        const SizedBox(height: 12),
        _primaryAction(
          icon: Icons.auto_awesome,
          label: 'Générer le résumé',
          onPressed: _generate,
        ),
      ],
    );
  }

  Widget _generating() {
    return const Row(
      children: [
        SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: MentoraColors.gold,
          ),
        ),
        SizedBox(width: 12),
        Text(
          'Génération en cours...',
          style: TextStyle(color: Colors.white70),
        ),
      ],
    );
  }

  Widget _available(ConsultationSummary summary) {
    final text = summary.summaryText ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Long summaries flow naturally: selectable, no artificial limit.
        SelectableText(
          text,
          style: const TextStyle(color: Colors.white, height: 1.5),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 4,
          children: [
            if (summary.updatedAt ?? summary.createdAt case final instant?)
              _metadata(Icons.schedule, 'Généré le ${_displayDate(instant)}'),
            if (summary.provider case final provider?)
              _metadata(Icons.memory, 'Moteur : $provider'),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _secondaryAction(
              icon: Icons.copy,
              label: 'Copier',
              onPressed: () => _copy(text),
            ),
            const SizedBox(width: 12),
            _secondaryAction(
              icon: Icons.refresh,
              label: 'Régénérer',
              onPressed: _generate,
            ),
          ],
        ),
      ],
    );
  }

  Widget _failed() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'La génération du résumé a échoué.',
          style: TextStyle(color: Colors.white54),
        ),
        const SizedBox(height: 12),
        _primaryAction(
          icon: Icons.refresh,
          label: 'Réessayer',
          onPressed: _generate,
        ),
      ],
    );
  }

  Widget _primaryAction({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: MentoraColors.gold,
        side: const BorderSide(color: MentoraColors.gold),
      ),
      icon: Icon(icon),
      label: Text(label),
    );
  }

  Widget _secondaryAction({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      style: TextButton.styleFrom(foregroundColor: Colors.white70),
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }

  Widget _metadata(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.white38),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white38, fontSize: 12),
        ),
      ],
    );
  }

  static String _displayDate(DateTime instant) {
    final local = instant.toLocal();
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(local.day)}/${two(local.month)}/${local.year} '
        '${two(local.hour)}:${two(local.minute)}';
  }
}
