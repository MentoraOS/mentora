import 'mentora_projection.dart';
import 'mentora_query.dart';

/// The official representation consulted. Nothing else.
///
/// A read model EXPOSES: asked an official question, it serves the
/// value the representation holds — and that is the entirety of what
/// it does. It computes nothing, reduces nothing, stores nothing,
/// decides nothing and modifies nothing: a reading that worked on
/// what it reads would be building a second representation, and there
/// is one, built by its one owner.
///
/// It answers THE question it was asked: a reading holds one
/// representation, and a question about another fact is refused —
/// a reading never guesses, and never reaches past its projection to
/// find what it does not hold.
final class MentoraReadModel {
  /// The representation this reading is served from — whole, and
  /// strictly intact.
  final MentoraProjection projection;

  const MentoraReadModel({required this.projection});

  /// What the read model refuses — fail closed.
  ///
  /// The representation speaks with its own voice — and through it
  /// the photograph and the fact with theirs.
  void verify() {
    projection.verify();
  }

  /// The official reading: the value the representation holds, served
  /// exactly as it is.
  ///
  /// The question speaks first with its own voice. Then the reading
  /// answers the question it was asked — and only that one: asking
  /// this reading about another fact is refused, because a reading
  /// never guesses.
  String read(MentoraQuery query) {
    query.verify();

    if (query.stateId != projection.snapshot.state.id) {
      throw StateError(
        'A reading answers the question it holds the representation '
        'for: this reading holds "${projection.snapshot.state.id}", '
        'and "${query.stateId}" was asked — a reading never guesses.',
      );
    }
    return projection.snapshot.state.value;
  }

  @override
  bool operator ==(Object other) {
    return other is MentoraReadModel && other.projection == projection;
  }

  @override
  int get hashCode => projection.hashCode;
}
