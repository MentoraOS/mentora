import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../application/consultation_notes/consultation_private_notes_application_service.dart';
import '../application/consultation_notes/consultation_private_notes_failure.dart';
import '../theme/mentora_theme.dart';

/// Expert-only private notes: write, save, read back. The owning screen only
/// renders this card for an expert session — the client never sees it.
class ConsultationPrivateNotesCard extends StatefulWidget {
  const ConsultationPrivateNotesCard({super.key, required this.bookingId});

  final String bookingId;

  @override
  State<ConsultationPrivateNotesCard> createState() =>
      _ConsultationPrivateNotesCardState();
}

enum _NotesState { loading, loaded, failed }

class _ConsultationPrivateNotesCardState
    extends State<ConsultationPrivateNotesCard> {
  final _controller = TextEditingController();
  _NotesState _state = _NotesState.loading;
  bool _hasStoredNotes = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _state = _NotesState.loading);
    try {
      final notes = await context
          .read<ConsultationPrivateNotesApplicationService>()
          .loadByBookingId(widget.bookingId);
      if (!mounted) return;
      setState(() {
        _hasStoredNotes = notes != null;
        _controller.text = notes ?? '';
        _state = _NotesState.loaded;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _state = _NotesState.failed);
    }
  }

  Future<void> _save() async {
    if (_controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Écrivez une note avant d’enregistrer.')),
      );
      return;
    }

    setState(() => _saving = true);
    var success = false;
    try {
      await context.read<ConsultationPrivateNotesApplicationService>().save(
        bookingId: widget.bookingId,
        notes: _controller.text,
      );
      success = true;
    } on ConsultationPrivateNotesFailure {
      success = false;
    } catch (_) {
      success = false;
    }

    if (!mounted) return;
    setState(() {
      _saving = false;
      if (success) _hasStoredNotes = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Notes enregistrées'
              : 'Impossible d’enregistrer les notes. Réessayez plus tard.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return switch (_state) {
      _NotesState.loading => const LinearProgressIndicator(
        color: MentoraColors.gold,
        backgroundColor: Colors.white12,
      ),
      _NotesState.failed => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Impossible de charger vos notes.',
            style: TextStyle(color: Colors.redAccent),
          ),
          TextButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
            label: const Text('Recharger'),
          ),
        ],
      ),
      _NotesState.loaded => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_hasStoredNotes)
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(
                'Aucune note privée.',
                style: TextStyle(color: Colors.white54),
              ),
            ),
          TextField(
            controller: _controller,
            maxLines: 6,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText:
                  'Écrivez vos notes personnelles concernant cette '
                  'consultation...',
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: Colors.white.withValues(alpha: .07),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _saving ? null : _save,
              icon: const Icon(Icons.save),
              label: Text(_saving ? 'Enregistrement...' : 'Enregistrer'),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Visible uniquement par vous.',
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    };
  }
}
