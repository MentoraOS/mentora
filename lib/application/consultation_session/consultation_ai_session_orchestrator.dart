import 'dart:async';

import '../../domain/action_items/action_items_provider.dart';
import '../../domain/assistant/assistant_provider.dart';
import '../../domain/transcript/consultation_audio_stream.dart';
import '../../domain/transcript/transcript_provider.dart';
import '../../domain/translation/translation_provider.dart';
import '../action_items/consultation_action_items_application_service.dart';
import '../assistant/consultation_assistant_application_service.dart';
import '../consultation_summary/consultation_summary_application_service.dart';
import '../recording/recording_orchestrator.dart';
import '../transcript/realtime_transcript_application_service.dart';
import '../translation/realtime_translation_application_service.dart';

/// The central coordinator of one consultation's ENTIRE intelligence —
/// and NOTHING but a coordinator.
///
/// It knows only the application contracts (transcript, translation,
/// assistant, action items, the recording coordinator, summary): never
/// a provider, never an adapter, never an engine, never the media
/// vendor, never storage. It contains zero business intelligence — each
/// component stays the owner of its own logic. It only starts them in
/// order, waits passively (no timer, no polling) and stops them in
/// reverse order, ALWAYS finishing with the summary.
///
/// Every step is independent and fails closed LOCALLY, never globally:
/// a failed translation stops neither the transcript, the copilot, the
/// proposals, the recording, nor the final summary. Every error is
/// RELAYED on [failures], never masked.
///
/// One orchestrator per consultation. The live room itself is owned by
/// the live screen (this coordinator may not know the video layer);
/// future evolutions — network-cut resume, session migration,
/// multi-device, expert handoff, pause/resume, crash recovery, realtime
/// monitoring, distributed/parallel/multi-region orchestration — extend
/// this coordination without touching any component.
final class ConsultationAISessionOrchestrator {
  ConsultationAISessionOrchestrator({
    required String bookingId,
    required ConsultationAudioStream audio,
    String? sourceLanguage,
    String? targetLanguage,
    required RealtimeTranscriptApplicationService transcripts,
    required RealtimeTranslationApplicationService translations,
    required ConsultationAssistantApplicationService assistant,
    required ConsultationActionItemsApplicationService actionItems,
    RecordingOrchestrator? recording,
    required ConsultationSummaryApplicationService summaries,
  }) : _bookingId = bookingId,
       _audio = audio,
       _sourceLanguage = sourceLanguage,
       _targetLanguage = targetLanguage,
       _transcripts = transcripts,
       _translations = translations,
       _assistant = assistant,
       _actionItems = actionItems,
       _recording = recording,
       _summaries = summaries;

  final String _bookingId;
  final ConsultationAudioStream _audio;
  final String? _sourceLanguage;
  final String? _targetLanguage;

  final RealtimeTranscriptApplicationService _transcripts;
  final RealtimeTranslationApplicationService _translations;
  final ConsultationAssistantApplicationService _assistant;
  final ConsultationActionItemsApplicationService _actionItems;
  final RecordingOrchestrator? _recording;
  final ConsultationSummaryApplicationService _summaries;

  final StreamController<Object> _failures =
      StreamController<Object>.broadcast();

  TranscriptStream? _transcript;
  TranslationStream? _translation;
  AssistantStream? _assistantStream;
  ActionItemsStream? _actionItemsStream;
  bool _started = false;
  bool _stopped = false;

  /// Every step failure, relayed — never masked, never fatal to the
  /// other steps.
  Stream<Object> get failures => _failures.stream;

  /// The live handles, for the surfaces that project them.
  TranscriptStream? get transcript => _transcript;
  TranslationStream? get translation => _translation;
  AssistantStream? get assistant => _assistantStream;
  ActionItemsStream? get actionItems => _actionItemsStream;
  RecordingOrchestrator? get recording => _recording;

  /// Starts the session's intelligence, in order. The live room is
  /// already the screen's business; the recording coordinator (when
  /// provided) is consent-driven and activates itself on the double
  /// agreement. Then this coordinator simply waits.
  Future<void> start() async {
    if (_started) return;
    _started = true;

    _transcript = await _step(
      () => _transcripts.start(sessionId: _bookingId, audio: _audio),
    );

    final source = _sourceLanguage;
    final target = _targetLanguage;
    if (source != null && target != null && _transcript != null) {
      _translation = await _step(
        () => _translations.start(
          transcript: _transcript!.chunks,
          sourceLanguage: source,
          targetLanguage: target,
        ),
      );
    }

    _assistantStream = await _step(() => _assistant.start(_bookingId));
    _actionItemsStream = await _step(() => _actionItems.start(_bookingId));
  }

  /// Stops the session's intelligence in REVERSE order, each step
  /// independent, and ALWAYS finishes by generating the summary.
  Future<void> stop() async {
    if (!_started || _stopped) return;
    _stopped = true;

    await _step(() async => _recording?.session?.stop());
    if (_actionItemsStream != null) {
      await _step(() => _actionItems.stop());
    }
    if (_assistantStream != null) {
      await _step(() => _assistant.stop());
    }
    if (_translation != null) {
      await _step(() => _translations.stop());
    }
    if (_transcript != null) {
      await _step(() => _transcripts.stop());
    }
    // The live room closes on the screen's side.

    // The summary is ALWAYS the last step — even after failures above.
    await _step(() => _summaries.generate(_bookingId));
  }

  Future<void> dispose() async {
    await _failures.close();
  }

  /// One independent step: its failure is relayed and the session keeps
  /// going — fail closed locally, never globally.
  Future<T?> _step<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (error) {
      if (!_failures.isClosed) _failures.add(error);
      return null;
    }
  }
}
