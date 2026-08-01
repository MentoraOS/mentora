import '../../domain/recording/recording_provider.dart';

/// Every LiveKit Egress deployment value is INJECTED — never a key,
/// secret or URL hard-coded. The composition root reads them from the
/// environment the day the backend exists.
final class LiveKitRecordingConfiguration {
  final String egressEndpoint;
  final String apiKey;

  const LiveKitRecordingConfiguration({
    required this.egressEndpoint,
    required this.apiKey,
  });

  /// Without a backend the provider is NOT configured and fails closed.
  bool get isConfigured =>
      egressEndpoint.trim().isNotEmpty && apiKey.trim().isNotEmpty;
}

/// The LiveKit recording provider — the ONLY place that will ever talk
/// to the LiveKit Egress backend.
///
/// Consultation recording runs SERVER-SIDE (LiveKit Egress): a backend
/// service starts and seals the media capture; this provider is its
/// single client. No endpoint, no HTTP call and no invented API live
/// here yet — until that backend exists, starting a recording through
/// this provider FAILS CLOSED with a typed failure: no fake recording,
/// ever. Implementing the real call — and only that — turns this class
/// live; nothing upstream changes, and the media vendor stays invisible
/// to every layer above Infrastructure.
final class LiveKitRecordingProvider implements RecordingProvider {
  const LiveKitRecordingProvider({required this.configuration});

  final LiveKitRecordingConfiguration configuration;

  @override
  Future<RecordingSession> start({required String bookingId}) async {
    if (!configuration.isConfigured) {
      throw const RecordingUnavailableFailure(
        cause:
            'The LiveKit egress backend is not configured: inject its '
            'endpoint and key through the environment (never hard-code '
            'them).',
      );
    }
    throw const RecordingUnavailableFailure(
      cause:
          'The LiveKit egress backend is not connected yet. Implement the '
          'egress call in LiveKitRecordingProvider, then swap it in for '
          'SimulatedRecordingProvider at the composition root.',
    );
  }
}
