import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../application/authentication/authentication_session.dart';
import '../application/consultation_documents/consultation_document_application_service.dart';
import '../domain/consultation_documents/consultation_shared_document.dart';
import '../theme/mentora_theme.dart';

/// A picked file: name plus raw bytes.
typedef PickedDocument = ({String fileName, List<int> bytes});

/// Shared consultation documents: upload, list, open. Two sections — the
/// client's files and the expert's files — with the add action on the
/// session user's own section only. Pickers and the opener are injectable
/// for tests; defaults use file_picker and url_launcher.
class ConsultationDocumentsCard extends StatefulWidget {
  const ConsultationDocumentsCard({
    super.key,
    required this.bookingId,
    this.pickDocument = _pickWithFilePicker,
    this.openUrl = _openWithLauncher,
  });

  final String bookingId;
  final Future<PickedDocument?> Function() pickDocument;
  final Future<void> Function(String url) openUrl;

  static Future<PickedDocument?> _pickWithFilePicker() async {
    final result = await FilePicker.platform.pickFiles(withData: true);
    final file = result?.files.firstOrNull;
    final bytes = file?.bytes;
    if (file == null || bytes == null) return null;
    return (fileName: file.name, bytes: bytes);
  }

  static Future<void> _openWithLauncher(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  State<ConsultationDocumentsCard> createState() =>
      _ConsultationDocumentsCardState();
}

enum _DocumentsState { loading, loaded, failed }

class _ConsultationDocumentsCardState extends State<ConsultationDocumentsCard> {
  List<ConsultationSharedDocument> _documents = const [];
  _DocumentsState _state = _DocumentsState.loading;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _state = _DocumentsState.loading);
    try {
      final documents = await context
          .read<ConsultationDocumentApplicationService>()
          .listByBookingId(widget.bookingId);
      if (!mounted) return;
      setState(() {
        _documents = documents;
        _state = _DocumentsState.loaded;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _state = _DocumentsState.failed);
    }
  }

  Future<void> _addDocument() async {
    final picked = await widget.pickDocument();
    if (picked == null || !mounted) return;

    setState(() => _uploading = true);
    var success = false;
    try {
      await context.read<ConsultationDocumentApplicationService>().upload(
        bookingId: widget.bookingId,
        fileName: picked.fileName,
        bytes: picked.bytes,
      );
      success = true;
    } catch (_) {
      success = false;
    }

    if (!mounted) return;
    setState(() => _uploading = false);
    if (success) {
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Document ajouté')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d’ajouter le document. Réessayez.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isExpert = context.read<AuthenticationSession>().isExpert;

    return switch (_state) {
      _DocumentsState.loading => const LinearProgressIndicator(
        color: MentoraColors.gold,
        backgroundColor: Colors.white12,
      ),
      _DocumentsState.failed => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Impossible de charger les documents.',
            style: TextStyle(color: Colors.redAccent),
          ),
          TextButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
            label: const Text('Recharger'),
          ),
        ],
      ),
      _DocumentsState.loaded => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_documents.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(
                'Aucun document partagé.',
                style: TextStyle(color: Colors.white54),
              ),
            ),
          _Section(
            title: 'Documents du client',
            documents: _documents
                .where((document) => document.uploaderRole == 'client')
                .toList(),
            canAdd: !isExpert,
            uploading: _uploading,
            onAdd: _addDocument,
            onOpen: widget.openUrl,
          ),
          const SizedBox(height: 14),
          _Section(
            title: 'Documents de l’expert',
            documents: _documents
                .where((document) => document.uploaderRole == 'expert')
                .toList(),
            canAdd: isExpert,
            uploading: _uploading,
            onAdd: _addDocument,
            onOpen: widget.openUrl,
          ),
        ],
      ),
    };
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.documents,
    required this.canAdd,
    required this.uploading,
    required this.onAdd,
    required this.onOpen,
  });

  final String title;
  final List<ConsultationSharedDocument> documents;
  final bool canAdd;
  final bool uploading;
  final VoidCallback onAdd;
  final Future<void> Function(String url) onOpen;

  static String _sizeLabel(int bytes) {
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} Mo';
    }
    if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(0)} Ko';
    }
    return '$bytes o';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: MentoraColors.gold,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (canAdd)
          OutlinedButton.icon(
            onPressed: uploading ? null : onAdd,
            icon: const Icon(Icons.attach_file),
            label: Text(uploading ? 'Envoi...' : 'Ajouter un document'),
            style: OutlinedButton.styleFrom(
              foregroundColor: MentoraColors.gold,
              side: const BorderSide(color: MentoraColors.gold),
            ),
          ),
        ...documents.map(
          (document) => Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              children: [
                const Icon(
                  Icons.insert_drive_file,
                  color: Colors.white54,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        document.fileName,
                        style: const TextStyle(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _sizeLabel(document.fileSize),
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => onOpen(document.fileUrl),
                  child: const Text('Ouvrir'),
                ),
              ],
            ),
          ),
        ),
        if (documents.isEmpty && !canAdd)
          const Text('—', style: TextStyle(color: Colors.white38)),
      ],
    );
  }
}
