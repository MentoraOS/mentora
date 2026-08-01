/// One consultation recording — OWNED BY THE CONSULTATION.
///
/// Never by a user, never by a device, never by the media vendor: the
/// vendor only produces media, Mentora owns the lifecycle. Exactly these
/// four facts, nothing else.
final class ConsultationRecording {
  final String bookingId;
  final String recordingId;
  final RecordingStatus status;
  final DateTime? createdAt;

  const ConsultationRecording({
    required this.bookingId,
    required this.recordingId,
    required this.status,
    required this.createdAt,
  });
}

/// The only recording lifecycle states. Nothing else.
enum RecordingStatus {
  notStarted,
  starting,
  recording,
  stopping,
  completed,
  failed,
}
