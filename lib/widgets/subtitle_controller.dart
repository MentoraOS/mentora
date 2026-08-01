import 'dart:async';

import 'package:flutter/foundation.dart';

import '../domain/translation/translated_transcript_chunk.dart';
import '../domain/translation/translation_provider.dart';

/// Presentation-only controller of the live subtitles.
///
/// GOVERNANCE: the only authorized chain is TranslationStream ->
/// SubtitleController -> LiveSubtitleOverlay. This controller consumes
/// the ALREADY-PRODUCED translated projection — it never touches the
/// translation provider, the gateway or any engine, generates nothing
/// and persists nothing. It simply keeps the last [maxVisible] subtitles
/// alive; older ones disappear automatically.
final class SubtitleController extends ChangeNotifier {
  SubtitleController({
    required TranslationStream translation,
    this.maxVisible = 3,
  }) {
    _subscription = translation.chunks.listen(
      _onChunk,
      // Fail closed: an errored flux stops producing subtitles; nothing
      // is ever invented to fill the screen.
      onError: (Object _) {},
    );
  }

  /// How many subtitles stay visible; the default is the product rule.
  final int maxVisible;

  final List<TranslatedTranscriptChunk> _visible = [];

  StreamSubscription<TranslatedTranscriptChunk>? _subscription;

  /// The last subtitles, oldest first. Never more than [maxVisible].
  List<TranslatedTranscriptChunk> get visible => List.unmodifiable(_visible);

  void _onChunk(TranslatedTranscriptChunk chunk) {
    _visible.add(chunk);
    while (_visible.length > maxVisible) {
      _visible.removeAt(0);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    super.dispose();
  }
}
