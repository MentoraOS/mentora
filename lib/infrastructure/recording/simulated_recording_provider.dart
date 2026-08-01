import 'dart:async';

import '../../domain/recording/consultation_recording.dart';
import '../../domain/recording/recording_provider.dart';

/// Simulated recording provider: walks the real lifecycle transitions
/// (STARTING -> RECORDING, then STOPPING -> COMPLETED) without producing
/// a single byte of media. The real vendor provider replaces this class
/// behind the same port; nothing upstream changes.
final class SimulatedRecordingProvider implements RecordingProvider {
  const SimulatedRecordingProvider();

  @override
  Future<RecordingSession> start({required String bookingId}) async {
    final session = _SimulatedRecordingSession(bookingId: bookingId);
    // Transitions run one tick later so subscribers attached right after
    // start() always observe them.
    unawaited(
      Future<void>.delayed(Duration.zero).then((_) => session.begin()),
    );
    return session;
  }
}

final class _SimulatedRecordingSession implements RecordingSession {
  _SimulatedRecordingSession({required String bookingId})
    : _current = ConsultationRecording(
        bookingId: bookingId,
        recordingId: 'simulated_recording_$bookingId',
        status: RecordingStatus.notStarted,
        createdAt: null,
      );

  ConsultationRecording _current;

  final StreamController<ConsultationRecording> _updates =
      StreamController<ConsultationRecording>.broadcast();

  @override
  ConsultationRecording get recording => _current;

  @override
  Stream<ConsultationRecording> get updates => _updates.stream;

  void begin() {
    if (_current.status != RecordingStatus.notStarted) return;
    _transition(RecordingStatus.starting);
    _transition(RecordingStatus.recording);
  }

  @override
  Future<RecordingResult> stop() async {
    if (_current.status == RecordingStatus.recording ||
        _current.status == RecordingStatus.starting ||
        _current.status == RecordingStatus.notStarted) {
      _transition(RecordingStatus.stopping);
      _transition(RecordingStatus.completed);
    }
    await _updates.close();
    return RecordingResult(recording: _current);
  }

  void _transition(RecordingStatus status) {
    _current = ConsultationRecording(
      bookingId: _current.bookingId,
      recordingId: _current.recordingId,
      status: status,
      createdAt: _current.createdAt ?? DateTime.now(),
    );
    if (!_updates.isClosed) _updates.add(_current);
  }
}
