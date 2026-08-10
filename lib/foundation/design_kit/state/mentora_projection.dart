import 'mentora_state_snapshot.dart';

/// The official representation built. Nothing else.
///
/// A projection never reads the living state directly: it is built
/// from a PHOTOGRAPH, and the photograph travels whole and strictly
/// intact. What the projection is, is that composition — the official
/// representation a reading will be served from.
///
/// It stores nothing, reduces nothing and decides nothing. It computes
/// nothing beyond being its own projection: a representation that
/// worked on what it represents would already be answering questions,
/// and answering belongs to the reading, not to the representation.
///
/// It invents no refusal: what a photograph owes, the photograph
/// refuses — and the fact through it. A projection of a malformed
/// photograph fails because the PHOTOGRAPH fails.
final class MentoraProjection {
  /// The photograph this representation is built from — whole, and
  /// strictly intact.
  final MentoraStateSnapshot snapshot;

  const MentoraProjection({required this.snapshot});

  /// What the projection refuses — fail closed.
  ///
  /// The photograph speaks with its own voice; a representation adds
  /// none.
  void verify() {
    snapshot.verify();
  }

  @override
  bool operator ==(Object other) {
    return other is MentoraProjection && other.snapshot == snapshot;
  }

  @override
  int get hashCode => snapshot.hashCode;
}
