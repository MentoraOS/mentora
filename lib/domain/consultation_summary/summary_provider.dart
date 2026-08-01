import '../consultation_memory/consultation_memory.dart';
import 'consultation_summary.dart';

/// Summary engine boundary — CONTRACT ONLY.
///
/// The provider receives the consultation's recorded business facts (the
/// memory) and reports the resulting summary STATUS. It never receives
/// anything else: the mandatory chain is the consultation memory -> its
/// application door -> the summary application service -> this port ->
/// (future) the AI gateway -> a real engine.
/// Today only the simulated implementation exists and no text is ever
/// produced. Swapping in a real engine touches ONLY the Infrastructure
/// adapter behind this port.
abstract interface class SummaryProvider {
  /// Runs (today: simulates) the summary generation over the memory and
  /// returns the resulting status. No content is returned.
  Future<SummaryStatus> generate({
    required String bookingId,
    required ConsultationMemory memory,
  });

  /// Whether the engine can currently serve.
  Future<bool> health();
}
