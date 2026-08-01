import '../../domain/consultation_memory/consultation_memory.dart';
import '../../domain/consultation_summary/consultation_summary.dart';
import '../../domain/consultation_summary/summary_provider.dart';

/// Simulated summary engine: acknowledges the memory and reports
/// AVAILABLE without producing any text — no engine, no content, ever.
/// The real provider replaces this class behind the same port and routes
/// through the AI gateway in its own wave.
final class SimulatedSummaryProvider implements SummaryProvider {
  const SimulatedSummaryProvider();

  @override
  Future<SummaryStatus> generate({
    required String bookingId,
    required ConsultationMemory memory,
  }) async {
    // The memory is received opaquely and deliberately unused today.
    return SummaryStatus.available;
  }

  @override
  Future<bool> health() async => true;
}
